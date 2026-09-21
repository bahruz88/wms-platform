using Wms.Common.Application.Paging;
using Wms.Inventory.Application.Dtos;

namespace Wms.Inventory.Application.Abstractions;

/// <summary>Filters of <c>GET /inventory/balances</c> (inventory.v1.yaml). <c>VisibleLocationIds</c> is empty for unrestricted users.</summary>
public sealed record BalanceFilter(
    uint? LocationId,
    uint? ProductId,
    long? BatchId,
    uint? CategoryId,
    bool IncludeZero,
    bool? BelowMin,
    int? ExpiringWithinDays,
    string? Search,
    IReadOnlyCollection<uint> VisibleLocationIds);

/// <summary>Filters of <c>GET /inventory/goods-receipts</c> (inventory.v1.yaml).</summary>
public sealed record GoodsReceiptFilter(
    string? Status,
    uint? SupplierId,
    uint? LocationId,
    long? PoId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    IReadOnlyCollection<uint> VisibleLocationIds);

/// <summary>Read side (<c>AsNoTracking</c>). Cost fields are dropped when <paramref name="includeCost"/> is false (spec §16).</summary>
public interface IStockBalanceQueries
{
    Task<PagedResult<StockBalanceDto>> GetBalancesAsync(BalanceFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken);

    Task<BalanceSummaryDto?> GetSummaryAsync(uint productId, uint? locationId, IReadOnlyCollection<uint> visibleLocationIds, bool includeCost, CancellationToken cancellationToken);
}

/// <summary>Filters of <c>GET /inventory/counts</c>.</summary>
public sealed record CountFilter(
    string? Status,
    string? CountType,
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    IReadOnlyCollection<uint> VisibleLocationIds);

public interface IStockCountQueries
{
    Task<CountDto?> GetAsync(long countId, bool includeCost, CancellationToken cancellationToken);

    Task<PagedResult<CountSummaryDto>> ListAsync(CountFilter filter, PageRequest page, CancellationToken cancellationToken);
}

public interface IGoodsReceiptQueries
{
    Task<GoodsReceiptDto?> GetAsync(long receiptId, bool includeCost, CancellationToken cancellationToken);

    Task<PagedResult<GoodsReceiptSummaryDto>> ListAsync(GoodsReceiptFilter filter, PageRequest page, CancellationToken cancellationToken);
}
