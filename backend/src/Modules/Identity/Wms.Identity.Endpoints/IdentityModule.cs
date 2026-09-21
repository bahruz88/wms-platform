using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Identity.Application;
using Wms.Identity.Application.Queries;
using Wms.Identity.Contracts;
using Wms.Identity.Infrastructure;

namespace Wms.Identity.Endpoints;

/// <summary><c>--Modules=identity</c>. Route prefix <c>/api/v1/identity</c>, table prefix <c>iam_</c>.</summary>
public sealed class IdentityModule : IModule
{
    public const string ModuleName = "identity";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddIdentityApplication();
        services.AddIdentityInfrastructure(configuration);
    }

    public void RegisterRemoteContracts(IServiceCollection services, IConfiguration configuration) =>
        services.AddIdentityRemoteContracts(configuration);

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(IdentityRoutes.Prefix).WithTags("Identity").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("IdentityPing");

        group.MapGet("/me", (ITenantContext tenant, ICurrentUser user) => TypedResults.Ok(new
            {
                tenantId = tenant.TenantId,
                userId = user.UserId,
                externalId = user.ExternalId,
                username = user.Username,
                roles = user.Roles,
                locationIds = user.LocationIds,
            }))
            .WithName("IdentityMe");

        group.MapGet("/users", async ([AsParameters] PagingRequest paging, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetUsersQuery(paging.ToPageRequest()), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.UserView)
            .WithName("GetUsers");

        group.MapGet("/internal/users/{userId:int}/permissions",
                async (uint userId, IPermissionChecker checker, CancellationToken cancellationToken) =>
                    Results.Ok(await checker.GetPermissionsAsync(userId, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalUserPermissions")
            .ExcludeFromDescription();

        group.MapGet("/internal/tenants/{tenantId:int}",
                async (uint tenantId, ITenantDirectory directory, CancellationToken cancellationToken) =>
                {
                    var tenant = await directory.GetAsync(tenantId, cancellationToken).ConfigureAwait(false);
                    return tenant is null ? Results.NotFound() : Results.Ok(tenant);
                })
            .WithName("InternalTenant")
            .ExcludeFromDescription();
    }
}
