using Wms.Common.Domain;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Entities;

/// <summary>
/// <c>proc_purchase_order</c> (spec §10). <see cref="FxRate"/> is the rate of the PO date and
/// <see cref="TotalAmountBase"/> is what the approval limits are checked against.
/// </summary>
public sealed class PurchaseOrder : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;

    private readonly List<PurchaseOrderLine> _lines = [];

    private PurchaseOrder()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public uint SupplierId { get; private set; }

    public string Currency { get; private set; } = "AZN";

    public decimal FxRate { get; private set; } = 1m;

    public decimal Subtotal { get; private set; }

    public decimal VatAmount { get; private set; }

    public decimal TotalAmount { get; private set; }

    public decimal TotalAmountBase { get; private set; }

    public uint DeliveryLocationId { get; private set; }

    public DateOnly? ExpectedDate { get; private set; }

    public string? Incoterms { get; private set; }

    public PurchaseOrderStatus Status { get; private set; } = PurchaseOrderStatus.Draft;

    public DateTimeOffset? SentAt { get; private set; }

    public IReadOnlyList<PurchaseOrderLine> Lines => _lines.AsReadOnly();

    public static Result<PurchaseOrder> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        uint supplierId,
        string currency,
        decimal fxRate,
        uint deliveryLocationId,
        DateOnly? expectedDate = null,
        string? incoterms = null)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (supplierId == 0 || deliveryLocationId == 0)
        {
            return ProcurementErrors.InvalidPurchaseOrder("supplier_id and delivery_location_id are required.");
        }

        if (!Money.IsValidCurrency(currency))
        {
            return ProcurementErrors.InvalidPurchaseOrder("currency must be an ISO 4217 code.");
        }

        if (fxRate <= 0m)
        {
            return ProcurementErrors.InvalidPurchaseOrder("fx_rate must be positive (spec §12.5: a missing rate blocks the document).");
        }

        return new PurchaseOrder
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            SupplierId = supplierId,
            Currency = currency.ToUpperInvariant(),
            FxRate = fxRate,
            DeliveryLocationId = deliveryLocationId,
            ExpectedDate = expectedDate,
            Incoterms = incoterms,
        };
    }

    public Result<PurchaseOrderLine> AddLine(uint productId, decimal qty, ushort uomId, decimal unitPrice, decimal vatRate, long? requisitionLineId = null)
    {
        if (Status != PurchaseOrderStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), "line added");
        }

        var line = PurchaseOrderLine.Create(TenantId, (ushort)(_lines.Count + 1), productId, qty, uomId, unitPrice, vatRate, requisitionLineId);
        if (line.IsFailure)
        {
            return line.Error;
        }

        _lines.Add(line.Value);
        Recalculate();
        return line.Value;
    }

    /// <summary>Recomputes subtotal / VAT / totals from the lines. Base amount uses the frozen <see cref="FxRate"/>.</summary>
    public void Recalculate()
    {
        Subtotal = Quantity.Round(_lines.Sum(l => l.LineTotal), Money.StorageDecimals);
        VatAmount = Quantity.Round(_lines.Sum(l => l.VatAmount()), Money.StorageDecimals);
        TotalAmount = Quantity.Round(Subtotal + VatAmount, Money.StorageDecimals);
        TotalAmountBase = Quantity.Round(TotalAmount * FxRate, Money.StorageDecimals);
    }

    public Result SubmitForApproval()
    {
        if (Status != PurchaseOrderStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.PendingApproval));
        }

        if (_lines.Count == 0)
        {
            return ProcurementErrors.InvalidPurchaseOrder("A purchase order needs at least one line.");
        }

        Status = PurchaseOrderStatus.PendingApproval;
        return Result.Success();
    }

    public Result Approve()
    {
        if (Status != PurchaseOrderStatus.PendingApproval)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.Approved));
        }

        Status = PurchaseOrderStatus.Approved;
        return Result.Success();
    }

    public Result Reject()
    {
        if (Status != PurchaseOrderStatus.PendingApproval)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.Rejected));
        }

        Status = PurchaseOrderStatus.Rejected;
        return Result.Success();
    }

    public Result MarkSent(DateTimeOffset sentAt)
    {
        if (Status != PurchaseOrderStatus.Approved)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.SentToSupplier));
        }

        Status = PurchaseOrderStatus.SentToSupplier;
        SentAt = sentAt;
        return Result.Success();
    }

    /// <summary>Called when a goods receipt posts against this PO; moves the status along the receiving path.</summary>
    public Result RegisterReceipt(ushort lineNo, decimal receivedQty)
    {
        var line = _lines.Find(l => l.LineNo == lineNo);
        if (line is null)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Line {lineNo} does not exist.");
        }

        var registered = line.RegisterReceipt(receivedQty);
        if (registered.IsFailure)
        {
            return registered;
        }

        Status = _lines.TrueForAll(l => l.IsFullyReceived())
            ? PurchaseOrderStatus.FullyReceived
            : PurchaseOrderStatus.PartiallyReceived;
        return Result.Success();
    }
}
