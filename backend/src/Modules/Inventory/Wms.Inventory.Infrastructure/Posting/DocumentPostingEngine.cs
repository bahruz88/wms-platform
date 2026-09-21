using Wms.Common.Application.Abstractions;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Domain.Services;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Infrastructure.Posting;

/// <inheritdoc cref="IDocumentPostingEngine"/>
public sealed class DocumentPostingEngine(
    InventoryDbContext db,
    IInventoryUnitOfWork unitOfWork,
    IMovementGroupRepository movementGroups,
    IStockBalanceRepository balances,
    IInventorySettings settings,
    IProductCatalog products,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : IDocumentPostingEngine
{
    public async Task<Result<PostingResult>> PostAsync(PostingRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;

        // Document-level idempotency (uq_mg_idem): a repeated key never creates a second ledger document.
        var replay = await movementGroups.FindByIdempotencyKeyAsync(tenantId, request.IdempotencyKey, cancellationToken).ConfigureAwait(false);
        if (replay is not null)
        {
            return new PostingResult(replay.Id, replay.DocNo, Replayed: true, []);
        }

        var allowNegativeStock = await settings.GetBoolAsync(InventorySettingKeys.AllowNegativeStock, cancellationToken).ConfigureAwait(false);
        var now = clock.UtcNow;

        var inputs = new List<MovementLineInput>(request.Lines.Count * 2);
        var posted = new List<PostedLine>(request.Lines.Count);

        foreach (var line in request.Lines)
        {
            var product = await products.GetAsync(line.ProductId, cancellationToken).ConfigureAwait(false);
            if (product is null || !product.IsActive)
            {
                return InventoryErrors.ProductNotFound(line.ProductId);
            }

            var factor = 1m;
            if (line.UomId != product.BaseUomId)
            {
                var resolved = await products.GetUomFactorAsync(line.ProductId, line.UomId, request.DocDate, cancellationToken).ConfigureAwait(false);
                if (resolved is not > 0m)
                {
                    return InventoryErrors.UomFactorNotFound(line.ProductId, line.UomId, request.DocDate);
                }

                factor = resolved.Value;
            }

            var qtyBase = Quantity.Convert(line.Qty, factor, product.BaseUomDecimals);
            if (qtyBase.IsZero)
            {
                return InventoryErrors.ZeroQuantityLine(line.Key == 0 ? 1 : (int)line.Key);
            }

            // Pure inbound (no source location): nothing to allocate, the caller named the batch.
            if (line.FromLocationId == 0)
            {
                inputs.Add(new MovementLineInput(
                    line.ProductId, line.ToLocationId, line.BatchId, qtyBase.Value, line.UomId, factor,
                    product.BaseUomId, product.BaseUomDecimals));
                posted.Add(new PostedLine(line.Key, line.ProductId, qtyBase.Value, line.BatchId, null, null));
                continue;
            }

            // Lock FIRST, allocate after: the availability the decision is based on cannot change underneath it.
            var rows = await balances.GetAllForUpdateAsync(tenantId, line.ProductId, line.FromLocationId, cancellationToken).ConfigureAwait(false);
            var candidates = await BuildCandidatesAsync(tenantId, rows, request.DocDate, cancellationToken).ConfigureAwait(false);

            var strategy = string.Equals(product.IssueStrategy, "FIFO", StringComparison.OrdinalIgnoreCase)
                ? IssueStrategy.Fifo
                : IssueStrategy.Fefo;
            var suggested = candidates
                .Select(c => c.Candidate)
                .Where(c => c.Status == BatchStatus.Active && c.QtyAvailable > 0m)
                .OrderBy(c => c, new BatchIssueComparer(strategy))
                .Select(c => (long?)c.BatchId)
                .FirstOrDefault();
            var suggestedBatchId = suggested is null or StockBalance.NoBatch ? null : suggested;

            // An explicit batch is honoured as given; otherwise FEFO/FIFO decides (spec §12.4).
            var pool = line.BatchId is { } explicitBatch
                ? candidates.Where(c => c.Candidate.BatchId == explicitBatch).ToList()
                : candidates;

            var allocation = BatchAllocator.Allocate(pool.Select(c => c.Candidate), qtyBase.Value, strategy);
            if (allocation.IsFailure)
            {
                return allocation.Error;
            }

            var costTotal = 0m;
            long? takenBatchId = null;
            foreach (var slice in allocation.Value)
            {
                var source = pool.First(c => c.Candidate.BatchId == slice.BatchId);
                var batchId = slice.BatchId == StockBalance.NoBatch ? (long?)null : slice.BatchId;
                takenBatchId ??= batchId;

                inputs.Add(new MovementLineInput(
                    line.ProductId, line.FromLocationId, batchId, -slice.Qty, product.BaseUomId, 1m,
                    product.BaseUomId, product.BaseUomDecimals, source.UnitCost));
                if (line.ToLocationId != 0)
                {
                    inputs.Add(new MovementLineInput(
                        line.ProductId, line.ToLocationId, batchId, slice.Qty, product.BaseUomId, 1m,
                        product.BaseUomId, product.BaseUomDecimals, source.UnitCost));
                }

                costTotal += slice.Qty * (source.UnitCost ?? 0m);
            }

            var unitCost = qtyBase.Value > 0m && costTotal > 0m
                ? Quantity.Round(costTotal / qtyBase.Value, Money.StorageDecimals)
                : (decimal?)null;
            posted.Add(new PostedLine(line.Key, line.ProductId, qtyBase.Value, takenBatchId, suggestedBatchId, unitCost));
        }

        if (inputs.Count < 2)
        {
            return InventoryErrors.EmptyMovementGroup();
        }

        var header = new MovementGroupHeader(
            tenantId, request.DocType, request.DocNo, request.DocDate, now, currentUser.UserId, request.IdempotencyKey,
            SourceDocType: request.SourceDocType,
            SourceDocId: request.SourceDocId,
            ReasonCodeId: request.ReasonCodeId,
            Note: request.Note);

        var group = MovementGroup.Create(header, inputs);
        if (group.IsFailure)
        {
            return group.Error;
        }

        movementGroups.Add(group.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var virtualLocations = request.VirtualLocationIds.ToHashSet();
        foreach (var movement in group.Value.Lines)
        {
            var balance = await balances.GetForUpdateAsync(
                tenantId, movement.ProductId, movement.LocationId, movement.BatchId ?? StockBalance.NoBatch, now, cancellationToken)
                .ConfigureAwait(false);

            var applied = balance.Apply(movement, allowNegativeStock || virtualLocations.Contains(movement.LocationId), now);
            if (applied.IsFailure)
            {
                return applied.Error;
            }
        }

        return new PostingResult(group.Value.Id, group.Value.DocNo, Replayed: false, posted);
    }

    /// <summary>Turns locked balance rows into allocation candidates, dropping non-allocatable and expired batches.</summary>
    private async Task<List<CandidateRow>> BuildCandidatesAsync(
        uint tenantId,
        IReadOnlyList<StockBalance> rows,
        DateOnly docDate,
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
                candidates.Add(new CandidateRow(
                    new BatchCandidate(StockBalance.NoBatch, BatchStatus.Active, null, DateTimeOffset.MinValue, row.QtyAvailable()),
                    unitCost));
                continue;
            }

            if (!batches.TryGetValue(row.BatchId, out var batch) || !batch.IsAllocatable() || batch.IsExpiredOn(docDate))
            {
                continue;
            }

            candidates.Add(new CandidateRow(
                new BatchCandidate(batch.Id, batch.Status, batch.ExpiryDate, batch.ReceivedAt, row.QtyAvailable()),
                unitCost));
        }

        return candidates;
    }

    private sealed record CandidateRow(BatchCandidate Candidate, decimal? UnitCost);
}
