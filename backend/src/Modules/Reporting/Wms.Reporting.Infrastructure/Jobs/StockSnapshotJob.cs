using Hangfire;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Inventory.Contracts;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Domain.Entities;

namespace Wms.Reporting.Infrastructure.Jobs;

/// <summary>
/// Builds the end-of-day balance projection of <c>rpt_stock_snapshot</c> (spec §15).
///
/// <c>inv_balance</c> keeps no history — it is the current projection of the ledger (ADR-004), so
/// "what did we hold on the 14th" cannot be answered from it. This job freezes one row per
/// product/location each night; the reports that compare periods read those rows rather than
/// replaying a million ledger lines.
///
/// It runs just after midnight and labels the result with the day that has just ended, which is why
/// <see cref="StockSnapshot.SnapshotDate"/> and <see cref="StockSnapshot.BuiltAt"/> are separate: the
/// first is the business day, the second says when the row was actually written.
/// </summary>
public sealed class StockSnapshotJob(
    IServiceScopeFactory scopeFactory,
    IClock clock,
    ILogger<StockSnapshotJob> logger)
{
    public const string JobId = "reporting-stock-snapshot";

    /// <summary>00:10 UTC — after the day has closed, before the morning's first reports.</summary>
    public const string Cron = "10 0 * * *";

    /// <summary>One source call per tenant; the port caps a slice at 20 000 rows anyway.</summary>
    private const int PageSize = 5_000;

    [DisableConcurrentExecution(timeoutInSeconds: 1800)]
    public Task RunAsync(CancellationToken cancellationToken) =>
        RunForAsync(DateOnly.FromDateTime(clock.UtcNow.UtcDateTime).AddDays(-1), cancellationToken);

    /// <summary>Rebuilds a named day. Used by the nightly run and by hand when a night was missed.</summary>
    public async Task RunForAsync(DateOnly snapshotDate, CancellationToken cancellationToken)
    {
        IReadOnlyList<uint> tenantIds;
        using (var scope = scopeFactory.CreateScope())
        {
            tenantIds = await scope.ServiceProvider
                .GetRequiredService<IReportingTenantScanner>()
                .GetActiveTenantsAsync(cancellationToken)
                .ConfigureAwait(false);
        }

        foreach (var tenantId in tenantIds)
        {
            try
            {
                var written = await RunTenantAsync(tenantId, snapshotDate, cancellationToken).ConfigureAwait(false);
                logger.LogInformation(
                    "Stock snapshot for {SnapshotDate} rebuilt for tenant {TenantId}: {Rows} rows.",
                    snapshotDate, tenantId, written);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                // One tenant's failure must not cost the others their snapshot.
                logger.LogError(ex, "Stock snapshot for {SnapshotDate} failed for tenant {TenantId}.", snapshotDate, tenantId);
            }
        }
    }

    private async Task<int> RunTenantAsync(uint tenantId, DateOnly snapshotDate, CancellationToken cancellationToken)
    {
        using var scope = scopeFactory.CreateScope();
        scope.ServiceProvider.GetRequiredService<ITenantContextInitializer>().Initialize(tenantId);

        var inventory = scope.ServiceProvider.GetRequiredService<IInventoryReportingSource>();
        var writer = scope.ServiceProvider.GetRequiredService<IStockSnapshotWriter>();
        var builtAt = clock.UtcNow;

        var rows = new List<StockSnapshot>();
        var skip = 0;
        while (true)
        {
            var page = await inventory
                .GetStockBalancesAsync(
                    new StockBalanceReportRequest(
                        ReportingScope.Unrestricted,
                        LocationId: null,
                        ProductId: null,
                        IncludeZero: false,
                        new ReportSlice(skip, PageSize)),
                    cancellationToken)
                .ConfigureAwait(false);

            if (page.Rows.Count == 0)
            {
                break;
            }

            rows.AddRange(page.Rows.Select(r => StockSnapshot.Create(
                tenantId, snapshotDate, r.ProductId, r.LocationId, r.QtyOnHand, r.AvgUnitCost, builtAt)));

            skip += page.Rows.Count;
            if (skip >= page.Total)
            {
                break;
            }
        }

        return await writer.ReplaceDayAsync(snapshotDate, rows, cancellationToken).ConfigureAwait(false);
    }
}
