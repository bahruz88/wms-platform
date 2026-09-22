using Wms.Common.Domain;

namespace Wms.Procurement.Domain.Entities;

/// <summary>
/// <c>proc_purchase_order_line</c>. Per <c>procurement.v1.yaml</c> the stored
/// <see cref="LineTotal"/> is <c>qty × unitPrice × (1 + vatRate/100)</c>, i.e. VAT included;
/// the PO header's <c>subtotal</c> is the sum of the net amounts.
/// </summary>
public sealed class PurchaseOrderLine : Entity<long>, ITenantEntity
{
    private PurchaseOrderLine()
    {
    }

    public uint TenantId { get; private set; }

    public long PoId { get; private set; }

    public ushort LineNo { get; private set; }

    public long? RequisitionLineId { get; private set; }

    public uint ProductId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    public decimal UnitPrice { get; private set; }

    public decimal VatRate { get; private set; }

    public decimal LineTotal { get; private set; }

    public decimal ReceivedQty { get; private set; }

    internal static Result<PurchaseOrderLine> Create(
        uint tenantId,
        ushort lineNo,
        uint productId,
        decimal qty,
        ushort uomId,
        decimal unitPrice,
        decimal vatRate,
        long? requisitionLineId)
    {
        if (productId == 0 || uomId == 0)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Line {lineNo}: product_id and uom_id are required.");
        }

        if (qty <= 0m)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Line {lineNo}: qty must be positive.");
        }

        if (unitPrice < 0m)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Line {lineNo}: unit_price cannot be negative.");
        }

        if (vatRate is < 0m or > 100m)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Line {lineNo}: vat_rate must be between 0 and 100.");
        }

        var net = Quantity.Round(qty * unitPrice, Money.StorageDecimals);
        return new PurchaseOrderLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            RequisitionLineId = requisitionLineId,
            ProductId = productId,
            Qty = Quantity.Round(qty, Quantity.StorageDecimals),
            UomId = uomId,
            UnitPrice = Quantity.Round(unitPrice, Money.StorageDecimals),
            VatRate = vatRate,
            LineTotal = Quantity.Round(net + (net * vatRate / 100m), Money.StorageDecimals),
        };
    }

    /// <summary>Net amount, VAT excluded — the PO header's <c>subtotal</c> is the sum of these.</summary>
    public decimal LineNet() => Quantity.Round(Qty * UnitPrice, Money.StorageDecimals);

    public decimal VatAmount() => Quantity.Round(LineNet() * VatRate / 100m, Money.StorageDecimals);

    public decimal RemainingQty() => Math.Max(0m, Qty - ReceivedQty);

    public bool IsFullyReceived() => ReceivedQty >= Qty;

    internal Result RegisterReceipt(decimal receivedQty)
    {
        if (receivedQty <= 0m)
        {
            return ProcurementErrors.InvalidPurchaseOrder("Received quantity must be positive.");
        }

        ReceivedQty = Quantity.Round(ReceivedQty + receivedQty, Quantity.StorageDecimals);
        return Result.Success();
    }
}
