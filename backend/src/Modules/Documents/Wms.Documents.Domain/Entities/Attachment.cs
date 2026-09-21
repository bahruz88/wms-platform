using Wms.Common.Domain;

namespace Wms.Documents.Domain.Entities;

/// <summary><c>common_attachment</c> (spec §11): metadata only; the bytes live in MinIO under <see cref="StorageKey"/>.</summary>
public sealed class Attachment : Entity<long>, ITenantEntity
{
    private Attachment()
    {
    }

    public uint TenantId { get; private set; }

    public string EntityType { get; private set; } = string.Empty;

    public long EntityId { get; private set; }

    public string AttachmentType { get; private set; } = string.Empty;

    public string FileName { get; private set; } = string.Empty;

    public string ContentType { get; private set; } = string.Empty;

    public ulong SizeBytes { get; private set; }

    /// <summary>MinIO object key.</summary>
    public string StorageKey { get; private set; } = string.Empty;

    public string ChecksumSha256 { get; private set; } = string.Empty;

    public uint UploadedBy { get; private set; }

    public DateTimeOffset UploadedAt { get; private set; }

    public static Result<Attachment> Create(
        uint tenantId,
        string entityType,
        long entityId,
        string attachmentType,
        string fileName,
        string contentType,
        ulong sizeBytes,
        string storageKey,
        string checksumSha256,
        uint uploadedBy,
        DateTimeOffset uploadedAt)
    {
        if (string.IsNullOrWhiteSpace(entityType) || entityType.Length > 80)
        {
            return DocumentsErrors.InvalidAttachment("entity_type must be 1..80 characters.");
        }

        if (string.IsNullOrWhiteSpace(fileName) || fileName.Length > 300)
        {
            return DocumentsErrors.InvalidAttachment("file_name must be 1..300 characters.");
        }

        if (string.IsNullOrWhiteSpace(storageKey) || storageKey.Length > 500)
        {
            return DocumentsErrors.InvalidAttachment("storage_key must be 1..500 characters.");
        }

        if (checksumSha256 is not { Length: 64 })
        {
            return DocumentsErrors.InvalidAttachment("checksum_sha256 must be a 64 character hex digest.");
        }

        var policy = AttachmentPolicy.Validate(contentType, sizeBytes);
        if (policy.IsFailure)
        {
            return policy.Error;
        }

        return new Attachment
        {
            TenantId = tenantId,
            EntityType = entityType.Trim(),
            EntityId = entityId,
            AttachmentType = attachmentType.Trim(),
            FileName = fileName.Trim(),
            ContentType = contentType,
            SizeBytes = sizeBytes,
            StorageKey = storageKey,
            ChecksumSha256 = checksumSha256.ToLowerInvariant(),
            UploadedBy = uploadedBy,
            UploadedAt = uploadedAt,
        };
    }
}
