using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Persistence;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Contracts;
using Wms.Procurement.Infrastructure.Persistence;

namespace Wms.Procurement.Infrastructure.Queries;

public sealed class ProcurementQueries(ProcurementDbContext db) : IProcurementQueries
{
    public async Task<PagedResult<PurchaseOrderListItemDto>> GetPurchaseOrdersAsync(PurchaseOrderFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.PurchaseOrders.AsNoTracking();
        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(po => po.SupplierId == supplierId);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(po => po.DocDate).ThenByDescending(po => po.Id)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(po => new
            {
                po.Id, po.DocNo, po.DocDate, po.SupplierId, po.Currency, po.TotalAmount,
                po.TotalAmountBase, po.Status, po.DeliveryLocationId, po.ExpectedDate,
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows
            .Select(po => new PurchaseOrderListItemDto(
                po.Id, po.DocNo, po.DocDate, po.SupplierId, po.Currency, po.TotalAmount,
                po.TotalAmountBase, UpperSnakeCaseEnum.Format(po.Status), po.DeliveryLocationId, po.ExpectedDate))
            .Where(po => filter.Status is null || string.Equals(po.Status, filter.Status, StringComparison.OrdinalIgnoreCase))
            .ToList();

        return new PagedResult<PurchaseOrderListItemDto>(items, page.Page, page.Size, total);
    }

    public async Task<PurchaseOrderDto?> GetPurchaseOrderAsync(long purchaseOrderId, CancellationToken cancellationToken)
    {
        var po = await db.PurchaseOrders.AsNoTracking()
            .Include(x => x.Lines)
            .FirstOrDefaultAsync(x => x.Id == purchaseOrderId, cancellationToken)
            .ConfigureAwait(false);
        if (po is null)
        {
            return null;
        }

        return new PurchaseOrderDto(
            po.Id,
            po.DocNo,
            po.DocDate,
            po.SupplierId,
            po.Currency,
            po.FxRate,
            UpperSnakeCaseEnum.Format(po.Status),
            po.DeliveryLocationId,
            po.Lines.OrderBy(l => l.LineNo)
                .Select(l => new PurchaseOrderLineDto(l.Id, l.LineNo, l.ProductId, l.Qty, l.UomId, l.UnitPrice, l.ReceivedQty))
                .ToList());
    }
}
