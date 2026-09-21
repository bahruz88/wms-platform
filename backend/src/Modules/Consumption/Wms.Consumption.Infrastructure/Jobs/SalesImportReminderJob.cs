using Hangfire;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Consumption.Application.Abstractions;

namespace Wms.Consumption.Infrastructure.Jobs;

/// <summary>
/// Daily 11:00 (branch-operations.md §8): reminds a branch that yesterday's sales are still missing. Without
/// the sales there is no theoretical consumption, so the branch balance silently drifts — the reminder is the
/// cheapest guard against that.
/// </summary>
public sealed class SalesImportReminderJob(
    IServiceScopeFactory scopeFactory,
    ITenantScanner tenants,
    IClock clock,
    ILogger<SalesImportReminderJob> logger)
{
    public const string JobId = "consumption-sales-import-reminder";
    public const string Cron = "0 11 * * *";

    [DisableConcurrentExecution(timeoutInSeconds: 300)]
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        var businessDate = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime).AddDays(-1);
        var tenantIds = await tenants.GetActiveTenantsAsync(cancellationToken).ConfigureAwait(false);

        foreach (var tenantId in tenantIds)
        {
            using var scope = scopeFactory.CreateScope();
            scope.ServiceProvider.GetRequiredService<ITenantContextInitializer>().Initialize(tenantId);
            var imports = scope.ServiceProvider.GetRequiredService<ISalesImportRepository>();

            var missing = await imports.LocationsMissingImportAsync(tenantId, businessDate, cancellationToken).ConfigureAwait(false);
            if (missing.Count == 0)
            {
                logger.LogInformation("SalesImportReminder: tenant {TenantId} reported every branch for {BusinessDate}", tenantId, businessDate);
                continue;
            }

            logger.LogWarning(
                "SalesImportReminder: tenant {TenantId}: {Count} branch(es) have no sales for {BusinessDate}: {Locations}",
                tenantId, missing.Count, businessDate, string.Join(", ", missing));
        }
    }
}
