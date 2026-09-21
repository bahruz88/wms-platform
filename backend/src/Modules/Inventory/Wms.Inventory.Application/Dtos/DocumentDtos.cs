using Wms.Common.Application.Dtos;

namespace Wms.Inventory.Application.Dtos;

// ==================================================================== stock requests

/// <summary><c>StockRequestSummary</c> of inventory.v1.yaml.</summary>
public sealed record StockRequestSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto FromLocation,
    LocationRefDto ToLocation,
    DateOnly? RequiredDate,
    string Status,
    int LineCount,
    uint RowVersion);

public sealed record StockRequestLineDto(
    long Id,
    ushort LineNo,
    ProductRefDto Product,
    decimal Qty,
    ushort UomId,
    string UomCode,
    decimal IssuedQty,
    string? Note);

/// <summary><c>StockRequest</c> of inventory.v1.yaml.</summary>
public sealed record StockRequestDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto FromLocation,
    LocationRefDto ToLocation,
    DateOnly? RequiredDate,
    string Status,
    int LineCount,
    uint RowVersion,
    string? Note,
    IReadOnlyList<StockRequestLineDto> Lines,
    IReadOnlyList<long> IssueIds,
    AuditFieldsDto Audit);

// ==================================================================== issues

/// <summary><c>IssueSummary</c> of inventory.v1.yaml.</summary>
public sealed record IssueSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    string IssueType,
    LocationRefDto FromLocation,
    LocationRefDto ToLocation,
    long? RequestId,
    string? RequestDocNo,
    string Status,
    DateTimeOffset? DispatchedAt,
    DateTimeOffset? ReceivedAt,
    int LineCount,
    uint RowVersion);

public sealed record IssueLineDto(
    long Id,
    ushort LineNo,
    ProductRefDto Product,
    long? RequestLineId,
    decimal Qty,
    ushort UomId,
    string UomCode,
    decimal QtyBase,
    BatchRefDto? Batch,
    BatchRefDto? SuggestedBatch,
    ushort? BatchOverrideReasonCodeId,
    decimal? ReceivedQty,
    decimal? DiscrepancyQty,
    ushort? DiscrepancyReasonCodeId,
    string? DiscrepancyNote,
    decimal? UnitCost);

/// <summary><c>Issue</c> of inventory.v1.yaml.</summary>
public sealed record IssueDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    string IssueType,
    LocationRefDto FromLocation,
    LocationRefDto ToLocation,
    long? RequestId,
    string? RequestDocNo,
    string Status,
    DateTimeOffset? DispatchedAt,
    DateTimeOffset? ReceivedAt,
    int LineCount,
    uint RowVersion,
    long? DispatchGroupId,
    long? ReceiptGroupId,
    uint? ReceivedBy,
    string? Note,
    IReadOnlyList<IssueLineDto> Lines,
    AuditFieldsDto Audit);

// ==================================================================== waste / sample / return-to-vendor

/// <summary>
/// <c>WasteLine</c> of inventory.v1.yaml — shared by waste, sample and return-to-vendor documents, which all
/// describe the same thing: stock leaving a location towards a virtual counter-account.
/// </summary>
public sealed record StockOutLineDto(
    long Id,
    ushort LineNo,
    ProductRefDto Product,
    BatchRefDto? Batch,
    decimal Qty,
    ushort UomId,
    string UomCode,
    decimal QtyBase,
    decimal? UnitCost,
    decimal? TotalValue,
    string? Note);

/// <summary><c>WasteSummary</c> of inventory.v1.yaml.</summary>
public sealed record WasteSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto Location,
    ushort ReasonCodeId,
    string ReasonCodeName,
    string Status,
    decimal? TotalValue,
    int LineCount,
    uint RowVersion);

/// <summary><c>Waste</c> of inventory.v1.yaml.</summary>
public sealed record WasteDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto Location,
    ushort ReasonCodeId,
    string ReasonCodeName,
    string Status,
    decimal? TotalValue,
    int LineCount,
    uint RowVersion,
    uint? ApprovedBy,
    DateTimeOffset? ApprovedAt,
    string? ApprovalComment,
    long? MovementGroupId,
    string? Note,
    IReadOnlyList<StockOutLineDto> Lines,
    IReadOnlyList<long> AttachmentIds,
    AuditFieldsDto Audit);

/// <summary><c>SampleSummary</c> of inventory.v1.yaml.</summary>
public sealed record SampleSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto Location,
    string Authority,
    string? Purpose,
    string Status,
    int LineCount,
    uint RowVersion);

/// <summary><c>Sample</c> of inventory.v1.yaml.</summary>
public sealed record SampleDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    LocationRefDto Location,
    string Authority,
    string? Purpose,
    string Status,
    int LineCount,
    uint RowVersion,
    ushort? ReasonCodeId,
    long? MovementGroupId,
    IReadOnlyList<StockOutLineDto> Lines,
    IReadOnlyList<long> AttachmentIds,
    AuditFieldsDto Audit);

/// <summary><c>ReturnToVendorSummary</c> of inventory.v1.yaml.</summary>
public sealed record ReturnToVendorSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    uint SupplierId,
    string SupplierName,
    LocationRefDto Location,
    long? ReceiptId,
    string? ReceiptDocNo,
    ushort ReasonCodeId,
    MoneyDto? ClaimAmount,
    string Status,
    uint RowVersion);

/// <summary><c>ReturnToVendor</c> of inventory.v1.yaml.</summary>
public sealed record ReturnToVendorDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    uint SupplierId,
    string SupplierName,
    LocationRefDto Location,
    long? ReceiptId,
    string? ReceiptDocNo,
    ushort ReasonCodeId,
    MoneyDto? ClaimAmount,
    string Status,
    uint RowVersion,
    long? MovementGroupId,
    string? Outcome,
    string? OutcomeNote,
    string? Note,
    IReadOnlyList<StockOutLineDto> Lines,
    IReadOnlyList<long> AttachmentIds,
    AuditFieldsDto Audit);

// ==================================================================== batches and the ledger

/// <summary><c>Batch</c> of inventory.v1.yaml.</summary>
public sealed record BatchLocationQtyDto(LocationRefDto Location, decimal QtyOnHand);

public sealed record BatchDto(
    long Id,
    ProductRefDto Product,
    string BatchNo,
    DateOnly? ProductionDate,
    DateOnly? ExpiryDate,
    uint? SupplierId,
    string? SupplierName,
    DateTimeOffset ReceivedAt,
    string Status,
    int? DaysToExpiry,
    decimal TotalQtyOnHand,
    IReadOnlyList<BatchLocationQtyDto> ByLocation,
    uint RowVersion);

/// <summary><c>Movement</c> of inventory.v1.yaml — one append-only ledger line.</summary>
public sealed record MovementDto(
    long Id,
    long GroupId,
    ushort LineNo,
    string DocType,
    string DocNo,
    DateOnly DocDate,
    ProductRefDto Product,
    BatchRefDto? Batch,
    LocationRefDto Location,
    decimal QtyBase,
    ushort BaseUomId,
    string BaseUomCode,
    decimal EnteredQty,
    ushort EnteredUomId,
    decimal ConversionRate,
    decimal? UnitCost,
    string? Currency,
    decimal? FxRate,
    DateTimeOffset PostedAt,
    uint PostedBy);

/// <summary><c>MovementGroup</c> of inventory.v1.yaml — a whole ledger document; <c>SUM(qtyBase) = 0</c> always.</summary>
public sealed record MovementGroupDto(
    long Id,
    string DocType,
    string DocNo,
    DateOnly DocDate,
    string? SourceDocType,
    long? SourceDocId,
    ushort? ReasonCodeId,
    string? Note,
    long? ReversesGroupId,
    /// <summary>The REVERSAL group that cancelled this one, or null. Lets a client see up front that a
    /// group is already reversed instead of discovering it from INVALID_STATE_TRANSITION.</summary>
    long? ReversedByGroupId,
    DateTimeOffset PostedAt,
    uint PostedBy,
    decimal SumQtyBase,
    IReadOnlyList<MovementDto> Lines);
