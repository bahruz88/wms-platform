using Wms.Common.Application.Paging;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Application.Dtos;
using Wms.Identity.Domain;
using Wms.Identity.Domain.Entities;
using Wms.Identity.Infrastructure.Persistence;

namespace Wms.Identity.Infrastructure.Queries;

/// <summary>Read side of the Identity module (<c>AsNoTracking</c>), shaped exactly as identity.v1.yaml declares.</summary>
public sealed class IdentityQueries(IdentityDbContext db) : IIdentityQueries
{
    public async Task<PagedResult<UserDetailDto>> GetUsersAsync(UserFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Users.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var term = $"%{filter.Search.Trim()}%";
            query = query.Where(u =>
                EF.Functions.Like(u.Username, term)
                || EF.Functions.Like(u.FullName, term)
                || (u.Email != null && EF.Functions.Like(u.Email, term)));
        }

        if (filter.IsActive is { } isActive)
        {
            query = query.Where(u => u.IsActive == isActive);
        }

        if (!string.IsNullOrWhiteSpace(filter.RoleCode))
        {
            var code = filter.RoleCode.Trim().ToUpperInvariant();
            var roleIds = db.Roles.AsNoTracking().Where(r => r.Code == code).Select(r => r.Id);
            query = query.Where(u => u.Roles.Any(ur => roleIds.Contains(ur.RoleId)));
        }

        if (filter.LocationId is { } locationId)
        {
            query = query.Where(u => u.Locations.Any(l => l.LocationId == locationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var users = await query
            .OrderBy(u => u.Username)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(u => new UserProjection(
                u.Id, u.ExternalId, u.Username, u.FullName, u.Email, u.Phone, u.IsActive,
                u.Roles.Select(r => r.RoleId).ToList(),
                u.Locations.Select(l => l.LocationId).ToList(),
                u.CreatedAt, u.CreatedBy, u.UpdatedAt, u.UpdatedBy, u.RowVersion))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var roles = await RoleSummariesAsync(users.SelectMany(u => u.RoleIds), cancellationToken).ConfigureAwait(false);
        return new PagedResult<UserDetailDto>([.. users.Select(u => u.ToDto(roles))], page.Page, page.Size, total);
    }

    public async Task<UserDetailDto?> GetUserAsync(uint userId, CancellationToken cancellationToken)
    {
        var user = await db.Users.AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => new UserProjection(
                u.Id, u.ExternalId, u.Username, u.FullName, u.Email, u.Phone, u.IsActive,
                u.Roles.Select(r => r.RoleId).ToList(),
                u.Locations.Select(l => l.LocationId).ToList(),
                u.CreatedAt, u.CreatedBy, u.UpdatedAt, u.UpdatedBy, u.RowVersion))
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
        if (user is null)
        {
            return null;
        }

        var roles = await RoleSummariesAsync(user.RoleIds, cancellationToken).ConfigureAwait(false);
        return user.ToDto(roles);
    }

    public async Task<IReadOnlyList<RoleDto>> GetRolesAsync(CancellationToken cancellationToken)
    {
        var roles = await db.Roles.AsNoTracking().OrderBy(r => r.Code).ToListAsync(cancellationToken).ConfigureAwait(false);
        var grants = await GrantsByRoleAsync([.. roles.Select(r => r.Id)], cancellationToken).ConfigureAwait(false);
        return [.. roles.Select(r => ToDto(r, grants))];
    }

    public async Task<RoleDto?> GetRoleAsync(uint roleId, CancellationToken cancellationToken)
    {
        var role = await db.Roles.AsNoTracking().FirstOrDefaultAsync(r => r.Id == roleId, cancellationToken).ConfigureAwait(false);
        if (role is null)
        {
            return null;
        }

        var grants = await GrantsByRoleAsync([role.Id], cancellationToken).ConfigureAwait(false);
        return ToDto(role, grants);
    }

    public async Task<IReadOnlyList<PermissionDto>> GetPermissionsAsync(string? module, CancellationToken cancellationToken)
    {
        var query = db.Permissions.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(module))
        {
            var normalized = module.Trim();
            query = query.Where(p => p.Module == normalized);
        }

        var rows = await query.OrderBy(p => p.Module).ThenBy(p => p.Code).ToListAsync(cancellationToken).ConfigureAwait(false);
        var described = PermissionCatalog.All.ToDictionary(p => p.Code, StringComparer.Ordinal);
        return
        [
            .. rows.Select(p => new PermissionDto(
                p.Id,
                p.Code,
                p.Module,
                described.TryGetValue(p.Code, out var definition) ? definition.Description : null,
                described.TryGetValue(p.Code, out var critical) && critical.IsCritical)),
        ];
    }

    public async Task<TenantDetailDto?> GetTenantAsync(uint tenantId, CancellationToken cancellationToken)
    {
        var tenant = await db.Tenants.AsNoTracking().FirstOrDefaultAsync(t => t.Id == tenantId, cancellationToken).ConfigureAwait(false);
        return tenant is null
            ? null
            : new TenantDetailDto(tenant.Id, tenant.Code, tenant.Name, tenant.DefaultCurrency, tenant.Timezone, tenant.Locale, tenant.IsActive);
    }

    public async Task<PagedResult<DelegationDto>> GetDelegationsAsync(
        DelegationFilter filter,
        PageRequest page,
        DateOnly today,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Delegations.AsNoTracking();
        if (filter.FromUserId is { } from)
        {
            query = query.Where(d => d.FromUserId == from);
        }

        if (filter.ToUserId is { } to)
        {
            query = query.Where(d => d.ToUserId == to);
        }

        if (filter.ActiveOn is { } on)
        {
            query = query.Where(d => d.ValidFrom <= on && d.ValidTo >= on);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(d => d.ValidFrom)
            .ThenByDescending(d => d.Id)
            .Skip(page.Skip)
            .Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var users = await UserSummariesAsync(rows.SelectMany(d => new[] { d.FromUserId, d.ToUserId }), cancellationToken).ConfigureAwait(false);
        return new PagedResult<DelegationDto>([.. rows.Select(d => ToDto(d, users, today))], page.Page, page.Size, total);
    }

    public async Task<DelegationDto?> GetDelegationAsync(uint delegationId, DateOnly today, CancellationToken cancellationToken)
    {
        var delegation = await db.Delegations.AsNoTracking()
            .FirstOrDefaultAsync(d => d.Id == delegationId, cancellationToken)
            .ConfigureAwait(false);
        if (delegation is null)
        {
            return null;
        }

        var users = await UserSummariesAsync([delegation.FromUserId, delegation.ToUserId], cancellationToken).ConfigureAwait(false);
        return ToDto(delegation, users, today);
    }

    private static RoleDto ToDto(Role role, IReadOnlyDictionary<uint, List<string>> grants) =>
        new(role.Id, role.Code, role.Name, role.IsSystem, grants.TryGetValue(role.Id, out var codes) ? codes : []);

    private static DelegationDto ToDto(Delegation delegation, IReadOnlyDictionary<uint, UserSummaryDto> users, DateOnly today) =>
        new(
            delegation.Id,
            users.TryGetValue(delegation.FromUserId, out var from) ? from : Unknown(delegation.FromUserId),
            users.TryGetValue(delegation.ToUserId, out var to) ? to : Unknown(delegation.ToUserId),
            delegation.ValidFrom,
            delegation.ValidTo,
            delegation.Reason,
            delegation.IsActiveOn(today),
            delegation.CreatedAt,
            delegation.CreatedBy);

    private static UserSummaryDto Unknown(uint userId) => new(userId, "?", "?", null, false);

    private async Task<IReadOnlyDictionary<uint, List<string>>> GrantsByRoleAsync(
        IReadOnlyCollection<uint> roleIds,
        CancellationToken cancellationToken)
    {
        if (roleIds.Count == 0)
        {
            return new Dictionary<uint, List<string>>();
        }

        var ids = roleIds.ToArray();
        var rows = await db.RolePermissions.AsNoTracking()
            .Where(rp => ids.Contains(rp.RoleId))
            .Join(db.Permissions.AsNoTracking(), rp => rp.PermissionId, p => p.Id, (rp, p) => new { rp.RoleId, p.Code })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows
            .GroupBy(r => r.RoleId)
            .ToDictionary(g => g.Key, g => g.Select(x => x.Code).Order(StringComparer.Ordinal).ToList());
    }

    private async Task<IReadOnlyDictionary<uint, RoleSummaryDto>> RoleSummariesAsync(
        IEnumerable<uint> roleIds,
        CancellationToken cancellationToken)
    {
        var ids = roleIds.Distinct().ToArray();
        if (ids.Length == 0)
        {
            return new Dictionary<uint, RoleSummaryDto>();
        }

        var rows = await db.Roles.AsNoTracking().Where(r => ids.Contains(r.Id)).ToListAsync(cancellationToken).ConfigureAwait(false);
        return rows.ToDictionary(r => r.Id, r => new RoleSummaryDto(r.Id, r.Code, r.Name, r.IsSystem));
    }

    private async Task<IReadOnlyDictionary<uint, UserSummaryDto>> UserSummariesAsync(
        IEnumerable<uint> userIds,
        CancellationToken cancellationToken)
    {
        var ids = userIds.Distinct().ToArray();
        if (ids.Length == 0)
        {
            return new Dictionary<uint, UserSummaryDto>();
        }

        return await db.Users.AsNoTracking()
            .Where(u => ids.Contains(u.Id))
            .Select(u => new UserSummaryDto(u.Id, u.Username, u.FullName, u.Email, u.IsActive))
            .ToDictionaryAsync(u => u.Id, cancellationToken)
            .ConfigureAwait(false);
    }

    private sealed record UserProjection(
        uint Id,
        string ExternalId,
        string Username,
        string FullName,
        string? Email,
        string? Phone,
        bool IsActive,
        List<uint> RoleIds,
        List<uint> LocationIds,
        DateTimeOffset CreatedAt,
        uint CreatedBy,
        DateTimeOffset? UpdatedAt,
        uint? UpdatedBy,
        uint RowVersion)
    {
        public UserDetailDto ToDto(IReadOnlyDictionary<uint, RoleSummaryDto> roles) =>
            new(
                Id,
                ExternalId,
                Username,
                FullName,
                Email,
                Phone,
                IsActive,
                [.. RoleIds.Select(id => roles.TryGetValue(id, out var role) ? role : new RoleSummaryDto(id, "?", "?", false))],
                [.. LocationIds.Order()],
                new AuditFieldsDto(CreatedAt, CreatedBy, UpdatedAt, UpdatedBy, RowVersion));
    }
}
