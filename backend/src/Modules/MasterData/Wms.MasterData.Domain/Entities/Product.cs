using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary>
/// <c>master_product</c> (spec §8). <c>sku</c> is mandatory and unique per tenant, <c>name</c> is trimmed and
/// <c>name_sort_key</c> is recomputed on every rename — the three concrete fixes for the Excel data issues (spec §1.4).
/// </summary>
public sealed class Product : AuditableAggregateRoot<uint>, ITenantEntity, ISoftDeletable
{
    public const decimal DefaultVatRate = 18.0000m;
    public const int SkuMaxLength = 48;
    public const int NameMaxLength = 250;
    public const int BarcodeMaxLength = 64;
    public const int BrandMaxLength = 120;

    private readonly List<ProductUom> _uoms = [];

    private Product()
    {
    }

    public uint TenantId { get; private set; }

    /// <summary>Immutable after creation (spec §12.1): posted movements are keyed by the product, audited by its sku.</summary>
    public string Sku { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public string NameSortKey { get; private set; } = string.Empty;

    public string? Barcode { get; private set; }

    public uint CategoryId { get; private set; }

    public string? Brand { get; private set; }

    /// <summary>Every balance and ledger quantity of this product is expressed in this UoM. Immutable after creation.</summary>
    public ushort BaseUomId { get; private set; }

    public uint? DefaultSupplierId { get; private set; }

    public decimal? MinStock { get; private set; }

    public decimal? MaxStock { get; private set; }

    public decimal? ReorderPoint { get; private set; }

    public decimal VatRate { get; private set; } = DefaultVatRate;

    public bool RequiresBatch { get; private set; }

    public bool RequiresExpiry { get; private set; }

    public IssueStrategy IssueStrategy { get; private set; } = IssueStrategy.Fefo;

    public ushort? ShelfLifeDays { get; private set; }

    /// <summary>Documents-module attachment holding the product photo; stored in the <c>image_key</c> column (spec §8).</summary>
    public long? ImageAttachmentId { get; private set; }

    public bool IsActive { get; private set; } = true;

    public bool IsDeleted { get; private set; }

    public IReadOnlyList<ProductUom> Uoms => _uoms.AsReadOnly();

    public static Result<Product> Create(
        uint tenantId,
        string sku,
        string name,
        uint categoryId,
        ushort baseUomId,
        DateOnly validFrom,
        bool requiresBatch = false,
        bool requiresExpiry = false,
        IssueStrategy issueStrategy = IssueStrategy.Fefo,
        decimal vatRate = DefaultVatRate)
    {
        var normalizedSku = NormalizeSku(sku);
        var normalizedName = (name ?? string.Empty).Trim();

        if (normalizedSku.Length is 0 or > SkuMaxLength)
        {
            return MasterDataErrors.InvalidProduct("sku is mandatory and must be 1..48 characters.");
        }

        if (normalizedName.Length is 0 or > NameMaxLength)
        {
            return MasterDataErrors.InvalidProduct("name must be 1..250 characters.");
        }

        if (categoryId == 0 || baseUomId == 0)
        {
            return MasterDataErrors.InvalidProduct("category_id and base_uom_id are required.");
        }

        if (vatRate is < 0m or > 100m)
        {
            return MasterDataErrors.InvalidProduct("vat_rate must be between 0 and 100.");
        }

        var product = new Product
        {
            TenantId = tenantId,
            Sku = normalizedSku,
            Name = normalizedName,
            NameSortKey = AzerbaijaniSortKey.Create(normalizedName),
            CategoryId = categoryId,
            BaseUomId = baseUomId,
            RequiresBatch = requiresBatch,
            RequiresExpiry = requiresExpiry,
            IssueStrategy = issueStrategy,
            VatRate = vatRate,
        };

        // The base UoM always has a factor of 1 (spec §8).
        product._uoms.Add(ProductUom.CreateBase(tenantId, baseUomId, validFrom));
        return product;
    }

    public static string NormalizeSku(string? sku) => (sku ?? string.Empty).Trim().ToUpperInvariant();

    public Result Rename(string name)
    {
        var normalized = (name ?? string.Empty).Trim();
        if (normalized.Length is 0 or > NameMaxLength)
        {
            return MasterDataErrors.InvalidProduct("name must be 1..250 characters.");
        }

        Name = normalized;
        NameSortKey = AzerbaijaniSortKey.Create(normalized);
        return Result.Success();
    }

    /// <summary>
    /// Spec §12.1: the sku is frozen once the product exists. Passing the current value is a no-op; anything else
    /// is refused with <c>SKU_IMMUTABLE</c> so the rule holds without an HTTP round trip.
    /// </summary>
    public Result ChangeSku(string? sku)
    {
        var normalized = NormalizeSku(sku);
        if (normalized.Length == 0 || string.Equals(normalized, Sku, StringComparison.Ordinal))
        {
            return Result.Success();
        }

        return MasterDataErrors.SkuImmutable(Sku, normalized);
    }

    /// <summary>Spec §12.1: every balance row is denominated in the base UoM, so it can never move.</summary>
    public Result ChangeBaseUom(ushort? baseUomId)
    {
        if (baseUomId is not { } requested || requested == 0 || requested == BaseUomId)
        {
            return Result.Success();
        }

        return MasterDataErrors.BaseUomImmutable(BaseUomId, requested);
    }

    public Result SetCategory(uint categoryId)
    {
        if (categoryId == 0)
        {
            return MasterDataErrors.InvalidProduct("category_id is required.");
        }

        CategoryId = categoryId;
        return Result.Success();
    }

    public Result SetVatRate(decimal vatRate)
    {
        if (vatRate is < 0m or > 100m)
        {
            return MasterDataErrors.InvalidProduct("vat_rate must be between 0 and 100.");
        }

        VatRate = vatRate;
        return Result.Success();
    }

    public void SetStockLevels(decimal? minStock, decimal? maxStock, decimal? reorderPoint)
    {
        MinStock = minStock;
        MaxStock = maxStock;
        ReorderPoint = reorderPoint;
    }

    public void SetBarcode(string? barcode) => Barcode = string.IsNullOrWhiteSpace(barcode) ? null : barcode.Trim();

    public void SetBrand(string? brand) => Brand = string.IsNullOrWhiteSpace(brand) ? null : brand.Trim();

    public void SetDefaultSupplier(uint? supplierId) => DefaultSupplierId = supplierId;

    public void SetShelfLife(ushort? shelfLifeDays) => ShelfLifeDays = shelfLifeDays;

    /// <summary>A non-positive or legacy non-numeric value means "no image" (the column also holds old MinIO keys).</summary>
    public void SetImageAttachment(long? attachmentId) => ImageAttachmentId = attachmentId is > 0 ? attachmentId : null;

    public void SetTraceability(bool requiresBatch, bool requiresExpiry)
    {
        RequiresBatch = requiresBatch;
        RequiresExpiry = requiresExpiry;
    }

    public void SetIssueStrategy(IssueStrategy issueStrategy) => IssueStrategy = issueStrategy;

    public void SetActive(bool isActive) => IsActive = isActive;

    /// <summary>
    /// Adds an alternative UoM. Changing an existing factor is forbidden (spec §12.1): the current row is closed with
    /// <c>valid_to</c> and a new one opens, so frozen <c>conversion_rate</c> values in the ledger stay correct.
    /// </summary>
    public Result<ProductUom> AddOrReplaceUom(ushort uomId, decimal factorToBase, DateOnly validFrom, bool isPurchaseDefault = false, bool isIssueDefault = false)
    {
        if (uomId == 0)
        {
            return MasterDataErrors.InvalidFactor("uom_id is required.");
        }

        if (factorToBase <= 0m)
        {
            return MasterDataErrors.InvalidFactor("factor_to_base must be positive.");
        }

        if (uomId == BaseUomId && factorToBase != 1m)
        {
            return MasterDataErrors.InvalidFactor("The base UoM factor must be exactly 1.");
        }

        var rows = _uoms.FindAll(u => u.UomId == uomId);
        var current = rows.Find(u => u.IsOpen);

        if (current is not null && current.FactorToBase == factorToBase)
        {
            // Unchanged factor: only the purchase/issue defaults move. Never a duplicate row.
            current.SetDefaults(isPurchaseDefault, isIssueDefault);
            return current;
        }

        // A new factor may only start after every existing validity window of this UoM closed.
        if (rows.Exists(row => row.OverlapsFrom(validFrom)))
        {
            return MasterDataErrors.UomValidityOverlap(uomId, validFrom);
        }

        current?.Close(validFrom.AddDays(-1));

        var replacement = ProductUom.Create(TenantId, uomId, factorToBase, validFrom, isPurchaseDefault, isIssueDefault);
        _uoms.Add(replacement);
        return replacement;
    }

    /// <summary>The factor valid on <paramref name="date"/>; null when none applies.</summary>
    public decimal? FactorOn(ushort uomId, DateOnly date) =>
        _uoms.Find(u => u.UomId == uomId && u.IsValidOn(date))?.FactorToBase;

    /// <summary>The rows valid on <paramref name="date"/>, base UoM first, then by uom id.</summary>
    public IReadOnlyList<ProductUom> UomsOn(DateOnly date) =>
        _uoms.Where(u => u.IsValidOn(date))
            .OrderByDescending(u => u.UomId == BaseUomId)
            .ThenBy(u => u.UomId)
            .ToList();

    public void Deactivate() => IsActive = false;

    public void SoftDelete()
    {
        IsDeleted = true;
        IsActive = false;
    }

    public void Restore() => IsDeleted = false;
}
