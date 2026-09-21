using Wms.Inventory.Domain.Services;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §12.8: PO ↔ receipt tolerance.</summary>
public sealed class ReceiptToleranceTests
{
    [Theory]
    [InlineData(100, 100, 0, 0, ToleranceOutcome.WithinTolerance)]
    [InlineData(100, 101, 0, 0, ToleranceOutcome.OverTolerance)]
    [InlineData(100, 99, 0, 0, ToleranceOutcome.UnderTolerance)]
    [InlineData(100, 105, 5, 5, ToleranceOutcome.WithinTolerance)]
    [InlineData(100, 106, 5, 5, ToleranceOutcome.OverTolerance)]
    [InlineData(100, 95, 5, 5, ToleranceOutcome.WithinTolerance)]
    [InlineData(100, 94, 5, 5, ToleranceOutcome.UnderTolerance)]
    public void Evaluate_applies_the_configured_tolerances(int ordered, int received, int overPct, int underPct, ToleranceOutcome expected)
    {
        var outcome = ReceiptTolerance.Evaluate(ordered, received, overPct, underPct);

        Assert.Equal(expected, outcome);
    }

    [Fact]
    public void VariancePct_is_signed_and_rounded_to_four_decimals()
    {
        Assert.Equal(-10.0000m, ReceiptTolerance.VariancePct(100m, 90m));
        Assert.Equal(5.0000m, ReceiptTolerance.VariancePct(100m, 105m));
        Assert.Equal(-0.6667m, ReceiptTolerance.VariancePct(300m, 298m));
    }

    [Fact]
    public void Evaluate_requires_a_positive_ordered_quantity()
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => ReceiptTolerance.Evaluate(0m, 10m, 0m, 0m));
    }
}
