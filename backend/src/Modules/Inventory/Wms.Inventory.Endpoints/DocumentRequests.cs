using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Http;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Queries.Documents;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Endpoints;

/// <summary>Query string shared by the document list endpoints of inventory.v1.yaml.</summary>
public sealed record DocumentListRequest(
    string? Status,
    uint? LocationId,
    uint? FromLocationId,
    uint? ToLocationId,
    uint? SupplierId,
    string? IssueType,
    string? CountType,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    int? Page,
    int? Size)
{
    public DocumentListQuery ToQuery() => new(
        Status,
        IssueType ?? CountType,
        ToLocationId ?? LocationId,
        FromLocationId,
        SupplierId,
        DateFrom,
        DateTo,
        Search,
        new PagingRequest(Page, Size).ToPageRequest());
}

// ==================================================================== stock requests

public sealed record StockRequestLineRequest(uint ProductId, decimal Qty, ushort UomId, string? Note);

public sealed record StockRequestCreateRequest(
    DateOnly DocDate,
    uint FromLocationId,
    uint ToLocationId,
    DateOnly? RequiredDate,
    string? Note,
    List<StockRequestLineRequest>? Lines);

public sealed record StockRequestUpdateRequest(
    uint RowVersion,
    DateOnly DocDate,
    DateOnly? RequiredDate,
    string? Note,
    List<StockRequestLineRequest>? Lines);

// ==================================================================== issues

public sealed record IssueLineRequest(
    uint ProductId,
    decimal Qty,
    ushort UomId,
    long? RequestLineId,
    long? BatchId,
    ushort? BatchOverrideReasonCodeId,
    string? BatchOverrideNote)
{
    public IssueLineInput ToInput() =>
        new(ProductId, Qty, UomId, RequestLineId, BatchId, BatchOverrideReasonCodeId, BatchOverrideNote);
}

public sealed record IssueCreateRequest(
    DateOnly DocDate,
    IssueType IssueType,
    uint FromLocationId,
    uint ToLocationId,
    long? RequestId,
    string? Note,
    List<IssueLineRequest>? Lines);

public sealed record IssueConfirmLineRequest(long LineId, decimal ReceivedQty, ushort? ReasonCodeId, string? Note)
{
    public IssueReceiptInput ToInput() => new(LineId, ReceivedQty, ReasonCodeId, Note);
}

public sealed record IssueConfirmReceiptRequest(uint RowVersion, List<IssueConfirmLineRequest>? Lines, List<long>? AttachmentIds);

// ==================================================================== waste / sample / return-to-vendor

/// <summary><c>WasteLineCreate</c> of inventory.v1.yaml — shared by waste, samples and returns.</summary>
public sealed record StockOutLineRequest(uint ProductId, long? BatchId, QuantityRequest? Quantity, string? Note)
{
    public StockOutLineInput ToInput() =>
        new(ProductId, Quantity?.Value ?? 0m, Quantity?.UomId ?? 0, BatchId, Note);
}

public sealed record WasteCreateRequest(
    DateOnly DocDate,
    uint LocationId,
    ushort ReasonCodeId,
    string? Note,
    List<StockOutLineRequest>? Lines,
    List<long>? AttachmentIds);

public sealed record SampleCreateRequest(
    DateOnly DocDate,
    uint LocationId,
    string? Authority,
    string? Purpose,
    ushort? ReasonCodeId,
    List<StockOutLineRequest>? Lines,
    List<long>? AttachmentIds);

public sealed record ReturnToVendorCreateRequest(
    DateOnly DocDate,
    uint SupplierId,
    uint LocationId,
    long? ReceiptId,
    ushort ReasonCodeId,
    decimal? ClaimAmount,
    string? Note,
    List<StockOutLineRequest>? Lines,
    List<long>? AttachmentIds);

public sealed record ReturnToVendorCloseRequest(uint RowVersion, string Outcome, decimal? ClaimAmount, string? OutcomeNote);

// ==================================================================== batches and the ledger

public sealed record BatchesRequest(
    uint? ProductId,
    uint? SupplierId,
    string? Status,
    DateOnly? ExpiryBefore,
    string? BatchNo,
    int? Page,
    int? Size)
{
    public ListBatchesQuery ToQuery() => new(
        new BatchFilter(ProductId, SupplierId, Status, ExpiryBefore, BatchNo),
        new PagingRequest(Page, Size).ToPageRequest());
}

/// <summary><c>BatchStatusChange</c> of inventory.v1.yaml.</summary>
public sealed record BatchStatusChangeRequest(uint RowVersion, string Status, ushort ReasonCodeId, string? Note);

public sealed record MovementsRequest(
    uint? ProductId,
    uint? LocationId,
    long? BatchId,
    string? DocType,
    long? GroupId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    int? Page,
    int? Size)
{
    public ListMovementsQuery ToQuery() => new(
        ProductId, LocationId, BatchId, DocType, GroupId, DateFrom, DateTo,
        new PagingRequest(Page, Size).ToPageRequest());
}

/// <summary><c>MovementGroupReverse</c> of inventory.v1.yaml.</summary>
public sealed record MovementGroupReverseRequest(ushort ReasonCodeId, string? Note);
