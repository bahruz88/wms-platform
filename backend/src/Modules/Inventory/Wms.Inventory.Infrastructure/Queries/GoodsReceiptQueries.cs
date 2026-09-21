using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Queries;

public sealed class GoodsReceiptQueries(InventoryDbContext db) : IGoodsReceiptQueries
{
    public async Task<GoodsReceiptDto?> GetAsync(long receiptId, bool includeCost, CancellationToken cancellationToken)
    {
        var receipt = await db.GoodsReceipts.AsNoTracking()
            .Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == receiptId, cancellationToken)
            .ConfigureAwait(false);
        if (receipt is null)
        {
            return null;
        }

        return new GoodsReceiptDto(
            receipt.Id,
            receipt.DocNo,
            receipt.DocDate,
            receipt.PoId,
            receipt.SupplierId,
            receipt.LocationId,
            receipt.TemperatureC,
            UpperSnakeCaseEnum.Format(receipt.QualityStatus),
            receipt.PackagingNote,
            UpperSnakeCaseEnum.Format(receipt.Status),
            receipt.MovementGroupId,
            receipt.CreatedAt,
            receipt.CreatedBy,
            receipt.RowVersion,
            receipt.Lines.OrderBy(l => l.LineNo).Select(l => new GoodsReceiptLineDto(
                l.Id,
                l.LineNo,
                l.ProductId,
                l.PoLineId,
                l.OrderedQty,
                l.ReceivedQty,
                l.RejectedQty,
                l.UomId,
                l.BatchNo,
                l.ProductionDate,
                l.ExpiryDate,
                includeCost ? l.UnitPrice : null,
                includeCost ? l.Currency : null,
                l.VarianceNote)).ToList());
    }
}
