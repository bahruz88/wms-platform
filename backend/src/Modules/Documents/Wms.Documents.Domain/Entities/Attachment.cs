using Wms.Common.Domain;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.Domain.Entities;

/// <summary>
/// <c>common_attachment</c> (spec §11): metadata only; the bytes live in MinIO under <see cref="StorageKey"/>.
/// The row is created PENDING when the presigned PUT is handed out and only becomes visible once
/// <see cref="MarkReady"/> has verified the object MinIO actually stored.
/// </summary>
public sealed class Attachment : Entity<long>, ITenantEntity
{
    /// <summary>
    /// <c>entity_id</c> of a row whose owning document does not exist yet. The contract models this as
    /// <c>null</c>; the spec DDL keeps the column NOT NULL, so zero is the sentinel.
    /// </summary>
    public const long UnassignedEntityId = 0;

    private Attachment()
    {
    }

    public uint TenantId { get; private set; }

    public string EntityType { get; private set; } = string.Empty;

    public long EntityId { get; private set; }

    public string AttachmentType { get; private set; } = string.Empty;

    public string FileName { get; private set; } = string.Empty;

    public string ContentType { get; private set; } = string.Empty;

    /// <summary>Declared size while PENDING, the size MinIO reports once READY.</summary>
    public ulong SizeBytes { get; private set; }

    /// <summary>MinIO object key. Server-generated, never supplied by the client.</summary>
    public string StorageKey { get; private set; } = string.Empty;

    /// <summary>Empty until the upload is completed; then the SHA-256 computed from the stored object.</summary>
    public string ChecksumSha256 { get; private set; } = string.Empty;

    public AttachmentStatus Status { get; private set; }

    /// <summary>ClamAV verdict: <c>CLEAN</c>, <c>SKIPPED</c> or <c>INFECTED:&lt;signature&gt;</c>.</summary>
    public string? ScanResult { get; private set; }

    public uint UploadedBy { get; private set; }

    public DateTimeOffset UploadedAt { get; private set; }

    /// <summary>PENDING and SCANNING rows are invisible to the read endpoints (the object is not verified yet).</summary>
    public bool IsVisible => Status is AttachmentStatus.Ready or AttachmentStatus.Rejected;

    public bool IsLinked => EntityId != UnassignedEntityId;

    /// <summary>Creates the PENDING row that backs a presigned upload.</summary>
    public static Result<Attachment> CreatePending(
        uint tenantId,
        string entityType,
        long entityId,
        string attachmentType,
        string fileName,
        string contentType,
        ulong declaredSizeBytes,
        string storageKey,
        uint uploadedBy,
        DateTimeOffset uploadedAt,
        string? declaredChecksumSha256 = null)
    {
        var metadata = ValidateMetadata(entityType, entityId, attachmentType, fileName, storageKey);
        if (metadata.IsFailure)
        {
            return metadata.Error;
        }

        var policy = AttachmentPolicy.Validate(contentType, declaredSizeBytes);
        if (policy.IsFailure)
        {
            return policy.Error;
        }

        if (declaredChecksumSha256 is not null && !AttachmentPolicy.IsChecksum(declaredChecksumSha256))
        {
            return DocumentsErrors.InvalidAttachment("checksum_sha256 must be a 64 character hex digest.");
        }

        return new Attachment
        {
            TenantId = tenantId,
            EntityType = entityType.Trim(),
            EntityId = entityId,
            AttachmentType = attachmentType.Trim(),
            FileName = fileName.Trim(),
            ContentType = AttachmentPolicy.Normalise(contentType),
            SizeBytes = declaredSizeBytes,
            StorageKey = storageKey,
            ChecksumSha256 = declaredChecksumSha256?.ToLowerInvariant() ?? string.Empty,
            Status = AttachmentStatus.Pending,
            UploadedBy = uploadedBy,
            UploadedAt = uploadedAt,
        };
    }

    /// <summary>True while the upload may still be completed (the scanner may retry a PENDING row).</summary>
    public bool CanComplete => Status is AttachmentStatus.Pending or AttachmentStatus.Scanning;

    /// <summary>PENDING/SCANNING → READY with the size and checksum read back from MinIO.</summary>
    public Result MarkReady(ulong actualSizeBytes, string checksumSha256, string scanResult)
    {
        if (Status is not (AttachmentStatus.Pending or AttachmentStatus.Scanning))
        {
            return DocumentsErrors.InvalidStatusTransition(Status.ToString(), nameof(AttachmentStatus.Ready));
        }

        if (actualSizeBytes == 0 || actualSizeBytes > AttachmentPolicy.MaxSizeBytes)
        {
            return DocumentsErrors.FileTooLarge(actualSizeBytes, AttachmentPolicy.MaxSizeBytes);
        }

        if (!AttachmentPolicy.IsChecksum(checksumSha256))
        {
            return DocumentsErrors.InvalidAttachment("checksum_sha256 must be a 64 character hex digest.");
        }

        SizeBytes = actualSizeBytes;
        ChecksumSha256 = checksumSha256.ToLowerInvariant();
        ScanResult = scanResult;
        Status = AttachmentStatus.Ready;
        return Result.Success();
    }

    /// <summary>Terminal failure: the object has been removed from MinIO, the row is kept for the audit trail.</summary>
    public Result MarkRejected(string reason)
    {
        if (Status is AttachmentStatus.Ready)
        {
            return DocumentsErrors.InvalidStatusTransition(Status.ToString(), nameof(AttachmentStatus.Rejected));
        }

        ScanResult = reason;
        Status = AttachmentStatus.Rejected;
        return Result.Success();
    }

    /// <summary>Links a row that was uploaded before its document existed (contract: <c>attachmentIds</c>).</summary>
    public Result LinkTo(long entityId)
    {
        if (entityId <= 0)
        {
            return DocumentsErrors.InvalidAttachment("entity_id must be positive.");
        }

        if (IsLinked && EntityId != entityId)
        {
            return DocumentsErrors.InvalidAttachment($"The attachment is already linked to {EntityType} {EntityId}.");
        }

        EntityId = entityId;
        return Result.Success();
    }

    private static Result ValidateMetadata(string entityType, long entityId, string attachmentType, string fileName, string storageKey)
    {
        if (string.IsNullOrWhiteSpace(entityType) || entityType.Length > 80)
        {
            return DocumentsErrors.InvalidAttachment("entity_type must be 1..80 characters.");
        }

        if (entityId < 0)
        {
            return DocumentsErrors.InvalidAttachment("entity_id must not be negative.");
        }

        if (string.IsNullOrWhiteSpace(attachmentType) || attachmentType.Length > 48)
        {
            return DocumentsErrors.InvalidAttachment("attachment_type must be 1..48 characters.");
        }

        if (string.IsNullOrWhiteSpace(fileName) || fileName.Length > AttachmentPolicy.FileNameMaxLength)
        {
            return DocumentsErrors.InvalidAttachment($"file_name must be 1..{AttachmentPolicy.FileNameMaxLength} characters.");
        }

        if (string.IsNullOrWhiteSpace(storageKey) || storageKey.Length > AttachmentPolicy.StorageKeyMaxLength)
        {
            return DocumentsErrors.InvalidAttachment($"storage_key must be 1..{AttachmentPolicy.StorageKeyMaxLength} characters.");
        }

        return Result.Success();
    }
}
