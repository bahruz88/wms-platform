using System.Data;
using Microsoft.EntityFrameworkCore;
using Wms.Common.Application.Abstractions;
using Wms.Identity.Domain;
using Wms.Identity.Domain.Entities;
using Wms.Identity.Infrastructure.Persistence;

namespace Wms.Identity.Infrastructure.Contracts;

/// <summary>
/// Resolves a Keycloak subject to its <c>iam_user</c> row, provisioning it on first sight (spec §7).
/// </summary>
/// <remarks>
/// <para>
/// Authentication lives in Keycloak; <c>iam_user</c> is the local projection the rest of the schema points at
/// (<c>created_by</c>, <c>posted_by</c>, <c>approved_by</c>, <c>uploaded_by</c>, <c>common_audit_log.user_id</c>).
/// Nothing wrote that projection, so every one of those columns was 0 and the §12.6 self-approval check —
/// guarded by <c>userId != 0</c> — never fired.
/// </para>
/// <para>
/// Just-in-time provisioning was chosen over a Keycloak protocol mapper. A mapper would have to carry the
/// internal id in the token, which means (a) Keycloak would need write access to the WMS database or a
/// bespoke SPI, (b) the id would be frozen for the lifetime of the token, and (c) every environment would
/// need the mapper configured identically or the whole audit trail silently reverts to 0. Resolving on the
/// server keeps Keycloak the single source of *authentication* and the WMS database the single source of
/// *identity*, and it means a role or location change takes effect on the next request without re-login.
/// The realm roles are mirrored into <c>iam_user_role</c> on first sight so a new user is immediately usable.
/// </para>
/// </remarks>
public sealed class PrincipalDirectory(IdentityDbContext db, ILogger<PrincipalDirectory> logger) : IPrincipalDirectory
{
    public async Task<PrincipalSnapshot?> ResolveAsync(PrincipalClaims claims, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(claims);

        var user = await db.Users
            .Include(u => u.Roles)
            .Include(u => u.Locations)
            .FirstOrDefaultAsync(u => u.ExternalId == claims.ExternalId, cancellationToken)
            .ConfigureAwait(false);

        if (user is null)
        {
            // A row prepared by the operator (or the seeder) before this person ever signed in: it carries the
            // username but a placeholder external_id, so the first real token claims it together with the roles
            // and location grants already attached to it.
            user = await db.Users
                .Include(u => u.Roles)
                .Include(u => u.Locations)
                .FirstOrDefaultAsync(
                    u => u.Username == claims.Username && u.ExternalId.StartsWith(User.UnclaimedExternalIdPrefix),
                    cancellationToken)
                .ConfigureAwait(false);

            if (user is not null && user.ClaimExternalId(claims.ExternalId))
            {
                user.SyncFromToken(claims.Username, claims.FullName, claims.Email);
                await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
                logger.LogInformation(
                    "Claimed pre-provisioned iam_user {UserId} ({Username}) for Keycloak subject {Subject}.",
                    user.Id,
                    user.Username,
                    claims.ExternalId);
            }
        }

        if (user is null)
        {
            user = await ProvisionAsync(claims, cancellationToken).ConfigureAwait(false);
            if (user is null)
            {
                return null;
            }
        }
        else if (user.SyncFromToken(claims.Username, claims.FullName, claims.Email))
        {
            await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }

        return await SnapshotAsync(user, claims, cancellationToken).ConfigureAwait(false);
    }

    private async Task<User?> ProvisionAsync(PrincipalClaims claims, CancellationToken cancellationToken)
    {
        var created = User.Create(claims.TenantId, claims.ExternalId, claims.Username, claims.FullName, claims.Email);
        if (created.IsFailure)
        {
            logger.LogWarning(
                "Cannot provision iam_user for subject {Subject}: {Reason}", claims.ExternalId, created.Error.Message);
            return null;
        }

        var user = created.Value;
        var roles = await db.Roles
            .Where(r => claims.RealmRoles.Contains(r.Code))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        await using var transaction = await db.Database
            .BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken)
            .ConfigureAwait(false);
        try
        {
            db.Users.Add(user);
            await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

            user.ReplaceRoles(roles.Select(r => r.Id));
            await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
        }
        catch (DbUpdateException ex)
        {
            // Two concurrent first requests from the same new user race on uq_user_external; the loser re-reads.
            await transaction.RollbackAsync(cancellationToken).ConfigureAwait(false);
            logger.LogDebug(ex, "iam_user provisioning for {Subject} lost a race; re-reading.", claims.ExternalId);
            db.ChangeTracker.Clear();
            return await db.Users
                .Include(u => u.Roles)
                .Include(u => u.Locations)
                .FirstOrDefaultAsync(u => u.ExternalId == claims.ExternalId, cancellationToken)
                .ConfigureAwait(false);
        }

        logger.LogInformation(
            "Provisioned iam_user {UserId} for Keycloak subject {Subject} with roles {Roles}.",
            user.Id,
            claims.ExternalId,
            string.Join(", ", roles.Select(r => r.Code)));
        return user;
    }

    private async Task<PrincipalSnapshot> SnapshotAsync(User user, PrincipalClaims claims, CancellationToken cancellationToken)
    {
        var roleIds = user.Roles.Select(r => r.RoleId).ToArray();
        var roles = roleIds.Length == 0
            ? []
            : await db.Roles.AsNoTracking()
                .Where(r => roleIds.Contains(r.Id))
                .Select(r => new { r.Id, r.Code })
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);

        var grants = roleIds.Length == 0
            ? []
            : await db.RolePermissions.AsNoTracking()
                .Where(rp => roleIds.Contains(rp.RoleId))
                .Join(db.Permissions.AsNoTracking(), rp => rp.PermissionId, p => p.Id, (rp, p) => new { rp.RoleId, p.Code })
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);

        var grantedRoleIds = grants.Select(g => g.RoleId).ToHashSet();
        var effective = new HashSet<string>(grants.Select(g => g.Code), StringComparer.OrdinalIgnoreCase);

        // Bootstrap fallback: a role whose iam_role_permission rows have not been seeded yet would otherwise
        // leave the user with no permissions at all and lock the product out of a fresh database. It applies
        // per role, only when that role has no rows, and only for the six system roles (README §8.12).
        foreach (var role in roles.Where(r => !grantedRoleIds.Contains(r.Id)))
        {
            var fallback = PermissionCatalog.GrantsFor(role.Code);
            if (fallback.Count == 0)
            {
                continue;
            }

            logger.LogWarning(
                "Role {RoleCode} has no iam_role_permission rows; falling back to the bootstrap grants. Run the migrator with --seed.",
                role.Code);
            foreach (var granted in fallback)
            {
                effective.Add(granted);
            }
        }

        return new PrincipalSnapshot(
            user.Id,
            user.TenantId,
            user.ExternalId,
            user.Username,
            user.FullName,
            user.Email,
            [.. roles.Select(r => r.Code).Union(claims.RealmRoles, StringComparer.OrdinalIgnoreCase)],
            [.. effective],
            [.. user.Locations.Select(l => l.LocationId)],
            user.IsActive);
    }
}
