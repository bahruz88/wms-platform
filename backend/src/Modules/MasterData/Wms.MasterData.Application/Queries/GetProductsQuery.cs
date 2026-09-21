using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Dtos;

namespace Wms.MasterData.Application.Queries;

/// <summary><c>GET /api/v1/masterdata/products</c>.</summary>
public sealed record GetProductsQuery(string? Search, uint? CategoryId, bool? IsActive, PageRequest Page) : IQuery<PagedResult<ProductListItemDto>>;

public sealed class GetProductsQueryHandler(IMasterDataQueries queries) : IQueryHandler<GetProductsQuery, PagedResult<ProductListItemDto>>
{
    public async Task<Result<PagedResult<ProductListItemDto>>> HandleAsync(GetProductsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new ProductFilter(query.Search, query.CategoryId, query.IsActive);
        return await queries.GetProductsAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /api/v1/masterdata/locations</c>.</summary>
public sealed record GetLocationsQuery(PageRequest Page) : IQuery<PagedResult<LocationListItemDto>>;

public sealed class GetLocationsQueryHandler(IMasterDataQueries queries) : IQueryHandler<GetLocationsQuery, PagedResult<LocationListItemDto>>
{
    public async Task<Result<PagedResult<LocationListItemDto>>> HandleAsync(GetLocationsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetLocationsAsync(query.Page, cancellationToken).ConfigureAwait(false);
    }
}
