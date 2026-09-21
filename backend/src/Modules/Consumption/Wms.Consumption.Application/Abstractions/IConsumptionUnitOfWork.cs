using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;

namespace Wms.Consumption.Application.Abstractions;

public interface IConsumptionTransaction : IAsyncDisposable
{
    Task CommitAsync(CancellationToken cancellationToken);

    Task RollbackAsync(CancellationToken cancellationToken);
}

/// <summary>Module unit of work over <c>ConsumptionDbContext</c>. Outbox and audit rows are written by the same SaveChanges (spec §14.1).</summary>
public interface IConsumptionUnitOfWork
{
    IIntegrationEventOutbox Outbox { get; }

    IAuditTrail Audit { get; }

    Task<IConsumptionTransaction> BeginTransactionAsync(CancellationToken cancellationToken);

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}
