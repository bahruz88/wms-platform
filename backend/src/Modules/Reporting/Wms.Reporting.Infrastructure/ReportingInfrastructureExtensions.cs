using Wms.Common.Infrastructure.Persistence;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Infrastructure.Persistence;
using Wms.Reporting.Infrastructure.Queries;

namespace Wms.Reporting.Infrastructure;

public static class ReportingInfrastructureExtensions
{
    public static IServiceCollection AddReportingInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddReportingPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddReportingServices();
        return services;
    }

    public static IServiceCollection AddReportingPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<ReportingDbContext>(connectionString, ReportingDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddReportingServices(this IServiceCollection services)
    {
        services.AddScoped<IReportCatalogQueries, ReportCatalogQueries>();
        return services;
    }
}
