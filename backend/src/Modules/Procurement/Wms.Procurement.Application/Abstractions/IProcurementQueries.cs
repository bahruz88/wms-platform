using Wms.Common.Application.Paging;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Contracts;

namespace Wms.Procurement.Application.Abstractions;

public sealed record PurchaseOrderFilter(uint? SupplierId, string? Status);

public interface IProcurementQueries
{
    Task<PagedResult<PurchaseOrderListItemDto>> GetPurchaseOrdersAsync(PurchaseOrderFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<PurchaseOrderDto?> GetPurchaseOrderAsync(long purchaseOrderId, CancellationToken cancellationToken);
}
