using Wms.Common.Application.Paging;
using Wms.Identity.Application.Dtos;

namespace Wms.Identity.Application.Abstractions;

/// <summary>Filters of <c>GET /identity/users</c> (identity.v1.yaml <c>listUsers</c>).</summary>
public sealed record UserFilter(string? Search, bool? IsActive, string? RoleCode, uint? LocationId);

/// <summary>Filters of <c>GET /identity/delegations</c>.</summary>
public sealed record DelegationFilter(uint? FromUserId, uint? ToUserId, DateOnly? ActiveOn);

public interface IIdentityQueries
{
    Task<PagedResult<UserDetailDto>> GetUsersAsync(UserFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<UserDetailDto?> GetUserAsync(uint userId, CancellationToken cancellationToken);

    Task<IReadOnlyList<RoleDto>> GetRolesAsync(CancellationToken cancellationToken);

    Task<RoleDto?> GetRoleAsync(uint roleId, CancellationToken cancellationToken);

    Task<IReadOnlyList<PermissionDto>> GetPermissionsAsync(string? module, CancellationToken cancellationToken);

    Task<TenantDetailDto?> GetTenantAsync(uint tenantId, CancellationToken cancellationToken);

    Task<PagedResult<DelegationDto>> GetDelegationsAsync(DelegationFilter filter, PageRequest page, DateOnly today, CancellationToken cancellationToken);

    Task<DelegationDto?> GetDelegationAsync(uint delegationId, DateOnly today, CancellationToken cancellationToken);
}
