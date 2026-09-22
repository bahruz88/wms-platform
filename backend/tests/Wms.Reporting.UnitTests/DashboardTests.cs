using Wms.Common.Application.Security;
using Wms.Inventory.Contracts;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Infrastructure.Queries;

namespace Wms.Reporting.UnitTests;

internal sealed class StubOutboxBacklog(int pending) : IOutboxBacklogReader
{
    public Task<int> CountPendingAsync(CancellationToken cancellationToken) => Task.FromResult(pending);
}

/// <summary>
/// <c>GET /reporting/dashboard/summary</c>: the KPI set adapts to the principal's permissions and location
/// grants, and the money KPIs are absent — not null — without <c>master.product.view_cost</c>.
/// </summary>
public sealed class DashboardTests
{
    private readonly RecordingInventorySource _inventory = new();

    private DashboardQueries Queries(int outboxPending = 0) =>
        new(_inventory, new StubOutboxBacklog(outboxPending), FixedClock.At());

    private static DashboardFilter Filter(
        bool includeCost = true,
        bool includeSystemHealth = true,
        LocationScope? scope = null,
        uint? locationId = null,
        DashboardPeriod period = DashboardPeriod.Week) =>
        new(locationId, period, scope ?? LocationScope.Unrestricted, includeCost, includeSystemHealth);

    [Fact]
    public async Task An_admin_sees_the_stock_value_kpi()
    {
        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        var stockValue = Assert.Single(summary.Kpis, k => k.Key == "stockValueTotal");
        Assert.True(stockValue.IsCost);
        Assert.Equal(1234.5678m, stockValue.Value);
        Assert.Equal("AZN", stockValue.Unit);
    }

    [Fact]
    public async Task A_keeper_without_the_cost_permission_gets_no_money_kpi_and_no_money_series()
    {
        var summary = await Queries().GetAsync(Filter(includeCost: false), TestCancellation.Token);

        Assert.DoesNotContain(summary.Kpis, k => k.IsCost);
        Assert.DoesNotContain(summary.Kpis, k => k.Key == "stockValueTotal");
        Assert.DoesNotContain(summary.Kpis, k => k.Key == "wasteValuePeriod");
        Assert.DoesNotContain(summary.Series, s => s.IsCost);
    }

    [Fact]
    public async Task The_non_cost_kpis_are_served_to_everybody()
    {
        var summary = await Queries().GetAsync(Filter(includeCost: false), TestCancellation.Token);

        Assert.Contains(summary.Kpis, k => k.Key == "balanceRows" && k.Value == 42m);
        Assert.Contains(summary.Kpis, k => k.Key == "expiringBatches");
        Assert.Contains(summary.Kpis, k => k.Key == "pendingApprovals");
        Assert.Contains(summary.Kpis, k => k.Key == "openStockRequests");
    }

    [Fact]
    public async Task Pending_approvals_add_up_the_documents_that_are_actually_waiting()
    {
        // The stub reports four waste documents pending approval and one count in review.
        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        var kpi = Assert.Single(summary.Kpis, k => k.Key == "pendingApprovals");
        Assert.Equal(5m, kpi.Value);
        Assert.Equal(KpiSeverity.Warning, kpi.Severity);
    }

    [Fact]
    public async Task Expiring_batches_raise_a_critical_alert_when_the_critical_window_is_breached()
    {
        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        Assert.Contains(summary.Alerts, a => a.Type == "BATCH_EXPIRING" && a.Severity == AlertSeverity.Critical);
        Assert.Contains(summary.Alerts, a => a.Type == "BATCH_EXPIRED");
        Assert.Contains(summary.Alerts, a => a.Type == "PENDING_APPROVAL");
    }

    [Fact]
    public async Task A_branch_principal_asks_inventory_only_about_its_own_locations()
    {
        await Queries().GetAsync(Filter(scope: LocationScope.RestrictedTo([11u])), TestCancellation.Token);

        Assert.True(_inventory.LastScope!.IsRestricted);
        Assert.Equal([11u], _inventory.LastScope.LocationIds);
    }

    [Fact]
    public async Task A_restricted_principal_with_no_grants_sees_nothing_rather_than_everything()
    {
        await Queries().GetAsync(Filter(scope: LocationScope.Nothing), TestCancellation.Token);

        Assert.True(_inventory.LastScope!.IsRestricted);
        Assert.Empty(_inventory.LastScope.LocationIds!);
    }

    [Fact]
    public async Task The_requested_location_is_echoed_back_so_the_client_can_label_the_screen()
    {
        var summary = await Queries().GetAsync(Filter(scope: LocationScope.RestrictedTo([11u]), locationId: 11), TestCancellation.Token);

        Assert.Equal(11u, summary.LocationId);
        Assert.Equal(11u, _inventory.LastLocationId);
    }

    [Fact]
    public async Task System_health_is_only_assembled_for_a_principal_that_may_audit()
    {
        var withHealth = await Queries(outboxPending: 3).GetAsync(Filter(includeSystemHealth: true), TestCancellation.Token);
        var withoutHealth = await Queries(outboxPending: 3).GetAsync(Filter(includeSystemHealth: false), TestCancellation.Token);

        Assert.Null(withoutHealth.SystemHealth);
        Assert.NotNull(withHealth.SystemHealth);
        Assert.Equal(3, withHealth.SystemHealth!.OutboxPending);

        // The self-check jobs only log their verdict (README §8.8), so the dashboard reports nothing rather
        // than inventing a green tick.
        Assert.Null(withHealth.SystemHealth.BalanceReconciliationOk);
        Assert.Null(withHealth.SystemHealth.LastBalanceReconciliationAt);
    }

    [Theory]
    [InlineData(DashboardPeriod.Today, 1)]
    [InlineData(DashboardPeriod.Week, 7)]
    [InlineData(DashboardPeriod.Month, 30)]
    public async Task The_period_sets_the_trend_window(DashboardPeriod period, int days)
    {
        await Queries().GetAsync(Filter(period: period), TestCancellation.Token);

        var today = DateOnly.FromDateTime(FixedClock.Default.UtcDateTime);
        Assert.Equal(today, _inventory.LastTo);
        Assert.Equal(today.AddDays(-(days - 1)), _inventory.LastFrom);
    }

    [Fact]
    public async Task A_trend_is_reported_against_the_previous_window()
    {
        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        // The stub reports 9 receipts against 6 in the previous window: +50 %.
        var receipts = Assert.Single(summary.Kpis, k => k.Key == "receiptsInPeriod");
        Assert.Equal(50m, receipts.TrendPct);
    }

    [Fact]
    public async Task Every_series_point_carries_a_date_and_a_decimal()
    {
        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        Assert.Contains(summary.Series, s => s.Key == "receiptsPerDay");
        Assert.Contains(summary.Series, s => s.Key == "issuesPerDay");
        Assert.Contains(summary.Series, s => s.Key == "wasteValuePerDay" && s.IsCost);
        Assert.All(summary.Series, s => Assert.NotEmpty(s.Points));
    }
}
