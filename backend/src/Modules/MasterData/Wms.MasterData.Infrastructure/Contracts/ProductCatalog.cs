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

        var id = (uint)productId;
        var row = await db.Products.AsNoTracking()
            .Where(p => p.Id == id)
            .Select(p => new
            {
                p.Id, p.Sku, p.Name, p.CategoryId, p.BaseUomId, p.RequiresBatch, p.RequiresExpiry,
                p.IssueStrategy, p.ShelfLifeDays, p.MinStock, p.MaxStock, p.ReorderPoint, p.VatRate, p.IsActive,
            })
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
        if (row is null)
        {
            return null;
        }

        var category = await db.Categories.AsNoTracking()
            .Where(c => c.Id == row.CategoryId)
            .Select(c => c.ProductType)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        var uom = await db.Uoms.AsNoTracking()
            .Where(u => u.Id == row.BaseUomId)
            .Select(u => new { u.Code, u.Decimals })
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        return new ProductDto(
            row.Id,
            row.Sku,
            row.Name,
            row.CategoryId,
            UpperSnakeCaseEnum.Format(category),
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
