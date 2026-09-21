using Wms.Common.Domain;

namespace Wms.Documents.Domain;

public static class DocumentsErrors
{
    public static Error AttachmentNotFound(long id) => new("ATTACHMENT_NOT_FOUND", $"Attachment {id} was not found.", 404);

    public static Error InvalidAttachment(string reason) => new("INVALID_ATTACHMENT", reason, 422);

    public static Error FileTooLarge(ulong sizeBytes, ulong maxBytes) =>
        new("FILE_TOO_LARGE", $"File size {sizeBytes} bytes exceeds the {maxBytes} byte limit.", 413);

    public static Error ContentTypeNotAllowed(string contentType) =>
        new("CONTENT_TYPE_NOT_ALLOWED", $"Content type '{contentType}' is not allowed.", 415);
}
