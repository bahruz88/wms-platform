using Wms.Common.Domain;

namespace Wms.Procurement.Domain.Entities;

/// <summary>
/// <c>proc_price_history</c> (spec §10, TOR §25): one row per product × supplier × purchase price, written
/// after a goods receipt is booked against a PO. Append-only — a correction is a new row, never an edit.
/// </summary>
public sealed class PriceHistoryEntry : Entity<long>, ITenantEntity
{
    private PriceHistoryEntry()
    {
    }

    public uint TenantId { get; private set; }

    public uint ProductId { get; private set; }

    public uint SupplierId { get; private set; }

    public long? PoId { get; private set; }

    public DateOnly PriceDate { get; private set; }

    public decimal UnitPrice { get; private set; }

    public string Currency { get; private set; } = "AZN";

    /// <summary>Base currency, per the product's base UoM.</summary>
    public decimal UnitPriceBase { get; private set; }

    public decimal? PrevPriceBase { get; private set; }

    public decimal? DiffAmount { get; private set; }

    public decimal? DiffPct { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public uint CreatedBy { get; private set; }

    /// <summary>
    /// Builds the next history row. <paramref name="prevPriceBase"/> is the last known base price of the same
    /// product × supplier pair; the difference and the percentage are derived, never supplied by the caller.
    /// </summary>
    public static Result<PriceHistoryEntry> Record(
        uint tenantId,
        uint productId,
        uint supplierId,
        long? poId,
        DateOnly priceDate,
        decimal unitPrice,
        string currency,
        decimal unitPriceBase,
        decimal? prevPriceBase,
        DateTimeOffset now,
        uint createdBy)
    {
        if (productId == 0 || supplierId == 0)
        {
            return ProcurementErrors.InvalidPurchaseOrder("product_id and supplier_id are required for a price history row.");
        }

        if (unitPrice < 0m || unitPriceBase < 0m)
        {
            return ProcurementErrors.InvalidPurchaseOrder("A price cannot be negative.");
        }

        if (!Money.IsValidCurrency(currency))
        {
            return ProcurementErrors.InvalidPurchaseOrder("currency must be an ISO 4217 code.");
        }

        var (diffAmount, diffPct) = Difference(prevPriceBase, unitPriceBase);
        return new PriceHistoryEntry
        {
            TenantId = tenantId,
            ProductId = productId,
            SupplierId = supplierId,
            PoId = poId,
            PriceDate = priceDate,
            UnitPrice = Quantity.Round(unitPrice, Money.StorageDecimals),
            Currency = currency.ToUpperInvariant(),
            UnitPriceBase = Quantity.Round(unitPriceBase, Money.StorageDecimals),
            PrevPriceBase = prevPriceBase,
            DiffAmount = diffAmount,
            DiffPct = diffPct,
            CreatedAt = now,
            CreatedBy = createdBy,
        };
    }

    /// <summary>
    /// Absolute and relative change against the previous base price. Returns <c>(null, null)</c> for the very
    /// first price of a pair, and a null percentage when the previous price was zero.
    /// </summary>
    public static (decimal? DiffAmount, decimal? DiffPct) Difference(decimal? prevPriceBase, decimal unitPriceBase)
    {
        if (prevPriceBase is not { } previous)
        {
            return (null, null);
        }

        var diff = Quantity.Round(unitPriceBase - previous, Money.StorageDecimals);
        var pct = previous == 0m ? (decimal?)null : Quantity.Round(diff / previous * 100m, 4);
        return (diff, pct);
    }

    /// <summary>True when the row represents a real price move — the trigger of <c>PriceChanged</c> (TOR §25).</summary>
    public bool IsPriceChange() => PrevPriceBase is not null && DiffAmount is not null && DiffAmount != 0m;
}
