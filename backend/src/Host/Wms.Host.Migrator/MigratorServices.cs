using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Infrastructure;
using Wms.Documents.Infrastructure;
using Wms.Identity.Infrastructure;
using Wms.Integration.Infrastructure;
using Wms.Inventory.Infrastructure;
using Wms.MasterData.Infrastructure;
using Wms.Notification.Infrastructure;
using Wms.Procurement.Infrastructure;
using Wms.Reporting.Infrastructure;

namespace Wms.Host.Migrator;

/// <summary>
/// Registers every module DbContext against <c>ConnectionStrings:WmsMigrator</c> — the privileged DB user that may
/// run DDL, unlike the runtime <c>wms_app</c> user (spec §16).
/// </summary>
public static class MigratorServices
{
    public const string ConnectionStringName = WmsMySql.MigratorConnectionStringName;

    public static IServiceCollection Register(IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        var connectionString = configuration.GetConnectionString(ConnectionStringName)
            ?? throw new InvalidOperationException($"ConnectionStrings:{ConnectionStringName} is required by the migrator.");

        services.AddSingleton(configuration);
        services.AddDbContext<CommonDbContext>(options => options.UseWmsMySql(connectionString, CommonDbContext.MigrationsHistoryTable));

        // Migrations never read the tenant/user/clock, but --seed does: the design-time stub reports
        // HasTenant = false, which would make every global query filter match tenant_id = 0 and hide the rows the
        // seeder reads back for its idempotency checks. One real context serves both jobs.
        var seedContext = new SeedContext(
            configuration.GetValue("tenantId", SeedContext.DefaultTenantId),
            configuration.GetValue("seedUserId", SeedContext.DefaultUserId));
        services.AddSingleton(seedContext);
        services.AddSingleton<ITenantContext>(seedContext);
        services.AddSingleton<ICurrentUser>(seedContext);
        services.AddSingleton<IClock>(seedContext);

        services.AddIdentityPersistence(connectionString);
        services.AddMasterDataPersistence(connectionString);
        services.AddInventoryPersistence(connectionString);
        services.AddConsumptionPersistence(connectionString);
        services.AddProcurementPersistence(connectionString);
        services.AddDocumentsPersistence(connectionString);
        services.AddNotificationPersistence(connectionString);
        services.AddReportingPersistence(connectionString);
        services.AddIntegrationPersistence(connectionString);

        return services;
    }
}
