using Wms.Common.Domain;
using Wms.Inventory.Domain.Services;

namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// Projection row of <c>inv_balance</c> (spec §9.5, ADR-004). Has NO public setters: the only way to change a
/// balance is <see cref="Apply"/> with a ledger <see cref="Movement"/>, inside the same transaction, after
/// <c>SELECT ... FOR UPDATE</c> (spec §12.2). Reconciliation recomputes it from <c>SUM(inv_movement.qty_base)</c>.
/// </summary>
public sealed class StockBalance : ITenantEntity
{
    /// <summary><c>batch_id = 0</c> means "no batch" (spec §9.5).</summary>
    public const long NoBatch = 0;

    private StockBalance()
    {
    }

    public uint TenantId { get; private set; }

    public uint ProductId { get; private set; }

    public uint LocationId { get; private set; }

    public long BatchId { get; private set; }

    public decimal QtyOnHand { get; private set; }

    public decimal QtyReserved { get; private set; }

    public decimal AvgUnitCost { get; private set; }

    public long? LastMovementId { get; private set; }

    public DateTimeOffset UpdatedAt { get; private set; }

    public decimal QtyAvailable() => QtyOnHand - QtyReserved;

    public static StockBalance Open(uint tenantId, uint productId, uint locationId, long batchId, DateTimeOffset now) =>
        new()
        {
            TenantId = tenantId,
            ProductId = productId,
            LocationId = locationId,
            BatchId = batchId,
            QtyOnHand = 0m,
            QtyReserved = 0m,
            AvgUnitCost = 0m,
            UpdatedAt = now,
        };

    /// <summary>
    /// Applies one ledger line. Rejects negative stock unless <paramref name="allowNegativeStock"/> (spec §12.1) and
    /// updates the moving average cost on receipts (spec §12.5).
    /// </summary>
    public Result Apply(Movement movement, bool allowNegativeStock, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(movement);

        if (movement.TenantId != TenantId
            || movement.ProductId != ProductId
            || movement.LocationId != LocationId
            || (movement.BatchId ?? NoBatch) != BatchId)
        {
            return InventoryErrors.BalanceKeyMismatch();
        }

        var newQtyOnHand = QtyOnHand + movement.QtyBase;
        if (newQtyOnHand < 0m && !allowNegativeStock)
        {
            return InventoryErrors.InsufficientStock(ProductId, LocationId, QtyAvailable(), -movement.QtyBase);
        }

        if (movement.QtyBase > 0m && movement.UnitCost is { } receiptUnitCost)
        {
            AvgUnitCost = MovingAverageCost.Next(QtyOnHand, AvgUnitCost, movement.QtyBase, receiptUnitCost);
        }

        QtyOnHand = newQtyOnHand;
        if (movement.Id != 0)
        {
            LastMovementId = movement.Id;
        }

        UpdatedAt = now;
        return Result.Success();
    }

    public Result Reserve(decimal qty, DateTimeOffset now)
    {
        if (qty <= 0m)
        {
            return InventoryErrors.InvalidQuantity("Reservation quantity must be positive.");
        }

        if (QtyAvailable() < qty)
        {
            return InventoryErrors.InsufficientStock(ProductId, LocationId, QtyAvailable(), qty);
        }

        QtyReserved += qty;
        UpdatedAt = now;
        return Result.Success();
    }

    public Result Release(decimal qty, DateTimeOffset now)
    {
        if (qty <= 0m || qty > QtyReserved)
        {
            return InventoryErrors.InvalidQuantity("Release quantity must be positive and not exceed the reserved quantity.");
        }

        QtyReserved -= qty;
        UpdatedAt = now;
        return Result.Success();
    }
}
