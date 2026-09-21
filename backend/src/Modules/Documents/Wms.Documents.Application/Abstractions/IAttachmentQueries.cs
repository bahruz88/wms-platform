using Wms.Documents.Contracts;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.Application.Abstractions;

/// <summary>What the download-url endpoint needs: the internal MinIO key plus the status gate.</summary>
public sealed record AttachmentDownloadTarget(
    long Id,
    string StorageKey,
    string FileName,
    string ContentType,
    ulong SizeBytes,
    AttachmentStatus Status);

/// <summary>
/// Read side of <c>common_attachment</c>. PENDING and SCANNING rows are never returned: the object behind
/// them has not been verified yet (size, content type, checksum, virus scan).
/// </summary>
public interface IAttachmentQueries
{
    /// <summary>READY attachments only — the cross-module reader contract.</summary>
    Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken);

    /// <summary>READY and REJECTED rows, so a client can see why its upload was refused.</summary>
    Task<AttachmentResponse?> GetVisibleAsync(long attachmentId, CancellationToken cancellationToken);

    /// <summary>READY attachments of one document, newest first.</summary>
    Task<IReadOnlyList<AttachmentResponse>> GetByEntityAsync(
        string entityType,
        long entityId,
        string? attachmentType,
        CancellationToken cancellationToken);

    /// <summary>Any status (the caller turns a non-READY row into a 409); tenant-filtered like every other read.</summary>
    Task<AttachmentDownloadTarget?> GetDownloadTargetAsync(long attachmentId, CancellationToken cancellationToken);
}
