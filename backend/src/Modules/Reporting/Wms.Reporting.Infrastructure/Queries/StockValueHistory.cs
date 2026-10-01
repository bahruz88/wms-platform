using Wms.Inventory.Contracts;
using Wms.Reporting.Application.Dtos;

namespace Wms.Reporting.Infrastructure.Queries;

/// <summary>End-of-day stock values over a window, and the value at the end of the day before it.</summary>
/// <param name="Points">One point for <b>every</b> day of the window, oldest first — the only dashboard series without gaps.</param>
public sealed record StockValueTimeline(IReadOnlyList<DashboardSeriesPointDto> Points, decimal ValueBeforeWindow);

/// <summary>
/// Rebuilds the stock value of past days from the one figure that is actually stored — the current value,
/// <c>Σ qty_on_hand × avg_unit_cost</c> of <c>inv_balance</c> — by walking the value ledger backwards: the value
/// at the end of day <c>d</c> is the current value minus the net ledger value dated after <c>d</c>.
/// </summary>
/// <remarks>
/// <para>
/// There is no daily snapshot to read instead: <c>rpt_stock_snapshot</c> is written by a nightly job, has no rows
/// before the job first ran and none for a day it missed, while the ledger is complete by construction
/// (ADR-004). The walk is exact under moving-average costing, because a receipt adds <c>qty × price</c> to the
/// balance value and every outflow leaves at the average cost it carries on its ledger line.
/// </para>
/// <para>
/// This is the only place the rebuild happens: <c>stockValuePerDay</c> and the <c>stockValueTotal</c> trend both
/// come from it, so the trend's base is always the point just left of the chart.
/// </para>
/// </remarks>
public static class StockValueHistory
{
    /// <param name="currentValue">Stock value now, over the same locations as the ledger figures.</param>
    /// <param name="from">First day of the window.</param>
    /// <param name="to">Last day of the window (today).</param>
    /// <param name="inboundPerDay">Positive ledger value per day; days outside the window are ignored.</param>
    /// <param name="outboundPerDay">Negative ledger value per day, as a positive number; days outside the window are ignored.</param>
    /// <param name="valueDatedAfterWindow">Net (signed) ledger value dated after <paramref name="to"/> — normally zero.</param>
    public static StockValueTimeline Rebuild(
        decimal currentValue,
        DateOnly from,
        DateOnly to,
        IReadOnlyList<DashboardDayPoint> inboundPerDay,
        IReadOnlyList<DashboardDayPoint> outboundPerDay,
        decimal valueDatedAfterWindow)
    {
        ArgumentNullException.ThrowIfNull(inboundPerDay);
        ArgumentNullException.ThrowIfNull(outboundPerDay);
        if (to < from)
        {
            throw new ArgumentOutOfRangeException(nameof(to), to, "The window ends before it starts.");
        }

        var netPerDay = new Dictionary<DateOnly, decimal>();
        foreach (var point in inboundPerDay)
        {
            netPerDay[point.Date] = netPerDay.GetValueOrDefault(point.Date) + point.Value;
        }

        foreach (var point in outboundPerDay)
        {
            netPerDay[point.Date] = netPerDay.GetValueOrDefault(point.Date) - point.Value;
        }

        var days = to.DayNumber - from.DayNumber + 1;
        var points = new DashboardSeriesPointDto[days];
        var endOfDay = currentValue - valueDatedAfterWindow;
        for (var i = days - 1; i >= 0; i--)
        {
            var day = from.AddDays(i);
            points[i] = new DashboardSeriesPointDto(day, endOfDay);
            endOfDay -= netPerDay.GetValueOrDefault(day);
        }

        // After the loop the walk has stepped back over the first day of the window as well.
        return new StockValueTimeline(points, endOfDay);
    }
}
