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

    private readonly List<ProductUom> _uoms = [];

    private Product()
    {
    }

    public uint TenantId { get; private set; }

    public string Sku { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public string NameSortKey { get; private set; } = string.Empty;

    public string? Barcode { get; private set; }

    public uint CategoryId { get; private set; }

    public string? Brand { get; private set; }

    /// <summary>Every balance and ledger quantity of this product is expressed in this UoM.</summary>
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

    public string? ImageKey { get; private set; }

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
        var normalizedSku = (sku ?? string.Empty).Trim().ToUpperInvariant();
        var normalizedName = (name ?? string.Empty).Trim();

        if (normalizedSku.Length is 0 or > 48)
        {
            return MasterDataErrors.InvalidProduct("sku is mandatory and must be 1..48 characters.");
        }

        if (normalizedName.Length is 0 or > 250)
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

    public Result Rename(string name)
    {
        var normalized = (name ?? string.Empty).Trim();
        if (normalized.Length is 0 or > 250)
        {
            return MasterDataErrors.InvalidProduct("name must be 1..250 characters.");
        }

        Name = normalized;
        NameSortKey = AzerbaijaniSortKey.Create(normalized);
        return Result.Success();
    }

    public void SetStockLevels(decimal? minStock, decimal? maxStock, decimal? reorderPoint)
    {
        MinStock = minStock;
        MaxStock = maxStock;
        ReorderPoint = reorderPoint;
    }

    public void SetBarcode(string? barcode) => Barcode = string.IsNullOrWhiteSpace(barcode) ? null : barcode.Trim();

    public void SetDefaultSupplier(uint? supplierId) => DefaultSupplierId = supplierId;

    public void SetShelfLife(ushort? shelfLifeDays) => ShelfLifeDays = shelfLifeDays;

    public void SetImageKey(string? imageKey) => ImageKey = imageKey;

    /// <summary>
    /// Adds an alternative UoM. Changing an existing factor is forbidden (spec §12.1): the current row is closed with
    /// <c>valid_to</c> and a new one opens, so frozen <c>conversion_rate</c> values in the ledger stay correct.
    /// </summary>
    public Result<ProductUom> AddOrReplaceUom(ushort uomId, decimal factorToBase, DateOnly validFrom, bool isPurchaseDefault = false, bool isIssueDefault = false)
    {
        if (factorToBase <= 0m)
        {
            return MasterDataErrors.InvalidFactor("factor_to_base must be positive.");
        }

        if (uomId == BaseUomId && factorToBase != 1m)
        {
            return MasterDataErrors.InvalidFactor("The base UoM factor must be exactly 1.");
        }

        var current = _uoms.Find(u => u.UomId == uomId && u.ValidTo is null);
        if (current is not null)
        {
            if (current.FactorToBase == factorToBase)
            {
                return current;
            }

            if (validFrom <= current.ValidFrom)
            {
                return MasterDataErrors.InvalidFactor("valid_from must be later than the current row's valid_from.");
            }

            current.Close(validFrom.AddDays(-1));
        }

        var replacement = ProductUom.Create(TenantId, uomId, factorToBase, validFrom, isPurchaseDefault, isIssueDefault);
        _uoms.Add(replacement);
        return replacement;
    }

    /// <summary>The factor valid on <paramref name="date"/>; null when none applies.</summary>
    public decimal? FactorOn(ushort uomId, DateOnly date) =>
        _uoms.Find(u => u.UomId == uomId && u.IsValidOn(date))?.FactorToBase;

    public void Deactivate() => IsActive = false;

    public void SoftDelete()
    {
        IsDeleted = true;
        IsActive = false;
    }

    public void Restore() => IsDeleted = false;
}
