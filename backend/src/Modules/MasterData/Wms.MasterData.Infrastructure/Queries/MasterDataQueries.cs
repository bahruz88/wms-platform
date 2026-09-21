using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.MasterData.Infrastructure.Queries;

public sealed class MasterDataQueries(MasterDataDbContext db) : IMasterDataQueries
{
    public async Task<PagedResult<ProductListItemDto>> GetProductsAsync(ProductFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Products.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(p => p.Sku.Contains(search) || p.Name.Contains(search));
        }

        if (filter.CategoryId is { } categoryId)
        {
            query = query.Where(p => p.CategoryId == categoryId);
        }

        if (filter.IsActive is { } isActive)
        {
            query = query.Where(p => p.IsActive == isActive);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderBy(p => p.NameSortKey)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(p => new
            {
                p.Id, p.Sku, p.Name, p.CategoryId, p.BaseUomId, p.RequiresBatch, p.RequiresExpiry,
                p.IssueStrategy, p.MinStock, p.MaxStock, p.IsActive,
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows.Select(p => new ProductListItemDto(
            p.Id, p.Sku, p.Name, p.CategoryId, p.BaseUomId, p.RequiresBatch, p.RequiresExpiry,
            UpperSnakeCaseEnum.Format(p.IssueStrategy), p.MinStock, p.MaxStock, p.IsActive)).ToList();

        return new PagedResult<ProductListItemDto>(items, page.Page, page.Size, total);
    }

    public async Task<PagedResult<LocationListItemDto>> GetLocationsAsync(PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(page);
        var query = db.Locations.AsNoTracking();
        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderBy(l => l.Code)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(l => new { l.Id, l.Code, l.Name, l.LocationType, l.ParentId, l.IsVirtual, l.IsActive })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows.Select(l => new LocationListItemDto(
            l.Id, l.Code, l.Name, UpperSnakeCaseEnum.Format(l.LocationType), l.ParentId, l.IsVirtual, l.IsActive)).ToList();

        return new PagedResult<LocationListItemDto>(items, page.Page, page.Size, total);
    }
}
