using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Identity.Domain.Entities;

namespace Wms.Identity.Application.Abstractions;

public interface IUnitOfWorkTransaction : IAsyncDisposable
{
    Task CommitAsync(CancellationToken cancellationToken);

    Task RollbackAsync(CancellationToken cancellationToken);
}

/// <summary>Module unit of work over <c>IdentityDbContext</c>; audit and outbox rows share its SaveChanges (spec §14.1).</summary>
public interface IIdentityUnitOfWork
{
    IIntegrationEventOutbox Outbox { get; }

    IAuditTrail Audit { get; }

    Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken);

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}

public interface IUserRepository
{
    Task<User?> GetAsync(uint userId, CancellationToken cancellationToken);

    Task<User?> FindByExternalIdAsync(string externalId, CancellationToken cancellationToken);

    Task<bool> ExistsAsync(string username, string externalId, CancellationToken cancellationToken);

    void Add(User user);
}

public interface IRoleRepository
{
    Task<Role?> GetAsync(uint roleId, CancellationToken cancellationToken);

    Task<Role?> FindByCodeAsync(string code, CancellationToken cancellationToken);

    Task<IReadOnlyList<Role>> GetManyAsync(IReadOnlyCollection<uint> roleIds, CancellationToken cancellationToken);

    /// <summary>Effective permission codes of the given roles (<c>iam_role_permission</c> → <c>iam_permission</c>).</summary>
    Task<IReadOnlyList<string>> GetPermissionCodesAsync(IReadOnlyCollection<uint> roleIds, CancellationToken cancellationToken);

    /// <summary>Replaces <c>iam_role_permission</c> for one role. Unknown codes are reported, not ignored.</summary>
    Task<IReadOnlyList<string>> ReplacePermissionsAsync(uint roleId, IReadOnlyCollection<string> permissionCodes, CancellationToken cancellationToken);

    void Add(Role role);
}

public interface IDelegationRepository
{
    Task<Delegation?> GetAsync(uint delegationId, CancellationToken cancellationToken);

    Task<IReadOnlyList<Delegation>> GetForUserAsync(uint fromUserId, CancellationToken cancellationToken);

    void Add(Delegation delegation);
}
