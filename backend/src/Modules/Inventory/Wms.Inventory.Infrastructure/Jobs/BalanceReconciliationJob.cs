using Dapper;
using Hangfire;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Jobs;

/// <summary>Spec §15 / ADR-004: <c>inv_balance.qty_on_hand</c> must equal <c>SUM(inv_movement.qty_base)</c> for every key; mismatch → critical alert.</summary>
public sealed class BalanceReconciliationJob(InventoryDbContext db, ILogger<BalanceReconciliationJob> logger)
{
    public const string JobId = "inventory-balance-reconciliation";
    public const string Cron = "0 2 * * *";

    [DisableConcurrentExecution(timeoutInSeconds: 600)]
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT b.tenant_id AS TenantId, b.product_id AS ProductId, b.location_id AS LocationId, b.batch_id AS BatchId,
                   b.qty_on_hand AS QtyOnHand, COALESCE(m.total, 0) AS LedgerQty
            FROM inv_balance b
            LEFT JOIN (
                SELECT tenant_id, product_id, location_id, COALESCE(batch_id, 0) AS batch_id, SUM(qty_base) AS total
                FROM inv_movement
                GROUP BY tenant_id, product_id, location_id, COALESCE(batch_id, 0)
            ) m ON m.tenant_id = b.tenant_id AND m.product_id = b.product_id
               AND m.location_id = b.location_id AND m.batch_id = b.batch_id
            WHERE b.qty_on_hand <> COALESCE(m.total, 0)
            """;

        var connection = db.Database.GetDbConnection();
        await db.Database.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            var mismatches = (await connection.QueryAsync<Mismatch>(new CommandDefinition(sql, cancellationToken: cancellationToken)).ConfigureAwait(false)).ToList();
            if (mismatches.Count == 0)
            {
                logger.LogInformation("BalanceReconciliation: every inv_balance row matches the ledger");
                return;
            }

            foreach (var m in mismatches)
            {
                logger.LogCritical(
                    "BalanceReconciliation: tenant {TenantId} product {ProductId} location {LocationId} batch {BatchId}: balance {QtyOnHand} vs ledger {LedgerQty}",
                    m.TenantId, m.ProductId, m.LocationId, m.BatchId, m.QtyOnHand, m.LedgerQty);
            }
        }
        finally
        {
            await db.Database.CloseConnectionAsync().ConfigureAwait(false);
        }
    }

    private sealed class Mismatch
    {
        public uint TenantId { get; set; }

        public uint ProductId { get; set; }

        public uint LocationId { get; set; }

        public long BatchId { get; set; }

        public decimal QtyOnHand { get; set; }

        public decimal LedgerQty { get; set; }
    }
}
