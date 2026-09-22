using Wms.Procurement.Domain.Entities;

namespace Wms.Procurement.UnitTests;

/// <summary>TOR §25: every purchase price is kept with the previous one, the difference and the percentage.</summary>
public sealed class PriceHistoryTests
{
    private const uint TenantId = 1;
    private static readonly DateOnly PriceDate = new(2026, 9, 21);

    [Fact]
    public void The_first_price_of_a_pair_has_no_previous_value_and_is_not_a_change()
    {
        var entry = Record(unitPriceBase: 10m, prevPriceBase: null);

        Assert.Null(entry.PrevPriceBase);
        Assert.Null(entry.DiffAmount);
        Assert.Null(entry.DiffPct);
        Assert.False(entry.IsPriceChange());
    }

    [Fact]
    public void A_rise_is_recorded_as_a_positive_difference_and_percentage()
    {
        var entry = Record(unitPriceBase: 12.50m, prevPriceBase: 10m);

        Assert.Equal(2.50m, entry.DiffAmount);
        Assert.Equal(25m, entry.DiffPct);
        Assert.True(entry.IsPriceChange());
    }

    [Fact]
    public void A_fall_is_recorded_as_a_negative_difference_and_percentage()
    {
        var entry = Record(unitPriceBase: 8m, prevPriceBase: 10m);

        Assert.Equal(-2m, entry.DiffAmount);
        Assert.Equal(-20m, entry.DiffPct);
        Assert.True(entry.IsPriceChange());
    }

    [Fact]
    public void An_unchanged_price_is_recorded_but_raises_no_event()
    {
        var entry = Record(unitPriceBase: 10m, prevPriceBase: 10m);

        Assert.Equal(0m, entry.DiffAmount);
        Assert.Equal(0m, entry.DiffPct);
        Assert.False(entry.IsPriceChange());
    }

    [Fact]
    public void A_previous_price_of_zero_yields_no_percentage_but_still_a_difference()
    {
        var entry = Record(unitPriceBase: 5m, prevPriceBase: 0m);

        Assert.Equal(5m, entry.DiffAmount);
        Assert.Null(entry.DiffPct);
        Assert.True(entry.IsPriceChange());
    }

    [Fact]
    public void The_percentage_is_rounded_to_four_decimals_away_from_zero()
    {
        var (_, pct) = PriceHistoryEntry.Difference(prevPriceBase: 3m, unitPriceBase: 4m);

        Assert.Equal(33.3333m, pct);
    }

    [Fact]
    public void A_negative_price_is_rejected()
    {
        var entry = PriceHistoryEntry.Record(
            TenantId, productId: 5, supplierId: 9, poId: 1, PriceDate, unitPrice: -1m, "AZN",
            unitPriceBase: -1m, prevPriceBase: null, DateTimeOffset.UnixEpoch, createdBy: 3);

        Assert.True(entry.IsFailure);
    }

    private static PriceHistoryEntry Record(decimal unitPriceBase, decimal? prevPriceBase)
    {
        var entry = PriceHistoryEntry.Record(
            TenantId, productId: 5, supplierId: 9, poId: 1, PriceDate, unitPrice: unitPriceBase, "AZN",
            unitPriceBase, prevPriceBase, DateTimeOffset.UnixEpoch, createdBy: 3);
        Assert.True(entry.IsSuccess);
        return entry.Value;
    }
}
