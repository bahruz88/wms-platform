using Wms.Common.Infrastructure.Persistence;
using Wms.Integration.Application.Abstractions;
using Wms.Integration.Infrastructure.Persistence;
using Wms.Integration.Infrastructure.Queries;

namespace Wms.Integration.Infrastructure;

public static class IntegrationInfrastructureExtensions
{
    public static IServiceCollection AddIntegrationInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddIntegrationPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddIntegrationServices();
        return services;
    }

    public static IServiceCollection AddIntegrationPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<IntegrationDbContext>(connectionString, IntegrationDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddIntegrationServices(this IServiceCollection services)
    {
        services.AddScoped<IIntegrationQueries, IntegrationQueries>();
        return services;
    }
}
