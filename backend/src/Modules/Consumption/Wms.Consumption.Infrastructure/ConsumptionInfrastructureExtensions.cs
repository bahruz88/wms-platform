using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Commands.Runs;
using Wms.Consumption.Infrastructure.Csv;
using Wms.Consumption.Infrastructure.Jobs;
using Wms.Consumption.Infrastructure.Persistence;
using Wms.Consumption.Infrastructure.Persistence.Repositories;
using Wms.Consumption.Infrastructure.Queries;

namespace Wms.Consumption.Infrastructure;

public static class ConsumptionInfrastructureExtensions
{
    public static IServiceCollection AddConsumptionInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddConsumptionPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddConsumptionServices();
        return services;
    }

    public static IServiceCollection AddConsumptionPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<ConsumptionDbContext>(connectionString, ConsumptionDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddConsumptionServices(this IServiceCollection services)
    {
        services.AddScoped<IConsumptionUnitOfWork, ConsumptionUnitOfWork>();
        services.AddScoped<IMenuItemRepository, MenuItemRepository>();
        services.AddScoped<IRecipeRepository, RecipeRepository>();
        services.AddScoped<ISalesImportRepository, SalesImportRepository>();
        services.AddScoped<IConsumptionRunRepository, ConsumptionRunRepository>();
        services.AddScoped<ITenantScanner, TenantScanner>();
        services.AddScoped<IConsumptionQueries, ConsumptionQueries>();
        services.AddScoped<ConsumptionCalculator>();
        services.AddSingleton<ISalesCsvParser, SalesCsvParser>();

        services.AddScoped<ConsumptionRunnerJob>();
        services.AddScoped<SalesImportReminderJob>();
        services.AddSingleton<IJobSchedule, ConsumptionJobSchedule>();
        return services;
    }
}
