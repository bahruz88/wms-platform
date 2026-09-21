using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
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

        // Module contexts need a tenant/user/clock; migrations never read them, so the design-time stubs are enough.
        services.AddSingleton(DesignTimeContext.Tenant);
        services.AddSingleton(DesignTimeContext.User);
        services.AddSingleton(DesignTimeContext.Clock);

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
