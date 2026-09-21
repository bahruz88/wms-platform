using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.UnitTests;

/// <summary>
/// ADR-012 invariant 3: <c>posted = min(theoretical, available)</c>, the remainder is recorded as a shortfall
/// and stock never goes negative. Plus the document's state machine.
/// </summary>
public sealed class ConsumptionRunTests
{
    private const uint Tenant = 1;
    private const uint Location = 11;
    private const uint Product = 101;
    private const ushort BaseUom = 1;
    private static readonly DateOnly BusinessDate = new(2026, 9, 20);
    private static readonly DateTimeOffset Now = new(2026, 9, 21, 3, 0, 0, TimeSpan.Zero);

    [Theory]
    [InlineData("100.0000", "250.0000", "100.0000", "0.0000")]
    [InlineData("100.0000", "100.0000", "100.0000", "0.0000")]
    [InlineData("100.0000", "40.5000", "40.5000", "59.5000")]
    [InlineData("100.0000", "0.0000", "0.0000", "100.0000")]
    [InlineData("100.0000", "-7.0000", "0.0000", "100.0000")]
    public void Posted_is_the_minimum_of_theoretical_and_available(string theoretical, string available, string expectedPosted, string expectedShortfall)
    {
        var culture = System.Globalization.CultureInfo.InvariantCulture;
        var line = ConsumptionRunLine.Create(Tenant, Product, decimal.Parse(theoretical, culture), BaseUom).Value;

        line.Plan(decimal.Parse(available, culture));

        Assert.Equal(decimal.Parse(expectedPosted, culture), line.PostedQtyBase);
        Assert.Equal(decimal.Parse(expectedShortfall, culture), line.ShortfallQtyBase);
        Assert.Equal(line.TheoreticalQtyBase, line.PostedQtyBase + line.ShortfallQtyBase);
    }

    [Fact]
    public void A_fresh_line_starts_as_a_full_shortfall_until_it_is_planned()
    {
        var line = ConsumptionRunLine.Create(Tenant, Product, 12.5m, BaseUom).Value;

        Assert.Equal(0m, line.PostedQtyBase);
        Assert.Equal(12.5m, line.ShortfallQtyBase);
    }

    [Fact]
    public void Settling_with_what_inventory_really_posted_recomputes_the_shortfall()
    {
        var line = ConsumptionRunLine.Create(Tenant, Product, 100m, BaseUom).Value;
        line.Plan(100m);

        // Inventory locked the balances and found only 62.5 allocatable after excluding a blocked batch.
        line.Settle(62.5m, unitCost: 3.2000m);

        Assert.Equal(62.5m, line.PostedQtyBase);
        Assert.Equal(37.5m, line.ShortfallQtyBase);
        Assert.Equal(3.2000m, line.UnitCost);
    }

    [Fact]
    public void Settling_can_never_post_more_than_the_theoretical_quantity()
    {
        var line = ConsumptionRunLine.Create(Tenant, Product, 10m, BaseUom).Value;

        line.Settle(999m, null);

        Assert.Equal(10m, line.PostedQtyBase);
        Assert.Equal(0m, line.ShortfallQtyBase);
    }

    [Fact]
    public void The_shortfall_count_is_the_number_of_products_stock_could_not_cover()
    {
        var run = Run();
        var covered = ConsumptionRunLine.Create(Tenant, 101, 10m, BaseUom).Value;
        covered.Plan(50m);
        var short1 = ConsumptionRunLine.Create(Tenant, 102, 10m, BaseUom).Value;
        short1.Plan(2m);
        var short2 = ConsumptionRunLine.Create(Tenant, 103, 10m, BaseUom).Value;
        short2.Plan(0m);

        Assert.True(run.ApplyCalculation([covered, short1, short2], unmappedCount: 4, Now).IsSuccess);

        Assert.Equal(ConsumptionRunStatus.Calculated, run.Status);
        Assert.Equal(2, run.ShortfallCount);
        Assert.Equal(4, run.UnmappedCount);
        Assert.Equal(12m, run.TotalPostedQtyBase());
        Assert.Equal(18m, run.TotalShortfallQtyBase());
    }

    [Fact]
    public void A_posted_document_is_never_recalculated()
    {
        var run = Calculated();
        run.MarkPosted(4242, Now, 7);

        var result = run.ApplyCalculation([], 0, Now);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
    }

    [Fact]
    public void Only_a_calculated_document_can_be_posted()
    {
        var run = Run();

        var result = run.MarkPosted(1, Now, 7);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", result.Error.Code);
    }

    [Fact]
    public void Posting_records_the_movement_group_and_the_poster()
    {
        var run = Calculated();

        Assert.True(run.MarkPosted(4242, Now, 7).IsSuccess);

        Assert.Equal(ConsumptionRunStatus.Posted, run.Status);
        Assert.Equal(4242, run.MovementGroupId);
        Assert.Equal(Now, run.PostedAt);
        Assert.Equal(7u, run.PostedBy);
    }

    [Fact]
    public void A_day_that_was_entirely_short_is_posted_without_a_movement_group()
    {
        var run = Run();
        var line = ConsumptionRunLine.Create(Tenant, Product, 10m, BaseUom).Value;
        line.Plan(0m);
        run.ApplyCalculation([line], 0, Now);

        Assert.True(run.MarkPosted(null, Now, 7).IsSuccess);

        Assert.Null(run.MovementGroupId);
        Assert.Equal(1, run.ShortfallCount);
    }

    [Fact]
    public void A_reversed_document_can_be_recalculated_and_posted_again()
    {
        var run = Calculated();
        run.MarkPosted(4242, Now, 7);
        Assert.True(run.MarkReversed().IsSuccess);

        var line = ConsumptionRunLine.Create(Tenant, Product, 5m, BaseUom).Value;
        line.Plan(5m);
        Assert.True(run.ApplyCalculation([line], 0, Now).IsSuccess);

        Assert.Equal(ConsumptionRunStatus.Calculated, run.Status);
        Assert.Null(run.MovementGroupId);
        Assert.True(run.MarkPosted(9999, Now, 7).IsSuccess);
    }

    [Fact]
    public void A_document_that_is_not_posted_cannot_be_reversed()
    {
        Assert.Equal("INVALID_STATE_TRANSITION", Calculated().MarkReversed().Error.Code);
    }

    [Fact]
    public void A_failed_calculation_keeps_the_document_with_its_reason()
    {
        var run = Run();

        Assert.True(run.MarkFailed("Sub-recipe cycle detected: 10 -> 20 -> 10.").IsSuccess);

        Assert.Equal(ConsumptionRunStatus.Failed, run.Status);
        Assert.Contains("cycle", run.FailureReason, StringComparison.Ordinal);
    }

    private static ConsumptionRun Run() =>
        ConsumptionRun.CreateDraft(Tenant, "CN-2026-00001", Location, BusinessDate, importId: 5).Value;

    private static ConsumptionRun Calculated()
    {
        var run = Run();
        var line = ConsumptionRunLine.Create(Tenant, Product, 10m, BaseUom).Value;
        line.Plan(10m);
        run.ApplyCalculation([line], 0, Now);
        return run;
    }
}
