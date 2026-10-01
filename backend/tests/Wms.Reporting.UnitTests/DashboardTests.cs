using System.Text.Json;
using System.Text.Json.Serialization;
using Wms.Common.Application.Security;
using Wms.Common.Infrastructure.Http;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;
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
    private static readonly DateOnly Today = DateOnly.FromDateTime(FixedClock.Default.UtcDateTime);

    private readonly RecordingInventorySource _inventory = new();

    // Product 1 is in category 10; product 2 of the stub dashboard is unknown to the catalogue.
    private readonly MapReferenceLoader _references = new(MapReferenceLoader.Product(1, categoryId: 10));

    private readonly StubLocationCatalog _locations = new();

    private DashboardQueries Queries(int outboxPending = 0) =>
        new(_inventory, new StubOutboxBacklog(outboxPending), _references, _locations, FixedClock.At());

    private static DashboardDayPoint Day(int daysAgo, decimal value) => new(Today.AddDays(-daysAgo), value);

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
    [InlineData(DashboardPeriod.TwoWeeks, 14)]
    [InlineData(DashboardPeriod.Month, 30)]
    public async Task The_period_sets_the_trend_window(DashboardPeriod period, int days)
    {
        await Queries().GetAsync(Filter(period: period), TestCancellation.Token);

        var request = _inventory.LastDashboardRequest!;
        Assert.Equal(Today, request.PeriodTo);
        Assert.Equal(Today.AddDays(-(days - 1)), request.PeriodFrom);

        // The comparison window is equally long and ends the day before.
        Assert.Equal(request.PeriodFrom.AddDays(-1), request.PreviousTo);
        Assert.Equal(days, request.PreviousTo.DayNumber - request.PreviousFrom.DayNumber + 1);
    }

    [Theory]
    [InlineData(DashboardPeriod.Today, 1)]
    [InlineData(DashboardPeriod.Week, 7)]
    [InlineData(DashboardPeriod.TwoWeeks, 14)]
    [InlineData(DashboardPeriod.Month, 30)]
    public async Task The_stock_value_series_has_a_point_for_every_day_of_the_window(DashboardPeriod period, int days)
    {
        var summary = await Queries().GetAsync(Filter(period: period), TestCancellation.Token);

        var series = Assert.Single(summary.Series, s => s.Key == "stockValuePerDay");
        Assert.True(series.IsCost);
        Assert.Equal("AZN", series.Unit);
        Assert.Equal(days, series.Points.Count);
        Assert.Equal(Today.AddDays(-(days - 1)), series.Points[0].Date);
        Assert.Equal(Today, series.Points[^1].Date);

        // Today's end-of-day value is the balance itself.
        Assert.Equal(1234.5678m, series.Points[^1].Value);
    }

    [Fact]
    public async Task The_stock_value_is_rebuilt_backwards_from_the_ledger_and_trends_against_the_day_before_the_window()
    {
        _inventory.Dashboard = _inventory.Dashboard with
        {
            StockValueTotal = 1000m,
            InboundValuePerDay = [Day(1, 300m), Day(0, 50m)],
            OutboundValuePerDay = [Day(1, 100m), Day(6, 20m)],
            LedgerValueAfterPeriod = 0m,
        };

        var summary = await Queries().GetAsync(Filter(period: DashboardPeriod.Week), TestCancellation.Token);

        var points = Assert.Single(summary.Series, s => s.Key == "stockValuePerDay").Points;
        Assert.Equal(
            [750m, 750m, 750m, 750m, 750m, 950m, 1000m],
            points.Select(p => p.Value));

        // End of the day before the window: 750 plus the 20 that left on its first day.
        var kpi = Assert.Single(summary.Kpis, k => k.Key == "stockValueTotal");
        Assert.Equal(1000m, kpi.Value);
        Assert.Equal(Math.Round((1000m - 770m) * 100m / 770m, 4, MidpointRounding.AwayFromZero), kpi.TrendPct);
    }

    [Fact]
    public async Task A_stock_value_that_started_the_window_at_zero_has_no_trend()
    {
        _inventory.Dashboard = _inventory.Dashboard with
        {
            StockValueTotal = 400m,
            InboundValuePerDay = [Day(6, 400m)],
            OutboundValuePerDay = [],
        };

        var summary = await Queries().GetAsync(Filter(period: DashboardPeriod.Week), TestCancellation.Token);

        var kpi = Assert.Single(summary.Kpis, k => k.Key == "stockValueTotal");
        Assert.Null(kpi.TrendPct);
        Assert.All(Assert.Single(summary.Series, s => s.Key == "stockValuePerDay").Points, p => Assert.Equal(400m, p.Value));
    }

    [Fact]
    public async Task The_value_series_are_served_to_a_cost_principal()
    {
        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        var inbound = Assert.Single(summary.Series, s => s.Key == "inboundValuePerDay");
        var outbound = Assert.Single(summary.Series, s => s.Key == "outboundValuePerDay");
        Assert.True(inbound.IsCost);
        Assert.True(outbound.IsCost);
        Assert.Equal("AZN", inbound.Unit);
        Assert.Equal(300m, Assert.Single(inbound.Points).Value);

        // Outbound travels as a positive number.
        Assert.Equal(100m, Assert.Single(outbound.Points).Value);
    }

    [Fact]
    public async Task Without_the_cost_permission_the_value_series_and_the_category_breakdown_are_absent()
    {
        var summary = await Queries().GetAsync(Filter(includeCost: false), TestCancellation.Token);

        Assert.DoesNotContain(summary.Series, s => s.Key is "inboundValuePerDay" or "outboundValuePerDay" or "stockValuePerDay");
        Assert.Null(summary.CategoryValues);

        // Absent, not merely empty: the catalogue is not even asked.
        Assert.Equal(0, _references.Calls);
    }

    [Fact]
    public async Task Stock_value_is_grouped_by_the_products_own_category_and_an_unknown_product_keeps_its_value()
    {
        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        Assert.NotNull(summary.CategoryValues);
        Assert.Collection(
            summary.CategoryValues,
            c =>
            {
                Assert.Equal(10u, c.CategoryId);
                Assert.Equal(1000m, c.Value);
            },
            c =>
            {
                Assert.Null(c.CategoryId);
                Assert.Equal(234.5678m, c.Value);
            });

        // The categories add up to the stock value KPI.
        Assert.Equal(
            Assert.Single(summary.Kpis, k => k.Key == "stockValueTotal").Value,
            summary.CategoryValues.Sum(c => c.Value));
    }

    [Fact]
    public async Task Products_of_one_category_are_summed_and_a_category_worth_nothing_is_not_sent()
    {
        var references = new MapReferenceLoader(
            MapReferenceLoader.Product(1, categoryId: 10),
            MapReferenceLoader.Product(2, categoryId: 10),
            MapReferenceLoader.Product(3, categoryId: 30),
            MapReferenceLoader.Product(4, categoryId: 30));
        _inventory.Dashboard = _inventory.Dashboard with
        {
            StockValueByProduct =
            [
                new DashboardProductValue(1, 100m),
                new DashboardProductValue(2, 50m),
                new DashboardProductValue(3, 40m),
                new DashboardProductValue(4, -40m),
            ],
        };

        var summary = await new DashboardQueries(_inventory, new StubOutboxBacklog(0), references, _locations, FixedClock.At())
            .GetAsync(Filter(), TestCancellation.Token);

        var category = Assert.Single(summary.CategoryValues!);
        Assert.Equal(10u, category.CategoryId);
        Assert.Equal(150m, category.Value);
        Assert.Equal([1u, 2u, 3u, 4u], references.RequestedProductIds);
    }

    [Fact]
    public async Task On_the_wire_an_uncategorised_value_says_null_and_a_withheld_breakdown_is_absent()
    {
        // The host's options (WmsCommonServiceCollectionExtensions): decimals as strings, nulls dropped.
        var options = new JsonSerializerOptions(JsonSerializerDefaults.Web) { DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull };
        options.Converters.Add(new DecimalStringJsonConverter());

        var withCost = JsonSerializer.SerializeToElement(await Queries().GetAsync(Filter(), TestCancellation.Token), options);
        var withoutCost = JsonSerializer.SerializeToElement(await Queries().GetAsync(Filter(includeCost: false), TestCancellation.Token), options);

        var uncategorised = withCost.GetProperty("categoryValues")[1];
        Assert.Equal(JsonValueKind.Null, uncategorised.GetProperty("categoryId").ValueKind);
        Assert.Equal("234.5678", uncategorised.GetProperty("value").GetString());
        Assert.False(withoutCost.TryGetProperty("categoryValues", out _));
    }

    [Fact]
    public async Task A_cost_principal_with_no_stock_gets_an_empty_breakdown_rather_than_none()
    {
        _inventory.Dashboard = _inventory.Dashboard with { StockValueByProduct = [] };

        var summary = await Queries().GetAsync(Filter(), TestCancellation.Token);

        Assert.NotNull(summary.CategoryValues);
        Assert.Empty(summary.CategoryValues);
    }

    [Fact]
    public async Task The_virtual_counter_accounts_are_left_out_of_the_stock_figures()
    {
        await Queries().GetAsync(Filter(), TestCancellation.Token);

        Assert.Equal(LocationTypes.Virtual.Order(StringComparer.Ordinal), _locations.RequestedTypes.Order(StringComparer.Ordinal));
        Assert.Equal(
            StubLocationCatalog.Default.Values.Order(),
            _inventory.LastDashboardRequest!.ExcludedLocationIds!.Order());
    }

    [Fact]
    public async Task A_tenant_without_a_virtual_location_of_some_type_still_gets_its_dashboard()
    {
        var locations = new StubLocationCatalog(new Dictionary<string, uint>(StringComparer.Ordinal) { [LocationTypes.VSupplier] = 900 });

        await new DashboardQueries(_inventory, new StubOutboxBacklog(0), _references, locations, FixedClock.At())
            .GetAsync(Filter(), TestCancellation.Token);

        Assert.Equal([900u], _inventory.LastDashboardRequest!.ExcludedLocationIds);
    }

    [Fact]
    public async Task Batch_expiries_ahead_are_served_to_everybody_and_add_up_to_the_expiring_batches_kpi()
    {
        var summary = await Queries().GetAsync(Filter(includeCost: false), TestCancellation.Token);

        var series = Assert.Single(summary.Series, s => s.Key == "batchExpiriesAhead");
        Assert.False(series.IsCost);
        Assert.Equal("batches", series.Unit);
        Assert.All(series.Points, p => Assert.True(p.Date >= Today));
        Assert.Equal(
            Assert.Single(summary.Kpis, k => k.Key == "expiringBatches").Value,
            series.Points.Sum(p => p.Value));
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
        Assert.Contains(summary.Series, s => s.Key == "inboundValuePerDay" && s.IsCost);
        Assert.Contains(summary.Series, s => s.Key == "outboundValuePerDay" && s.IsCost);
        Assert.Contains(summary.Series, s => s.Key == "stockValuePerDay" && s.IsCost);
        Assert.Contains(summary.Series, s => s.Key == "batchExpiriesAhead" && !s.IsCost);
        Assert.All(summary.Series, s => Assert.NotEmpty(s.Points));
    }
}
