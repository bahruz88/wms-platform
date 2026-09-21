using Wms.Common.Infrastructure.Modules;
using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Contracts;
using Wms.MasterData.Infrastructure.Contracts;
using Wms.MasterData.Infrastructure.Persistence;
using Wms.MasterData.Infrastructure.Persistence.Repositories;
using Wms.MasterData.Infrastructure.Queries;

namespace Wms.MasterData.Infrastructure;

public static class MasterDataInfrastructureExtensions
{
    public static IServiceCollection AddMasterDataInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddMasterDataPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddMasterDataServices();
        return services;
    }

    public static IServiceCollection AddMasterDataPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<MasterDataDbContext>(connectionString, MasterDataDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddMasterDataServices(this IServiceCollection services)
    {
        services.AddScoped<IMasterDataQueries, MasterDataQueries>();
        services.AddScoped<IMasterDataUnitOfWork, MasterDataUnitOfWork>();
        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<IProductCategoryRepository, ProductCategoryRepository>();
        services.AddScoped<IUomRepository, UomRepository>();
        services.AddScoped<ISupplierRepository, SupplierRepository>();
        services.AddScoped<ILocationRepository, LocationRepository>();
        services.AddScoped<ICurrencyRateRepository, CurrencyRateRepository>();
        services.AddScoped<IReasonCodeRepository, ReasonCodeRepository>();
        services.AddScoped<IProductCatalog, ProductCatalog>();
        services.AddScoped<ILocationCatalog, LocationCatalog>();
        services.AddScoped<ISupplierCatalog, SupplierCatalog>();
        services.AddScoped<IUomCatalog, UomCatalog>();
        services.AddScoped<IReasonCodeCatalog, ReasonCodeCatalog>();
        services.AddScoped<INumberSequenceService, NumberSequenceService>();
        services.AddScoped<ICurrencyRateReader, CurrencyRateReader>();
        return services;
    }

    public static IServiceCollection AddMasterDataRemoteContracts(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddModuleHttpClient<IProductCatalog, HttpProductCatalog>(configuration, MasterDataRoutes.ModuleName);
        services.AddModuleHttpClient<ILocationCatalog, HttpLocationCatalog>(configuration, MasterDataRoutes.ModuleName);
        services.AddModuleHttpClient<ISupplierCatalog, HttpSupplierCatalog>(configuration, MasterDataRoutes.ModuleName);
        services.AddModuleHttpClient<IUomCatalog, HttpUomCatalog>(configuration, MasterDataRoutes.ModuleName);
        services.AddModuleHttpClient<IReasonCodeCatalog, HttpReasonCodeCatalog>(configuration, MasterDataRoutes.ModuleName);
        services.AddModuleHttpClient<INumberSequenceService, HttpNumberSequenceService>(configuration, MasterDataRoutes.ModuleName);
        services.AddModuleHttpClient<ICurrencyRateReader, HttpCurrencyRateReader>(configuration, MasterDataRoutes.ModuleName);
        return services;
    }
}
