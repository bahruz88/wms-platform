using System.Data;
using Microsoft.EntityFrameworkCore.Storage;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Consumption.Application.Abstractions;

namespace Wms.Consumption.Infrastructure.Persistence.Repositories;

public sealed class ConsumptionUnitOfWork(ConsumptionDbContext db) : IConsumptionUnitOfWork
{
    public IIntegrationEventOutbox Outbox => db;

    public IAuditTrail Audit => db;

    public async Task<IConsumptionTransaction> BeginTransactionAsync(CancellationToken cancellationToken)
    {
        var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken).ConfigureAwait(false);
        return new EfTransaction(transaction);
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);

    private sealed class EfTransaction(IDbContextTransaction transaction) : IConsumptionTransaction
    {
        public Task CommitAsync(CancellationToken cancellationToken) => transaction.CommitAsync(cancellationToken);

        public Task RollbackAsync(CancellationToken cancellationToken) => transaction.RollbackAsync(cancellationToken);

        public ValueTask DisposeAsync() => transaction.DisposeAsync();
    }
}
