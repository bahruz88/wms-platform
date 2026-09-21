using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;

namespace Wms.Inventory.Application.Abstractions;

public interface IUnitOfWorkTransaction : IAsyncDisposable
{
    Task CommitAsync(CancellationToken cancellationToken);

    Task RollbackAsync(CancellationToken cancellationToken);
}

/// <summary>Module unit of work over <c>InventoryDbContext</c>. Outbox and audit rows are written by the same SaveChanges (spec §14.1).</summary>
public interface IInventoryUnitOfWork
{
    IIntegrationEventOutbox Outbox { get; }

    IAuditTrail Audit { get; }

    Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken);

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}
