using Wms.Inventory.Domain.Services;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §12.5: moving average, including a receipt in a foreign currency.</summary>
public sealed class MovingAverageCostTests
{
    [Fact]
    public void Next_computes_the_weighted_average()
    {
        // (100 × 10.0000 + 50 × 13.0000) / 150 = 11.0000
        var result = MovingAverageCost.Next(qtyOnHand: 100m, avgUnitCost: 10m, receiptQty: 50m, receiptUnitCost: 13m);

        Assert.Equal(11.0000m, result);
    }

    [Fact]
    public void Next_rounds_to_four_decimals()
    {
        // (3 × 1 + 1 × 2) / 4 = 1.25 → exact; (1×1 + 2×2)/3 = 1.666... → 1.6667
        Assert.Equal(1.6667m, MovingAverageCost.Next(1m, 1m, 2m, 2m));
    }

    [Fact]
    public void Next_uses_the_receipt_cost_when_there_is_no_stock()
    {
        Assert.Equal(7.5000m, MovingAverageCost.Next(qtyOnHand: 0m, avgUnitCost: 0m, receiptQty: 10m, receiptUnitCost: 7.5m));
    }

    [Fact]
    public void Next_ignores_a_negative_on_hand_quantity_as_carrying_no_value()
    {
        Assert.Equal(7.5000m, MovingAverageCost.Next(qtyOnHand: -5m, avgUnitCost: 99m, receiptQty: 10m, receiptUnitCost: 7.5m));
    }

    [Fact]
    public void Next_requires_a_positive_receipt_quantity()
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => MovingAverageCost.Next(1m, 1m, 0m, 1m));
    }

    [Fact]
    public void ToBaseCurrency_multiplies_the_price_by_the_fx_rate()
    {
        // 12.50 USD at 1.7000 AZN/USD = 21.2500 AZN
        Assert.Equal(21.2500m, MovingAverageCost.ToBaseCurrency(unitPrice: 12.50m, fxRate: 1.70m));
    }

    [Fact]
    public void Foreign_currency_receipt_feeds_the_average_in_the_tenant_currency()
    {
        var unitCostBase = MovingAverageCost.ToBaseCurrency(unitPrice: 10m, fxRate: 1.70m);

        // 100 units at 15 AZN, then 100 units at 17 AZN (= 10 USD × 1.70) → 16 AZN
        var average = MovingAverageCost.Next(qtyOnHand: 100m, avgUnitCost: 15m, receiptQty: 100m, receiptUnitCost: unitCostBase);

        Assert.Equal(17.0000m, unitCostBase);
        Assert.Equal(16.0000m, average);
    }

    [Fact]
    public void ToBaseCurrency_requires_a_positive_rate()
    {
        // Spec §12.5: a missing rate must block the receipt, never default to 0 or an old rate.
        Assert.Throws<ArgumentOutOfRangeException>(() => MovingAverageCost.ToBaseCurrency(10m, 0m));
    }
}
