using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Contracts;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.MasterData.Infrastructure.Contracts;

/// <summary>In-process <see cref="IProductCatalog"/> (spec §4.2).</summary>
public sealed class ProductCatalog(MasterDataDbContext db) : IProductCatalog
{
    public async Task<ProductDto?> GetAsync(long productId, CancellationToken cancellationToken)
    {
        if (productId is <= 0 or > uint.MaxValue)
        {
            return null;
        }

        var products = await GetManyAsync([(uint)productId], cancellationToken).ConfigureAwait(false);
        return products.Count == 0 ? null : products[0];
    }

    public async Task<IReadOnlyList<ProductDto>> GetManyAsync(IReadOnlyCollection<uint> productIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(productIds);
        if (productIds.Count == 0)
        {
            return [];
        }

        var ids = productIds.Distinct().ToArray();
        var rows = await db.Products.AsNoTracking()
            .Where(p => ids.Contains(p.Id))
            .Select(p => new
            {
                p.Id, p.Sku, p.Name, p.CategoryId, p.BaseUomId, p.RequiresBatch, p.RequiresExpiry,
                p.IssueStrategy, p.ShelfLifeDays, p.MinStock, p.MaxStock, p.ReorderPoint, p.VatRate, p.IsActive,
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        if (rows.Count == 0)
        {
            return [];
        }

        var categoryIds = rows.Select(r => r.CategoryId).Distinct().ToArray();
        var categories = await db.Categories.AsNoTracking()
            .Where(c => categoryIds.Contains(c.Id))
            .Select(c => new { c.Id, c.ProductType })
            .ToDictionaryAsync(c => c.Id, c => c.ProductType, cancellationToken)
            .ConfigureAwait(false);

        var uomIds = rows.Select(r => r.BaseUomId).Distinct().ToArray();
        var uoms = await db.Uoms.AsNoTracking()
            .Where(u => uomIds.Contains(u.Id))
            .Select(u => new { u.Id, u.Code, u.Decimals })
            .ToDictionaryAsync(u => u.Id, u => new { u.Code, u.Decimals }, cancellationToken)
            .ConfigureAwait(false);

        return rows.Select(row =>
        {
            uoms.TryGetValue(row.BaseUomId, out var uom);
            return new ProductDto(
                row.Id,
                row.Sku,
                row.Name,
                row.CategoryId,
                UpperSnakeCaseEnum.Format(categories.GetValueOrDefault(row.CategoryId)),
                row.BaseUomId,
                uom?.Code ?? string.Empty,
                uom?.Decimals ?? Uom.DefaultDecimals,
                row.RequiresBatch,
                row.RequiresExpiry,
                UpperSnakeCaseEnum.Format(row.IssueStrategy),
                row.ShelfLifeDays,
                row.MinStock,
                row.MaxStock,
                row.ReorderPoint,
                row.VatRate,
                row.IsActive);
        }).ToList();
    }

    public async Task<IReadOnlyList<uint>> GetIdsByCategoryAsync(IReadOnlyCollection<uint> categoryIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(categoryIds);
        if (categoryIds.Count == 0)
        {
            return [];
        }

        var ids = categoryIds.Distinct().ToArray();
        return await db.Products.AsNoTracking()
            .Where(p => ids.Contains(p.CategoryId) && p.IsActive)
            .Select(p => p.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task<decimal?> GetUomFactorAsync(long productId, long uomId, DateOnly date, CancellationToken cancellationToken)
    {
        if (productId is <= 0 or > uint.MaxValue || uomId is <= 0 or > ushort.MaxValue)
        {
            return null;
        }

        var product = (uint)productId;
        var uom = (ushort)uomId;
        return await db.ProductUoms.AsNoTracking()
            .Where(pu => pu.ProductId == product
                && pu.UomId == uom
                && pu.ValidFrom <= date
                && (pu.ValidTo == null || pu.ValidTo >= date))
            .OrderByDescending(pu => pu.ValidFrom)
            .Select(pu => (decimal?)pu.FactorToBase)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
    }
}

/// <summary>In-process <see cref="ISupplierCatalog"/> (spec §4.2).</summary>
public sealed class SupplierCatalog(MasterDataDbContext db) : ISupplierCatalog
{
    public async Task<SupplierRefDto?> GetAsync(long supplierId, CancellationToken cancellationToken)
    {
        if (supplierId is <= 0 or > uint.MaxValue)
        {
            return null;
        }

        var suppliers = await GetManyAsync([(uint)supplierId], cancellationToken).ConfigureAwait(false);
        return suppliers.Count == 0 ? null : suppliers[0];
    }

    public async Task<IReadOnlyList<SupplierRefDto>> GetManyAsync(IReadOnlyCollection<uint> supplierIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(supplierIds);
        if (supplierIds.Count == 0)
        {
            return [];
        }

        var ids = supplierIds.Distinct().ToArray();
        return await db.Suppliers.AsNoTracking()
            .Where(s => ids.Contains(s.Id))
            .Select(s => new SupplierRefDto(s.Id, s.Code, s.Name, s.Currency, s.IsApprovedFoodSupplier, s.IsActive))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
    }
}
