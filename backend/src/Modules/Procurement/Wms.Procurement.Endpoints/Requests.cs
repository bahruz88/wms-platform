using Wms.Common.Domain;
using Wms.Common.Infrastructure.Persistence;
using Wms.Procurement.Application.Commands.PurchaseOrders;
using Wms.Procurement.Application.Commands.Quotations;
using Wms.Procurement.Application.Commands.Requisitions;
using Wms.Procurement.Application.Commands.Rfqs;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Endpoints;

/// <summary><c>{ "id": 42 }</c> — body of a 201 when only the key matters.</summary>
public sealed record CreatedResponse(long Id);

/// <summary><c>VersionedAction</c> of common.v1.yaml.</summary>
public sealed record VersionedActionRequest(uint RowVersion);

/// <summary><c>VersionedComment</c> of procurement.v1.yaml.</summary>
public sealed record VersionedCommentRequest(uint RowVersion, string? Comment);

// ==================================================================== Requisitions

public sealed record RequisitionLineRequest(uint ProductId, decimal Qty, ushort UomId, string? Note)
{
    public RequisitionLineInput ToInput() => new(ProductId, Qty, UomId, Note);
}

/// <summary><c>RequisitionCreate</c>.</summary>
public sealed record RequisitionCreateRequest(
    DateOnly DocDate,
    uint RequesterLocationId,
    ProductType ProductType,
    Priority? Priority,
    DateOnly? RequiredDate,
    string? Note,
    List<RequisitionLineRequest>? Lines,
    List<long>? AttachmentIds)
{
    public CreateRequisitionCommand ToCommand() => new(
        DocDate, RequesterLocationId, ProductType, Priority ?? Domain.Enums.Priority.Normal, RequiredDate, Note,
        (Lines ?? []).Select(l => l.ToInput()).ToList());
}

/// <summary><c>RequisitionUpdate</c>.</summary>
public sealed record RequisitionUpdateRequest(
    uint RowVersion,
    DateOnly DocDate,
    uint RequesterLocationId,
    ProductType ProductType,
    Priority? Priority,
    DateOnly? RequiredDate,
    string? Note,
    List<RequisitionLineRequest>? Lines,
    List<long>? AttachmentIds)
{
    public UpdateRequisitionCommand ToCommand(long id) => new(
        id, RowVersion, DocDate, RequesterLocationId, ProductType, Priority ?? Domain.Enums.Priority.Normal,
        RequiredDate, Note, (Lines ?? []).Select(l => l.ToInput()).ToList());
}

/// <summary>Query string of <c>GET /requisitions</c>.</summary>
public sealed record RequisitionsQueryRequest(
    string? Status,
    string? ProductType,
    string? Priority,
    uint? RequesterLocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    int? Page,
    int? Size);

// ==================================================================== RFQs

public sealed record RfqLineRequest(uint ProductId, decimal Qty, ushort UomId, long? RequisitionLineId, string? Note)
{
    public RfqLineInput ToInput() => new(ProductId, Qty, UomId, RequisitionLineId, Note);
}

/// <summary><c>RfqCreate</c>.</summary>
public sealed record RfqCreateRequest(
    DateOnly DocDate,
    DateOnly? DueDate,
    List<uint>? SupplierIds,
    List<RfqLineRequest>? Lines,
    string? Note)
{
    public CreateRfqCommand ToCommand() => new(
        DocDate, DueDate, SupplierIds ?? [], (Lines ?? []).Select(l => l.ToInput()).ToList(), Note);
}

/// <summary>Query string of <c>GET /rfqs</c>.</summary>
public sealed record RfqsQueryRequest(
    string? Status,
    uint? SupplierId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    int? Page,
    int? Size);

// ==================================================================== Quotations

public sealed record QuotationLineRequest(uint ProductId, decimal Qty, ushort UomId, decimal UnitPrice, long? RfqLineId, string? Note)
{
    public QuotationLineInput ToInput() => new(ProductId, Qty, UomId, UnitPrice, RfqLineId, Note);
}

/// <summary><c>QuotationCreate</c>.</summary>
public sealed record QuotationCreateRequest(
    long? RfqId,
    uint SupplierId,
    string? QuoteNo,
    DateOnly QuoteDate,
    DateOnly? ValidUntil,
    string Currency,
    ushort? DeliveryDays,
    string? PaymentTerms,
    List<QuotationLineRequest>? Lines,
    List<long>? AttachmentIds)
{
    public CreateQuotationCommand ToCommand() => new(
        RfqId, SupplierId, QuoteNo, QuoteDate, ValidUntil, Currency ?? "AZN", DeliveryDays, PaymentTerms,
        (Lines ?? []).Select(l => l.ToInput()).ToList());
}

/// <summary><c>QuotationUpdate</c>.</summary>
public sealed record QuotationUpdateRequest(
    uint RowVersion,
    long? RfqId,
    uint SupplierId,
    string? QuoteNo,
    DateOnly QuoteDate,
    DateOnly? ValidUntil,
    string Currency,
    ushort? DeliveryDays,
    string? PaymentTerms,
    List<QuotationLineRequest>? Lines,
    List<long>? AttachmentIds)
{
    public UpdateQuotationCommand ToCommand(long id) => new(
        id, RowVersion, RfqId, SupplierId, QuoteNo, QuoteDate, ValidUntil, Currency ?? "AZN", DeliveryDays,
        PaymentTerms, (Lines ?? []).Select(l => l.ToInput()).ToList());
}

/// <summary><c>QuotationSelect</c>.</summary>
public sealed record QuotationSelectRequest(uint RowVersion, string? SelectionNote);

/// <summary>Query string of <c>GET /quotations</c>.</summary>
public sealed record QuotationsQueryRequest(
    long? RfqId,
    uint? SupplierId,
    bool? IsSelected,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Sort,
    int? Page,
    int? Size);

// ==================================================================== Purchase orders

public sealed record PurchaseOrderLineRequest(
    uint ProductId,
    decimal Qty,
    ushort UomId,
    decimal UnitPrice,
    decimal? VatRate,
    long? RequisitionLineId)
{
    public PurchaseOrderLineInput ToInput() => new(ProductId, Qty, UomId, UnitPrice, VatRate, RequisitionLineId);
}

/// <summary><c>PurchaseOrderCreate</c>.</summary>
public sealed record PurchaseOrderCreateRequest(
    DateOnly DocDate,
    uint SupplierId,
    string Currency,
    uint DeliveryLocationId,
    DateOnly? ExpectedDate,
    string? Incoterms,
    string? PaymentTerms,
    long? QuotationId,
    string? Note,
    List<PurchaseOrderLineRequest>? Lines,
    List<long>? AttachmentIds)
{
    public CreatePurchaseOrderCommand ToCommand() => new(
        DocDate, SupplierId, Currency ?? "AZN", DeliveryLocationId, ExpectedDate, Incoterms, PaymentTerms,
        QuotationId, Note, (Lines ?? []).Select(l => l.ToInput()).ToList());
}

/// <summary><c>PurchaseOrderUpdate</c>.</summary>
public sealed record PurchaseOrderUpdateRequest(
    uint RowVersion,
    DateOnly DocDate,
    uint SupplierId,
    string Currency,
    uint DeliveryLocationId,
    DateOnly? ExpectedDate,
    string? Incoterms,
    string? PaymentTerms,
    long? QuotationId,
    string? Note,
    List<PurchaseOrderLineRequest>? Lines,
    List<long>? AttachmentIds)
{
    public UpdatePurchaseOrderCommand ToCommand(long id) => new(
        id, RowVersion, DocDate, SupplierId, Currency ?? "AZN", DeliveryLocationId, ExpectedDate, Incoterms,
        PaymentTerms, QuotationId, Note, (Lines ?? []).Select(l => l.ToInput()).ToList());
}

/// <summary>Query string of <c>GET /purchase-orders</c>.</summary>
public sealed record PurchaseOrdersQueryRequest(
    string? Status,
    uint? SupplierId,
    uint? DeliveryLocationId,
    string? ProductType,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    int? Page,
    int? Size);

/// <summary>Query string of <c>GET /purchase-orders/open-for-receipt</c>.</summary>
public sealed record OpenPurchaseOrdersQueryRequest(uint? SupplierId, uint? DeliveryLocationId, string? Search, int? Page, int? Size);

// ==================================================================== Approvals

/// <summary><c>ApprovalDecision</c>.</summary>
public sealed record ApprovalDecisionRequest(string Decision, string? Comment, int? ExpectedStepNo);

/// <summary>Query string of <c>GET /approvals/pending</c>.</summary>
public sealed record PendingApprovalsQueryRequest(string? DocType, int? Page, int? Size);

/// <summary>Query string of <c>GET /approval-rules</c>.</summary>
public sealed record ApprovalRulesQueryRequest(string? DocType, bool? IsActive);

/// <summary><c>ApprovalRuleCreate</c>.</summary>
public sealed record ApprovalRuleCreateRequest(
    string DocType,
    string? ProductType,
    decimal MinAmountBase,
    decimal? MaxAmountBase,
    byte StepNo,
    uint ApproverRoleId,
    string? ApproverRoleCode);

/// <summary><c>ApprovalRuleUpdate</c>.</summary>
public sealed record ApprovalRuleUpdateRequest(
    uint RowVersion,
    string DocType,
    string? ProductType,
    decimal MinAmountBase,
    decimal? MaxAmountBase,
    byte StepNo,
    uint ApproverRoleId,
    string? ApproverRoleCode,
    bool IsActive);

// ==================================================================== Price history

/// <summary>Query string of <c>GET /price-history</c>.</summary>
public sealed record PriceHistoryQueryRequest(
    uint? ProductId,
    uint? SupplierId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    decimal? MinDiffPct,
    string? Sort,
    int? Page,
    int? Size);

// ==================================================================== Internal

/// <summary>Body of the internal receipt callback used by Inventory (see <c>RecordReceiptPricesCommand</c>).</summary>
public sealed record ReceiptRegistrationRequest(long GoodsReceiptId, DateOnly ReceiptDate, List<ReceiptRegistrationLine>? Lines);

public sealed record ReceiptRegistrationLine(long PurchaseOrderLineId, decimal ReceivedQty);

/// <summary>Parses an UPPER_SNAKE query-string enum; an unknown value is a 400, never a silent default.</summary>
internal static class EnumQuery
{
    public static Result<TEnum?> Parse<TEnum>(string? value, string parameterName)
        where TEnum : struct, Enum
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return Result.Success<TEnum?>(null);
        }

        try
        {
            return Result.Success<TEnum?>(UpperSnakeCaseEnum.Parse<TEnum>(value.Trim().ToUpperInvariant()));
        }
        catch (ArgumentException)
        {
            return CommonErrors.Validation(new Dictionary<string, string[]>(StringComparer.Ordinal)
            {
                [parameterName] = [$"'{value}' is not a valid value; expected one of {string.Join(", ", UpperSnakeCaseEnum.Names<TEnum>())}."],
            });
        }
    }

    public static Result<TEnum> Required<TEnum>(string? value, string parameterName)
        where TEnum : struct, Enum
    {
        var parsed = Parse<TEnum>(value, parameterName);
        if (parsed.IsFailure)
        {
            return parsed.Error;
        }

        return parsed.Value is { } result
            ? Result.Success(result)
            : CommonErrors.Validation(new Dictionary<string, string[]>(StringComparer.Ordinal) { [parameterName] = ["Value is required."] });
    }
}
