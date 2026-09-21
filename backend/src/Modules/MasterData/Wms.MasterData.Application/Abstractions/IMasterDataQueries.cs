using Wms.Common.Application.Paging;
using Wms.MasterData.Application.Dtos;

namespace Wms.MasterData.Application.Abstractions;

public sealed record ProductFilter(string? Search, uint? CategoryId, bool? IsActive);

public interface IMasterDataQueries
{
    /// <summary>Ordered by <c>name_sort_key</c> so the Azerbaijani alphabet order is respected (spec §6.4).</summary>
    Task<PagedResult<ProductListItemDto>> GetProductsAsync(ProductFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<PagedResult<LocationListItemDto>> GetLocationsAsync(PageRequest page, CancellationToken cancellationToken);
}
