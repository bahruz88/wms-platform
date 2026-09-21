using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Identity.Application;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Application.Commands;
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

        MapMe(group);
        MapUsers(group);
        MapRoles(group);
        MapDelegations(group);
        MapInternalEndpoints(group);
    }

    private static void MapMe(RouteGroupBuilder group)
    {
        group.MapGet("/me", async (IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetMeQuery(), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.MeView)
            .WithName("IdentityMe");

        group.MapGet("/tenant", async (IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetTenantQuery(), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.MeView)
            .WithName("GetTenant");
    }

    private static void MapUsers(RouteGroupBuilder group)
    {
        group.MapGet("/users", async ([AsParameters] UsersRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var query = new GetUsersQuery(
                    new UserFilter(request.Q, request.IsActive, request.RoleCode, request.LocationId),
                    new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.UserView)
            .WithName("GetUsers");

        group.MapPost("/users", async (CreateUserRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var command = new CreateUserCommand(
                    body.ExternalId, body.Username, body.FullName, body.Email, body.Phone,
                    body.RoleIds ?? [], body.LocationIds ?? []);
                var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
                return result.ToCreated(user => $"{IdentityRoutes.Prefix}/users/{user.Id}");
            })
            .RequirePermission(IdentityPermissions.UserManage)
            .RequireIdempotencyKey()
            .WithName("CreateUser");

        group.MapGet("/users/{id:int}", async (uint id, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetUserQuery(id), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.UserView)
            .WithName("GetUser");

        group.MapPut("/users/{id:int}", async (uint id, UpdateUserRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var command = new UpdateUserCommand(id, body.FullName, body.Email, body.Phone, body.IsActive, body.RowVersion);
                var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.UserManage)
            .WithName("UpdateUser");

        group.MapPut("/users/{id:int}/roles", async (uint id, SetUserRolesRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher
                    .SendAsync(new SetUserRolesCommand(id, body.RoleIds ?? [], body.RowVersion), cancellationToken)
                    .ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.UserManage)
            .WithName("SetUserRoles");

        group.MapPut("/users/{id:int}/locations", async (uint id, SetUserLocationsRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher
                    .SendAsync(new SetUserLocationsCommand(id, body.LocationIds ?? [], body.RowVersion), cancellationToken)
                    .ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.UserManage)
            .WithName("SetUserLocations");
    }

    private static void MapRoles(RouteGroupBuilder group)
    {
        group.MapGet("/roles", async (IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetRolesQuery(), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.RoleView)
            .WithName("GetRoles");

        group.MapPost("/roles", async (CreateRoleRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher
                    .SendAsync(new CreateRoleCommand(body.Code, body.Name, body.Permissions ?? []), cancellationToken)
                    .ConfigureAwait(false);
                return result.ToCreated(role => $"{IdentityRoutes.Prefix}/roles/{role.Id}");
            })
            .RequirePermission(IdentityPermissions.RoleManage)
            .RequireIdempotencyKey()
            .WithName("CreateRole");

        group.MapGet("/roles/{id:int}", async (uint id, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetRoleQuery(id), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.RoleView)
            .WithName("GetRole");

        group.MapPut("/roles/{id:int}/permissions", async (uint id, SetRolePermissionsRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher
                    .SendAsync(new SetRolePermissionsCommand(id, body.Permissions ?? []), cancellationToken)
                    .ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.RoleManage)
            .WithName("SetRolePermissions");

        group.MapGet("/permissions", async (string? module, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetPermissionsQuery(module), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.RoleView)
            .WithName("GetPermissions");
    }

    private static void MapDelegations(RouteGroupBuilder group)
    {
        group.MapGet("/delegations", async ([AsParameters] DelegationsRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var query = new GetDelegationsQuery(
                    new DelegationFilter(request.FromUserId, request.ToUserId, request.ActiveOn),
                    new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.DelegationView)
            .WithName("GetDelegations");

        group.MapPost("/delegations", async (CreateDelegationRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var command = new CreateDelegationCommand(body.FromUserId, body.ToUserId, body.ValidFrom, body.ValidTo, body.Reason);
                var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
                return result.ToCreated(delegation => $"{IdentityRoutes.Prefix}/delegations/{delegation.Id}");
            })
            .RequirePermission(IdentityPermissions.DelegationCreate)
            .RequireIdempotencyKey()
            .WithName("CreateDelegation");

        group.MapGet("/delegations/{id:int}", async (uint id, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetDelegationQuery(id), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IdentityPermissions.DelegationView)
            .WithName("GetDelegation");

        group.MapDelete("/delegations/{id:int}", async (uint id, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.SendAsync(new RevokeDelegationCommand(id), cancellationToken).ConfigureAwait(false);
                return result.IsSuccess ? Results.NoContent() : result.Error.ToProblem();
            })
            .RequirePermission(IdentityPermissions.DelegationCreate)
            .WithName("RevokeDelegation");
    }

    /// <summary>Module-to-module routes (spec §4.2): refused at the gateway, secret-guarded on every host.</summary>
    private static void MapInternalEndpoints(RouteGroupBuilder group)
    {
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

        group.MapPost("/internal/principals/resolve",
                async (PrincipalClaims claims, IPrincipalDirectory directory, CancellationToken cancellationToken) =>
                {
                    var snapshot = await directory.ResolveAsync(claims, cancellationToken).ConfigureAwait(false);
                    return snapshot is null ? Results.NotFound() : Results.Ok(snapshot);
                })
            .WithName("InternalResolvePrincipal")
            .ExcludeFromDescription();
    }
}

/// <summary>Query string of <c>GET /api/v1/identity/users</c>.</summary>
public sealed record UsersRequest(string? Q, bool? IsActive, string? RoleCode, uint? LocationId, int? Page, int? Size);

/// <summary>Query string of <c>GET /api/v1/identity/delegations</c>.</summary>
public sealed record DelegationsRequest(uint? FromUserId, uint? ToUserId, DateOnly? ActiveOn, int? Page, int? Size);

public sealed record CreateUserRequest(
    string ExternalId,
    string Username,
    string FullName,
    string? Email,
    string? Phone,
    IReadOnlyList<uint>? RoleIds,
    IReadOnlyList<uint>? LocationIds);

public sealed record UpdateUserRequest(string FullName, string? Email, string? Phone, bool IsActive, uint RowVersion);

public sealed record SetUserRolesRequest(IReadOnlyList<uint>? RoleIds, uint RowVersion);

public sealed record SetUserLocationsRequest(IReadOnlyList<uint>? LocationIds, uint RowVersion);

public sealed record CreateRoleRequest(string Code, string Name, IReadOnlyList<string>? Permissions);

public sealed record SetRolePermissionsRequest(IReadOnlyList<string>? Permissions);

public sealed record CreateDelegationRequest(uint? FromUserId, uint ToUserId, DateOnly ValidFrom, DateOnly ValidTo, string? Reason);
