using Wms.Inventory.Application.Commands.GoodsReceipts;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Endpoints;

public sealed record GoodsReceiptLineRequest(
    uint ProductId,
    decimal ReceivedQty,
    ushort UomId,
    long? PoLineId,
    decimal? OrderedQty,
    decimal RejectedQty,
    string? BatchNo,
    DateOnly? ProductionDate,
    DateOnly? ExpiryDate,
    decimal? UnitPrice,
    string? Currency,
    string? VarianceNote);

/// <summary>Body of <c>POST /api/v1/inventory/goods-receipts</c>. Quantities are JSON strings (<c>"12.5000"</c>).</summary>
public sealed record CreateGoodsReceiptRequest(
    DateOnly DocDate,
    long? PurchaseOrderId,
    uint SupplierId,
    uint LocationId,
    decimal? TemperatureC,
    QualityStatus QualityStatus,
    string? PackagingNote,
    List<GoodsReceiptLineRequest> Lines)
{
    public CreateGoodsReceiptCommand ToCommand() => new(
        DocDate,
        PurchaseOrderId,
        SupplierId,
        LocationId,
        TemperatureC,
        QualityStatus,
        PackagingNote,
        (Lines ?? []).Select(l => new CreateGoodsReceiptLine(
            l.ProductId, l.ReceivedQty, l.UomId, l.PoLineId, l.OrderedQty, l.RejectedQty,
            l.BatchNo, l.ProductionDate, l.ExpiryDate, l.UnitPrice, l.Currency, l.VarianceNote)).ToList());
}

public sealed record CreatedResponse(long Id);

/// <summary>Query string of <c>GET /api/v1/inventory/balances</c>.</summary>
public sealed record BalancesRequest(uint? LocationId, uint? ProductId, int? Page, int? Size);
