using Wms.Common.Application.Paging;
using Wms.Inventory.Application.Dtos;

namespace Wms.Inventory.Application.Abstractions;

public sealed record BalanceFilter(uint? LocationId, uint? ProductId, IReadOnlyCollection<uint> VisibleLocationIds);

/// <summary>Read side (<c>AsNoTracking</c>). Cost fields are dropped when <paramref name="includeCost"/> is false (spec §16).</summary>
public interface IStockBalanceQueries
{
    Task<PagedResult<StockBalanceDto>> GetBalancesAsync(BalanceFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken);
}

public interface IGoodsReceiptQueries
{
    Task<GoodsReceiptDto?> GetAsync(long receiptId, bool includeCost, CancellationToken cancellationToken);
}
