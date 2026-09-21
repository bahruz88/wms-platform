using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Modules;
using Wms.Common.Infrastructure.Persistence;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Contracts;
using Wms.Identity.Infrastructure.Contracts;
using Wms.Identity.Infrastructure.Persistence;
using Wms.Identity.Infrastructure.Persistence.Repositories;
using Wms.Identity.Infrastructure.Queries;

namespace Wms.Identity.Infrastructure;

public static class IdentityInfrastructureExtensions
{
    public static IServiceCollection AddIdentityInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddIdentityPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddIdentityServices();
        return services;
    }

    public static IServiceCollection AddIdentityPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<IdentityDbContext>(connectionString, IdentityDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddIdentityServices(this IServiceCollection services)
    {
        services.AddScoped<IIdentityQueries, IdentityQueries>();
        services.AddScoped<IPermissionChecker, PermissionChecker>();
        services.AddScoped<ITenantDirectory, TenantDirectory>();
        services.AddScoped<IPrincipalDirectory, PrincipalDirectory>();
        services.AddScoped<IIdentityUnitOfWork, IdentityUnitOfWork>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IRoleRepository, RoleRepository>();
        services.AddScoped<IDelegationRepository, DelegationRepository>();
        return services;
    }

    public static IServiceCollection AddIdentityRemoteContracts(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddModuleHttpClient<IPermissionChecker, HttpPermissionChecker>(configuration, IdentityRoutes.ModuleName);
        services.AddModuleHttpClient<ITenantDirectory, HttpTenantDirectory>(configuration, IdentityRoutes.ModuleName);
        services.AddModuleHttpClient<IPrincipalDirectory, HttpPrincipalDirectory>(configuration, IdentityRoutes.ModuleName);
        return services;
    }
}
