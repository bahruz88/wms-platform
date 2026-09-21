using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Contracts;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Domain.Services;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Infrastructure.Contracts;

/// <summary>
/// In-process <see cref="IStockPostingService"/> (ADR-012): Consumption asks, Inventory posts. Everything below
/// runs inside ONE Inventory transaction, so no other module ever touches <c>inv_balance</c> or <c>inv_movement</c>:
/// <list type="number">
/// <item>count-freeze check (<c>409 LOCATION_FROZEN</c>) and location/product resolution;</item>
/// <item><c>SELECT ... FOR UPDATE</c> on every batch row of the product at the branch, THEN the FEFO/FIFO
/// allocation — BLOCKED, EXPIRED and QUARANTINE batches are skipped (spec §12.4);</item>
/// <item>the quantity is capped at what is allocatable, so stock never goes negative; the rest comes back as a
/// shortfall (ADR-012 invariant 3);</item>
/// <item>the double-entry group (branch −qty / V_CONSUMPTION +qty), the balance projection and the audit row.</item>
/// </list>
/// </summary>
public sealed class StockPostingService(
    InventoryDbContext db,
    IInventoryUnitOfWork unitOfWork,
    IMovementGroupRepository movementGroups,
    IStockBalanceRepository balances,
    ILocationFreezeChecker freezeChecker,
    IProductCatalog products,
    ILocationCatalog locations,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : IStockPostingService
{
    public async Task<StockPostingOutcome> PostConsumptionAsync(ConsumptionPostingRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (!tenantContext.HasTenant)
        {
            return Failure(CommonErrors.TenantRequired());
        }

        var tenantId = tenantContext.TenantId;

        // Document-level idempotency (uq_mg_idem): a repeated key never creates a second ledger document.
        var replay = await movementGroups.FindByIdempotencyKeyAsync(tenantId, request.IdempotencyKey, cancellationToken).ConfigureAwait(false);
        if (replay is not null)
        {
            var replayed = await ReadPostedLinesAsync(replay.Id, cancellationToken).ConfigureAwait(false);
            return StockPostingOutcome.Success(replay.Id, replay.DocNo, replayed);
        }

        if (await freezeChecker.IsFrozenAsync(request.LocationId, cancellationToken).ConfigureAwait(false))
        {
            return Failure(InventoryErrors.LocationFrozen(request.LocationId));
        }

        var branch = await locations.GetAsync(request.LocationId, cancellationToken).ConfigureAwait(false);
        if (branch is null || !branch.IsActive || branch.IsVirtual)
        {
            return Failure(InventoryErrors.LocationNotFound(request.LocationId));
        }

        var consumptionLocation = await locations.GetVirtualAsync(LocationTypes.VConsumption, cancellationToken).ConfigureAwait(false);
        if (consumptionLocation is null)
        {
            return Failure(InventoryErrors.VirtualLocationMissing(LocationTypes.VConsumption));
        }

        var now = clock.UtcNow;
        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var inputs = new List<MovementLineInput>();
        var posted = new List<ConsumptionPostedLine>();

        foreach (var line in request.Lines.Where(l => l.RequestedQtyBase > 0m))
        {
            var product = await products.GetAsync(line.ProductId, cancellationToken).ConfigureAwait(false);
            if (product is null)
            {
                return Failure(InventoryErrors.ProductNotFound(line.ProductId));
            }

            // Lock FIRST, allocate after: the availability the decision is based on cannot change underneath it.
            var rows = await balances.GetAllForUpdateAsync(tenantId, line.ProductId, request.LocationId, cancellationToken).ConfigureAwait(false);
            var candidates = await BuildCandidatesAsync(tenantId, rows, request.BusinessDate, cancellationToken).ConfigureAwait(false);

            var totalAvailable = candidates.Sum(c => c.Candidate.QtyAvailable);
            var takeable = Math.Min(line.RequestedQtyBase, Math.Max(totalAvailable, 0m));
            var strategy = string.Equals(product.IssueStrategy, nameof(IssueStrategy.Fifo), StringComparison.OrdinalIgnoreCase)
                ? IssueStrategy.Fifo
                : IssueStrategy.Fefo;

            var takenQty = 0m;
            decimal? weightedCost = null;
            if (takeable > 0m)
            {
                var allocation = BatchAllocator.Allocate(candidates.Select(c => c.Candidate), takeable, strategy);
                if (allocation.IsFailure)
                {
                    return Failure(allocation.Error);
                }

                var costTotal = 0m;
                foreach (var slice in allocation.Value)
                {
                    var source = candidates.First(c => c.Candidate.BatchId == slice.BatchId);
                    var batchId = slice.BatchId == StockBalance.NoBatch ? (long?)null : slice.BatchId;

                    inputs.Add(new MovementLineInput(
                        line.ProductId, request.LocationId, batchId, -slice.Qty, product.BaseUomId, 1m,
                        product.BaseUomId, product.BaseUomDecimals, source.UnitCost));
                    inputs.Add(new MovementLineInput(
                        line.ProductId, consumptionLocation.Id, batchId, slice.Qty, product.BaseUomId, 1m,
                        product.BaseUomId, product.BaseUomDecimals, source.UnitCost));

                    takenQty += slice.Qty;
                    costTotal += slice.Qty * (source.UnitCost ?? 0m);
                }

                weightedCost = takenQty > 0m ? Quantity.Round(costTotal / takenQty, Money.StorageDecimals) : null;
            }

            posted.Add(new ConsumptionPostedLine(
                line.ProductId,
                takenQty,
                line.RequestedQtyBase - takenQty,
                product.BaseUomId,
                weightedCost));
        }

        // Every product was a shortfall: there is no double-entry document to write, only the report.
        if (inputs.Count == 0)
        {
            await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
            return StockPostingOutcome.Success(null, request.DocNo, posted);
        }

        var header = new MovementGroupHeader(
            tenantId,
            DocType.Consumption,
            request.DocNo,
            request.BusinessDate,
            now,
            currentUser.UserId,
            request.IdempotencyKey,
            SourceDocType: request.SourceDocType,
            SourceDocId: request.SourceDocId,
            Note: request.Note);

        var group = MovementGroup.Create(header, inputs);
        if (group.IsFailure)
        {
            return Failure(group.Error);
        }

        movementGroups.Add(group.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        foreach (var movement in group.Value.Lines)
        {
            var balance = await balances.GetForUpdateAsync(
                tenantId, movement.ProductId, movement.LocationId, movement.BatchId ?? StockBalance.NoBatch, now, cancellationToken).ConfigureAwait(false);

            // V_CONSUMPTION is a virtual counter-account; only the branch side is constrained to stay non-negative.
            var isVirtual = movement.LocationId == consumptionLocation.Id;
            var applied = balance.Apply(movement, isVirtual, now);
            if (applied.IsFailure)
            {
                return Failure(applied.Error);
            }
        }

        unitOfWork.Audit.Record("inv_movement_group", group.Value.Id, AuditAction.Post, new
        {
            docType = nameof(DocType.Consumption),
            request.DocNo,
            request.LocationId,
            sourceDocId = request.SourceDocId,
        });

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return StockPostingOutcome.Success(group.Value.Id, group.Value.DocNo, posted);
    }

    public async Task<StockReversalOutcome> ReverseAsync(StockReversalRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (!tenantContext.HasTenant)
        {
            var tenantError = CommonErrors.TenantRequired();
            return StockReversalOutcome.Failure(tenantError.Code, tenantError.Message, tenantError.Status);
        }

        var tenantId = tenantContext.TenantId;
        var replay = await movementGroups.FindByIdempotencyKeyAsync(tenantId, request.IdempotencyKey, cancellationToken).ConfigureAwait(false);
        if (replay is not null)
        {
            return StockReversalOutcome.Success(replay.Id, replay.DocNo);
        }

        var original = await movementGroups.GetAsync(request.MovementGroupId, cancellationToken).ConfigureAwait(false);
        if (original is null)
        {
            return StockReversalOutcome.Failure("NOT_FOUND", $"Movement group {request.MovementGroupId} was not found.", 404);
        }

        if (await movementGroups.IsReversedAsync(tenantId, original.Id, cancellationToken).ConfigureAwait(false))
        {
            return StockReversalOutcome.Failure("INVALID_STATE_TRANSITION", $"Movement group {original.Id} is already reversed.", 409);
        }

        var now = clock.UtcNow;
        var docDate = request.DocDate;
        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.Reversal, docDate, cancellationToken).ConfigureAwait(false);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var reversal = original.BuildReversal(docNo, docDate, now, currentUser.UserId, request.IdempotencyKey, request.ReasonCodeId, request.Note);
        if (reversal.IsFailure)
        {
            return StockReversalOutcome.Failure(reversal.Error.Code, reversal.Error.Message, reversal.Error.Status);
        }

        movementGroups.Add(reversal.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        foreach (var movement in reversal.Value.Lines)
        {
            var balance = await balances.GetForUpdateAsync(
                tenantId, movement.ProductId, movement.LocationId, movement.BatchId ?? StockBalance.NoBatch, now, cancellationToken).ConfigureAwait(false);
            var applied = balance.Apply(movement, allowNegativeStock: true, now);
            if (applied.IsFailure)
            {
                return StockReversalOutcome.Failure(applied.Error.Code, applied.Error.Message, applied.Error.Status);
            }
        }

        unitOfWork.Audit.Record("inv_movement_group", reversal.Value.Id, AuditAction.Reverse, new { reversesGroupId = original.Id, docNo });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return StockReversalOutcome.Success(reversal.Value.Id, docNo);
    }

    public Task<bool> IsLocationFrozenAsync(uint locationId, CancellationToken cancellationToken) =>
        freezeChecker.IsFrozenAsync(locationId, cancellationToken);

    private static StockPostingOutcome Failure(Error error) => StockPostingOutcome.Failure(error.Code, error.Message, error.Status);

    /// <summary>Turns locked balance rows into allocation candidates, dropping non-allocatable and expired batches.</summary>
    private async Task<List<CandidateRow>> BuildCandidatesAsync(
        uint tenantId,
        IReadOnlyList<StockBalance> rows,
        DateOnly businessDate,
        CancellationToken cancellationToken)
    {
        var withStock = rows.Where(r => r.QtyAvailable() > 0m).ToList();
        if (withStock.Count == 0)
        {
            return [];
        }

        var batchIds = withStock.Where(r => r.BatchId != StockBalance.NoBatch).Select(r => r.BatchId).ToArray();
        var batches = batchIds.Length == 0
            ? []
            : await db.Batches.AsNoTracking()
                .Where(b => b.TenantId == tenantId && batchIds.Contains(b.Id))
                .ToDictionaryAsync(b => b.Id, cancellationToken)
                .ConfigureAwait(false);

        var candidates = new List<CandidateRow>(withStock.Count);
        foreach (var row in withStock)
        {
            var unitCost = row.AvgUnitCost > 0m ? row.AvgUnitCost : (decimal?)null;
            if (row.BatchId == StockBalance.NoBatch)
            {
                // Product kept without batch tracking: one always-allocatable pool, sorted last under FEFO.
                candidates.Add(new CandidateRow(
                    new BatchCandidate(StockBalance.NoBatch, BatchStatus.Active, null, DateTimeOffset.MinValue, row.QtyAvailable()),
                    unitCost));
                continue;
            }

            if (!batches.TryGetValue(row.BatchId, out var batch) || !batch.IsAllocatable() || batch.IsExpiredOn(businessDate))
            {
                continue;
            }

            candidates.Add(new CandidateRow(
                new BatchCandidate(batch.Id, batch.Status, batch.ExpiryDate, batch.ReceivedAt, row.QtyAvailable()),
                unitCost));
        }

        return candidates;
    }

    /// <summary>Rebuilds the per-product answer of an already posted group so a replay returns the same payload.</summary>
    private async Task<IReadOnlyList<ConsumptionPostedLine>> ReadPostedLinesAsync(long groupId, CancellationToken cancellationToken)
    {
        var rows = await db.Movements.AsNoTracking()
            .Where(m => m.GroupId == groupId && m.QtyBase < 0m)
            .GroupBy(m => new { m.ProductId, m.BaseUomId })
            .Select(g => new { g.Key.ProductId, g.Key.BaseUomId, Qty = g.Sum(m => m.QtyBase) })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows.Select(r => new ConsumptionPostedLine(r.ProductId, -r.Qty, 0m, r.BaseUomId, null)).ToList();
    }

    private sealed record CandidateRow(BatchCandidate Candidate, decimal? UnitCost);
}
