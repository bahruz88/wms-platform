using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Infrastructure.Persistence;
using Wms.Documents.Infrastructure.Persistence;
using Wms.Identity.Infrastructure.Persistence;
using Wms.Integration.Infrastructure.Persistence;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Infrastructure.Persistence;
using Wms.Notification.Infrastructure.Persistence;
using Wms.Procurement.Infrastructure.Persistence;
using Wms.Reporting.Infrastructure.Persistence;

namespace Wms.Host.Migrator;

/// <summary>Applies <c>Database.MigrateAsync()</c> to every context in dependency order.</summary>
public sealed class MigrationRunner(IServiceProvider services, IConfiguration configuration, ILogger<MigrationRunner> logger)
{
    /// <summary>Common tables first (outbox/audit are referenced by every module context), then the modules.</summary>
    public static IReadOnlyList<Type> ContextTypes { get; } =
    [
        typeof(CommonDbContext),
        typeof(IdentityDbContext),
        typeof(MasterDataDbContext),
        typeof(InventoryDbContext),
        typeof(ConsumptionDbContext),
        typeof(ProcurementDbContext),
        typeof(DocumentsDbContext),
        typeof(NotificationDbContext),
        typeof(ReportingDbContext),
        typeof(IntegrationDbContext),
    ];

    public async Task<int> RunAsync(CancellationToken cancellationToken)
    {
        var failed = 0;
        foreach (var contextType in ContextTypes)
        {
            if (cancellationToken.IsCancellationRequested)
            {
                logger.LogWarning("Migration run cancelled before {Context}", contextType.Name);
                return 1;
            }

            using var scope = services.CreateScope();
            var context = (DbContext)scope.ServiceProvider.GetRequiredService(contextType);
            try
            {
                var pending = (await context.Database.GetPendingMigrationsAsync(cancellationToken).ConfigureAwait(false)).ToList();
                if (pending.Count == 0)
                {
                    logger.LogInformation("{Context}: already up to date", contextType.Name);
                    continue;
                }

                logger.LogInformation("{Context}: applying {Count} migration(s): {Migrations}", contextType.Name, pending.Count, string.Join(", ", pending));
                await context.Database.MigrateAsync(cancellationToken).ConfigureAwait(false);
                logger.LogInformation("{Context}: done", contextType.Name);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                failed++;
                logger.LogError(ex, "{Context}: migration failed", contextType.Name);
            }
        }

        if (failed > 0)
        {
            logger.LogError("Migration finished with {Failed} failing context(s)", failed);
            return 1;
        }

        logger.LogInformation("All {Count} contexts are migrated", ContextTypes.Count);

        // The hangfire_* tables are DDL too, so they belong to this job and not to the API host:
        // the runtime user (wms_app) has no CREATE privilege and spec §18.3 forbids startup migration.
        try
        {
            var connectionString = configuration.GetConnectionString(MigratorServices.ConnectionStringName)!;
            WmsJobsExtensions.EnsureJobStorageSchema(configuration, connectionString);
            logger.LogInformation("Hangfire job storage schema ({Prefix}*) is up to date", WmsJobsExtensions.TablePrefix);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogError(ex, "Hangfire job storage schema creation failed");
            return 1;
        }

        return 0;
    }
}
