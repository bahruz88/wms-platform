using Wms.Common.Domain;

namespace Wms.Inventory.Domain.Services;

public enum ToleranceOutcome
{
    WithinTolerance,
    OverTolerance,
    UnderTolerance,
}

/// <summary>PO ↔ receipt tolerance (spec §12.8): over → warning + approval, under → variance_note mandatory.</summary>
public static class ReceiptTolerance
{
    public static ToleranceOutcome Evaluate(decimal orderedQty, decimal receivedQty, decimal overTolerancePct, decimal underTolerancePct)
    {
        if (orderedQty <= 0m)
        {
            throw new ArgumentOutOfRangeException(nameof(orderedQty), "Ordered quantity must be positive.");
        }

        var upper = orderedQty * (1m + overTolerancePct / 100m);
        var lower = orderedQty * (1m - underTolerancePct / 100m);

        if (receivedQty > upper)
        {
            return ToleranceOutcome.OverTolerance;
        }

        if (receivedQty < lower)
        {
            return ToleranceOutcome.UnderTolerance;
        }

        return ToleranceOutcome.WithinTolerance;
    }

    /// <summary>DECIMAL(9,4) variance percent: (received − ordered) / ordered × 100.</summary>
    public static decimal VariancePct(decimal orderedQty, decimal receivedQty) =>
        orderedQty == 0m ? 0m : Quantity.Round((receivedQty - orderedQty) / orderedQty * 100m, 4);
}
