using System.Data;
using Microsoft.EntityFrameworkCore.Storage;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Inventory.Application.Abstractions;

namespace Wms.Inventory.Infrastructure.Persistence.Repositories;

public sealed class InventoryUnitOfWork(InventoryDbContext db) : IInventoryUnitOfWork
{
    public IIntegrationEventOutbox Outbox => db;

    public IAuditTrail Audit => db;

    public async Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken)
    {
        // READ COMMITTED + explicit FOR UPDATE row locks (spec §12.2).
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
