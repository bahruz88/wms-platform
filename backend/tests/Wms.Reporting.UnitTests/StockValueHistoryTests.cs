using Wms.Inventory.Contracts;
using Wms.Reporting.Infrastructure.Queries;

namespace Wms.Reporting.UnitTests;

/// <summary>
/// The one place the dashboard rebuilds past stock values: current value minus the net ledger value dated
/// after each day. <c>stockValuePerDay</c> and the <c>stockValueTotal</c> trend both come from it.
/// </summary>
public sealed class StockValueHistoryTests
{
    private static readonly DateOnly From = new(2026, 9, 20);
    private static readonly DateOnly To = new(2026, 9, 22);

    private static DashboardDayPoint P(DateOnly date, decimal value) => new(date, value);

    [Fact]
    public void Each_day_ends_at_the_current_value_minus_what_the_ledger_moved_after_it()
    {
        var timeline = StockValueHistory.Rebuild(
            1000m,
            From,
            To,
            inboundPerDay: [P(To.AddDays(-1), 300m), P(To, 50m)],
            outboundPerDay: [P(To.AddDays(-1), 100m), P(From, 20m)],
            valueDatedAfterWindow: 0m);

        Assert.Equal([From, From.AddDays(1), To], timeline.Points.Select(p => p.Date));
        Assert.Equal([750m, 950m, 1000m], timeline.Points.Select(p => p.Value));
        Assert.Equal(770m, timeline.ValueBeforeWindow);
    }

    [Fact]
    public void A_document_dated_after_the_window_is_taken_off_every_day_of_it()
    {
        var timeline = StockValueHistory.Rebuild(1000m, From, To, [], [], valueDatedAfterWindow: 40m);

        Assert.All(timeline.Points, p => Assert.Equal(960m, p.Value));
        Assert.Equal(960m, timeline.ValueBeforeWindow);
    }

    [Fact]
    public void A_quiet_window_still_has_a_point_for_every_day()
    {
        var timeline = StockValueHistory.Rebuild(12.5m, new DateOnly(2026, 9, 1), new DateOnly(2026, 9, 30), [], [], 0m);

        Assert.Equal(30, timeline.Points.Count);
        Assert.All(timeline.Points, p => Assert.Equal(12.5m, p.Value));
        Assert.Equal(12.5m, timeline.ValueBeforeWindow);
    }

    [Fact]
    public void A_one_day_window_trends_against_yesterday_evening()
    {
        var timeline = StockValueHistory.Rebuild(500m, To, To, [P(To, 80m)], [P(To, 30m)], 0m);

        var point = Assert.Single(timeline.Points);
        Assert.Equal(500m, point.Value);
        Assert.Equal(450m, timeline.ValueBeforeWindow);
    }

    [Fact]
    public void Ledger_days_outside_the_window_do_not_move_it()
    {
        // Days after the window reach the rebuild only through valueDatedAfterWindow, never as series points.
        var timeline = StockValueHistory.Rebuild(
            100m, From, To, [P(From.AddDays(-3), 999m), P(To.AddDays(2), 7m)], [P(From.AddDays(-1), 5m)], 0m);

        Assert.All(timeline.Points, p => Assert.Equal(100m, p.Value));
        Assert.Equal(100m, timeline.ValueBeforeWindow);
    }

    [Fact]
    public void A_window_that_ends_before_it_starts_is_refused()
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => StockValueHistory.Rebuild(1m, To, From, [], [], 0m));
    }
}
