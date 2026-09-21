using Wms.Common.Domain;

namespace Wms.Documents.Domain;

/// <summary>Upload limits of spec §11 — application configuration, not <c>inv_setting</c>.</summary>
public static class AttachmentPolicy
{
    public const ulong MaxSizeBytes = 25UL * 1024 * 1024;

    public static IReadOnlySet<string> AllowedContentTypes { get; } = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
    {
        "application/pdf",
        "image/jpeg",
        "image/png",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    };

    public static Result Validate(string contentType, ulong sizeBytes)
    {
        if (!AllowedContentTypes.Contains(contentType))
        {
            return DocumentsErrors.ContentTypeNotAllowed(contentType);
        }

        if (sizeBytes == 0 || sizeBytes > MaxSizeBytes)
        {
            return DocumentsErrors.FileTooLarge(sizeBytes, MaxSizeBytes);
        }

        return Result.Success();
    }
}

/// <summary>Values of <c>common_attachment.attachment_type</c>.</summary>
public static class AttachmentTypes
{
    public const string Quotation = "QUOTATION";
    public const string TempPhoto = "TEMP_PHOTO";
    public const string Invoice = "INVOICE";
    public const string Certificate = "CERTIFICATE";
    public const string WastePhoto = "WASTE_PHOTO";
    public const string DeliveryNote = "DELIVERY_NOTE";
}
