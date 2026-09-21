namespace Wms.Documents.Contracts;

public sealed record AttachmentDto(
    long Id,
    string EntityType,
    long EntityId,
    string AttachmentType,
    string FileName,
    string ContentType,
    ulong SizeBytes,
    string StorageKey,
    DateTimeOffset UploadedAt);

/// <summary>Attachment metadata (<c>common_attachment</c>). Binary content lives in MinIO, never in MySQL (spec §3).</summary>
public interface IAttachmentReader
{
    Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken);
}

public static class DocumentsRoutes
{
    public const string ModuleName = "Documents";
    public const string Prefix = "/api/v1/documents";
    public const string InternalAttachment = Prefix + "/internal/attachments/{attachmentId}";
}
