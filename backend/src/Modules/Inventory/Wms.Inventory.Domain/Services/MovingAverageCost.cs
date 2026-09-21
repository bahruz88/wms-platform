using Wms.Common.Domain;

namespace Wms.Inventory.Domain.Services;

/// <summary>Moving-average costing per base UoM in the tenant currency (spec §12.5).</summary>
public static class MovingAverageCost
{
    /// <summary>
    /// <c>new_avg = (qty_on_hand × avg_unit_cost + receipt_qty × receipt_unit_cost) / (qty_on_hand + receipt_qty)</c>.
    /// A non-positive on-hand quantity carries no value, so the receipt cost becomes the new average.
    /// </summary>
    public static decimal Next(decimal qtyOnHand, decimal avgUnitCost, decimal receiptQty, decimal receiptUnitCost)
    {
        if (receiptQty <= 0m)
        {
            throw new ArgumentOutOfRangeException(nameof(receiptQty), "Receipt quantity must be positive.");
        }

        var existingQty = qtyOnHand > 0m ? qtyOnHand : 0m;
        var totalQty = existingQty + receiptQty;
        var totalValue = existingQty * avgUnitCost + receiptQty * receiptUnitCost;
        return Quantity.Round(totalValue / totalQty, Money.StorageDecimals);
    }

    /// <summary><c>unit_cost_base = unit_price × fx_rate</c> (CBAR rate of the PO date); fx_rate = 1 for the base currency.</summary>
    public static decimal ToBaseCurrency(decimal unitPrice, decimal fxRate)
    {
        if (fxRate <= 0m)
        {
            throw new ArgumentOutOfRangeException(nameof(fxRate), "FX rate must be positive.");
        }

        return Quantity.Round(unitPrice * fxRate, Money.StorageDecimals);
    }
}
