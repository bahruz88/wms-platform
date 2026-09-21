using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Contracts.Events;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.Issues;

// ==================================================================== create

/// <summary><c>POST /api/v1/inventory/issues</c> — DRAFT issue or transfer.</summary>
public sealed record CreateIssueCommand(
    DateOnly DocDate,
    IssueType IssueType,
    uint FromLocationId,
    uint ToLocationId,
    long? RequestId,
    string? Note,
    IReadOnlyList<IssueLineInput> Lines) : ICommand<long>;

public sealed class CreateIssueCommandValidator : AbstractValidator<CreateIssueCommand>
{
    public CreateIssueCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.FromLocationId).GreaterThan(0u);
        RuleFor(c => c.ToLocationId).GreaterThan(0u);
        RuleFor(c => c.Note).MaximumLength(Issue.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.Qty).GreaterThan(0m);
        });
    }
}

public sealed class CreateIssueCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IIssueRepository issues,
    ILocationCatalog locations,
    ILocationFreezeChecker freezeChecker,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext) : ICommandHandler<CreateIssueCommand, long>
{
    public async Task<Result<long>> HandleAsync(CreateIssueCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        foreach (var locationId in new[] { command.FromLocationId, command.ToLocationId })
        {
            var location = await locations.GetAsync(locationId, cancellationToken).ConfigureAwait(false);
            if (location is null || !location.IsActive || location.IsVirtual)
            {
                return InventoryErrors.LocationNotFound(locationId);
            }
        }

        // Fail early while the operator is still on the form (spec §12.7); dispatch re-checks inside its transaction.
        if (await freezeChecker.IsFrozenAsync(command.FromLocationId, cancellationToken).ConfigureAwait(false))
        {
            return InventoryErrors.LocationFrozen(command.FromLocationId);
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.Issue, command.DocDate, cancellationToken).ConfigureAwait(false);
        var issue = Issue.CreateDraft(
            tenantContext.TenantId, docNo, command.DocDate, command.IssueType,
            command.FromLocationId, command.ToLocationId, command.RequestId, command.Note);
        if (issue.IsFailure)
        {
            return issue.Error;
        }

        var lines = issue.Value.ReplaceLines(command.Lines);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        issues.Add(issue.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("inv_issue", issue.Value.Id, AuditAction.Create, new { issue.Value.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return issue.Value.Id;
    }
}

// ==================================================================== dispatch

public sealed record IssueActionResult(long IssueId, long? MovementGroupId, string DocNo);

/// <summary><c>POST /api/v1/inventory/issues/{id}/dispatch</c> — source −qty / IN_TRANSIT +qty.</summary>
public sealed record DispatchIssueCommand(long IssueId, uint RowVersion, Guid IdempotencyKey) : ICommand<IssueActionResult>;

public sealed class DispatchIssueCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IIssueRepository issues,
    IStockRequestRepository requests,
    IDocumentPostingEngine posting,
    ILocationCatalog locations,
    ILocationFreezeChecker freezeChecker,
    IReasonCodeCatalog reasonCodes,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<DispatchIssueCommand, IssueActionResult>
{
    public async Task<Result<IssueActionResult>> HandleAsync(DispatchIssueCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var issue = await issues.GetAsync(command.IssueId, cancellationToken).ConfigureAwait(false);
        if (issue is null)
        {
            return InventoryErrors.DocumentNotFound("issue", command.IssueId);
        }

        if (issue.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (issue.Status != IssueStatus.Draft)
        {
            return InventoryErrors.InvalidDocumentTransition("issue", issue.Status.ToString(), nameof(IssueStatus.Dispatched));
        }

        if (await freezeChecker.IsFrozenAsync(issue.FromLocationId, cancellationToken).ConfigureAwait(false))
        {
            return InventoryErrors.LocationFrozen(issue.FromLocationId);
        }

        var inTransit = await locations.GetVirtualAsync(LocationTypes.InTransit, cancellationToken).ConfigureAwait(false);
        if (inTransit is null)
        {
            return InventoryErrors.VirtualLocationMissing(LocationTypes.InTransit);
        }

        // A batch chosen against the FEFO/FIFO suggestion must be explained (spec §12.4).
        var overrides = issue.Lines.Where(l => l.BatchOverrideReasonCodeId is > 0).Select(l => l.BatchOverrideReasonCodeId!.Value).Distinct().ToArray();
        if (overrides.Length > 0)
        {
            var known = await reasonCodes.GetManyAsync(overrides, cancellationToken).ConfigureAwait(false);
            foreach (var id in overrides)
            {
                if (known.FirstOrDefault(r => r.Id == id) is not { IsActive: true })
                {
                    return InventoryErrors.ReasonCodeNotFound(id, ReasonGroups.Transfer);
                }
            }
        }

        var now = clock.UtcNow;
        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var request = new PostingRequest(
            DocType.Transfer,
            issue.DocNo,
            issue.DocDate,
            command.IdempotencyKey,
            SourceDocType: "ISSUE",
            SourceDocId: issue.Id,
            ReasonCodeId: null,
            Note: issue.Note,
            Lines: issue.Lines
                .Select(l => new PostingLine(l.Id, l.ProductId, l.Qty, l.UomId, issue.FromLocationId, inTransit.Id, l.BatchId))
                .ToList());

        var posted = await posting.PostAsync(request, cancellationToken).ConfigureAwait(false);
        if (posted.IsFailure)
        {
            return posted.Error;
        }

        var recorded = issue.RecordDispatch(posted.Value.Lines
            .Select(l => new PostedLineResult(l.Key, l.QtyBase, l.BatchId, l.SuggestedBatchId, l.UnitCost))
            .ToList());
        if (recorded.IsFailure)
        {
            return recorded.Error;
        }

        var dispatched = issue.MarkDispatched(posted.Value.MovementGroupId, now);
        if (dispatched.IsFailure)
        {
            return dispatched.Error;
        }

        // Keep the originating request's issued quantities in step so the branch sees progress.
        if (issue.RequestId is { } requestId)
        {
            var stockRequest = await requests.GetAsync(requestId, cancellationToken).ConfigureAwait(false);
            if (stockRequest is not null)
            {
                var issuedByLineNo = issue.Lines
                    .Where(l => l.RequestLineId is not null)
                    .Select(l => (RequestLine: stockRequest.Lines.FirstOrDefault(r => r.Id == l.RequestLineId!.Value), l.Qty))
                    .Where(x => x.RequestLine is not null)
                    .GroupBy(x => x.RequestLine!.LineNo)
                    .ToDictionary(g => g.Key, g => g.Sum(x => x.Qty));
                stockRequest.RecordIssued(issuedByLineNo);
            }
        }

        unitOfWork.Audit.Record("inv_issue", issue.Id, AuditAction.Post, new { action = "DISPATCH", issue.DocNo, movementGroupId = posted.Value.MovementGroupId });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new IssueActionResult(issue.Id, posted.Value.MovementGroupId, issue.DocNo);
    }
}

// ==================================================================== confirm receipt

/// <summary><c>POST /api/v1/inventory/issues/{id}/confirm-receipt</c> — IN_TRANSIT −received / target +received.</summary>
public sealed record ConfirmIssueReceiptCommand(
    long IssueId,
    uint RowVersion,
    Guid IdempotencyKey,
    IReadOnlyList<IssueReceiptInput> Lines) : ICommand<IssueActionResult>;

public sealed class ConfirmIssueReceiptCommandValidator : AbstractValidator<ConfirmIssueReceiptCommand>
{
    public ConfirmIssueReceiptCommandValidator()
    {
        RuleFor(c => c.Lines).NotEmpty();
        RuleFor(c => c.IdempotencyKey).NotEqual(Guid.Empty);
    }
}

/// <summary>
/// The branch confirms what arrived. Anything short of the dispatched quantity stays in <c>IN_TRANSIT</c> and the
/// document lands in <c>DISCREPANCY</c> — the loss is visible and someone has to clear it with an adjustment
/// rather than it evaporating between two locations.
/// </summary>
public sealed class ConfirmIssueReceiptCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IIssueRepository issues,
    IDocumentPostingEngine posting,
    ILocationCatalog locations,
    ILocationFreezeChecker freezeChecker,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<ConfirmIssueReceiptCommand, IssueActionResult>
{
    public async Task<Result<IssueActionResult>> HandleAsync(ConfirmIssueReceiptCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var issue = await issues.GetAsync(command.IssueId, cancellationToken).ConfigureAwait(false);
        if (issue is null)
        {
            return InventoryErrors.DocumentNotFound("issue", command.IssueId);
        }

        if (issue.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (issue.Status != IssueStatus.Dispatched)
        {
            return InventoryErrors.InvalidDocumentTransition("issue", issue.Status.ToString(), nameof(IssueStatus.Received));
        }

        if (await freezeChecker.IsFrozenAsync(issue.ToLocationId, cancellationToken).ConfigureAwait(false))
        {
            return InventoryErrors.LocationFrozen(issue.ToLocationId);
        }

        var inTransit = await locations.GetVirtualAsync(LocationTypes.InTransit, cancellationToken).ConfigureAwait(false);
        if (inTransit is null)
        {
            return InventoryErrors.VirtualLocationMissing(LocationTypes.InTransit);
        }

        var now = clock.UtcNow;
        var confirmed = issue.ConfirmReceipt(command.Lines, currentUser.UserId, now);
        if (confirmed.IsFailure)
        {
            return confirmed.Error;
        }

        var accepted = issue.Lines.Where(l => l.ReceivedQty is > 0m).ToList();
        if (accepted.Count == 0)
        {
            // Nothing arrived at all: the whole shipment stays in IN_TRANSIT, no second group is written.
            await using var emptyTransaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
            unitOfWork.Audit.Record("inv_issue", issue.Id, AuditAction.Update, new { action = "CONFIRM_RECEIPT", issue.DocNo, received = 0 });
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            await emptyTransaction.CommitAsync(cancellationToken).ConfigureAwait(false);
            return new IssueActionResult(issue.Id, null, issue.DocNo);
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var request = new PostingRequest(
            DocType.Transfer,
            issue.DocNo + "-R",
            DateOnly.FromDateTime(now.UtcDateTime),
            command.IdempotencyKey,
            SourceDocType: "ISSUE",
            SourceDocId: issue.Id,
            ReasonCodeId: null,
            Note: issue.Note,
            Lines: accepted
                .Select(l => new PostingLine(l.Id, l.ProductId, l.ReceivedQty!.Value, l.UomId, inTransit.Id, issue.ToLocationId, l.BatchId))
                .ToList())
        {
            VirtualLocationIds = [inTransit.Id],
        };

        var posted = await posting.PostAsync(request, cancellationToken).ConfigureAwait(false);
        if (posted.IsFailure)
        {
            return posted.Error;
        }

        issue.AttachReceiptGroup(posted.Value.MovementGroupId);
        unitOfWork.Audit.Record("inv_issue", issue.Id, AuditAction.Post, new
        {
            action = "CONFIRM_RECEIPT",
            issue.DocNo,
            movementGroupId = posted.Value.MovementGroupId,
            status = issue.Status.ToString(),
        });

        unitOfWork.Outbox.Enqueue(new TransferCompleted(
            tenantContext.TenantId, now, issue.Id, issue.DocNo, issue.FromLocationId, issue.ToLocationId,
            posted.Value.MovementGroupId, issue.HasDiscrepancy));

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new IssueActionResult(issue.Id, posted.Value.MovementGroupId, issue.DocNo);
    }
}

/// <summary><c>POST /api/v1/inventory/issues/{id}/cancel</c> — DRAFT only.</summary>
public sealed record CancelIssueCommand(long IssueId, uint RowVersion, string? Note) : ICommand<long>;

public sealed class CancelIssueCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IIssueRepository issues,
    ITenantContext tenantContext) : ICommandHandler<CancelIssueCommand, long>
{
    public async Task<Result<long>> HandleAsync(CancelIssueCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var issue = await issues.GetAsync(command.IssueId, cancellationToken).ConfigureAwait(false);
        if (issue is null)
        {
            return InventoryErrors.DocumentNotFound("issue", command.IssueId);
        }

        if (issue.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var cancelled = issue.Cancel();
        if (cancelled.IsFailure)
        {
            return cancelled.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_issue", issue.Id, AuditAction.Update, new { action = "CANCEL", issue.DocNo, command.Note });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return issue.Id;
    }
}
