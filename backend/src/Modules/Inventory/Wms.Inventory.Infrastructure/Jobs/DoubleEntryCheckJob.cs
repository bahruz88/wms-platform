using Dapper;
using Hangfire;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Jobs;

/// <summary>Spec §15 / ADR-003: <c>SUM(qty_base) GROUP BY group_id &lt;&gt; 0</c> must be empty; anything else is a transaction bug → critical alert.</summary>
public sealed class DoubleEntryCheckJob(InventoryDbContext db, ILogger<DoubleEntryCheckJob> logger)
{
    public const string JobId = "inventory-double-entry-check";
    public const string Cron = "10 2 * * *";

    [DisableConcurrentExecution(timeoutInSeconds: 300)]
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT group_id AS GroupId, SUM(qty_base) AS Total
            FROM inv_movement
            GROUP BY group_id
            HAVING SUM(qty_base) <> 0
            """;

        var connection = db.Database.GetDbConnection();
        await db.Database.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            var violations = (await connection.QueryAsync<Violation>(new CommandDefinition(sql, cancellationToken: cancellationToken)).ConfigureAwait(false)).ToList();
            if (violations.Count == 0)
            {
                logger.LogInformation("DoubleEntryCheck: all movement groups balance to zero");
                return;
            }

            foreach (var violation in violations)
            {
                logger.LogCritical("DoubleEntryCheck: movement group {GroupId} sums to {Total} (expected 0)", violation.GroupId, violation.Total);
            }
        }
        finally
        {
            await db.Database.CloseConnectionAsync().ConfigureAwait(false);
        }
    }

    private sealed class Violation
    {
        public long GroupId { get; set; }

        public decimal Total { get; set; }
    }
}
