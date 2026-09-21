namespace Wms.Procurement.Contracts;

public sealed record PurchaseOrderLineDto(long Id, ushort LineNo, uint ProductId, decimal Qty, ushort UomId, decimal UnitPrice, decimal ReceivedQty);

public sealed record PurchaseOrderDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    uint SupplierId,
    string Currency,
    decimal FxRate,
    string Status,
    uint DeliveryLocationId,
    IReadOnlyList<PurchaseOrderLineDto> Lines);

/// <summary>Lets Inventory pre-fill a goods receipt from an approved PO (spec §12.8).</summary>
public interface IPurchaseOrderReader
{
    Task<PurchaseOrderDto?> GetAsync(long purchaseOrderId, CancellationToken cancellationToken);
}

public static class ProcurementRoutes
{
    public const string ModuleName = "Procurement";
    public const string Prefix = "/api/v1/procurement";
    public const string InternalPurchaseOrder = Prefix + "/internal/purchase-orders/{purchaseOrderId}";
}
