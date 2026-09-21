using Wms.Common.Infrastructure.Modules;
using Wms.Common.Infrastructure.Persistence;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Contracts;
using Wms.Procurement.Infrastructure.Contracts;
using Wms.Procurement.Infrastructure.Persistence;
using Wms.Procurement.Infrastructure.Queries;

namespace Wms.Procurement.Infrastructure;

public static class ProcurementInfrastructureExtensions
{
    public static IServiceCollection AddProcurementInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddProcurementPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddProcurementServices();
        return services;
    }

    public static IServiceCollection AddProcurementPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<ProcurementDbContext>(connectionString, ProcurementDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddProcurementServices(this IServiceCollection services)
    {
        services.AddScoped<IProcurementQueries, ProcurementQueries>();
        services.AddScoped<IPurchaseOrderReader, PurchaseOrderReader>();
        return services;
    }

    public static IServiceCollection AddProcurementRemoteContracts(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddModuleHttpClient<IPurchaseOrderReader, HttpPurchaseOrderReader>(configuration, ProcurementRoutes.ModuleName);
        return services;
    }
}
