using Dapper;
using Hangfire;
using Wms.Common.Application.Abstractions;
using Wms.Common.Contracts.Events;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Jobs;

/// <summary>
/// Spec §15 (daily 06:00): per tenant, marks batches past their expiry date as EXPIRED (removing them from allocation)
/// and raises <see cref="BatchExpired"/> / <see cref="BatchNearExpiry"/> through the outbox.
/// </summary>
public sealed class ExpiryScannerJob(InventoryDbContext rootDb, IServiceScopeFactory scopeFactory, IClock clock, ILogger<ExpiryScannerJob> logger)
{
    public const string JobId = "inventory-expiry-scanner";
    public const string Cron = "0 6 * * *";

    [DisableConcurrentExecution(timeoutInSeconds: 600)]
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        const string tenantsSql = "SELECT DISTINCT tenant_id FROM inv_batch WHERE expiry_date IS NOT NULL AND status <> 'EXPIRED'";
        var connection = rootDb.Database.GetDbConnection();
        await rootDb.Database.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        List<uint> tenants;
        try
        {
            tenants = (await connection.QueryAsync<uint>(new CommandDefinition(tenantsSql, cancellationToken: cancellationToken)).ConfigureAwait(false)).ToList();
        }
        finally
        {
            await rootDb.Database.CloseConnectionAsync().ConfigureAwait(false);
        }

        foreach (var tenantId in tenants)
        {
            await ScanTenantAsync(tenantId, cancellationToken).ConfigureAwait(false);
        }
    }

    private async Task ScanTenantAsync(uint tenantId, CancellationToken cancellationToken)
    {
        // A dedicated scope per tenant so the query filter and audit stamping apply as for a normal request.
        using var scope = scopeFactory.CreateScope();
        scope.ServiceProvider.GetRequiredService<ITenantContextInitializer>().Initialize(tenantId);
        var db = scope.ServiceProvider.GetRequiredService<InventoryDbContext>();
        var settings = scope.ServiceProvider.GetRequiredService<IInventorySettings>();

        var warningDays = await settings.GetIntAsync(InventorySettingKeys.ExpiryWarningDays, cancellationToken).ConfigureAwait(false);
        var criticalDays = await settings.GetIntAsync(InventorySettingKeys.ExpiryCriticalDays, cancellationToken).ConfigureAwait(false);
        var now = clock.UtcNow;
        var today = DateOnly.FromDateTime(now.UtcDateTime);
        var horizon = today.AddDays(warningDays);

        var batches = await db.Batches
            .Where(b => b.ExpiryDate != null && b.ExpiryDate <= horizon && b.Status != BatchStatus.Expired)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        if (batches.Count == 0)
        {
            return;
        }

        var batchIds = batches.Select(b => b.Id).ToArray();
        var onHand = await db.Balances.AsNoTracking()
            .Where(bal => batchIds.Contains(bal.BatchId))
            .GroupBy(bal => bal.BatchId)
            .Select(g => new { BatchId = g.Key, Qty = g.Sum(x => x.QtyOnHand) })
            .ToDictionaryAsync(x => x.BatchId, x => x.Qty, cancellationToken)
            .ConfigureAwait(false);

        var expired = 0;
        foreach (var batch in batches)
        {
            var qty = onHand.GetValueOrDefault(batch.Id);
            var expiry = batch.ExpiryDate!.Value;
            if (batch.IsExpiredOn(today))
            {
                if (batch.MarkExpired().IsSuccess)
                {
                    expired++;
                    db.Enqueue(new BatchExpired(tenantId, now, batch.Id, batch.ProductId, batch.BatchNo, expiry, qty));
                }

                continue;
            }

            if (qty <= 0m)
            {
                continue;
            }

            var daysLeft = expiry.DayNumber - today.DayNumber;
            db.Enqueue(new BatchNearExpiry(tenantId, now, batch.Id, batch.ProductId, batch.BatchNo, expiry, daysLeft, daysLeft <= criticalDays, qty));
        }

        await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        logger.LogInformation("ExpiryScanner: tenant {TenantId}: {Scanned} batches scanned, {Expired} marked EXPIRED", tenantId, batches.Count, expired);
    }
}
