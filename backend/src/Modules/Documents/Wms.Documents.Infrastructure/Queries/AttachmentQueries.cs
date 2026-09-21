using Wms.Documents.Application;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Contracts;
using Wms.Documents.Domain.Entities;
using Wms.Documents.Domain.Enums;
using Wms.Documents.Infrastructure.Persistence;

namespace Wms.Documents.Infrastructure.Queries;

/// <summary>
/// Every query runs against <c>DocumentsDbContext.Attachments</c>, which carries the tenant global query
/// filter (spec §12.9) — no query here bypasses it. PENDING and SCANNING rows are filtered out on top:
/// the object behind them has not been verified yet.
/// </summary>
public sealed class AttachmentQueries(DocumentsDbContext db) : IAttachmentQueries
{
    public async Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken)
    {
        var attachment = await db.Attachments.AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == attachmentId && a.Status == AttachmentStatus.Ready, cancellationToken)
            .ConfigureAwait(false);
        return attachment is null ? null : MapDto(attachment);
    }

    public async Task<AttachmentResponse?> GetVisibleAsync(long attachmentId, CancellationToken cancellationToken)
    {
        var attachment = await db.Attachments.AsNoTracking()
            .FirstOrDefaultAsync(
                a => a.Id == attachmentId
                    && (a.Status == AttachmentStatus.Ready || a.Status == AttachmentStatus.Rejected),
                cancellationToken)
            .ConfigureAwait(false);
        return attachment is null ? null : AttachmentResponse.From(attachment);
    }

    public async Task<IReadOnlyList<AttachmentResponse>> GetByEntityAsync(
        string entityType,
        long entityId,
        string? attachmentType,
        CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(entityType);

        var query = db.Attachments.AsNoTracking()
            .Where(a => a.EntityType == entityType && a.EntityId == entityId && a.Status == AttachmentStatus.Ready);

        if (!string.IsNullOrWhiteSpace(attachmentType))
        {
            query = query.Where(a => a.AttachmentType == attachmentType);
        }

        var rows = await query
            .OrderByDescending(a => a.UploadedAt)
            .ThenByDescending(a => a.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows.ConvertAll(AttachmentResponse.From);
    }

    public async Task<AttachmentDownloadTarget?> GetDownloadTargetAsync(long attachmentId, CancellationToken cancellationToken) =>
        await db.Attachments.AsNoTracking()
            .Where(a => a.Id == attachmentId)
            .Select(a => new AttachmentDownloadTarget(a.Id, a.StorageKey, a.FileName, a.ContentType, a.SizeBytes, a.Status))
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

    private static AttachmentDto MapDto(Attachment a) => new(
        a.Id,
        a.EntityType,
        a.IsLinked ? a.EntityId : null,
        a.AttachmentType,
        a.FileName,
        a.ContentType,
        a.SizeBytes,
        a.StorageKey,
        a.ChecksumSha256,
        a.Status.ToString().ToUpperInvariant(),
        a.UploadedAt);
}
