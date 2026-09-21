using System.Data;
using Microsoft.EntityFrameworkCore.Storage;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Domain.Entities;

namespace Wms.Identity.Infrastructure.Persistence.Repositories;

public sealed class IdentityUnitOfWork(IdentityDbContext db) : IIdentityUnitOfWork
{
    public IIntegrationEventOutbox Outbox => db;

    public IAuditTrail Audit => db;

    public async Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken)
    {
        var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken).ConfigureAwait(false);
        return new EfTransaction(transaction);
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);

    private sealed class EfTransaction(IDbContextTransaction transaction) : IUnitOfWorkTransaction
    {
        public Task CommitAsync(CancellationToken cancellationToken) => transaction.CommitAsync(cancellationToken);

        public Task RollbackAsync(CancellationToken cancellationToken) => transaction.RollbackAsync(cancellationToken);

        public ValueTask DisposeAsync() => transaction.DisposeAsync();
    }
}

public sealed class UserRepository(IdentityDbContext db) : IUserRepository
{
    public Task<User?> GetAsync(uint userId, CancellationToken cancellationToken) =>
        db.Users
            .Include(u => u.Roles)
            .Include(u => u.Locations)
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

    public Task<User?> FindByExternalIdAsync(string externalId, CancellationToken cancellationToken) =>
        db.Users
            .Include(u => u.Roles)
            .Include(u => u.Locations)
            .FirstOrDefaultAsync(u => u.ExternalId == externalId, cancellationToken);

    public Task<bool> ExistsAsync(string username, string externalId, CancellationToken cancellationToken) =>
        db.Users.AnyAsync(u => u.Username == username || u.ExternalId == externalId, cancellationToken);

    public void Add(User user) => db.Users.Add(user);
}

public sealed class RoleRepository(IdentityDbContext db) : IRoleRepository
{
    public Task<Role?> GetAsync(uint roleId, CancellationToken cancellationToken) =>
        db.Roles.FirstOrDefaultAsync(r => r.Id == roleId, cancellationToken);

    public Task<Role?> FindByCodeAsync(string code, CancellationToken cancellationToken) =>
        db.Roles.FirstOrDefaultAsync(r => r.Code == code, cancellationToken);

    public async Task<IReadOnlyList<Role>> GetManyAsync(IReadOnlyCollection<uint> roleIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roleIds);
        if (roleIds.Count == 0)
        {
            return [];
        }

        var ids = roleIds.ToArray();
        return await db.Roles.Where(r => ids.Contains(r.Id)).ToListAsync(cancellationToken).ConfigureAwait(false);
    }

    public async Task<IReadOnlyList<string>> GetPermissionCodesAsync(IReadOnlyCollection<uint> roleIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roleIds);
        if (roleIds.Count == 0)
        {
            return [];
        }

        var ids = roleIds.ToArray();
        return await db.RolePermissions.AsNoTracking()
            .Where(rp => ids.Contains(rp.RoleId))
            .Join(db.Permissions.AsNoTracking(), rp => rp.PermissionId, p => p.Id, (_, p) => p.Code)
            .Distinct()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task<IReadOnlyList<string>> ReplacePermissionsAsync(
        uint roleId,
        IReadOnlyCollection<string> permissionCodes,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(permissionCodes);
        var codes = permissionCodes.Distinct(StringComparer.Ordinal).ToArray();
        var permissions = await db.Permissions.AsNoTracking()
            .Where(p => codes.Contains(p.Code))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var existing = await db.RolePermissions.Where(rp => rp.RoleId == roleId).ToListAsync(cancellationToken).ConfigureAwait(false);
        db.RolePermissions.RemoveRange(existing);
        foreach (var permission in permissions)
        {
            db.RolePermissions.Add(RolePermission.Create(roleId, permission.Id));
        }

        return [.. permissions.Select(p => p.Code)];
    }

    public void Add(Role role) => db.Roles.Add(role);
}

public sealed class DelegationRepository(IdentityDbContext db) : IDelegationRepository
{
    public Task<Delegation?> GetAsync(uint delegationId, CancellationToken cancellationToken) =>
        db.Delegations.FirstOrDefaultAsync(d => d.Id == delegationId, cancellationToken);

    public async Task<IReadOnlyList<Delegation>> GetForUserAsync(uint fromUserId, CancellationToken cancellationToken) =>
        await db.Delegations.AsNoTracking()
            .Where(d => d.FromUserId == fromUserId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

    public void Add(Delegation delegation) => db.Delegations.Add(delegation);
}
