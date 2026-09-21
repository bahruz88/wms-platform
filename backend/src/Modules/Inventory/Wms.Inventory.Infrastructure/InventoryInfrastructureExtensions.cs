using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Modules;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Contracts;
using Wms.Inventory.Infrastructure.Contracts;
using Wms.Inventory.Infrastructure.Jobs;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.Inventory.Infrastructure.Persistence.Repositories;
using Wms.Inventory.Infrastructure.Queries;

namespace Wms.Inventory.Infrastructure;

public static class InventoryInfrastructureExtensions
{
    public static IServiceCollection AddInventoryInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddInventoryPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddInventoryServices();
        return services;
    }

    public static IServiceCollection AddInventoryPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<InventoryDbContext>(connectionString, InventoryDbContext.MigrationsHistoryTable);

    /// <summary>Repositories, queries, jobs and the in-process <see cref="IStockBalanceReader"/>.</summary>
    public static IServiceCollection AddInventoryServices(this IServiceCollection services)
    {
        services.AddScoped<IInventoryUnitOfWork, InventoryUnitOfWork>();
        services.AddScoped<IGoodsReceiptRepository, GoodsReceiptRepository>();
        services.AddScoped<IMovementGroupRepository, MovementGroupRepository>();
        services.AddScoped<IBatchRepository, BatchRepository>();
        services.AddScoped<IStockBalanceRepository, StockBalanceRepository>();
        services.AddScoped<IInventorySettings, InventorySettings>();
        services.AddScoped<ILocationFreezeChecker, LocationFreezeChecker>();
        services.AddScoped<IStockBalanceQueries, StockBalanceQueries>();
        services.AddScoped<IGoodsReceiptQueries, GoodsReceiptQueries>();
        services.AddScoped<IStockBalanceReader, StockBalanceReader>();
        services.AddScoped<IStockPostingService, StockPostingService>();
        services.AddScoped<IStockMovementReader, StockMovementReader>();

        services.AddScoped<ExpiryScannerJob>();
        services.AddScoped<BalanceReconciliationJob>();
        services.AddScoped<DoubleEntryCheckJob>();
        services.AddSingleton<IJobSchedule, InventoryJobSchedule>();
        return services;
    }

    /// <summary>HTTP stubs of the Inventory contracts for processes where the module is not loaded.</summary>
    public static IServiceCollection AddInventoryRemoteContracts(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddModuleHttpClient<IStockBalanceReader, HttpStockBalanceReader>(configuration, InventoryRoutes.ModuleName);
        services.AddModuleHttpClient<IStockPostingService, HttpStockPostingService>(configuration, InventoryRoutes.ModuleName);
        services.AddModuleHttpClient<IStockMovementReader, HttpStockMovementReader>(configuration, InventoryRoutes.ModuleName);
        return services;
    }
}
