using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Wms.Identity.Domain;
using Wms.Identity.Domain.Entities;
using Wms.Identity.Infrastructure.Persistence;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.Host.Migrator;

/// <summary>
/// Fills the <c>iam</c> schema (spec §7).
/// </summary>
/// <remarks>
/// <para>
/// Every <c>iam_*</c> table was empty, so authorization had nothing to read and fell back to a compiled map,
/// <c>iam_user_location</c> could not restrict anybody, and no <c>iam_user.id</c> existed for the audit
/// columns to point at. The catalogue part (tenant, roles, permissions, role→permission) is <b>system
/// reference data</b>, not demo data: it runs on every migrator invocation, because without it the product
/// cannot authorize a single request. The dev users are demo data and only run under <c>--seed</c>.
/// </para>
/// <para>
/// Every step is an upsert keyed on the natural key, so re-running changes nothing and a partially filled
/// schema is completed rather than duplicated. New permission codes added to
/// <see cref="PermissionCatalog"/> are inserted, and the system roles' grants are re-applied, on the next run.
/// </para>
/// </remarks>
public sealed class IamSeeder(
    IdentityDbContext identity,
    MasterDataDbContext masterData,
    SeedContext context,
    ILogger<IamSeeder> logger)
{
    private const uint Tenant = SeedContext.DefaultTenantId;

    private static readonly (string Code, string Name)[] RoleNames =
    [
        (SystemRoles.Admin, "Administrator"),
        (SystemRoles.ProcurementOfficer, "Satınalma mütəxəssisi"),
        (SystemRoles.ProcurementManager, "Satınalma meneceri"),
        (SystemRoles.WarehouseKeeper, "Anbardar"),
        (SystemRoles.BranchUser, "Filial istifadəçisi"),
        (SystemRoles.Auditor, "Auditor"),
    ];

    /// <summary>
    /// The dev users of CONVENTIONS.md (Keycloak realm <c>wms</c>). They are written with a placeholder
    /// <c>external_id</c> and claimed by the first real token carrying the same <c>preferred_username</c>,
    /// so the roles and the location grants below are in force from that user's very first request.
    /// </summary>
    private static readonly (string Username, string FullName, string Role, string[] Locations)[] DevUsers =
    [
        ("admin", "Sistem administratoru", SystemRoles.Admin, []),
        ("procurement", "Satınalma mütəxəssisi", SystemRoles.ProcurementOfficer, []),
        ("manager", "Satınalma meneceri", SystemRoles.ProcurementManager, []),
        ("keeper", "Anbardar", SystemRoles.WarehouseKeeper, ["WH-01", "WH-02"]),
        ("branch1", "Nizami filialı işçisi", SystemRoles.BranchUser, ["BR-NIZ"]),
        ("auditor", "Daxili auditor", SystemRoles.Auditor, []),
    ];

    /// <summary>Tenant, roles, the permission catalogue and the system role grants. Always runs.</summary>
    public async Task<int> SeedCatalogueAsync(CancellationToken cancellationToken)
    {
        await SeedTenantAsync(cancellationToken).ConfigureAwait(false);
        var permissions = await SeedPermissionsAsync(cancellationToken).ConfigureAwait(false);
        await PruneRetiredPermissionsAsync(permissions, cancellationToken).ConfigureAwait(false);
        var roles = await SeedRolesAsync(cancellationToken).ConfigureAwait(false);
        await SeedRolePermissionsAsync(roles, permissions, cancellationToken).ConfigureAwait(false);
        logger.LogInformation(
            "iam catalogue ready: {Roles} roles, {Permissions} permissions.", roles.Count, permissions.Count);
        return 0;
    }

    /// <summary>The six dev users with their roles and location grants. Only under <c>--seed</c>.</summary>
    public async Task<int> SeedDevUsersAsync(CancellationToken cancellationToken)
    {
        var roles = await identity.Roles.ToDictionaryAsync(r => r.Code, cancellationToken).ConfigureAwait(false);
        var locations = await masterData.Locations
            .ToDictionaryAsync(l => l.Code, l => l.Id, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);
        var existing = await identity.Users
            .Include(u => u.Roles)
            .Include(u => u.Locations)
            .ToDictionaryAsync(u => u.Username, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);

        foreach (var (username, fullName, roleCode, locationCodes) in DevUsers)
        {
            if (!roles.TryGetValue(roleCode, out var role))
            {
                throw new InvalidOperationException($"Seed user '{username}': role '{roleCode}' is missing.");
            }

            if (!existing.TryGetValue(username, out var user))
            {
                var created = User.Create(
                    Tenant, User.UnclaimedExternalIdPrefix + username, username, fullName, $"{username}@wms.local");
                if (created.IsFailure)
                {
                    throw new InvalidOperationException($"Seed user '{username}': {created.Error.Message}");
                }

                user = created.Value;
                identity.Users.Add(user);
                await identity.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
                existing[username] = user;
            }

            user.ReplaceRoles([role.Id]);

            var granted = new List<uint>();
            foreach (var code in locationCodes)
            {
                if (!locations.TryGetValue(code, out var locationId))
                {
                    throw new InvalidOperationException($"Seed user '{username}': location '{code}' is missing.");
                }

                granted.Add(locationId);
            }

            user.ReplaceLocations(granted);
        }

        await identity.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        logger.LogInformation(
            "iam dev users ready: {Users}. branch1 is restricted to BR-NIZ, keeper to WH-01/WH-02 (spec §16).",
            string.Join(", ", DevUsers.Select(u => u.Username)));
        return 0;
    }

    private async Task SeedTenantAsync(CancellationToken cancellationToken)
    {
        if (await identity.Tenants.AnyAsync(t => t.Id == Tenant, cancellationToken).ConfigureAwait(false))
        {
            return;
        }

        var tenant = Wms.Identity.Domain.Entities.Tenant.Create("WMS", "WMS platforması", context.UtcNow);
        if (tenant.IsFailure)
        {
            throw new InvalidOperationException($"Seed tenant: {tenant.Error.Message}");
        }

        identity.Tenants.Add(tenant.Value);
        await identity.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    private async Task<Dictionary<string, Permission>> SeedPermissionsAsync(CancellationToken cancellationToken)
    {
        var existing = await identity.Permissions
            .ToDictionaryAsync(p => p.Code, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);

        foreach (var definition in PermissionCatalog.All)
        {
            if (existing.ContainsKey(definition.Code))
            {
                continue;
            }

            var permission = Permission.Create(definition.Code, definition.Module);
            identity.Permissions.Add(permission);
            existing[definition.Code] = permission;
        }

        await identity.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    /// <summary>
    /// Drops permission rows that left <see cref="PermissionCatalog"/> (a code that was renamed, e.g.
    /// <c>inv.return.create</c> → <c>inv.rtv.create</c> when the service adopted the contract's spelling).
    /// Leaving them behind would keep granting a code nothing checks any more, which reads like a live
    /// permission in the admin UI. The matching <c>iam_role_permission</c> rows go with them.
    /// </summary>
    private async Task PruneRetiredPermissionsAsync(Dictionary<string, Permission> permissions, CancellationToken cancellationToken)
    {
        var retired = permissions.Values.Where(p => !PermissionCatalog.Codes.Contains(p.Code)).ToList();
        if (retired.Count == 0)
        {
            return;
        }

        var retiredIds = retired.Select(p => p.Id).ToHashSet();
        var grants = await identity.RolePermissions
            .Where(rp => retiredIds.Contains(rp.PermissionId))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        identity.RolePermissions.RemoveRange(grants);
        identity.Permissions.RemoveRange(retired);
        await identity.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        foreach (var permission in retired)
        {
            permissions.Remove(permission.Code);
        }

        logger.LogInformation(
            "Retired {Count} permission code(s) that left the catalogue: {Codes}.",
            retired.Count,
            string.Join(", ", retired.Select(p => p.Code)));
    }

    private async Task<Dictionary<string, Role>> SeedRolesAsync(CancellationToken cancellationToken)
    {
        var existing = await identity.Roles
            .ToDictionaryAsync(r => r.Code, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);

        foreach (var (code, name) in RoleNames)
        {
            if (existing.ContainsKey(code))
            {
                continue;
            }

            var role = Role.Create(Tenant, code, name, isSystem: true);
            identity.Roles.Add(role);
            existing[code] = role;
        }

        await identity.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    private async Task SeedRolePermissionsAsync(
        Dictionary<string, Role> roles,
        Dictionary<string, Permission> permissions,
        CancellationToken cancellationToken)
    {
        var existing = await identity.RolePermissions
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        var byRole = existing.GroupBy(rp => rp.RoleId).ToDictionary(g => g.Key, g => g.Select(x => x.PermissionId).ToHashSet());

        foreach (var (code, role) in roles)
        {
            // Only the six system roles are platform-owned. A custom role created through
            // POST /identity/roles is the operator's, and is never touched here.
            if (!role.IsSystem)
            {
                continue;
            }

            var wanted = PermissionCatalog.GrantsFor(code);
            if (wanted.Count == 0)
            {
                continue;
            }

            var wantedIds = wanted
                .Select(c => permissions.TryGetValue(c, out var p) ? p.Id : (ushort)0)
                .Where(id => id != 0)
                .ToHashSet();
            var current = byRole.GetValueOrDefault(role.Id, []);

            foreach (var permissionId in wantedIds.Except(current))
            {
                identity.RolePermissions.Add(RolePermission.Create(role.Id, permissionId));
            }

            // Exact reconciliation, not just top-up: when a release NARROWS a system role - as narrowing
            // doc.attachment.* to view/upload/delete did, so that a branch user can no longer delete
            // somebody else's attachment - a top-up-only seeder would leave the wider grant in place and
            // the fix would never reach an existing database.
            var stale = current.Except(wantedIds).ToList();
            if (stale.Count > 0)
            {
                var rows = await identity.RolePermissions
                    .Where(rp => rp.RoleId == role.Id && stale.Contains(rp.PermissionId))
                    .ToListAsync(cancellationToken)
                    .ConfigureAwait(false);
                identity.RolePermissions.RemoveRange(rows);
                logger.LogInformation(
                    "Revoked {Count} grant(s) from system role {RoleCode} that the catalogue no longer lists.",
                    stale.Count,
                    code);
            }
        }

        await identity.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }
}
