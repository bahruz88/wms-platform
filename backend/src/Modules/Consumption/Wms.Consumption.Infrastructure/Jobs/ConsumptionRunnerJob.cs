using Hangfire;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Commands.Runs;

namespace Wms.Consumption.Infrastructure.Jobs;

/// <summary>
/// Daily 03:00 (branch-operations.md §8): calculates and posts the previous business day for every branch that
/// submitted its sales. It runs AFTER the 02:00 balance reconciliation and the 02:10 double-entry self-check so
/// consumption is never written on top of a balance that is already known to be inconsistent.
/// A frozen location simply fails with LOCATION_FROZEN and is retried on the next run (invariant 7).
/// </summary>
public sealed class ConsumptionRunnerJob(
    IServiceScopeFactory scopeFactory,
    ITenantScanner tenants,
    IClock clock,
    ILogger<ConsumptionRunnerJob> logger)
{
    public const string JobId = "consumption-runner";

    /// <summary>03:00 UTC — after inventory-balance-reconciliation (02:00) and inventory-double-entry-check (02:10).</summary>
    public const string Cron = "0 3 * * *";

    [DisableConcurrentExecution(timeoutInSeconds: 900)]
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        var businessDate = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime).AddDays(-1);
        var tenantIds = await tenants.GetActiveTenantsAsync(cancellationToken).ConfigureAwait(false);

        foreach (var tenantId in tenantIds)
        {
            await RunTenantAsync(tenantId, businessDate, cancellationToken).ConfigureAwait(false);
        }
    }

    private async Task RunTenantAsync(uint tenantId, DateOnly businessDate, CancellationToken cancellationToken)
    {
        // A dedicated scope per tenant so the query filters and audit stamping behave exactly as in a request.
        using var scope = scopeFactory.CreateScope();
        scope.ServiceProvider.GetRequiredService<ITenantContextInitializer>().Initialize(tenantId);

        var runs = scope.ServiceProvider.GetRequiredService<IConsumptionRunRepository>();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        var pending = await runs.PendingImportIdsAsync(tenantId, businessDate, cancellationToken).ConfigureAwait(false);
        if (pending.Count == 0)
        {
            logger.LogInformation("ConsumptionRunner: tenant {TenantId} has nothing to calculate for {BusinessDate}", tenantId, businessDate);
            return;
        }

        var posted = 0;
        foreach (var importId in pending)
        {
            var result = await dispatcher
                .SendAsync(new CreateConsumptionRunCommand(importId, PostImmediately: true, Guid.NewGuid()), cancellationToken)
                .ConfigureAwait(false);

            if (result.IsFailure)
            {
                logger.LogError(
                    "ConsumptionRunner: tenant {TenantId} import {ImportId} failed with {Code}: {Message}",
                    tenantId, importId, result.Error.Code, result.Error.Message);
                continue;
            }

            posted++;
            if (result.Value.ShortfallCount > 0)
            {
                logger.LogWarning(
                    "ConsumptionRunner: {DocNo} posted with {ShortfallCount} shortfall line(s) — an unrecorded receipt is the usual cause",
                    result.Value.DocNo, result.Value.ShortfallCount);
            }
        }

        logger.LogInformation(
            "ConsumptionRunner: tenant {TenantId}, {BusinessDate}: {Posted}/{Total} document(s) posted",
            tenantId, businessDate, posted, pending.Count);
    }
}
