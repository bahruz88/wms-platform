using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Application.Dtos;

/// <summary><c>common.v1.yaml#/components/schemas/AuditFields</c> (spec §6.2).</summary>
public sealed record AuditFieldsDto(
    DateTimeOffset CreatedAt,
    uint CreatedBy,
    DateTimeOffset? UpdatedAt,
    uint? UpdatedBy,
    uint RowVersion);

// ==================================================================== products

/// <summary><c>ProductSummary</c> — the list row and the shape other screens embed.</summary>
public sealed record ProductSummaryDto(
    uint Id,
    string Sku,
    string Name,
    string? Barcode,
    ushort BaseUomId,
    string BaseUomCode,
    ProductType ProductType,
    bool RequiresBatch,
    bool RequiresExpiry,
    bool IsActive);

/// <summary><c>ProductUom</c> — one versioned conversion factor row (spec §12.1).</summary>
public sealed record ProductUomDto(
    uint Id,
    uint ProductId,
    ushort UomId,
    string UomCode,
    decimal FactorToBase,
    bool IsPurchaseDefault,
    bool IsIssueDefault,
    DateOnly ValidFrom,
    DateOnly? ValidTo);

/// <summary><c>Product</c> — the full card returned by get/create/update.</summary>
public sealed record ProductDetailDto(
    uint Id,
    string Sku,
    string Name,
    string? Barcode,
    ushort BaseUomId,
    string BaseUomCode,
    ProductType ProductType,
    bool RequiresBatch,
    bool RequiresExpiry,
    bool IsActive,
    uint CategoryId,
    string CategoryPath,
    string? Brand,
    uint? DefaultSupplierId,
    decimal? MinStock,
    decimal? MaxStock,
    decimal? ReorderPoint,
    decimal VatRate,
    IssueStrategy IssueStrategy,
    ushort? ShelfLifeDays,
    long? ImageAttachmentId,
    IReadOnlyList<ProductUomDto> Uoms,
    AuditFieldsDto Audit);

// ==================================================================== categories

public sealed record CategoryDto(
    uint Id,
    uint? ParentId,
    string Code,
    string Name,
    ProductType ProductType,
    string Path,
    IssueStrategy? DefaultIssueStrategy,
    bool IsActive,
    uint RowVersion);

// ==================================================================== units of measure

public sealed record UomDto(
    ushort Id,
    string Code,
    string Name,
    UomClass UomClass,
    byte Decimals);

// ==================================================================== suppliers

public sealed record SupplierSummaryDto(
    uint Id,
    string Code,
    string Name,
    string? TaxId,
    string Currency,
    bool IsApprovedFoodSupplier,
    bool IsActive);

public sealed record SupplierCertificateDto(
    uint Id,
    uint SupplierId,
    string CertType,
    string? CertNumber,
    DateOnly? IssuedDate,
    DateOnly? ExpiryDate,
    long? AttachmentId,
    bool IsExpired);

public sealed record SupplierDetailDto(
    uint Id,
    string Code,
    string Name,
    string? TaxId,
    string Currency,
    bool IsApprovedFoodSupplier,
    bool IsActive,
    string? ContactPerson,
    string? Phone,
    string? Email,
    string? Address,
    string? BankDetails,
    string? PaymentTerms,
    string? DeliveryTerms,
    string? Incoterms,
    IReadOnlyList<SupplierCertificateDto> Certificates,
    AuditFieldsDto Audit);

// ==================================================================== locations

public sealed record LocationDetailDto(
    uint Id,
    uint? ParentId,
    string Code,
    string Name,
    LocationType LocationType,
    bool IsVirtual,
    bool AllowsFood,
    bool AllowsNonFood,
    bool IsActive,
    uint RowVersion);

// ==================================================================== currency rates

public sealed record CurrencyRateDto(
    uint Id,
    string Currency,
    DateOnly RateDate,
    decimal RateToBase,
    string Source);

// ==================================================================== reason codes

public sealed record ReasonCodeDto(
    ushort Id,
    string Code,
    string Name,
    ReasonGroup ReasonGroup,
    bool RequiresApproval,
    bool RequiresPhoto,
    bool IsActive,
    uint RowVersion);

// ==================================================================== number sequences

public sealed record NumberSequenceDto(
    uint Id,
    string DocType,
    string Prefix,
    string Period,
    uint LastNumber,
    byte Padding,
    string NextNumberPreview);
