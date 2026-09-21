using Wms.Documents.Domain;
using Wms.Documents.Domain.Entities;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.Application;

/// <summary>
/// Public shape of <c>documents.v1.yaml#/components/schemas/Attachment</c>. It deliberately omits
/// <c>storage_key</c>: the MinIO key is an internal, unguessable secret and never leaves the server.
/// </summary>
public sealed record AttachmentResponse(
    long Id,
    string EntityType,
    long? EntityId,
    string AttachmentType,
    string FileName,
    string ContentType,
    ulong SizeBytes,
    string? ChecksumSha256,
    AttachmentStatus Status,
    string? ScanResult,
    uint UploadedBy,
    DateTimeOffset UploadedAt,
    bool ThumbnailAvailable)
{
    public static AttachmentResponse From(Attachment attachment)
    {
        ArgumentNullException.ThrowIfNull(attachment);
        return new AttachmentResponse(
            attachment.Id,
            attachment.EntityType,
            attachment.IsLinked ? attachment.EntityId : null,
            attachment.AttachmentType,
            attachment.FileName,
            attachment.ContentType,
            attachment.SizeBytes,
            attachment.ChecksumSha256.Length == AttachmentPolicy.ChecksumLength ? attachment.ChecksumSha256 : null,
            attachment.Status,
            attachment.ScanResult,
            attachment.UploadedBy,
            attachment.UploadedAt,
            ThumbnailAvailable: false);
    }
}

/// <summary><c>documents.v1.yaml#/components/schemas/PresignResponse</c>.</summary>
public sealed record PresignResponse(
    long AttachmentId,
    Uri UploadUrl,
    string Method,
    IReadOnlyDictionary<string, string> UploadHeaders,
    DateTimeOffset ExpiresAt,
    ulong MaxSizeBytes)
{
    public const string PutMethod = "PUT";
}

/// <summary><c>documents.v1.yaml#/components/schemas/DownloadUrlResponse</c>.</summary>
public sealed record DownloadUrlResponse(
    Uri DownloadUrl,
    DateTimeOffset ExpiresAt,
    string FileName,
    string ContentType,
    ulong SizeBytes);

/// <summary>
/// Lifetimes of the presigned links, built from the <c>Minio</c> configuration section in the infrastructure
/// layer and injected as a singleton so the handlers stay free of <c>IOptions</c> and stay unit testable.
/// </summary>
public sealed record AttachmentLinkOptions(TimeSpan UploadUrlLifetime, TimeSpan DownloadUrlLifetime)
{
    /// <summary>Contract: 15 minutes to upload, 5 minutes to download.</summary>
    public static AttachmentLinkOptions Default { get; } = new(TimeSpan.FromMinutes(15), TimeSpan.FromMinutes(5));
}
