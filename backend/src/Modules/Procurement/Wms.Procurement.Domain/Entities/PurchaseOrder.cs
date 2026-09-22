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
    public const int IncotermsMaxLength = 16;
    public const int PaymentTermsMaxLength = 200;
    public const int NoteMaxLength = 1000;
    public const int SplitCheckWarningMaxLength = 500;

    /// <summary>Statuses a goods receipt may be booked against (contract: <c>listOpenPurchaseOrdersForReceipt</c>).</summary>
    public static readonly IReadOnlyList<PurchaseOrderStatus> OpenForReceiptStatuses =
        [PurchaseOrderStatus.SentToSupplier, PurchaseOrderStatus.PartiallyReceived];

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

    /// <summary>One PO carries one product type — the approval rules are selected by it (spec §10).</summary>
    public ProductType ProductType { get; private set; }

    public DateOnly? ExpectedDate { get; private set; }

    public string? Incoterms { get; private set; }

    public string? PaymentTerms { get; private set; }

    public string? Note { get; private set; }

    /// <summary>The selected quotation this PO was assembled from, when there was one.</summary>
    public long? QuotationId { get; private set; }

    public PurchaseOrderStatus Status { get; private set; } = PurchaseOrderStatus.Draft;

    public DateTimeOffset? SentAt { get; private set; }

    /// <summary>Filled when the PR-splitting control fires (SoD, <c>proc_split_check_log</c>).</summary>
    public string? SplitCheckWarning { get; private set; }

    public string? RejectComment { get; private set; }

    public IReadOnlyList<PurchaseOrderLine> Lines => _lines.AsReadOnly();

    public static Result<PurchaseOrder> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        uint supplierId,
        string currency,
        decimal fxRate,
        uint deliveryLocationId,
        ProductType productType,
        DateOnly? expectedDate = null,
        string? incoterms = null,
        string? paymentTerms = null,
        string? note = null,
        long? quotationId = null)
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
            ProductType = productType,
            ExpectedDate = expectedDate,
            Incoterms = Requisition.Truncate(incoterms, IncotermsMaxLength),
            PaymentTerms = Requisition.Truncate(paymentTerms, PaymentTermsMaxLength),
            Note = Requisition.Truncate(note, NoteMaxLength),
            QuotationId = quotationId,
        };
    }

    /// <summary>Header edit of a DRAFT PO. A rejected PO returns to DRAFT first (contract: <c>updatePurchaseOrder</c>).</summary>
    public Result UpdateHeader(
        DateOnly docDate,
        uint supplierId,
        string currency,
        decimal fxRate,
        uint deliveryLocationId,
        ProductType productType,
        DateOnly? expectedDate,
        string? incoterms,
        string? paymentTerms,
        string? note,
        long? quotationId)
    {
        if (Status != PurchaseOrderStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), "updated");
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
            return ProcurementErrors.InvalidPurchaseOrder("fx_rate must be positive (spec §12.5).");
        }

        DocDate = docDate;
        SupplierId = supplierId;
        Currency = currency.ToUpperInvariant();
        FxRate = fxRate;
        DeliveryLocationId = deliveryLocationId;
        ProductType = productType;
        ExpectedDate = expectedDate;
        Incoterms = Requisition.Truncate(incoterms, IncotermsMaxLength);
        PaymentTerms = Requisition.Truncate(paymentTerms, PaymentTermsMaxLength);
        Note = Requisition.Truncate(note, NoteMaxLength);
        QuotationId = quotationId;
        return Result.Success();
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

    public Result ReplaceLines(IEnumerable<PurchaseOrderLineDraft> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != PurchaseOrderStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), "lines replaced");
        }

        var replacement = new List<PurchaseOrderLine>();
        ushort lineNo = 1;
        foreach (var draft in lines)
        {
            var line = PurchaseOrderLine.Create(
                TenantId, lineNo, draft.ProductId, draft.Qty, draft.UomId, draft.UnitPrice, draft.VatRate, draft.RequisitionLineId);
            if (line.IsFailure)
            {
                return line.Error;
            }

            replacement.Add(line.Value);
            lineNo++;
        }

        if (replacement.Count == 0)
        {
            return ProcurementErrors.InvalidPurchaseOrder("A purchase order needs at least one line.");
        }

        _lines.Clear();
        _lines.AddRange(replacement);
        Recalculate();
        return Result.Success();
    }

    /// <summary>Recomputes subtotal / VAT / totals from the lines. Base amount uses the frozen <see cref="FxRate"/>.</summary>
    public void Recalculate()
    {
        Subtotal = Quantity.Round(_lines.Sum(l => l.LineNet()), Money.StorageDecimals);
        VatAmount = Quantity.Round(_lines.Sum(l => l.VatAmount()), Money.StorageDecimals);
        TotalAmount = Quantity.Round(Subtotal + VatAmount, Money.StorageDecimals);
        TotalAmountBase = Quantity.Round(TotalAmount * FxRate, Money.StorageDecimals);
    }

    public void FlagSplitCheck(string? warning) => SplitCheckWarning = Requisition.Truncate(warning, SplitCheckWarningMaxLength);

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

        if (TotalAmountBase <= 0m)
        {
            return ProcurementErrors.InvalidPurchaseOrder("total_amount_base must be greater than zero.");
        }

        Status = PurchaseOrderStatus.PendingApproval;
        RejectComment = null;
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

    public Result Reject(string comment)
    {
        if (Status != PurchaseOrderStatus.PendingApproval)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.Rejected));
        }

        if (string.IsNullOrWhiteSpace(comment))
        {
            return ProcurementErrors.CommentRequired("comment");
        }

        Status = PurchaseOrderStatus.Rejected;
        RejectComment = Requisition.Truncate(comment, NoteMaxLength);
        return Result.Success();
    }

    /// <summary>A rejected PO goes back to the creator for correction (contract: <c>updatePurchaseOrder</c>).</summary>
    public Result ReturnToDraft()
    {
        if (Status != PurchaseOrderStatus.Rejected)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.Draft));
        }

        Status = PurchaseOrderStatus.Draft;
        return Result.Success();
    }

    public Result MarkSent(DateTimeOffset sentAt)
    {
        if (Status == PurchaseOrderStatus.Draft || Status == PurchaseOrderStatus.PendingApproval || Status == PurchaseOrderStatus.Rejected)
        {
            return ProcurementErrors.ApprovalRequired(DocNo);
        }

        if (Status != PurchaseOrderStatus.Approved)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.SentToSupplier));
        }

        Status = PurchaseOrderStatus.SentToSupplier;
        SentAt = sentAt;
        return Result.Success();
    }

    /// <summary>Nothing more is expected from the supplier. From SENT_TO_SUPPLIER a comment is mandatory.</summary>
    public Result Close(string? comment)
    {
        switch (Status)
        {
            case PurchaseOrderStatus.PartiallyReceived:
            case PurchaseOrderStatus.FullyReceived:
                Status = PurchaseOrderStatus.Closed;
                Note = comment is null ? Note : Requisition.Truncate(comment, NoteMaxLength);
                return Result.Success();

            case PurchaseOrderStatus.SentToSupplier when !string.IsNullOrWhiteSpace(comment):
                Status = PurchaseOrderStatus.Closed;
                Note = Requisition.Truncate(comment, NoteMaxLength);
                return Result.Success();

            case PurchaseOrderStatus.SentToSupplier:
                return ProcurementErrors.CommentRequired("comment");

            default:
                return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.Closed));
        }
    }

    public Result Cancel(string? comment)
    {
        if (Status is not (PurchaseOrderStatus.Draft or PurchaseOrderStatus.Rejected or PurchaseOrderStatus.Approved))
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), nameof(PurchaseOrderStatus.Cancelled));
        }

        Status = PurchaseOrderStatus.Cancelled;
        RejectComment = Requisition.Truncate(comment, NoteMaxLength);
        return Result.Success();
    }

    /// <summary>Called when a goods receipt posts against this PO; moves the status along the receiving path.</summary>
    public Result RegisterReceipt(long lineId, decimal receivedQty)
    {
        if (!OpenForReceiptStatuses.Contains(Status))
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), Status.ToString(), "received");
        }

        var line = _lines.Find(l => l.Id == lineId);
        if (line is null)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Line {lineId} does not belong to purchase order {DocNo}.");
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

    /// <summary>Received share weighted by line quantity, 0..100 (contract: <c>receivedPct</c>).</summary>
    public decimal ReceivedPct()
    {
        var ordered = _lines.Sum(l => l.Qty);
        if (ordered <= 0m)
        {
            return 0m;
        }

        var received = _lines.Sum(l => Math.Min(l.ReceivedQty, l.Qty));
        return Quantity.Round(received / ordered * 100m, 4);
    }
}

public sealed record PurchaseOrderLineDraft(
    uint ProductId,
    decimal Qty,
    ushort UomId,
    decimal UnitPrice,
    decimal VatRate,
    long? RequisitionLineId);
