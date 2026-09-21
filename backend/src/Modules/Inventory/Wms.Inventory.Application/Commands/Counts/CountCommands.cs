using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.Counts;

// ==================================================================== create

/// <summary><c>POST /api/v1/inventory/counts</c> — DRAFT document. The lines appear at freeze time.</summary>
public sealed record CreateCountCommand(
    uint LocationId,
    CountType CountType,
    IReadOnlyList<uint> CategoryIds,
    IReadOnlyList<uint> ProductIds,
    string? Note) : ICommand<long>;

public sealed class CreateCountCommandValidator : AbstractValidator<CreateCountCommand>
{
    public CreateCountCommandValidator()
    {
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.Note).MaximumLength(StockCount.NoteMaxLength);
    }
}

public sealed class CreateCountCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockCountRepository counts,
    ILocationCatalog locations,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<CreateCountCommand, long>
{
    public async Task<Result<long>> HandleAsync(CreateCountCommand command, CancellationToken cancellationToken)
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

        // One open count per location; otherwise two freezes would fight over the same book quantities.
        var open = await counts.FindOpenForLocationAsync(tenantContext.TenantId, command.LocationId, cancellationToken).ConfigureAwait(false);
        if (open is not null)
        {
            return InventoryErrors.CountAlreadyOpen(command.LocationId, open.DocNo);
        }

        var docDate = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.InventoryCount, docDate, cancellationToken).ConfigureAwait(false);

        var count = StockCount.CreateDraft(
            tenantContext.TenantId, docNo, command.LocationId, command.CountType,
            command.CategoryIds, command.ProductIds, command.Note);
        if (count.IsFailure)
        {
            return count.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        counts.Add(count.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("inv_count", count.Value.Id, AuditAction.Create, new { count.Value.DocNo, count.Value.LocationId, countType = command.CountType.ToString() });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return count.Value.Id;
    }
}

// ==================================================================== freeze

/// <summary><c>POST /api/v1/inventory/counts/{id}/freeze</c> — blocks the location and writes <c>book_qty</c> (spec §12.7).</summary>
public sealed record FreezeCountCommand(long CountId, uint RowVersion) : ICommand<long>;

public sealed class FreezeCountCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockCountRepository counts,
    IStockBalanceRepository balances,
    IProductCatalog products,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<FreezeCountCommand, long>
{
    public async Task<Result<long>> HandleAsync(FreezeCountCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var count = await counts.GetAsync(command.CountId, cancellationToken).ConfigureAwait(false);
        if (count is null)
        {
            return InventoryErrors.CountNotFound(command.CountId);
        }

        if (count.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (count.Status != CountStatus.Draft)
        {
            return InventoryErrors.InvalidCountTransition(count.Status, CountStatus.Frozen);
        }

        var scope = await ResolveScopeAsync(count, cancellationToken).ConfigureAwait(false);
        if (scope.IsFailure)
        {
            return scope.Error;
        }

        var now = clock.UtcNow;
        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        // FOR UPDATE over the whole location: the snapshot and the status change land in one atomic step, so no
        // posting can slip between reading qty_on_hand and blocking the location.
        var rows = await balances
            .GetLocationForUpdateAsync(tenantContext.TenantId, count.LocationId, scope.Value, cancellationToken)
            .ConfigureAwait(false);

        var snapshot = rows
            .Select(r => new CountSnapshotRow(r.ProductId, r.BatchId, r.QtyOnHand, r.AvgUnitCost))
            .ToList();

        var frozen = count.Freeze(snapshot, now);
        if (frozen.IsFailure)
        {
            return frozen.Error;
        }

        unitOfWork.Audit.Record("inv_count", count.Id, AuditAction.Update, new { action = "FREEZE", count.DocNo, count.LocationId, lines = snapshot.Count, frozenAt = now });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return count.Id;
    }

    private async Task<Result<IReadOnlyCollection<uint>>> ResolveScopeAsync(StockCount count, CancellationToken cancellationToken)
    {
        if (count.CountType == CountType.Full)
        {
            return Result.Success<IReadOnlyCollection<uint>>([]);
        }

        var scope = new HashSet<uint>(count.ScopeProducts());
        var categories = count.ScopeCategories();
        if (categories.Count > 0)
        {
            foreach (var productId in await products.GetIdsByCategoryAsync(categories, cancellationToken).ConfigureAwait(false))
            {
                scope.Add(productId);
            }
        }

        return scope.Count == 0
            ? InventoryErrors.CountScopeRequired(count.CountType.ToString().ToUpperInvariant(), "a non-empty product scope")
            : Result.Success<IReadOnlyCollection<uint>>(scope);
    }
}

// ==================================================================== count lines

public sealed record CountLineInput(uint ProductId, long? BatchId, decimal CountedQty, ushort UomId, ushort? ReasonCodeId, string? Note);

/// <summary><c>POST /api/v1/inventory/counts/{id}/lines</c> — upsert by <c>(productId, batchId)</c>, partial submits allowed.</summary>
public sealed record SubmitCountLinesCommand(long CountId, uint RowVersion, IReadOnlyList<CountLineInput> Lines) : ICommand<long>;

public sealed class SubmitCountLinesCommandValidator : AbstractValidator<SubmitCountLinesCommand>
{
    public SubmitCountLinesCommandValidator()
    {
        RuleFor(c => c.Lines).NotEmpty();
        RuleFor(c => c.Lines).Must(l => l.Count <= 500).WithMessage("A single submit carries at most 500 lines.");
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.CountedQty).GreaterThanOrEqualTo(0m);
            line.RuleFor(l => l.Note).MaximumLength(StockCountLine.NoteMaxLength);
        });
    }
}

public sealed class SubmitCountLinesCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockCountRepository counts,
    IProductCatalog products,
    IReasonCodeCatalog reasonCodes,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<SubmitCountLinesCommand, long>
{
    public async Task<Result<long>> HandleAsync(SubmitCountLinesCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var count = await counts.GetAsync(command.CountId, cancellationToken).ConfigureAwait(false);
        if (count is null)
        {
            return InventoryErrors.CountNotFound(command.CountId);
        }

        if (count.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (count.Status is not (CountStatus.Frozen or CountStatus.Counting))
        {
            return InventoryErrors.InvalidCountTransition(count.Status, CountStatus.Counting);
        }

        // Every reason code used here must exist, be active and belong to the ADJUSTMENT group (spec §12.6).
        var usedReasonCodes = command.Lines.Where(l => l.ReasonCodeId is > 0).Select(l => l.ReasonCodeId!.Value).Distinct().ToArray();
        if (usedReasonCodes.Length > 0)
        {
            var known = await reasonCodes.GetManyAsync(usedReasonCodes, cancellationToken).ConfigureAwait(false);
            foreach (var id in usedReasonCodes)
            {
                var code = known.FirstOrDefault(r => r.Id == id);
                if (code is null || !code.IsActive || !string.Equals(code.ReasonGroup, ReasonGroups.Adjustment, StringComparison.Ordinal))
                {
                    return InventoryErrors.ReasonCodeNotFound(id, ReasonGroups.Adjustment);
                }
            }
        }

        var now = clock.UtcNow;
        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        foreach (var input in command.Lines)
        {
            var product = await products.GetAsync(input.ProductId, cancellationToken).ConfigureAwait(false);
            if (product is null)
            {
                return InventoryErrors.ProductNotFound(input.ProductId);
            }

            // The client enters the quantity in whatever unit it likes; the server converts to base (spec §12.1).
            var uomId = input.UomId == 0 ? product.BaseUomId : input.UomId;
            decimal factor;
            if (uomId == product.BaseUomId)
            {
                factor = 1m;
            }
            else
            {
                var resolved = await products
                    .GetUomFactorAsync(input.ProductId, uomId, DateOnly.FromDateTime(now.UtcDateTime), cancellationToken)
                    .ConfigureAwait(false);
                if (resolved is not > 0m)
                {
                    return InventoryErrors.UomFactorNotFound(input.ProductId, uomId, DateOnly.FromDateTime(now.UtcDateTime));
                }

                factor = resolved.Value;
            }

            var countedBase = Quantity.Convert(input.CountedQty, factor, product.BaseUomDecimals).Value;
            var applied = count.CountLine(input.ProductId, input.BatchId, countedBase, input.ReasonCodeId, input.Note, currentUser.UserId, now);
            if (applied.IsFailure)
            {
                return applied.Error;
            }
        }

        unitOfWork.Audit.Record("inv_count", count.Id, AuditAction.Update, new { action = "COUNT_LINES", count.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return count.Id;
    }
}

// ==================================================================== submit / approve / cancel

/// <summary><c>POST /api/v1/inventory/counts/{id}/submit</c> — COUNTING → REVIEW.</summary>
public sealed record SubmitCountCommand(long CountId, uint RowVersion) : ICommand<long>;

public sealed class SubmitCountCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockCountRepository counts,
    IInventorySettings settings,
    ITenantContext tenantContext) : ICommandHandler<SubmitCountCommand, long>
{
    public async Task<Result<long>> HandleAsync(SubmitCountCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var count = await counts.GetAsync(command.CountId, cancellationToken).ConfigureAwait(false);
        if (count is null)
        {
            return InventoryErrors.CountNotFound(command.CountId);
        }

        if (count.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var threshold = await settings
            .GetDecimalAsync(InventorySettingKeys.CountVarianceApprovalThresholdPct, cancellationToken)
            .ConfigureAwait(false);

        var submitted = count.Submit(threshold);
        if (submitted.IsFailure)
        {
            return submitted.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_count", count.Id, AuditAction.Update, new { action = "SUBMIT", count.DocNo, count.RequiresApproval, thresholdPct = threshold });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return count.Id;
    }
}

/// <summary><c>POST /api/v1/inventory/counts/{id}/approve</c> — REVIEW → APPROVED, or back to COUNTING on rejection.</summary>
public sealed record ApproveCountCommand(long CountId, uint RowVersion, bool Approved, string? Comment) : ICommand<long>;

public sealed class ApproveCountCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockCountRepository counts,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<ApproveCountCommand, long>
{
    public async Task<Result<long>> HandleAsync(ApproveCountCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var count = await counts.GetAsync(command.CountId, cancellationToken).ConfigureAwait(false);
        if (count is null)
        {
            return InventoryErrors.CountNotFound(command.CountId);
        }

        if (count.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (!command.Approved && string.IsNullOrWhiteSpace(command.Comment))
        {
            return InventoryErrors.ApprovalCommentRequired();
        }

        // Segregation of duties (spec §7.1, TOR §21): whoever entered the numbers may not sign them off.
        if (command.Approved && currentUser.UserId != 0 && count.Lines.Any(l => l.CountedBy == currentUser.UserId))
        {
            return InventoryErrors.SelfApprovalForbidden();
        }

        var result = command.Approved ? count.Approve(currentUser.UserId, clock.UtcNow) : count.Reject();
        if (result.IsFailure)
        {
            return result.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            "inv_count",
            count.Id,
            command.Approved ? AuditAction.Approve : AuditAction.Reject,
            new { count.DocNo, command.Comment });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return count.Id;
    }
}

/// <summary><c>POST /api/v1/inventory/counts/{id}/cancel</c> — lifts the freeze without writing to the ledger.</summary>
public sealed record CancelCountCommand(long CountId, uint RowVersion, ushort ReasonCodeId, string? Note) : ICommand<long>;

public sealed class CancelCountCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockCountRepository counts,
    ITenantContext tenantContext) : ICommandHandler<CancelCountCommand, long>
{
    public async Task<Result<long>> HandleAsync(CancelCountCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var count = await counts.GetAsync(command.CountId, cancellationToken).ConfigureAwait(false);
        if (count is null)
        {
            return InventoryErrors.CountNotFound(command.CountId);
        }

        if (count.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var cancelled = count.Cancel(command.Note);
        if (cancelled.IsFailure)
        {
            return cancelled.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_count", count.Id, AuditAction.Update, new { action = "CANCEL", count.DocNo, command.ReasonCodeId, command.Note });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return count.Id;
    }
}
