using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_product_category</c> (spec §8).</summary>
public sealed class ProductCategory : Entity<uint>, ITenantEntity
{
    private ProductCategory()
    {
    }

    public uint TenantId { get; private set; }

    public uint? ParentId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public ProductType ProductType { get; private set; }

    /// <summary>Materialised path, e.g. <c>/NON_FOOD/CHEMICAL</c>.</summary>
    public string Path { get; private set; } = "/";

    public static ProductCategory Create(uint tenantId, string code, string name, ProductType productType, uint? parentId = null, string? parentPath = null)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(code);
        var normalizedCode = code.Trim().ToUpperInvariant();
        return new ProductCategory
        {
            TenantId = tenantId,
            ParentId = parentId,
            Code = normalizedCode,
            Name = (name ?? string.Empty).Trim(),
            ProductType = productType,
            Path = string.Concat(parentPath?.TrimEnd('/') ?? string.Empty, "/", normalizedCode),
        };
    }
}
