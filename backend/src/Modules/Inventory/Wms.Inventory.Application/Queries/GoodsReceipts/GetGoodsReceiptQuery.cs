using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Queries.GoodsReceipts;

/// <summary><c>GET /api/v1/inventory/goods-receipts/{id}</c>.</summary>
public sealed record GetGoodsReceiptQuery(long ReceiptId) : IQuery<GoodsReceiptDto>;

public sealed class GetGoodsReceiptQueryHandler(IGoodsReceiptQueries queries, ICurrentUser currentUser) : IQueryHandler<GetGoodsReceiptQuery, GoodsReceiptDto>
{
    public async Task<Result<GoodsReceiptDto>> HandleAsync(GetGoodsReceiptQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var includeCost = currentUser.HasPermission(InventoryPermissions.ViewCost);
        var dto = await queries.GetAsync(query.ReceiptId, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? InventoryErrors.ReceiptNotFound(query.ReceiptId) : dto;
    }
}

/// <summary><c>GET /api/v1/inventory/goods-receipts</c> (inventory.v1.yaml <c>listGoodsReceipts</c>).</summary>
public sealed record ListGoodsReceiptsQuery(
    string? Status,
    uint? SupplierId,
    uint? LocationId,
    long? PoId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    PageRequest Page) : IQuery<PagedResult<GoodsReceiptSummaryDto>>;

public sealed class ListGoodsReceiptsQueryHandler(IGoodsReceiptQueries queries, ICurrentUser currentUser)
    : IQueryHandler<ListGoodsReceiptsQuery, PagedResult<GoodsReceiptSummaryDto>>
{
    public async Task<Result<PagedResult<GoodsReceiptSummaryDto>>> HandleAsync(ListGoodsReceiptsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new GoodsReceiptFilter(
            query.Status, query.SupplierId, query.LocationId, query.PoId,
            query.DateFrom, query.DateTo, query.Search, currentUser.LocationIds);
        return await queries.ListAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}
