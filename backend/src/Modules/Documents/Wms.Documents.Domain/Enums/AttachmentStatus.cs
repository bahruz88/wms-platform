namespace Wms.Documents.Domain.Enums;

/// <summary>
/// Lifecycle of <c>common_attachment</c> (contract <c>documents.v1.yaml#/components/schemas/AttachmentStatus</c>).
/// The spec DDL of §11 has no status column; it is added here because the bytes arrive out of band
/// (the client PUTs them straight to MinIO) and a row must not become visible before the object is verified.
/// </summary>
public enum AttachmentStatus
{
    /// <summary>Presign issued, the object is not verified yet. Never returned by the read endpoints.</summary>
    Pending,

    /// <summary>Handed to the virus scanner. Never returned by the read endpoints.</summary>
    Scanning,

    /// <summary>Size, content type, checksum and scan all passed; the only status other documents may link to.</summary>
    Ready,

    /// <summary>Checksum mismatch, oversized object, wrong content type or an infected file. The object is removed from MinIO.</summary>
    Rejected,
}
