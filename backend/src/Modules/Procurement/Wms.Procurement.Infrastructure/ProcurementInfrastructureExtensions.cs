using Microsoft.Extensions.DependencyInjection.Extensions;
using Wms.Common.Infrastructure.Modules;
using Wms.Common.Infrastructure.Persistence;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Contracts;
using Wms.Procurement.Infrastructure.Contracts;
using Wms.Procurement.Infrastructure.Persistence;
using Wms.Procurement.Infrastructure.Persistence.Repositories;
using Wms.Procurement.Infrastructure.Queries;
using Wms.Procurement.Infrastructure.Services;

namespace Wms.Procurement.Infrastructure;

public static class ProcurementInfrastructureExtensions
{
    public static IServiceCollection AddProcurementInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddProcurementPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddSingleton<IProcurementSettings>(new ProcurementSettings(configuration));
        services.AddProcurementServices();
        return services;
    }

    public static IServiceCollection AddProcurementPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<ProcurementDbContext>(connectionString, ProcurementDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddProcurementServices(this IServiceCollection services)
    {
        ArgumentNullException.ThrowIfNull(services);

        services.AddScoped<IProcurementQueries, ProcurementQueries>();
        services.AddScoped<IProcurementUnitOfWork, ProcurementUnitOfWork>();
        services.AddScoped<IRequisitionRepository, RequisitionRepository>();
        services.AddScoped<IRfqRepository, RfqRepository>();
        services.AddScoped<IQuotationRepository, QuotationRepository>();
        services.AddScoped<IPurchaseOrderRepository, PurchaseOrderRepository>();
        services.AddScoped<IApprovalRuleRepository, ApprovalRuleRepository>();
        services.AddScoped<IApprovalInstanceRepository, ApprovalInstanceRepository>();
        services.AddScoped<IPriceHistoryRepository, PriceHistoryRepository>();
        services.AddScoped<ISplitCheckRepository, SplitCheckRepository>();
        services.AddScoped<IProcurementReferenceDataLoader, ProcurementReferenceDataLoader>();
        services.AddScoped<IPurchaseOrderReader, PurchaseOrderReader>();

        // The host may register an Identity-backed directory instead; this one only knows the caller's own token.
        services.TryAddScoped<IApprovalDirectory, ClaimsApprovalDirectory>();
        services.TryAddSingleton<IProcurementSettings>(new FixedProcurementSettings(Domain.Services.SplitCheckWindow.DefaultWindowDays));
        return services;
    }

    public static IServiceCollection AddProcurementRemoteContracts(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddModuleHttpClient<IPurchaseOrderReader, HttpPurchaseOrderReader>(configuration, ProcurementRoutes.ModuleName);
        return services;
    }
}
