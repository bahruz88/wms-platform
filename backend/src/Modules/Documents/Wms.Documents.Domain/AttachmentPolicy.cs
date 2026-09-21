using System.Globalization;
using System.Text;
using Wms.Common.Domain;

namespace Wms.Documents.Domain;

/// <summary>Upload limits of spec §11 — application configuration, not <c>inv_setting</c>.</summary>
public static class AttachmentPolicy
{
    /// <summary>25 MB, the hard cap of spec §11. Enforced on the declared size at presign and on the real object size at complete.</summary>
    public const ulong MaxSizeBytes = 25UL * 1024 * 1024;

    public const int FileNameMaxLength = 300;

    public const int StorageKeyMaxLength = 500;

    public const int ChecksumLength = 64;

    public static IReadOnlySet<string> AllowedContentTypes { get; } = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
    {
        "application/pdf",
        "image/jpeg",
        "image/png",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    };

    public static bool IsAllowedContentType(string? contentType) =>
        !string.IsNullOrWhiteSpace(contentType) && AllowedContentTypes.Contains(Normalise(contentType));

    /// <summary>Strips the <c>; charset=…</c> parameters MinIO may echo back and trims.</summary>
    public static string Normalise(string? contentType)
    {
        if (string.IsNullOrWhiteSpace(contentType))
        {
            return string.Empty;
        }

        var separator = contentType.IndexOf(';', StringComparison.Ordinal);
        var media = separator < 0 ? contentType : contentType[..separator];
        return media.Trim();
    }

    public static bool IsChecksum(string? value)
    {
        if (value is not { Length: ChecksumLength })
        {
            return false;
        }

        foreach (var c in value)
        {
            var isHex = c is >= '0' and <= '9' or >= 'a' and <= 'f' or >= 'A' and <= 'F';
            if (!isHex)
            {
                return false;
            }
        }

        return true;
    }

    public static Result Validate(string contentType, ulong sizeBytes)
    {
        if (!IsAllowedContentType(contentType))
        {
            return DocumentsErrors.ContentTypeNotAllowed(Normalise(contentType));
        }

        if (sizeBytes == 0 || sizeBytes > MaxSizeBytes)
        {
            return DocumentsErrors.FileTooLarge(sizeBytes, MaxSizeBytes);
        }

        return Result.Success();
    }
}

/// <summary>
/// MinIO object keys. The key is always built by the server from the tenant, the owning entity and a fresh
/// GUID — never taken from the client — so one tenant can neither guess nor address another tenant's objects.
/// </summary>
public static class AttachmentStorageKey
{
    /// <summary>Used when the owning document does not exist yet (contract allows a null <c>entityId</c>).</summary>
    public const string UnassignedSegment = "unassigned";

    private const int FileNameSegmentMaxLength = 120;
    private const string FallbackFileName = "file";

    /// <summary><c>{tenantId}/{entityType}/{entityId}/{guid}/{sanitised file name}</c>.</summary>
    public static string Build(uint tenantId, string entityType, long entityId, Guid objectId, string fileName)
    {
        var entity = Slug(entityType, "entity");
        var owner = entityId > 0 ? entityId.ToString(CultureInfo.InvariantCulture) : UnassignedSegment;
        return string.Create(
            CultureInfo.InvariantCulture,
            $"{tenantId}/{entity}/{owner}/{objectId:N}/{SanitiseFileName(fileName)}");
    }

    /// <summary>Keeps only <c>[A-Za-z0-9._-]</c>, so path traversal, separators and control characters cannot survive.</summary>
    public static string SanitiseFileName(string? fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName))
        {
            return FallbackFileName;
        }

        var builder = new StringBuilder(fileName.Length);
        var lastWasSeparator = false;
        foreach (var c in fileName.Trim())
        {
            if (c is >= 'a' and <= 'z' or >= 'A' and <= 'Z' or >= '0' and <= '9' or '.' or '-')
            {
                builder.Append(c);
                lastWasSeparator = false;
                continue;
            }

            if (lastWasSeparator)
            {
                continue;
            }

            builder.Append('_');
            lastWasSeparator = true;
        }

        var sanitised = builder.ToString().Trim('_', '.', '-');
        if (sanitised.Length > FileNameSegmentMaxLength)
        {
            sanitised = sanitised[^FileNameSegmentMaxLength..];
            sanitised = sanitised.Trim('_', '.', '-');
        }

        return sanitised.Length == 0 ? FallbackFileName : sanitised;
    }

    private static string Slug(string? value, string fallback)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return fallback;
        }

        var builder = new StringBuilder(value.Length);
        foreach (var c in value.Trim())
        {
            builder.Append(c is >= 'a' and <= 'z' or >= 'A' and <= 'Z' or >= '0' and <= '9'
                ? char.ToLowerInvariant(c)
                : '_');
        }

        var slug = builder.ToString().Trim('_');
        return slug.Length == 0 ? fallback : slug;
    }
}

/// <summary>Values of <c>common_attachment.attachment_type</c> (contract <c>AttachmentType</c>).</summary>
public static class AttachmentTypes
{
    public const string Quotation = "QUOTATION";
    public const string Invoice = "INVOICE";
    public const string DeliveryNote = "DELIVERY_NOTE";
    public const string Certificate = "CERTIFICATE";
    public const string TempPhoto = "TEMP_PHOTO";
    public const string WastePhoto = "WASTE_PHOTO";
    public const string DiscrepancyPhoto = "DISCREPANCY_PHOTO";
    public const string ProductImage = "PRODUCT_IMAGE";
    public const string Contract = "CONTRACT";
    public const string Other = "OTHER";

    public static IReadOnlySet<string> All { get; } = new HashSet<string>(StringComparer.Ordinal)
    {
        Quotation, Invoice, DeliveryNote, Certificate, TempPhoto,
        WastePhoto, DiscrepancyPhoto, ProductImage, Contract, Other,
    };

    public static bool IsKnown(string? value) => value is not null && All.Contains(value);
}

/// <summary>Values of <c>common_attachment.entity_type</c> (contract <c>EntityType</c>).</summary>
public static class AttachmentEntityTypes
{
    public static IReadOnlySet<string> All { get; } = new HashSet<string>(StringComparer.Ordinal)
    {
        "PRODUCT",
        "SUPPLIER",
        "SUPPLIER_CERTIFICATE",
        "GOODS_RECEIPT",
        "ISSUE",
        "COUNT",
        "WASTE",
        "SAMPLE",
        "RETURN_TO_VENDOR",
        "REQUISITION",
        "RFQ",
        "QUOTATION",
        "PURCHASE_ORDER",
        "USER",
    };

    public static bool IsKnown(string? value) => value is not null && All.Contains(value);
}
