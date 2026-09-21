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
using Wms.Inventory.Domain.Services;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.GoodsReceipts;

public sealed record PostGoodsReceiptResult(long ReceiptId, long MovementGroupId, string DocNo);

/// <summary><c>POST /api/v1/inventory/goods-receipts/{id}/post</c>. <see cref="IdempotencyKey"/> is the request header (spec §13.2) and becomes <c>inv_movement_group.idempotency_key</c>.</summary>
public sealed record PostGoodsReceiptCommand(long ReceiptId, Guid IdempotencyKey) : ICommand<PostGoodsReceiptResult>;

public sealed class PostGoodsReceiptCommandValidator : AbstractValidator<PostGoodsReceiptCommand>
{
    public PostGoodsReceiptCommandValidator()
    {
        RuleFor(c => c.ReceiptId).GreaterThan(0L);
        RuleFor(c => c.IdempotencyKey).NotEqual(Guid.Empty);
    }
}

/// <summary>
/// The single allowed transaction path that changes stock (spec §12.2, ADR-003/004):
/// <list type="number">
/// <item>resolve master data (product, UoM factor, FX rate, V_SUPPLIER) and create missing batches;</item>
/// <item>build the double-entry <see cref="MovementGroup"/> (V_SUPPLIER −qty / warehouse +qty) — rejected unless SUM(qty_base) = 0;</item>
/// <item>INSERT the movements; for every line <c>SELECT ... FOR UPDATE</c> the <c>inv_balance</c> row and <see cref="StockBalance.Apply"/>;</item>
/// <item>mark the receipt POSTED, write audit + outbox rows — all in ONE transaction, then COMMIT.</item>
/// </list>
/// </summary>
public sealed class PostGoodsReceiptCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IGoodsReceiptRepository receipts,
    IMovementGroupRepository movementGroups,
    IStockBalanceRepository balances,
    IBatchRepository batches,
    IInventorySettings settings,
    ILocationFreezeChecker freezeChecker,
    IProductCatalog products,
    ILocationCatalog locations,
    ICurrencyRateReader currencyRates,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<PostGoodsReceiptCommand, PostGoodsReceiptResult>
{
    public async Task<Result<PostGoodsReceiptResult>> HandleAsync(PostGoodsReceiptCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;

        // Document-level idempotency (uq_mg_idem): a repeated key returns the previous result, no new document.
        var existing = await movementGroups.FindByIdempotencyKeyAsync(tenantId, command.IdempotencyKey, cancellationToken).ConfigureAwait(false);
        if (existing is not null)
        {
            return new PostGoodsReceiptResult(command.ReceiptId, existing.Id, existing.DocNo);
        }

        var receipt = await receipts.GetAsync(command.ReceiptId, cancellationToken).ConfigureAwait(false);
        if (receipt is null)
        {
            return InventoryErrors.ReceiptNotFound(command.ReceiptId);
        }

        if (receipt.Status != ReceiptStatus.Draft)
        {
            return InventoryErrors.ReceiptNotDraft(receipt.Id, receipt.Status);
        }

        if (receipt.Lines.Count == 0)
        {
            return InventoryErrors.ReceiptHasNoLines(receipt.Id);
        }

        if (await freezeChecker.IsFrozenAsync(receipt.LocationId, cancellationToken).ConfigureAwait(false))
        {
            return InventoryErrors.LocationFrozen(receipt.LocationId);
        }

        var warehouse = await locations.GetAsync(receipt.LocationId, cancellationToken).ConfigureAwait(false);
        if (warehouse is null || !warehouse.IsActive || warehouse.IsVirtual)
        {
            return InventoryErrors.LocationNotFound(receipt.LocationId);
        }

        var supplierLocation = await locations.GetVirtualAsync(LocationTypes.VSupplier, cancellationToken).ConfigureAwait(false);
        if (supplierLocation is null)
        {
            return InventoryErrors.VirtualLocationMissing(LocationTypes.VSupplier);
        }

        var allowNegativeStock = await settings.GetBoolAsync(InventorySettingKeys.AllowNegativeStock, cancellationToken).ConfigureAwait(false);
        var overTolerancePct = await settings.GetDecimalAsync(InventorySettingKeys.ReceiptOverTolerancePct, cancellationToken).ConfigureAwait(false);
        var underTolerancePct = await settings.GetDecimalAsync(InventorySettingKeys.ReceiptUnderTolerancePct, cancellationToken).ConfigureAwait(false);
        var baseCurrency = await currencyRates.GetBaseCurrencyAsync(cancellationToken).ConfigureAwait(false);
        var now = clock.UtcNow;

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        // 1. Resolve master data and batches. New batches are saved first so their ids can be referenced by movements.
        var resolved = new List<ResolvedLine>(receipt.Lines.Count);
        var variances = new List<ReceiptVarianceDetected>();
        foreach (var line in receipt.Lines)
        {
            var product = await products.GetAsync(line.ProductId, cancellationToken).ConfigureAwait(false);
            if (product is null || !product.IsActive)
            {
                return InventoryErrors.ProductNotFound(line.ProductId);
            }

            if (product.RequiresBatch && line.BatchNo is null)
            {
                return InventoryErrors.BatchRequired(line.ProductId);
            }

            if (product.RequiresExpiry && line.ExpiryDate is null)
            {
                return InventoryErrors.ExpiryRequired(line.ProductId);
            }

            var factor = await products.GetUomFactorAsync(line.ProductId, line.UomId, receipt.DocDate, cancellationToken).ConfigureAwait(false);
            if (factor is not > 0m)
            {
                return InventoryErrors.UomFactorNotFound(line.ProductId, line.UomId, receipt.DocDate);
            }

            if (line.OrderedQty is { } orderedQty && orderedQty > 0m)
            {
                var outcome = ReceiptTolerance.Evaluate(orderedQty, line.ReceivedQty, overTolerancePct, underTolerancePct);
                if (outcome != ToleranceOutcome.WithinTolerance)
                {
                    if (string.IsNullOrWhiteSpace(line.VarianceNote))
                    {
                        return InventoryErrors.VarianceNoteRequired(line.LineNo);
                    }

                    variances.Add(new ReceiptVarianceDetected(
                        tenantId, now, receipt.Id, receipt.DocNo, receipt.PoId, line.ProductId,
                        orderedQty, line.ReceivedQty, ReceiptTolerance.VariancePct(orderedQty, line.ReceivedQty), line.VarianceNote));
                }
            }

            decimal? unitCostBase = null;
            decimal? fxRate = null;
            string? currency = null;
            if (line.UnitPrice is { } unitPrice)
            {
                currency = line.Currency ?? baseCurrency;
                if (string.Equals(currency, baseCurrency, StringComparison.OrdinalIgnoreCase))
                {
                    fxRate = 1m;
                }
                else
                {
                    fxRate = await currencyRates.GetRateToBaseAsync(currency, receipt.DocDate, cancellationToken).ConfigureAwait(false);
                    if (fxRate is not > 0m)
                    {
                        return InventoryErrors.FxRateMissing(currency, receipt.DocDate);
                    }
                }

                // unit_price is per entered UoM; the ledger stores cost per base UoM in the tenant currency.
                unitCostBase = MovingAverageCost.ToBaseCurrency(unitPrice / factor.Value, fxRate.Value);
            }

            Batch? batch = null;
            if (line.BatchNo is not null)
            {
                batch = await batches.FindAsync(tenantId, line.ProductId, line.BatchNo, line.ExpiryDate, cancellationToken).ConfigureAwait(false);
                if (batch is null)
                {
                    var created = Batch.Create(tenantId, line.ProductId, line.BatchNo, line.ProductionDate, line.ExpiryDate, receipt.SupplierId, now);
                    if (created.IsFailure)
                    {
                        return created.Error;
                    }

                    batch = created.Value;
                    batches.Add(batch);
                }
                else if (!batch.IsAllocatable())
                {
                    return InventoryErrors.BatchNotAllocatable(batch.Id, batch.Status);
                }
            }

            resolved.Add(new ResolvedLine(line, product, factor.Value, unitCostBase, currency, fxRate, batch));
        }

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        // 2. Double-entry group: V_SUPPLIER −qty, warehouse +qty for every line (spec §12.3).
        var inputs = new List<MovementLineInput>(resolved.Count * 2);
        foreach (var r in resolved)
        {
            var qty = r.Line.QtyToStock();
            var batchId = r.Batch?.Id;
            inputs.Add(new MovementLineInput(
                r.Line.ProductId, supplierLocation.Id, batchId, -qty, r.Line.UomId, r.Factor,
                r.Product.BaseUomId, r.Product.BaseUomDecimals, r.UnitCostBase, r.Currency, r.FxRate));
            inputs.Add(new MovementLineInput(
                r.Line.ProductId, receipt.LocationId, batchId, qty, r.Line.UomId, r.Factor,
                r.Product.BaseUomId, r.Product.BaseUomDecimals, r.UnitCostBase, r.Currency, r.FxRate));
        }

        var header = new MovementGroupHeader(
            tenantId, DocType.Receipt, receipt.DocNo, receipt.DocDate, now, currentUser.UserId, command.IdempotencyKey,
            SourceDocType: "GOODS_RECEIPT", SourceDocId: receipt.Id);
        var group = MovementGroup.Create(header, inputs);
        if (group.IsFailure)
        {
            return group.Error;
        }

        // 3. INSERT movements, then lock and update every balance row (FOR UPDATE) in the same transaction.
        movementGroups.Add(group.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        foreach (var movement in group.Value.Lines)
        {
            var balance = await balances.GetForUpdateAsync(
                tenantId, movement.ProductId, movement.LocationId, movement.BatchId ?? StockBalance.NoBatch, now, cancellationToken).ConfigureAwait(false);

            // Virtual counter-locations (V_SUPPLIER etc.) legitimately go negative; physical stock follows the tenant setting.
            var isVirtual = movement.LocationId == supplierLocation.Id;
            var applied = balance.Apply(movement, allowNegativeStock || isVirtual, now);
            if (applied.IsFailure)
            {
                return applied.Error;
            }
        }

        // 4. Document status, audit, outbox — same transaction.
        var posted = receipt.MarkPosted(group.Value.Id);
        if (posted.IsFailure)
        {
            return posted.Error;
        }

        unitOfWork.Audit.Record("inv_goods_receipt", receipt.Id, AuditAction.Post, new { receipt.DocNo, movementGroupId = group.Value.Id });

        unitOfWork.Outbox.Enqueue(new GoodsReceiptPosted(
            tenantId,
            now,
            receipt.Id,
            receipt.DocNo,
            receipt.PoId,
            receipt.SupplierId,
            receipt.LocationId,
            group.Value.Id,
            group.Value.Lines
                .Where(m => m.LocationId == receipt.LocationId)
                .Select(m => new GoodsReceiptPostedLine(m.ProductId, m.BatchId, m.QtyBase, m.BaseUomId, m.UnitCost))
                .ToList()));
        foreach (var variance in variances)
        {
            unitOfWork.Outbox.Enqueue(variance);
        }

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new PostGoodsReceiptResult(receipt.Id, group.Value.Id, receipt.DocNo);
    }

    private sealed record ResolvedLine(
        GoodsReceiptLine Line,
        ProductDto Product,
        decimal Factor,
        decimal? UnitCostBase,
        string? Currency,
        decimal? FxRate,
        Batch? Batch);
}
