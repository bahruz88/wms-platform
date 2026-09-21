using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_product_category</c> (spec §8).</summary>
public sealed class ProductCategory : Entity<uint>, ITenantEntity, IVersioned
{
    public const int CodeMaxLength = 32;
    public const int NameMaxLength = 150;
    public const int PathMaxLength = 500;

    private ProductCategory()
    {
    }

    public uint TenantId { get; private set; }

    public uint? ParentId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    /// <summary>Immutable after creation: products already hang off the category (spec §8).</summary>
    public ProductType ProductType { get; private set; }

    /// <summary>Materialised path, e.g. <c>/NON_FOOD/CHEMICAL</c>.</summary>
    public string Path { get; private set; } = "/";

    /// <summary>Category-level default; the product overrides it (spec §12.4).</summary>
    public IssueStrategy? DefaultIssueStrategy { get; private set; }

    public bool IsActive { get; private set; } = true;

    public uint RowVersion { get; private set; } = 1;

    public static ProductCategory Create(
        uint tenantId,
        string code,
        string name,
        ProductType productType,
        uint? parentId = null,
        string? parentPath = null,
        IssueStrategy? defaultIssueStrategy = null)
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
            Path = BuildPath(parentPath, normalizedCode),
            DefaultIssueStrategy = defaultIssueStrategy,
        };
    }

    public static string BuildPath(string? parentPath, string code) =>
        string.Concat(parentPath?.TrimEnd('/') ?? string.Empty, "/", code);

    public void BumpVersion() => RowVersion++;

    public Result Rename(string name)
    {
        var normalized = (name ?? string.Empty).Trim();
        if (normalized.Length is 0 or > NameMaxLength)
        {
            return MasterDataErrors.InvalidCategory("name must be 1..150 characters.");
        }

        Name = normalized;
        return Result.Success();
    }

    /// <summary>Spec §8: the FOOD / NON_FOOD split drives storage rules, so it cannot move under existing products.</summary>
    public Result ChangeProductType(ProductType? productType)
    {
        if (productType is not { } requested || requested == ProductType)
        {
            return Result.Success();
        }

        return MasterDataErrors.ProductTypeImmutable(ProductType.ToString(), requested.ToString());
    }

    public Result Reparent(uint? parentId, string? parentPath)
    {
        if (parentId == Id && parentId is not null)
        {
            return MasterDataErrors.CategoryCycle(Id);
        }

        var path = BuildPath(parentPath, Code);
        if (path.Length > PathMaxLength)
        {
            return MasterDataErrors.InvalidCategory("The resulting category path exceeds 500 characters.");
        }

        ParentId = parentId;
        Path = path;
        return Result.Success();
    }

    /// <summary>Rewrites the materialised path after an ancestor moved.</summary>
    public Result RebuildPath(string? parentPath)
    {
        var path = BuildPath(parentPath, Code);
        if (path.Length > PathMaxLength)
        {
            return MasterDataErrors.InvalidCategory("The resulting category path exceeds 500 characters.");
        }

        Path = path;
        return Result.Success();
    }

    public void SetDefaultIssueStrategy(IssueStrategy? issueStrategy) => DefaultIssueStrategy = issueStrategy;

    public void SetActive(bool isActive) => IsActive = isActive;
}
