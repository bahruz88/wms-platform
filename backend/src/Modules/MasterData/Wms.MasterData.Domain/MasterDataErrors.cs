using System.Globalization;
using Wms.Common.Domain;

namespace Wms.MasterData.Domain;

public static class MasterDataErrors
{
    // ------------------------------------------------------------------ shape / value validation (422)

    public static Error InvalidProduct(string reason) => new("INVALID_PRODUCT", reason, 422);

    public static Error InvalidUom(string reason) => new("INVALID_UOM", reason, 422);

    public static Error InvalidLocation(string reason) => new("INVALID_LOCATION", reason, 422);

    public static Error InvalidSupplier(string reason) => new("INVALID_SUPPLIER", reason, 422);

    public static Error InvalidFactor(string reason) => new("INVALID_FACTOR", reason, 422);

    public static Error InvalidCategory(string reason) => new("INVALID_CATEGORY", reason, 422);

    public static Error InvalidReasonCode(string reason) => new("INVALID_REASON_CODE", reason, 422);

    public static Error InvalidCurrencyRate(string reason) => new("INVALID_CURRENCY_RATE", reason, 422);

    public static Error InvalidCertificate(string reason) => new("INVALID_CERTIFICATE", reason, 422);

    // ------------------------------------------------------------------ immutability after creation (422)
    // Spec §12.1, §12.3, §12.6: these four columns are frozen once a row exists because posted movements,
    // ledger counter-accounts and audit history were written against them.

    public static Error SkuImmutable(string currentSku, string attemptedSku) => new(
        "SKU_IMMUTABLE",
        $"sku cannot change after creation ('{currentSku}' -> '{attemptedSku}'): posted movements reference it. Deactivate this product and create a new one instead.",
        422);

    public static Error BaseUomImmutable(ushort currentBaseUomId, ushort attemptedBaseUomId) => new(
        "BASE_UOM_IMMUTABLE",
        $"base_uom_id cannot change after creation ({currentBaseUomId} -> {attemptedBaseUomId}): every balance and ledger quantity is stored in it. Add an alternative UoM with a conversion factor instead.",
        422);

    public static Error LocationTypeImmutable(string currentType, string attemptedType) => new(
        "LOCATION_TYPE_IMMUTABLE",
        $"location_type cannot change after creation ('{currentType}' -> '{attemptedType}'): the double-entry ledger is posted against it. Deactivate this location and create a new one instead.",
        422);

    public static Error ReasonGroupImmutable(string currentGroup, string attemptedGroup) => new(
        "REASON_GROUP_IMMUTABLE",
        $"reason_group cannot change after creation ('{currentGroup}' -> '{attemptedGroup}'): posted waste, adjustment and return documents reference it. Deactivate this reason code and create a new one instead.",
        422);

    public static Error ProductTypeImmutable(string currentType, string attemptedType) => new(
        "PRODUCT_TYPE_IMMUTABLE",
        $"product_type cannot change after creation ('{currentType}' -> '{attemptedType}'): products already hang off this category. Create a new category and move the products instead.",
        422);

    // ------------------------------------------------------------------ versioned conversion factors (422)

    /// <summary>Spec §12.1: <c>factor_to_base</c> is never UPDATEd, so validity windows of one (product, uom) may not overlap.</summary>
    public static Error UomValidityOverlap(ushort uomId, DateOnly validFrom) => new(
        "UOM_VALIDITY_OVERLAP",
        string.Create(
            CultureInfo.InvariantCulture,
            $"A factor for uom {uomId} is already valid on {validFrom:yyyy-MM-dd}. A new factor must start after the last validity window ends; factors are versioned, never overwritten."),
        422);

    public static Error VirtualLocationExists(string locationType) => new(
        "VIRTUAL_LOCATION_EXISTS",
        $"The tenant already has a '{locationType}' virtual location; exactly one counter-account per type is allowed (spec §12.3).",
        422);

    public static Error CategoryCycle(uint categoryId) => new(
        "CATEGORY_CYCLE",
        $"Category {categoryId} cannot be moved under one of its own descendants.",
        422);

    // ------------------------------------------------------------------ not found (404)

    public static Error ProductNotFound(uint productId) => new("PRODUCT_NOT_FOUND", $"Product {productId} was not found.", 404);

    public static Error LocationNotFound(uint locationId) => new("LOCATION_NOT_FOUND", $"Location {locationId} was not found.", 404);

    public static Error CategoryNotFound(uint categoryId) => new("CATEGORY_NOT_FOUND", $"Category {categoryId} was not found.", 404);

    public static Error UomNotFound(ushort uomId) => new("UOM_NOT_FOUND", $"Unit of measure {uomId} was not found.", 404);

    public static Error SupplierNotFound(uint supplierId) => new("SUPPLIER_NOT_FOUND", $"Supplier {supplierId} was not found.", 404);

    public static Error ReasonCodeNotFound(ushort reasonCodeId) => new("REASON_CODE_NOT_FOUND", $"Reason code {reasonCodeId} was not found.", 404);

    // ------------------------------------------------------------------ uniqueness conflicts (409)
    // Answered before the INSERT so a unique-index violation never surfaces as a 500.

    public static Error SkuAlreadyExists(string sku) => new("SKU_ALREADY_EXISTS", $"A product with sku '{sku}' already exists in this tenant.", 409);

    public static Error CategoryCodeAlreadyExists(string code) => new("CATEGORY_CODE_ALREADY_EXISTS", $"A category with code '{code}' already exists in this tenant.", 409);

    public static Error UomCodeAlreadyExists(string code) => new("UOM_CODE_ALREADY_EXISTS", $"A unit of measure with code '{code}' already exists in this tenant.", 409);

    public static Error SupplierCodeAlreadyExists(string code) => new("SUPPLIER_CODE_ALREADY_EXISTS", $"A supplier with code '{code}' already exists in this tenant.", 409);

    public static Error LocationCodeAlreadyExists(string code) => new("LOCATION_CODE_ALREADY_EXISTS", $"A location with code '{code}' already exists in this tenant.", 409);

    public static Error ReasonCodeAlreadyExists(string code) => new("REASON_CODE_ALREADY_EXISTS", $"A reason code with code '{code}' already exists in this tenant.", 409);

    public static Error CurrencyRateAlreadyExists(string currency, DateOnly rateDate) => new(
        "CURRENCY_RATE_ALREADY_EXISTS",
        string.Create(CultureInfo.InvariantCulture, $"A rate for {currency} on {rateDate:yyyy-MM-dd} was inserted concurrently; reload and retry."),
        409);

    public static Error NumberSequenceExhausted(string docType) =>
        new("NUMBER_SEQUENCE_EXHAUSTED", $"Number sequence for '{docType}' exceeded its padding width.", 409);
}
