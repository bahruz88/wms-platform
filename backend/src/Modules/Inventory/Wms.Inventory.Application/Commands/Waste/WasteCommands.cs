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

namespace Wms.Inventory.Application.Commands.Waste;

using WasteDocument = Wms.Inventory.Domain.Entities.Waste;

// ==================================================================== create

/// <summary><c>POST /api/v1/inventory/waste</c> — DRAFT waste document (TOR §22).</summary>
public sealed record CreateWasteCommand(
    DateOnly DocDate,
    uint LocationId,
    ushort ReasonCodeId,
    string? Note,
    IReadOnlyList<StockOutLineInput> Lines) : ICommand<long>;

public sealed class CreateWasteCommandValidator : AbstractValidator<CreateWasteCommand>
{
    public CreateWasteCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.ReasonCodeId).GreaterThan((ushort)0);
        RuleFor(c => c.Note).MaximumLength(WasteDocument.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.Qty).GreaterThan(0m);
        });
    }
}

public sealed class CreateWasteCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IWasteRepository wastes,
    ILocationCatalog locations,
    IReasonCodeCatalog reasonCodes,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext) : ICommandHandler<CreateWasteCommand, long>
{
    public async Task<Result<long>> HandleAsync(CreateWasteCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var location = await locations.GetAsync(command.LocationId, cancellationToken).ConfigureAwait(false);
        if (location is null || !location.IsActive || location.IsVirtual)
        {
            return InventoryErrors.LocationNotFound(command.LocationId);
        }

        var reason = await reasonCodes.GetAsync(command.ReasonCodeId, cancellationToken).ConfigureAwait(false);
        if (reason is null || !reason.IsActive || !string.Equals(reason.ReasonGroup, ReasonGroups.Waste, StringComparison.Ordinal))
        {
            return InventoryErrors.ReasonCodeNotFound(command.ReasonCodeId, ReasonGroups.Waste);
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.Waste, command.DocDate, cancellationToken).ConfigureAwait(false);
        var waste = WasteDocument.CreateDraft(tenantContext.TenantId, docNo, command.DocDate, command.LocationId, command.ReasonCodeId, command.Note);
        if (waste.IsFailure)
        {
            return waste.Error;
        }

        var lines = waste.Value.ReplaceLines(command.Lines);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        wastes.Add(waste.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("inv_waste", waste.Value.Id, AuditAction.Create, new { waste.Value.DocNo, command.ReasonCodeId, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return waste.Value.Id;
    }
}

// ==================================================================== submit / approve

/// <summary><c>POST /api/v1/inventory/waste/{id}/submit</c> — DRAFT → PENDING_APPROVAL.</summary>
public sealed record SubmitWasteCommand(long WasteId, uint RowVersion) : ICommand<long>;

/// <summary><c>POST /api/v1/inventory/waste/{id}/approve</c> — PENDING_APPROVAL → APPROVED | REJECTED.</summary>
public sealed record ApproveWasteCommand(long WasteId, uint RowVersion, bool Approved, string? Comment) : ICommand<long>;

public sealed class WasteStateHandler(
    IInventoryUnitOfWork unitOfWork,
    IWasteRepository wastes,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) :
    ICommandHandler<SubmitWasteCommand, long>,
    ICommandHandler<ApproveWasteCommand, long>
{
    public Task<Result<long>> HandleAsync(SubmitWasteCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(command.WasteId, command.RowVersion, w => w.Submit(), AuditAction.Update, "SUBMIT", null, cancellationToken);
    }

    public Task<Result<long>> HandleAsync(ApproveWasteCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!command.Approved && string.IsNullOrWhiteSpace(command.Comment))
        {
            return Task.FromResult(Result.Failure<long>(InventoryErrors.ApprovalCommentRequired()));
        }

        var now = clock.UtcNow;
        var userId = currentUser.UserId;
        if (command.Approved && userId == 0)
        {
            return Task.FromResult(Result.Failure<long>(InventoryErrors.ApproverUnknown()));
        }

        return ApplyAsync(
            command.WasteId,
            command.RowVersion,
            w => command.Approved ? w.Approve(userId, now, command.Comment) : w.Reject(userId, now, command.Comment),
            command.Approved ? AuditAction.Approve : AuditAction.Reject,
            command.Approved ? "APPROVE" : "REJECT",
            command.Comment,
            cancellationToken);
    }

    private async Task<Result<long>> ApplyAsync(
        long wasteId,
        uint rowVersion,
        Func<WasteDocument, Result> action,
        AuditAction auditAction,
        string label,
        string? comment,
        CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var waste = await wastes.GetAsync(wasteId, cancellationToken).ConfigureAwait(false);
        if (waste is null)
        {
            return InventoryErrors.DocumentNotFound("waste", wasteId);
        }

        if (waste.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        // Segregation of duties (spec §12.6, §7.1): the person who raised the waste document may not approve
        // it. The rule was missing here entirely - only the count had it - and it was inert there anyway
        // because ICurrentUser.UserId was always 0.
        if (auditAction == AuditAction.Approve && waste.CreatedBy == currentUser.UserId)
        {
            return InventoryErrors.SelfApprovalForbidden();
        }

        var result = action(waste);
        if (result.IsFailure)
        {
            return result.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_waste", waste.Id, auditAction, new { action = label, waste.DocNo, status = waste.Status.ToString(), comment });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return waste.Id;
    }
}

// ==================================================================== post

public sealed record WastePostResult(long WasteId, long MovementGroupId, string DocNo);

/// <summary><c>POST /api/v1/inventory/waste/{id}/post</c> — location −qty / V_WASTE +qty (spec §12.3).</summary>
public sealed record PostWasteCommand(long WasteId, uint RowVersion, Guid IdempotencyKey) : ICommand<WastePostResult>;

public sealed class PostWasteCommandValidator : AbstractValidator<PostWasteCommand>
{
    public PostWasteCommandValidator()
    {
        RuleFor(c => c.WasteId).GreaterThan(0L);
        RuleFor(c => c.IdempotencyKey).NotEqual(Guid.Empty);
    }
}

public sealed class PostWasteCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IWasteRepository wastes,
    IDocumentPostingEngine posting,
    ILocationCatalog locations,
    ILocationFreezeChecker freezeChecker,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<PostWasteCommand, WastePostResult>
{
    public async Task<Result<WastePostResult>> HandleAsync(PostWasteCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var waste = await wastes.GetAsync(command.WasteId, cancellationToken).ConfigureAwait(false);
        if (waste is null)
        {
            return InventoryErrors.DocumentNotFound("waste", command.WasteId);
        }

        if (waste.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (waste.Status != WasteStatus.Approved)
        {
            return InventoryErrors.InvalidDocumentTransition("waste", waste.Status.ToString(), nameof(WasteStatus.Posted));
        }

        if (await freezeChecker.IsFrozenAsync(waste.LocationId, cancellationToken).ConfigureAwait(false))
        {
            return InventoryErrors.LocationFrozen(waste.LocationId);
        }

        var wasteLocation = await locations.GetVirtualAsync(LocationTypes.VWaste, cancellationToken).ConfigureAwait(false);
        if (wasteLocation is null)
        {
            return InventoryErrors.VirtualLocationMissing(LocationTypes.VWaste);
        }

        var now = clock.UtcNow;
        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var request = new PostingRequest(
            DocType.Waste,
            waste.DocNo,
            waste.DocDate,
            command.IdempotencyKey,
            SourceDocType: "WASTE",
            SourceDocId: waste.Id,
            ReasonCodeId: waste.ReasonCodeId,
            Note: waste.Note,
            Lines: waste.Lines
                .Select(l => new PostingLine(l.Id, l.ProductId, l.Qty, l.UomId, waste.LocationId, wasteLocation.Id, l.BatchId))
                .ToList())
        {
            VirtualLocationIds = [wasteLocation.Id],
        };

        var posted = await posting.PostAsync(request, cancellationToken).ConfigureAwait(false);
        if (posted.IsFailure)
        {
            return posted.Error;
        }

        waste.RecordPostedLines(posted.Value.Lines
            .Select(l => new PostedLineResult(l.Key, l.QtyBase, l.BatchId, l.SuggestedBatchId, l.UnitCost))
            .ToList());

        var totalQty = posted.Value.Lines.Sum(l => l.QtyBase);
        var totalCost = posted.Value.Lines.Sum(l => Quantity.Round(l.QtyBase * (l.UnitCost ?? 0m), Money.StorageDecimals));

        var marked = waste.MarkPosted(posted.Value.MovementGroupId);
        if (marked.IsFailure)
        {
            return marked.Error;
        }

        unitOfWork.Audit.Record("inv_waste", waste.Id, AuditAction.Post, new { waste.DocNo, movementGroupId = posted.Value.MovementGroupId });
        unitOfWork.Outbox.Enqueue(new WastePosted(
            tenantContext.TenantId, now, waste.Id, waste.DocNo, waste.LocationId, waste.ReasonCodeId,
            posted.Value.MovementGroupId, totalQty, totalCost));

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new WastePostResult(waste.Id, posted.Value.MovementGroupId, waste.DocNo);
    }
}
