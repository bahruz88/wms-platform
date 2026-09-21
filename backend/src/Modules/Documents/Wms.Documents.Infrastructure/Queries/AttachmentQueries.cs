using Wms.Common.Application.Paging;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Contracts;
using Wms.Documents.Infrastructure.Persistence;

namespace Wms.Documents.Infrastructure.Queries;

public sealed class AttachmentQueries(DocumentsDbContext db) : IAttachmentQueries
{
    public async Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken)
    {
        var attachment = await db.Attachments.AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == attachmentId, cancellationToken)
            .ConfigureAwait(false);
        return attachment is null ? null : Map(attachment);
    }

    public async Task<PagedResult<AttachmentDto>> GetByEntityAsync(string entityType, long entityId, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(entityType);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Attachments.AsNoTracking().Where(a => a.EntityType == entityType && a.EntityId == entityId);
        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(a => a.UploadedAt)
            .Skip(page.Skip)
            .Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new PagedResult<AttachmentDto>(rows.Select(Map).ToList(), page.Page, page.Size, total);
    }

    private static AttachmentDto Map(Wms.Documents.Domain.Entities.Attachment a) => new(
        a.Id, a.EntityType, a.EntityId, a.AttachmentType, a.FileName, a.ContentType, a.SizeBytes, a.StorageKey, a.UploadedAt);
}
