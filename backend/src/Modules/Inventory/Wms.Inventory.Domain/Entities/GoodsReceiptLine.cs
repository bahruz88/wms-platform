using Wms.Common.Domain;

namespace Wms.Inventory.Domain.Entities;

/// <summary>Row of <c>inv_goods_receipt_line</c>. <c>received_qty</c> is the physical quantity; <c>rejected_qty</c> is the part not taken into stock.</summary>
public sealed class GoodsReceiptLine : Entity<long>, ITenantEntity
{
    public const int BatchNoMaxLength = 64;
    public const int VarianceNoteMaxLength = 500;

    private GoodsReceiptLine()
    {
    }

    public uint TenantId { get; private set; }

    public long ReceiptId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public long? PoLineId { get; private set; }

    public decimal? OrderedQty { get; private set; }

    public decimal ReceivedQty { get; private set; }

    public decimal RejectedQty { get; private set; }

    public ushort UomId { get; private set; }

    public string? BatchNo { get; private set; }

    public DateOnly? ProductionDate { get; private set; }

    public DateOnly? ExpiryDate { get; private set; }

    public decimal? UnitPrice { get; private set; }

    public string? Currency { get; private set; }

    public string? VarianceNote { get; private set; }

    /// <summary>Quantity that enters stock (entered UoM).</summary>
    public decimal QtyToStock() => ReceivedQty - RejectedQty;

    internal static Result<GoodsReceiptLine> Create(
        uint tenantId,
        ushort lineNo,
        uint productId,
        decimal receivedQty,
        ushort uomId,
        long? poLineId,
        decimal? orderedQty,
        decimal rejectedQty,
        string? batchNo,
        DateOnly? productionDate,
        DateOnly? expiryDate,
        decimal? unitPrice,
        string? currency,
        string? varianceNote)
    {
        if (productId == 0 || uomId == 0)
        {
            return InventoryErrors.InvalidReceiptLine($"Line {lineNo}: product_id and uom_id are required.");
        }

        if (receivedQty <= 0m)
        {
            return InventoryErrors.InvalidReceiptLine($"Line {lineNo}: received_qty must be positive.");
        }

        if (rejectedQty < 0m || rejectedQty > receivedQty)
        {
            return InventoryErrors.InvalidReceiptLine($"Line {lineNo}: rejected_qty must be between 0 and received_qty.");
        }

        if (unitPrice is < 0m)
        {
            return InventoryErrors.InvalidReceiptLine($"Line {lineNo}: unit_price cannot be negative.");
        }

        if (currency is not null && !Money.IsValidCurrency(currency))
        {
            return InventoryErrors.InvalidReceiptLine($"Line {lineNo}: currency must be an ISO 4217 code.");
        }

        var normalizedBatch = string.IsNullOrWhiteSpace(batchNo) ? null : batchNo.Trim();
        if (normalizedBatch is { Length: > BatchNoMaxLength })
        {
            return InventoryErrors.InvalidReceiptLine($"Line {lineNo}: batch_no exceeds {BatchNoMaxLength} characters.");
        }

        return new GoodsReceiptLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            ProductId = productId,
            PoLineId = poLineId,
            OrderedQty = orderedQty,
            ReceivedQty = receivedQty,
            RejectedQty = rejectedQty,
            UomId = uomId,
            BatchNo = normalizedBatch,
            ProductionDate = productionDate,
            ExpiryDate = expiryDate,
            UnitPrice = unitPrice,
            Currency = currency?.ToUpperInvariant(),
            VarianceNote = varianceNote is { Length: > VarianceNoteMaxLength } note ? note[..VarianceNoteMaxLength] : varianceNote,
        };
    }
}
