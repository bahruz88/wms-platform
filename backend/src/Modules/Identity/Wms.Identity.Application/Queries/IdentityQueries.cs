using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Application.Dtos;
using Wms.Identity.Domain;

namespace Wms.Identity.Application.Queries;

// ==================================================================== users

/// <summary><c>GET /api/v1/identity/users</c> (identity.v1.yaml <c>listUsers</c>).</summary>
public sealed record GetUsersQuery(UserFilter Filter, PageRequest Page) : IQuery<PagedResult<UserDetailDto>>;

public sealed class GetUsersQueryHandler(IIdentityQueries queries) : IQueryHandler<GetUsersQuery, PagedResult<UserDetailDto>>
{
    public async Task<Result<PagedResult<UserDetailDto>>> HandleAsync(GetUsersQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetUsersAsync(query.Filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /api/v1/identity/users/{id}</c> (<c>getUser</c>).</summary>
public sealed record GetUserQuery(uint UserId) : IQuery<UserDetailDto>;

public sealed class GetUserQueryValidator : AbstractValidator<GetUserQuery>
{
    public GetUserQueryValidator() => RuleFor(q => q.UserId).GreaterThan(0u);
}

public sealed class GetUserQueryHandler(IIdentityQueries queries) : IQueryHandler<GetUserQuery, UserDetailDto>
{
    public async Task<Result<UserDetailDto>> HandleAsync(GetUserQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var user = await queries.GetUserAsync(query.UserId, cancellationToken).ConfigureAwait(false);
        return user is null ? IdentityErrors.UserNotFound(query.UserId) : user;
    }
}

// ==================================================================== roles and permissions

/// <summary><c>GET /api/v1/identity/roles</c> (<c>listRoles</c>) — not paged, a tenant has a handful of roles.</summary>
public sealed record GetRolesQuery : IQuery<IReadOnlyList<RoleDto>>;

public sealed class GetRolesQueryHandler(IIdentityQueries queries) : IQueryHandler<GetRolesQuery, IReadOnlyList<RoleDto>>
{
    public async Task<Result<IReadOnlyList<RoleDto>>> HandleAsync(GetRolesQuery query, CancellationToken cancellationToken) =>
        Result.Success(await queries.GetRolesAsync(cancellationToken).ConfigureAwait(false));
}

/// <summary><c>GET /api/v1/identity/roles/{id}</c> (<c>getRole</c>).</summary>
public sealed record GetRoleQuery(uint RoleId) : IQuery<RoleDto>;

public sealed class GetRoleQueryHandler(IIdentityQueries queries) : IQueryHandler<GetRoleQuery, RoleDto>
{
    public async Task<Result<RoleDto>> HandleAsync(GetRoleQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var role = await queries.GetRoleAsync(query.RoleId, cancellationToken).ConfigureAwait(false);
        return role is null ? IdentityErrors.RoleNotFound(query.RoleId) : role;
    }
}

/// <summary><c>GET /api/v1/identity/permissions</c> (<c>listPermissions</c>) — the global catalogue.</summary>
public sealed record GetPermissionsQuery(string? Module) : IQuery<IReadOnlyList<PermissionDto>>;

public sealed class GetPermissionsQueryHandler(IIdentityQueries queries) : IQueryHandler<GetPermissionsQuery, IReadOnlyList<PermissionDto>>
{
    public async Task<Result<IReadOnlyList<PermissionDto>>> HandleAsync(GetPermissionsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.GetPermissionsAsync(query.Module, cancellationToken).ConfigureAwait(false));
    }
}

// ==================================================================== tenant

/// <summary><c>GET /api/v1/identity/tenant</c> (<c>getTenant</c>).</summary>
public sealed record GetTenantQuery : IQuery<TenantDetailDto>;

public sealed class GetTenantQueryHandler(IIdentityQueries queries, ITenantContext tenantContext) : IQueryHandler<GetTenantQuery, TenantDetailDto>
{
    public async Task<Result<TenantDetailDto>> HandleAsync(GetTenantQuery query, CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenant = await queries.GetTenantAsync(tenantContext.TenantId, cancellationToken).ConfigureAwait(false);
        return tenant is null ? IdentityErrors.TenantNotFound(tenantContext.TenantId) : tenant;
    }
}

// ==================================================================== delegations

/// <summary><c>GET /api/v1/identity/delegations</c> (<c>listDelegations</c>).</summary>
public sealed record GetDelegationsQuery(DelegationFilter Filter, PageRequest Page) : IQuery<PagedResult<DelegationDto>>;

public sealed class GetDelegationsQueryHandler(IIdentityQueries queries, ICurrentUser currentUser, IClock clock)
    : IQueryHandler<GetDelegationsQuery, PagedResult<DelegationDto>>
{
    public async Task<Result<PagedResult<DelegationDto>>> HandleAsync(GetDelegationsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = query.Filter;

        // Contract: an ordinary user sees only delegations from or to themselves; iam.delegation.manage sees all.
        if (!currentUser.HasPermission(IdentityPermissions.DelegationManage)
            && filter.FromUserId != currentUser.UserId
            && filter.ToUserId != currentUser.UserId)
        {
            filter = filter with { ToUserId = currentUser.UserId };
        }

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        return await queries.GetDelegationsAsync(filter, query.Page, today, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /api/v1/identity/delegations/{id}</c> (<c>getDelegation</c>).</summary>
public sealed record GetDelegationQuery(uint DelegationId) : IQuery<DelegationDto>;

public sealed class GetDelegationQueryHandler(IIdentityQueries queries, ICurrentUser currentUser, IClock clock)
    : IQueryHandler<GetDelegationQuery, DelegationDto>
{
    public async Task<Result<DelegationDto>> HandleAsync(GetDelegationQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var delegation = await queries.GetDelegationAsync(query.DelegationId, today, cancellationToken).ConfigureAwait(false);
        if (delegation is null)
        {
            return IdentityErrors.DelegationNotFound(query.DelegationId);
        }

        var mine = delegation.FromUser.Id == currentUser.UserId || delegation.ToUser.Id == currentUser.UserId;
        return mine || currentUser.HasPermission(IdentityPermissions.DelegationManage)
            ? delegation
            : IdentityErrors.DelegationNotFound(query.DelegationId);
    }
}

// ==================================================================== me

/// <summary>
/// <c>GET /api/v1/identity/me</c> (<c>getMe</c>) — the bootstrap call of both clients.
/// </summary>
/// <remarks>
/// The old implementation answered an ad-hoc object (<c>tenantId</c>, <c>userId</c>, <c>externalId</c>,
/// <c>username</c>, <c>roles</c>, <c>locationIds</c>) that matched no schema, so the web and Flutter clients
/// had to derive permissions themselves from the role code. The contract's <c>Me</c> is served here:
/// <c>user</c>, <c>tenant</c>, <c>roles</c>, <c>permissions</c>, <c>locationIds</c>, <c>canViewCost</c> and
/// today's incoming delegations.
/// </remarks>
public sealed record GetMeQuery : IQuery<MeDto>;

public sealed class GetMeQueryHandler(
    IIdentityQueries queries,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : IQueryHandler<GetMeQuery, MeDto>
{
    public async Task<Result<MeDto>> HandleAsync(GetMeQuery query, CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        if (currentUser.UserId == 0)
        {
            return IdentityErrors.InvalidUser("The bearer token could not be resolved to an iam_user row.");
        }

        var tenant = await queries.GetTenantAsync(tenantContext.TenantId, cancellationToken).ConfigureAwait(false);
        if (tenant is null)
        {
            return IdentityErrors.TenantNotFound(tenantContext.TenantId);
        }

        var user = await queries.GetUserAsync(currentUser.UserId, cancellationToken).ConfigureAwait(false);
        if (user is null)
        {
            return IdentityErrors.UserNotFound(currentUser.UserId);
        }

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var delegations = await queries
            .GetDelegationsAsync(new DelegationFilter(null, currentUser.UserId, today), new PageRequest(1, 50), today, cancellationToken)
            .ConfigureAwait(false);

        return new MeDto(
            new UserSummaryDto(user.Id, user.Username, user.FullName, user.Email, user.IsActive),
            tenant,
            [.. currentUser.Roles.Order(StringComparer.Ordinal)],
            [.. currentUser.Permissions.Order(StringComparer.Ordinal)],
            [.. currentUser.LocationIds.Order()],
            currentUser.HasPermission(PermissionCatalog.ProductViewCost),
            delegations.Items);
    }
}
