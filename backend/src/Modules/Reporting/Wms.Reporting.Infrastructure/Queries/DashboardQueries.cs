using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Infrastructure.Reports;

namespace Wms.Reporting.Infrastructure.Queries;

/// <summary>
/// Assembles <c>DashboardSummary</c> (reporting.v1.yaml). Three rules govern every figure on it:
/// <list type="bullet">
///   <item>money is <b>absent</b> — not null, not zero — without <c>master.product.view_cost</c> (spec §16);</item>
///   <item>everything is scoped by <c>iam_user_location</c>, so a branch principal's dashboard describes their
///   branch and not the company (README §8.17);</item>
///   <item>stock means physical stock: the virtual counter-accounts (ADR-003) are left out of every balance and
///   ledger figure, so the company dashboard is the sum of the branch dashboards.</item>
/// </list>
/// The numbers come from <c>Wms.Inventory.Contracts</c>, the virtual locations and product categories from
/// <c>Wms.MasterData.Contracts</c>; <c>common_outbox</c> is shared platform infrastructure that every module
/// context maps, not another module's table.
/// </summary>
/// <remarks>
/// The third rule is not cosmetic. Every document is double-entry in value as well as in quantity, and the
/// counter-accounts carry balances of their own: <c>V_SUPPLIER</c> runs a large negative quantity. Left in, an
/// unrestricted principal's stock value netted the supplier account against the warehouses, the rebuilt
/// stock-value line stayed flat because every day's ledger summed to zero, and each receipt appeared as an
/// outbound movement of the supplier account. Wasted batches sitting on <c>V_WASTE</c> also counted as expired.
/// </remarks>
public sealed class DashboardQueries(
    IInventoryReportingSource inventory,
    IOutboxBacklogReader outbox,
    IReportReferenceLoader references,
    ILocationCatalog locations,
    IClock clock) : IDashboardQueries
{
    public async Task<DashboardSummaryDto> GetAsync(DashboardFilter filter, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);

        var now = clock.UtcNow;
        var today = DateOnly.FromDateTime(now.UtcDateTime);
        var (from, to, previousFrom, previousTo) = Window(today, filter.Period);

        var virtualLocations = await VirtualLocationIdsAsync(cancellationToken).ConfigureAwait(false);
        var metrics = await inventory
            .GetDashboardAsync(
                new InventoryDashboardRequest(
                    Scope(filter.VisibleLocations),
                    filter.LocationId,
                    from,
                    to,
                    previousFrom,
                    previousTo,
                    virtualLocations),
                cancellationToken)
            .ConfigureAwait(false);

        // The KPI trend and the series come from the same walk, so the trend's base is the point left of the chart.
        var stockValue = StockValueHistory.Rebuild(
            metrics.StockValueTotal, from, to, metrics.InboundValuePerDay, metrics.OutboundValuePerDay, metrics.LedgerValueAfterPeriod);

        var kpis = new List<KpiDto>();
        if (filter.IncludeCost)
        {
            kpis.Add(new KpiDto(
                "stockValueTotal",
                "Anbar dəyəri",
                metrics.StockValueTotal,
                "AZN",
                Trend(metrics.StockValueTotal, stockValue.ValueBeforeWindow),
                KpiSeverity.Normal,
                "/inventory/balances",
                IsCost: true));
        }

        kpis.Add(new KpiDto(
            "balanceRows",
            "Qalıq sətirləri",
            metrics.BalanceRowCount,
            "rows",
            null,
            KpiSeverity.Normal,
            "/inventory/balances",
            IsCost: false));

        var pendingApprovals = metrics.PendingWasteApprovals + metrics.CountsAwaitingReview;
        kpis.Add(new KpiDto(
            "pendingApprovals",
            "Təsdiq gözləyən sənədlər",
            pendingApprovals,
            null,
            null,
            pendingApprovals > 0 ? KpiSeverity.Warning : KpiSeverity.Normal,
            "/inventory/waste",
            IsCost: false));

        kpis.Add(new KpiDto(
            "expiringBatches",
            "Vaxtı yaxınlaşan partiyalar",
            metrics.ExpiringBatchCount + metrics.CriticalBatchCount,
            "batches",
            null,
            metrics.CriticalBatchCount > 0 ? KpiSeverity.Critical
                : metrics.ExpiringBatchCount > 0 ? KpiSeverity.Warning : KpiSeverity.Normal,
            "/inventory/batches",
            IsCost: false));

        kpis.Add(new KpiDto(
            "openStockRequests",
            "Açıq tələblər",
            metrics.OpenStockRequests,
            null,
            null,
            KpiSeverity.Normal,
            "/inventory/stock-requests",
            IsCost: false));

        kpis.Add(new KpiDto(
            "receiptsInPeriod",
            "Dövr üzrə qəbullar",
            metrics.ReceiptCount,
            null,
            Trend(metrics.ReceiptCount, metrics.ReceiptCountPrevious),
            KpiSeverity.Normal,
            "/inventory/goods-receipts",
            IsCost: false));

        if (filter.IncludeCost)
        {
            kpis.Add(new KpiDto(
                "wasteValuePeriod",
                "Dövr üzrə tullantı dəyəri",
                metrics.WasteValue,
                "AZN",
                Trend(metrics.WasteValue, metrics.WasteValuePrevious),
                metrics.WasteValue > 0m ? KpiSeverity.Warning : KpiSeverity.Normal,
                "/inventory/waste",
                IsCost: true));
        }

        var alerts = new List<DashboardAlertDto>();
        if (metrics.CriticalBatchCount > 0)
        {
            alerts.Add(new DashboardAlertDto(
                "BATCH_EXPIRING",
                AlertSeverity.Critical,
                metrics.CriticalBatchCount,
                $"{metrics.CriticalBatchCount} partiya {metrics.ExpiryCriticalDays} gün ərzində bitir",
                "/inventory/batches"));
        }

        if (metrics.ExpiringBatchCount > 0)
        {
            alerts.Add(new DashboardAlertDto(
                "BATCH_EXPIRING",
                AlertSeverity.Warning,
                metrics.ExpiringBatchCount,
                $"{metrics.ExpiringBatchCount} partiya {metrics.ExpiryWarningDays} gün ərzində bitir",
                "/inventory/batches"));
        }

        if (metrics.ExpiredBatchCount > 0)
        {
            alerts.Add(new DashboardAlertDto(
                "BATCH_EXPIRED",
                AlertSeverity.Critical,
                metrics.ExpiredBatchCount,
                $"{metrics.ExpiredBatchCount} partiyanın vaxtı keçib",
                "/inventory/batches"));
        }

        if (pendingApprovals > 0)
        {
            alerts.Add(new DashboardAlertDto(
                "PENDING_APPROVAL",
                AlertSeverity.Info,
                pendingApprovals,
                $"{pendingApprovals} sənəd təsdiq gözləyir",
                "/inventory/waste"));
        }

        var series = new List<DashboardSeriesDto>
        {
            new("receiptsPerDay", "Gündəlik qəbul sayı", null, false, Points(metrics.ReceiptsPerDay)),
            new("issuesPerDay", "Gündəlik məxaric sayı", null, false, Points(metrics.IssuesPerDay)),
        };

        IReadOnlyList<DashboardCategoryValueDto>? categoryValues = null;
        if (filter.IncludeCost)
        {
            series.Add(new DashboardSeriesDto("wasteValuePerDay", "Gündəlik tullantı dəyəri", "AZN", true, Points(metrics.WasteValuePerDay)));
            series.Add(new DashboardSeriesDto("inboundValuePerDay", "Gündəlik giriş dəyəri", "AZN", true, Points(metrics.InboundValuePerDay)));
            series.Add(new DashboardSeriesDto("outboundValuePerDay", "Gündəlik çıxış dəyəri", "AZN", true, Points(metrics.OutboundValuePerDay)));
            series.Add(new DashboardSeriesDto("stockValuePerDay", "Gün sonuna anbar dəyəri", "AZN", true, stockValue.Points));
            categoryValues = await CategoryValuesAsync(metrics.StockValueByProduct, cancellationToken).ConfigureAwait(false);
        }

        // Future dates, whatever the period: the same rows as the expiringBatches KPI, spread over the day they expire.
        series.Add(new DashboardSeriesDto(
            "batchExpiriesAhead", "Qarşıdakı günlərdə bitən partiyalar", "batches", false, Points(metrics.BatchExpiriesAhead)));

        SystemHealthDto? health = null;
        if (filter.IncludeSystemHealth)
        {
            var pending = await outbox.CountPendingAsync(cancellationToken).ConfigureAwait(false);

            // BalanceReconciliationJob and DoubleEntryCheckJob write their verdict to the log only (README §8.8),
            // so there is nothing to read back and the dashboard reports null rather than inventing a green tick.
            health = new SystemHealthDto(null, null, null, null, pending);
        }

        return new DashboardSummaryDto(now, filter.LocationId, kpis, alerts, series, health, categoryValues);
    }

    /// <summary>
    /// The tenant's virtual locations, one per type (<see cref="LocationTypes.Virtual"/>). Six lookups rather than
    /// one because that is the catalogue contract there is; each is a single-row read by type.
    /// </summary>
    private async Task<IReadOnlyList<uint>> VirtualLocationIdsAsync(CancellationToken cancellationToken)
    {
        var ids = new List<uint>(LocationTypes.Virtual.Count);
        foreach (var locationType in LocationTypes.Virtual)
        {
            var location = await locations.GetVirtualAsync(locationType, cancellationToken).ConfigureAwait(false);
            if (location is not null)
            {
                ids.Add(location.Id);
            }
        }

        return ids;
    }

    /// <summary>
    /// Current stock value per product category. The grouping happens here and not in SQL because Reporting may
    /// not join <c>master_product</c> (ADR-001); the catalogue lookup is chunked by the reference loader. A product
    /// the catalogue no longer returns keeps its value under a <c>null</c> category instead of vanishing, so the
    /// categories always add up to the stock value KPI.
    /// </summary>
    private async Task<IReadOnlyList<DashboardCategoryValueDto>> CategoryValuesAsync(
        IReadOnlyList<DashboardProductValue> productValues,
        CancellationToken cancellationToken)
    {
        if (productValues.Count == 0)
        {
            return [];
        }

        var reference = await references
            .LoadAsync(productValues.Select(p => p.ProductId), [], [], cancellationToken)
            .ConfigureAwait(false);

        return
        [
            .. productValues
                .GroupBy(p => reference.Product(p.ProductId)?.CategoryId)
                .Select(g => new DashboardCategoryValueDto(g.Key, g.Sum(p => p.Value)))
                .Where(c => c.Value != 0m)
                .OrderByDescending(c => c.Value),
        ];
    }

    private static IReadOnlyList<DashboardSeriesPointDto> Points(IReadOnlyList<DashboardDayPoint> points) =>
        [.. points.Select(p => new DashboardSeriesPointDto(p.Date, p.Value))];

    private static ReportingScope Scope(LocationScope scope) =>
        scope.IsRestricted ? ReportingScope.RestrictedTo(scope.VisibleIds) : ReportingScope.Unrestricted;

    private static decimal? Trend(decimal current, decimal previous) =>
        previous == 0m ? null : Math.Round((current - previous) * 100m / previous, 4, MidpointRounding.AwayFromZero);

    /// <summary>Series and trend window of <c>period</c>: the current stretch and the equally long one before it.</summary>
    private static (DateOnly From, DateOnly To, DateOnly PreviousFrom, DateOnly PreviousTo) Window(DateOnly today, DashboardPeriod period)
    {
        var days = period switch
        {
            DashboardPeriod.Today => 1,
            DashboardPeriod.TwoWeeks => 14,
            DashboardPeriod.Month => 30,
            _ => 7,
        };

        var from = today.AddDays(-(days - 1));
        return (from, today, from.AddDays(-days), from.AddDays(-1));
    }
}
