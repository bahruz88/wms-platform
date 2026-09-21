using Wms.Common.Domain;

namespace Wms.Documents.Domain;

public static class DocumentsErrors
{
    public static Error AttachmentNotFound(long id) => new("ATTACHMENT_NOT_FOUND", $"Attachment {id} was not found.", 404);

    public static Error InvalidAttachment(string reason) => new("INVALID_ATTACHMENT", reason, 422);

    /// <summary>Spec §11: 25 MB per file. Checked against the declared size at presign and the real object size at complete.</summary>
    public static Error FileTooLarge(ulong sizeBytes, ulong maxBytes) =>
        new("ATTACHMENT_TOO_LARGE", $"File size {sizeBytes} bytes exceeds the {maxBytes} byte limit.", 422);

    /// <summary>Spec §11: only PDF, JPEG, PNG, XLSX and DOCX may be stored.</summary>
    public static Error ContentTypeNotAllowed(string contentType) =>
        new("ATTACHMENT_TYPE_NOT_ALLOWED", $"Content type '{contentType}' is not allowed.", 422);

    /// <summary>The object MinIO stored does not carry the content type the presign was issued for.</summary>
    public static Error ContentTypeMismatch(string declared, string stored) =>
        new(
            "ATTACHMENT_CONTENT_TYPE_MISMATCH",
            $"The stored object is '{stored}' but the upload was presigned for '{declared}'.",
            422);

    /// <summary>The SHA-256 of the stored object differs from the one the client declared.</summary>
    public static Error ChecksumMismatch(string expected, string actual) =>
        new("CHECKSUM_MISMATCH", $"The stored object hashes to '{actual}', the request declared '{expected}'.", 422);

    /// <summary>ClamAV found a signature. The object is removed and the row is rejected.</summary>
    public static Error AttachmentInfected(string signature) =>
        new("ATTACHMENT_INFECTED", $"The uploaded file is infected ({signature}) and has been removed.", 422);

    /// <summary>Antivirus is enabled but clamd could not be reached. Fail closed: the upload stays pending.</summary>
    public static Error VirusScanUnavailable() =>
        new("VIRUS_SCAN_UNAVAILABLE", "The virus scanner is unavailable; the upload cannot be completed yet.", 503);

    /// <summary>Presign was issued but the client never PUT the object (or the presign expired first).</summary>
    public static Error AttachmentObjectMissing(long id) =>
        new("ATTACHMENT_NOT_FOUND", $"No object has been uploaded for attachment {id}.", 404);

    public static Error InvalidStatusTransition(string from, string to) =>
        new("INVALID_STATE_TRANSITION", $"An attachment cannot move from {from} to {to}.", 409);

    /// <summary>A download URL may only be issued for a READY attachment (contract 409 on the download-url route).</summary>
    public static Error AttachmentNotReady(string status) =>
        new("ATTACHMENT_NOT_READY", $"The attachment is {status}; only READY attachments can be downloaded.", 409);

    /// <summary>Contract: only the uploader or a holder of <c>doc.attachment.manage</c> may delete.</summary>
    public static Error NotTheUploader() =>
        new("FORBIDDEN", "Only the uploader or a holder of 'doc.attachment.manage' can delete this attachment.", 403);
}
