using System.Data;
using Microsoft.EntityFrameworkCore.Storage;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain.Entities;

namespace Wms.Documents.Infrastructure.Persistence.Repositories;

/// <summary>
/// Reads go through <c>DocumentsDbContext.Attachments</c>, which carries the tenant global query filter
/// (spec §12.9). Nothing here calls <c>IgnoreQueryFilters()</c>, so another tenant's row is simply absent
/// and the caller answers 404 instead of leaking a 403.
/// </summary>
public sealed class AttachmentRepository(DocumentsDbContext db) : IAttachmentRepository
{
    public Task<Attachment?> GetAsync(long attachmentId, CancellationToken cancellationToken) =>
        db.Attachments.FirstOrDefaultAsync(a => a.Id == attachmentId, cancellationToken);

    public void Add(Attachment attachment) => db.Attachments.Add(attachment);

    public void Remove(Attachment attachment) => db.Attachments.Remove(attachment);
}

public sealed class DocumentsUnitOfWork(DocumentsDbContext db) : IDocumentsUnitOfWork
{
    public IIntegrationEventOutbox Outbox => db;

    public IAuditTrail Audit => db;

    public async Task<IDocumentsUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken)
    {
        var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken).ConfigureAwait(false);
        return new EfTransaction(transaction);
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);

    private sealed class EfTransaction(IDbContextTransaction transaction) : IDocumentsUnitOfWorkTransaction
    {
        public Task CommitAsync(CancellationToken cancellationToken) => transaction.CommitAsync(cancellationToken);

        public Task RollbackAsync(CancellationToken cancellationToken) => transaction.RollbackAsync(cancellationToken);

        public ValueTask DisposeAsync() => transaction.DisposeAsync();
    }
}
