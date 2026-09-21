using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Documents.Domain.Entities;

namespace Wms.Documents.Application.Abstractions;

/// <summary>
/// Write side of <c>common_attachment</c>. Every read goes through the tenant query filter of
/// <c>DocumentsDbContext</c>, so another tenant's row simply does not exist (404, never 403).
/// </summary>
public interface IAttachmentRepository
{
    /// <summary>Tracked lookup in any status — the upload flow needs its own PENDING row back.</summary>
    Task<Attachment?> GetAsync(long attachmentId, CancellationToken cancellationToken);

    void Add(Attachment attachment);

    void Remove(Attachment attachment);
}

public interface IDocumentsUnitOfWorkTransaction : IAsyncDisposable
{
    Task CommitAsync(CancellationToken cancellationToken);

    Task RollbackAsync(CancellationToken cancellationToken);
}

/// <summary>Module unit of work over <c>DocumentsDbContext</c>; audit rows are written by the same SaveChanges (spec §14.1).</summary>
public interface IDocumentsUnitOfWork
{
    IIntegrationEventOutbox Outbox { get; }

    IAuditTrail Audit { get; }

    Task<IDocumentsUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken);

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}
