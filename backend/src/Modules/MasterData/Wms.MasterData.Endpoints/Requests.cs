using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Application.Commands;

namespace Wms.MasterData.Endpoints;

/// <summary>
/// Parses an UPPER_SNAKE query-string enum (<c>?productType=NON_FOOD</c>). Minimal API's own binder only matches the
/// PascalCase member name, so <c>NON_FOOD</c> would silently fail to bind.
/// </summary>
public static class EnumQuery
{
    public static bool TryParse<TEnum>(string? raw, out TEnum? value)
        where TEnum : struct, Enum
    {
        value = null;
        if (string.IsNullOrWhiteSpace(raw))
        {
            return true;
        }

        var trimmed = raw.Trim();
        foreach (var candidate in Enum.GetValues<TEnum>())
        {
            if (string.Equals(UpperSnakeCaseEnum.Format(candidate), trimmed, StringComparison.OrdinalIgnoreCase))
            {
                value = candidate;
                return true;
            }
        }

        return false;
    }

    public static string Invalid<TEnum>(string parameter, string? raw)
        where TEnum : struct, Enum
        => $"'{raw}' is not a valid {parameter}; expected one of {string.Join(", ", UpperSnakeCaseEnum.Names<TEnum>())}.";
}

// ==================================================================== query strings

/// <summary>Query string of <c>GET /masterdata/products</c>.</summary>
public sealed record ProductsRequest(
    string? Q,
    uint? CategoryId,
    string? ProductType,
    uint? SupplierId,
    string? Barcode,
    bool? IsActive,
    int? Page,
    int? Size,
    string? Sort);

/// <summary>Query string of <c>GET /masterdata/suppliers</c>.</summary>
public sealed record SuppliersRequest(
    string? Q,
    bool? ApprovedFoodOnly,
    bool? IsActive,
    int? Page,
    int? Size,
    string? Sort);

/// <summary>Query string of <c>GET /masterdata/locations</c>.</summary>
public sealed record LocationsRequest(string? LocationType, uint? ParentId, bool? IncludeVirtual, bool? IsActive);

/// <summary>Query string of <c>GET /masterdata/currency-rates</c>.</summary>
public sealed record CurrencyRatesRequest(
    string? Currency,
    DateOnly? Date,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    int? Page,
    int? Size);

// ==================================================================== products

/// <summary><c>ProductUomCreate</c>.</summary>
public sealed record ProductUomCreateRequest(
    ushort UomId,
    decimal FactorToBase,
    bool? IsPurchaseDefault,
    bool? IsIssueDefault,
    DateOnly ValidFrom)
{
    public ProductUomInput ToInput() => new(UomId, FactorToBase, IsPurchaseDefault ?? false, IsIssueDefault ?? false, ValidFrom);
}

/// <summary><c>ProductCreate</c>.</summary>
public sealed record ProductCreateRequest(
    string? Sku,
    string? Name,
    string? Barcode,
    uint CategoryId,
    string? Brand,
    ushort BaseUomId,
    uint? DefaultSupplierId,
    decimal? MinStock,
    decimal? MaxStock,
    decimal? ReorderPoint,
    decimal? VatRate,
    bool? RequiresBatch,
    bool? RequiresExpiry,
    Domain.Enums.IssueStrategy? IssueStrategy,
    ushort? ShelfLifeDays,
    List<ProductUomCreateRequest>? AdditionalUoms);

/// <summary>
/// <c>ProductUpdate</c>. <c>sku</c> and <c>baseUomId</c> are not part of the contract body but are accepted so a
/// client that tries to change them receives <c>422 SKU_IMMUTABLE</c> / <c>422 BASE_UOM_IMMUTABLE</c> rather than a
/// silently ignored field.
/// </summary>
public sealed record ProductUpdateRequest(
    string? Name,
    string? Barcode,
    uint CategoryId,
    string? Brand,
    uint? DefaultSupplierId,
    decimal? MinStock,
    decimal? MaxStock,
    decimal? ReorderPoint,
    decimal VatRate,
    bool RequiresBatch,
    bool RequiresExpiry,
    Domain.Enums.IssueStrategy IssueStrategy,
    ushort? ShelfLifeDays,
    long? ImageAttachmentId,
    bool IsActive,
    uint RowVersion,
    string? Sku,
    ushort? BaseUomId);

// ==================================================================== categories

/// <summary><c>CategoryCreate</c>.</summary>
public sealed record CategoryCreateRequest(
    uint? ParentId,
    string? Code,
    string? Name,
    Domain.Enums.ProductType ProductType,
    Domain.Enums.IssueStrategy? DefaultIssueStrategy);

/// <summary><c>CategoryUpdate</c> (<c>productType</c> accepted only to answer <c>422 PRODUCT_TYPE_IMMUTABLE</c>).</summary>
public sealed record CategoryUpdateRequest(
    uint? ParentId,
    string? Name,
    Domain.Enums.IssueStrategy? DefaultIssueStrategy,
    bool IsActive,
    uint RowVersion,
    Domain.Enums.ProductType? ProductType);

// ==================================================================== units of measure

/// <summary><c>UomCreate</c>.</summary>
public sealed record UomCreateRequest(string? Code, string? Name, Domain.Enums.UomClass UomClass, byte? Decimals);

// ==================================================================== suppliers

/// <summary><c>SupplierCreate</c>.</summary>
public sealed record SupplierCreateRequest(
    string? Code,
    string? Name,
    string? TaxId,
    string? ContactPerson,
    string? Phone,
    string? Email,
    string? Address,
    string? BankDetails,
    string? Currency,
    string? PaymentTerms,
    string? DeliveryTerms,
    string? Incoterms,
    bool? IsApprovedFoodSupplier)
{
    public SupplierProfile ToProfile() => new(
        Name ?? string.Empty,
        TaxId,
        ContactPerson,
        Phone,
        Email,
        Address,
        BankDetails,
        (Currency ?? "AZN").Trim().ToUpperInvariant(),
        PaymentTerms,
        DeliveryTerms,
        Incoterms,
        IsApprovedFoodSupplier ?? false);
}

/// <summary><c>SupplierUpdate</c> = <c>SupplierCreate</c> + <c>isActive</c> + <c>rowVersion</c>.</summary>
public sealed record SupplierUpdateRequest(
    string? Code,
    string? Name,
    string? TaxId,
    string? ContactPerson,
    string? Phone,
    string? Email,
    string? Address,
    string? BankDetails,
    string? Currency,
    string? PaymentTerms,
    string? DeliveryTerms,
    string? Incoterms,
    bool? IsApprovedFoodSupplier,
    bool IsActive,
    uint RowVersion)
{
    public SupplierProfile ToProfile() => new(
        Name ?? string.Empty,
        TaxId,
        ContactPerson,
        Phone,
        Email,
        Address,
        BankDetails,
        (Currency ?? "AZN").Trim().ToUpperInvariant(),
        PaymentTerms,
        DeliveryTerms,
        Incoterms,
        IsApprovedFoodSupplier ?? false);
}

/// <summary><c>SupplierCertificateCreate</c>.</summary>
public sealed record SupplierCertificateCreateRequest(
    string? CertType,
    string? CertNumber,
    DateOnly? IssuedDate,
    DateOnly? ExpiryDate,
    long? AttachmentId);

// ==================================================================== locations

/// <summary><c>LocationCreate</c>.</summary>
public sealed record LocationCreateRequest(
    uint? ParentId,
    string? Code,
    string? Name,
    Domain.Enums.LocationType LocationType,
    bool? AllowsFood,
    bool? AllowsNonFood);

/// <summary><c>LocationUpdate</c> (<c>locationType</c> accepted only to answer <c>422 LOCATION_TYPE_IMMUTABLE</c>).</summary>
public sealed record LocationUpdateRequest(
    uint? ParentId,
    string? Name,
    bool AllowsFood,
    bool AllowsNonFood,
    bool IsActive,
    uint RowVersion,
    Domain.Enums.LocationType? LocationType);

// ==================================================================== currency rates

/// <summary><c>CurrencyRateUpsert</c>.</summary>
public sealed record CurrencyRateUpsertRequest(string? Currency, DateOnly RateDate, decimal RateToBase);

// ==================================================================== reason codes

/// <summary><c>ReasonCodeCreate</c>.</summary>
public sealed record ReasonCodeCreateRequest(
    string? Code,
    string? Name,
    Domain.Enums.ReasonGroup ReasonGroup,
    bool? RequiresApproval,
    bool? RequiresPhoto);

/// <summary><c>ReasonCodeUpdate</c> (<c>reasonGroup</c> accepted only to answer <c>422 REASON_GROUP_IMMUTABLE</c>).</summary>
public sealed record ReasonCodeUpdateRequest(
    string? Name,
    bool RequiresApproval,
    bool RequiresPhoto,
    bool IsActive,
    uint RowVersion,
    Domain.Enums.ReasonGroup? ReasonGroup);
