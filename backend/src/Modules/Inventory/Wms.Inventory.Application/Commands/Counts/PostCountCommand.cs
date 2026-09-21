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

namespace Wms.Inventory.Application.Commands.Counts;

public sealed record PostCountResult(long CountId, long? AdjustGroupId, string DocNo);

/// <summary><c>POST /api/v1/inventory/counts/{id}/post</c> — APPROVED → POSTED.</summary>
public sealed record PostCountCommand(long CountId, uint RowVersion, Guid IdempotencyKey) : ICommand<PostCountResult>;

public sealed class PostCountCommandValidator : AbstractValidator<PostCountCommand>
{
    public PostCountCommandValidator()
    {
        RuleFor(c => c.CountId).GreaterThan(0L);
        RuleFor(c => c.IdempotencyKey).NotEqual(Guid.Empty);
    }
}

/// <summary>
/// Turns the counted variances into one <c>COUNT_ADJUST</c> double-entry group against <c>V_ADJUSTMENT</c>
/// (spec §12.3, §12.6):
/// <list type="bullet">
/// <item>surplus — <c>V_ADJUSTMENT −v</c> / location <c>+v</c>;</item>
/// <item>shortage — location <c>−|v|</c> / <c>V_ADJUSTMENT +|v|</c>, valued at the frozen <c>avg_unit_cost</c>.</item>
/// </list>
/// Lines that came out exactly right produce no movement. A count where nothing varied posts with
/// <c>adjustGroupId = null</c> — a two-line group cannot be built from zero movements, and writing an empty
/// document would be noise. Either way the location is released.
/// </summary>
public sealed class PostCountCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockCountRepository counts,
    IMovementGroupRepository movementGroups,
    IStockBalanceRepository balances,
    IInventorySettings settings,
    IProductCatalog products,
    ILocationCatalog locations,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<PostCountCommand, PostCountResult>
{
    public async Task<Result<PostCountResult>> HandleAsync(PostCountCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;

        // Document-level idempotency (uq_mg_idem): a repeated key returns the previous result, no second group.
        var replay = await movementGroups.FindByIdempotencyKeyAsync(tenantId, command.IdempotencyKey, cancellationToken).ConfigureAwait(false);
        if (replay is not null)
        {
            return new PostCountResult(command.CountId, replay.Id, replay.DocNo);
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

        if (count.Status != CountStatus.Approved)
        {
            return InventoryErrors.InvalidCountTransition(count.Status, CountStatus.Posted);
        }

        if (count.Lines.Count == 0)
        {
            return InventoryErrors.CountEmpty(count.Id);
        }

        var adjustment = await locations.GetVirtualAsync(LocationTypes.VAdjustment, cancellationToken).ConfigureAwait(false);
        if (adjustment is null)
        {
            return InventoryErrors.VirtualLocationMissing(LocationTypes.VAdjustment);
        }

        var allowNegativeStock = await settings.GetBoolAsync(InventorySettingKeys.AllowNegativeStock, cancellationToken).ConfigureAwait(false);
        var now = clock.UtcNow;
        var docDate = DateOnly.FromDateTime(now.UtcDateTime);

        var varianceLines = count.Lines.Where(l => l.HasVariance).ToList();
        var inputs = new List<MovementLineInput>(varianceLines.Count * 2);
        var totalVarianceQty = 0m;
        var totalVarianceCost = 0m;

        foreach (var line in varianceLines)
        {
            var product = await products.GetAsync(line.ProductId, cancellationToken).ConfigureAwait(false);
            if (product is null)
            {
                return InventoryErrors.ProductNotFound(line.ProductId);
            }

            // Spec §12.6 again, this time as a posting guard: no unexplained adjustment ever reaches the ledger.
            if (line.ReasonCodeId is null or 0)
            {
                return InventoryErrors.ReasonCodeRequired(line.ProductId);
            }

            var variance = line.VarianceQty!.Value;
            var batchId = line.BatchId;
            var unitCost = line.AvgUnitCost == 0m ? (decimal?)null : line.AvgUnitCost;

            inputs.Add(new MovementLineInput(
                line.ProductId, count.LocationId, batchId, variance, product.BaseUomId, 1m,
                product.BaseUomId, product.BaseUomDecimals, unitCost));
            inputs.Add(new MovementLineInput(
                line.ProductId, adjustment.Id, batchId, -variance, product.BaseUomId, 1m,
                product.BaseUomId, product.BaseUomDecimals, unitCost));

            totalVarianceQty += variance;
            totalVarianceCost += Quantity.Round(variance * line.AvgUnitCost, Money.StorageDecimals);
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        long? adjustGroupId = null;
        if (inputs.Count > 0)
        {
            var header = new MovementGroupHeader(
                tenantId, DocType.CountAdjust, count.DocNo, docDate, now, currentUser.UserId, command.IdempotencyKey,
                SourceDocType: "COUNT",
                SourceDocId: count.Id,
                ReasonCodeId: varianceLines[0].ReasonCodeId,
                Note: count.Note);
            var group = MovementGroup.Create(header, inputs);
            if (group.IsFailure)
            {
                return group.Error;
            }

            movementGroups.Add(group.Value);
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

            foreach (var movement in group.Value.Lines)
            {
                var balance = await balances.GetForUpdateAsync(
                    tenantId, movement.ProductId, movement.LocationId, movement.BatchId ?? StockBalance.NoBatch, now, cancellationToken)
                    .ConfigureAwait(false);

                // V_ADJUSTMENT is a counter-account and is expected to go negative; physical stock is not.
                var isVirtual = movement.LocationId == adjustment.Id;
                var applied = balance.Apply(movement, allowNegativeStock || isVirtual, now);
                if (applied.IsFailure)
                {
                    return applied.Error;
                }
            }

            adjustGroupId = group.Value.Id;
        }

        var posted = count.MarkPosted(adjustGroupId);
        if (posted.IsFailure)
        {
            return posted.Error;
        }

        unitOfWork.Audit.Record("inv_count", count.Id, AuditAction.Post, new { count.DocNo, adjustGroupId, varianceLines = varianceLines.Count });
        unitOfWork.Outbox.Enqueue(new CountVarianceApproved(
            tenantId, now, count.Id, count.DocNo, count.LocationId, count.ApprovedBy ?? currentUser.UserId, adjustGroupId,
            totalVarianceQty, totalVarianceCost));

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new PostCountResult(count.Id, adjustGroupId, count.DocNo);
    }
}
