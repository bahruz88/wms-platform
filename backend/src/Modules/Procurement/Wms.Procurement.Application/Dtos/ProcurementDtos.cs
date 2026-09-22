using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Dtos;

// ============================================================================ Requisition

/// <summary><c>RequisitionSummary</c>.</summary>
public sealed record RequisitionSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto RequesterLocation,
    ProductType ProductType,
    Priority Priority,
    DateOnly? RequiredDate,
    RequisitionStatus Status,
    int LineCount,
    UserRefDto CreatedBy,
    uint RowVersion);

/// <summary><c>RequisitionLine</c>.</summary>
public sealed record RequisitionLineDto(
    long Id,
    ushort LineNo,
    ProductRefDto Product,
    decimal Qty,
    ushort UomId,
    string UomCode,
    decimal ConvertedQty,
    decimal? CurrentStockQty,
    string? Note);

/// <summary><c>Requisition</c>.</summary>
public sealed record RequisitionDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto RequesterLocation,
    ProductType ProductType,
    Priority Priority,
    DateOnly? RequiredDate,
    RequisitionStatus Status,
    int LineCount,
    UserRefDto CreatedBy,
    uint RowVersion,
    string? Note,
    string? RejectComment,
    IReadOnlyList<RequisitionLineDto> Lines,
    IReadOnlyList<long> RfqIds,
    IReadOnlyList<long> PurchaseOrderIds,
    IReadOnlyList<long> AttachmentIds,
    AuditDto Audit);

// ============================================================================ RFQ

/// <summary><c>RfqSummary</c>.</summary>
public sealed record RfqSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    DateOnly? DueDate,
    RfqStatus Status,
    int SupplierCount,
    int QuotationCount,
    long? SelectedQuotationId,
    uint RowVersion);

/// <summary><c>RfqLine</c>.</summary>
public sealed record RfqLineDto(
    long Id,
    ushort LineNo,
    ProductRefDto Product,
    long? RequisitionLineId,
    decimal Qty,
    ushort UomId,
    string UomCode,
    string? Note);

/// <summary><c>Rfq</c>.</summary>
public sealed record RfqDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    DateOnly? DueDate,
    RfqStatus Status,
    int SupplierCount,
    int QuotationCount,
    long? SelectedQuotationId,
    uint RowVersion,
    string? Note,
    IReadOnlyList<RfqLineDto> Lines,
    IReadOnlyList<SupplierRefDto> Suppliers,
    IReadOnlyList<long> RequisitionIds,
    AuditDto Audit);

// ============================================================================ Quotation

/// <summary><c>QuotationSummary</c>.</summary>
public sealed record QuotationSummaryDto(
    long Id,
    long? RfqId,
    string? RfqDocNo,
    SupplierRefDto Supplier,
    string? QuoteNo,
    DateOnly QuoteDate,
    DateOnly? ValidUntil,
    string Currency,
    ushort? DeliveryDays,
    decimal? TotalAmount,
    decimal? TotalAmountBase,
    bool IsSelected,
    bool IsCheapest,
    string? SelectionNote,
    uint RowVersion);

/// <summary><c>QuotationLine</c>.</summary>
public sealed record QuotationLineDto(
    long Id,
    ushort LineNo,
    long? RfqLineId,
    ProductRefDto Product,
    decimal Qty,
    ushort UomId,
    string UomCode,
    decimal UnitPrice,
    decimal? UnitPriceBase,
    decimal LineTotal,
    string? Note);

/// <summary><c>Quotation</c>.</summary>
public sealed record QuotationDto(
    long Id,
    long? RfqId,
    string? RfqDocNo,
    SupplierRefDto Supplier,
    string? QuoteNo,
    DateOnly QuoteDate,
    DateOnly? ValidUntil,
    string Currency,
    ushort? DeliveryDays,
    decimal? TotalAmount,
    decimal? TotalAmountBase,
    bool IsSelected,
    bool IsCheapest,
    string? SelectionNote,
    uint RowVersion,
    string? PaymentTerms,
    decimal? FxRate,
    IReadOnlyList<QuotationLineDto> Lines,
    IReadOnlyList<long> AttachmentIds,
    AuditDto Audit);

/// <summary><c>RfqComparisonCell</c>.</summary>
public sealed record RfqComparisonCellDto(
    long QuotationId,
    long? QuotationLineId,
    decimal? UnitPrice,
    string? Currency,
    decimal? UnitPriceBase,
    decimal? LineTotalBase,
    decimal? DiffFromPrevPct,
    bool IsLowest);

/// <summary><c>RfqComparisonRow</c>.</summary>
public sealed record RfqComparisonRowDto(
    long RfqLineId,
    ProductRefDto Product,
    decimal Qty,
    string UomCode,
    decimal? PrevPriceBase,
    IReadOnlyList<RfqComparisonCellDto> Cells);

/// <summary><c>RfqComparison</c>.</summary>
public sealed record RfqComparisonDto(
    long RfqId,
    string RfqDocNo,
    string BaseCurrency,
    long? CheapestQuotationId,
    long? SelectedQuotationId,
    IReadOnlyList<QuotationSummaryDto> Quotations,
    IReadOnlyList<RfqComparisonRowDto> Rows);

// ============================================================================ Purchase order

/// <summary><c>PurchaseOrderSummary</c>.</summary>
public sealed record PurchaseOrderSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    SupplierRefDto Supplier,
    string Currency,
    decimal TotalAmount,
    decimal TotalAmountBase,
    LocationRefDto DeliveryLocation,
    ProductType ProductType,
    DateOnly? ExpectedDate,
    PurchaseOrderStatus Status,
    decimal ReceivedPct,
    UserRefDto CreatedBy,
    uint RowVersion);

/// <summary><c>PurchaseOrderLine</c>.</summary>
public sealed record PurchaseOrderLineDto(
    long Id,
    ushort LineNo,
    long? RequisitionLineId,
    ProductRefDto Product,
    decimal Qty,
    ushort UomId,
    string UomCode,
    decimal UnitPrice,
    decimal VatRate,
    decimal LineTotal,
    decimal ReceivedQty,
    decimal RemainingQty);

/// <summary><c>PurchaseOrder</c>.</summary>
public sealed record PurchaseOrderDetailDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    SupplierRefDto Supplier,
    string Currency,
    decimal TotalAmount,
    decimal TotalAmountBase,
    LocationRefDto DeliveryLocation,
    ProductType ProductType,
    DateOnly? ExpectedDate,
    PurchaseOrderStatus Status,
    decimal ReceivedPct,
    UserRefDto CreatedBy,
    uint RowVersion,
    decimal FxRate,
    decimal Subtotal,
    decimal VatAmount,
    string? Incoterms,
    string? PaymentTerms,
    string? Note,
    long? QuotationId,
    DateTimeOffset? SentAt,
    ApprovalInstanceDto? Approval,
    string? SplitCheckWarning,
    IReadOnlyList<PurchaseOrderLineDto> Lines,
    IReadOnlyList<long> GoodsReceiptIds,
    IReadOnlyList<long> AttachmentIds,
    AuditDto Audit);

/// <summary>One line of <c>OpenPurchaseOrder</c> — deliberately price free.</summary>
public sealed record OpenPurchaseOrderLineDto(
    long Id,
    ushort LineNo,
    ProductRefDto Product,
    decimal Qty,
    ushort UomId,
    string UomCode,
    decimal ReceivedQty,
    decimal RemainingQty);

/// <summary><c>OpenPurchaseOrder</c>: the warehouse keeper's view, without any amount (spec §7.1).</summary>
public sealed record OpenPurchaseOrderDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    SupplierRefDto Supplier,
    LocationRefDto DeliveryLocation,
    DateOnly? ExpectedDate,
    PurchaseOrderStatus Status,
    IReadOnlyList<OpenPurchaseOrderLineDto> Lines);

// ============================================================================ Approvals

/// <summary><c>ApprovalStep</c>.</summary>
public sealed record ApprovalStepDto(
    long Id,
    byte StepNo,
    string ApproverRoleCode,
    UserRefDto? ApproverUser,
    UserRefDto? DelegatedFromUser,
    ApprovalDecision Decision,
    DateTimeOffset? DecidedAt,
    string? Comment);

/// <summary><c>ApprovalInstance</c>.</summary>
public sealed record ApprovalInstanceDto(
    long Id,
    ApprovalDocType DocType,
    long DocId,
    string DocNo,
    decimal? AmountBase,
    byte CurrentStep,
    ApprovalStatus Status,
    IReadOnlyList<ApprovalStepDto> Steps,
    DateTimeOffset CreatedAt);

/// <summary><c>PendingApproval</c>.</summary>
public sealed record PendingApprovalDto(
    long ApprovalId,
    long StepId,
    ApprovalDocType DocType,
    long DocId,
    string DocNo,
    byte StepNo,
    decimal? AmountBase,
    string Summary,
    UserRefDto RequestedBy,
    UserRefDto? ViaDelegationFrom,
    DateTimeOffset WaitingSince);

/// <summary><c>ApprovalRule</c>.</summary>
public sealed record ApprovalRuleDto(
    uint Id,
    ApprovalDocType DocType,
    ApprovalProductType ProductType,
    decimal MinAmountBase,
    decimal? MaxAmountBase,
    byte StepNo,
    uint ApproverRoleId,
    string ApproverRoleCode,
    bool IsActive,
    uint RowVersion);

// ============================================================================ Price history

/// <summary><c>PriceHistoryEntry</c>.</summary>
public sealed record PriceHistoryEntryDto(
    long Id,
    ProductRefDto Product,
    SupplierRefDto Supplier,
    long? PoId,
    string? PoDocNo,
    DateOnly PriceDate,
    decimal UnitPrice,
    string Currency,
    decimal UnitPriceBase,
    decimal? PrevPriceBase,
    decimal? DiffAmount,
    decimal? DiffPct);
