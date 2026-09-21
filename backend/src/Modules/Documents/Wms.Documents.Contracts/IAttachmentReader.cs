namespace Wms.Documents.Contracts;

/// <summary>
/// Internal cross-module view of <c>common_attachment</c>. It carries <see cref="StorageKey"/>, so it is
/// never serialised to an API client — the public shape is <c>Wms.Documents.Application.AttachmentResponse</c>.
/// </summary>
public sealed record AttachmentDto(
    long Id,
    string EntityType,
    long? EntityId,
    string AttachmentType,
    string FileName,
    string ContentType,
    ulong SizeBytes,
    string StorageKey,
    string ChecksumSha256,
    string Status,
    DateTimeOffset UploadedAt);

/// <summary>Attachment metadata (<c>common_attachment</c>). Binary content lives in MinIO, never in MySQL (spec §3).</summary>
public interface IAttachmentReader
{
    /// <summary>Returns the attachment only when it is READY; pending uploads are invisible to other modules.</summary>
    Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken);
}

public static class DocumentsRoutes
{
    public const string ModuleName = "Documents";
    public const string Prefix = "/api/v1/documents";
    public const string Attachments = Prefix + "/attachments";
    public const string InternalAttachment = Prefix + "/internal/attachments/{attachmentId}";
}
