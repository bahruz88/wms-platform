using Wms.Identity.Contracts;
using Wms.Identity.Infrastructure.Persistence;

namespace Wms.Identity.Infrastructure.Contracts;

/// <summary>In-process <see cref="IPermissionChecker"/>: <c>iam_user_role</c> → <c>iam_role_permission</c> → <c>iam_permission.code</c>.</summary>
public sealed class PermissionChecker(IdentityDbContext db) : IPermissionChecker
{
    public async Task<bool> HasPermissionAsync(uint userId, string permission, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(permission);
        var permissions = await GetPermissionsAsync(userId, cancellationToken).ConfigureAwait(false);
        return permissions.Contains(permission);
    }

    public async Task<IReadOnlyCollection<string>> GetPermissionsAsync(uint userId, CancellationToken cancellationToken)
    {
        var roleIds = await db.UserRoles.AsNoTracking()
            .Where(ur => ur.UserId == userId)
            .Select(ur => ur.RoleId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        if (roleIds.Count == 0)
        {
            return [];
        }

        var permissionIds = await db.RolePermissions.AsNoTracking()
            .Where(rp => roleIds.Contains(rp.RoleId))
            .Select(rp => rp.PermissionId)
            .Distinct()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var codes = await db.Permissions.AsNoTracking()
            .Where(p => permissionIds.Contains(p.Id))
            .Select(p => p.Code)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new HashSet<string>(codes, StringComparer.OrdinalIgnoreCase);
    }
}

/// <summary>In-process <see cref="ITenantDirectory"/>.</summary>
public sealed class TenantDirectory(IdentityDbContext db) : ITenantDirectory
{
    public async Task<TenantDto?> GetAsync(uint tenantId, CancellationToken cancellationToken)
    {
        var tenant = await db.Tenants.AsNoTracking()
            .FirstOrDefaultAsync(t => t.Id == tenantId, cancellationToken)
            .ConfigureAwait(false);
        return tenant is null
            ? null
            : new TenantDto(tenant.Id, tenant.Code, tenant.Name, tenant.DefaultCurrency, tenant.Timezone, tenant.Locale, tenant.IsActive);
    }
}
