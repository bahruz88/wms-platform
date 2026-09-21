using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;

namespace Wms.Procurement.Application.Queries;

/// <summary><c>GET /api/v1/procurement/purchase-orders</c>.</summary>
public sealed record GetPurchaseOrdersQuery(uint? SupplierId, string? Status, PageRequest Page) : IQuery<PagedResult<PurchaseOrderListItemDto>>;

public sealed class GetPurchaseOrdersQueryHandler(IProcurementQueries queries) : IQueryHandler<GetPurchaseOrdersQuery, PagedResult<PurchaseOrderListItemDto>>
{
    public async Task<Result<PagedResult<PurchaseOrderListItemDto>>> HandleAsync(GetPurchaseOrdersQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new PurchaseOrderFilter(query.SupplierId, query.Status);
        return await queries.GetPurchaseOrdersAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}
