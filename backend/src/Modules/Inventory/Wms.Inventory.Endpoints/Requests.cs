using Wms.Inventory.Application.Commands.Counts;
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
public sealed record BalancesRequest(
    uint? LocationId,
    uint? ProductId,
    long? BatchId,
    uint? CategoryId,
    bool? IncludeZero,
    bool? BelowMin,
    int? ExpiringWithinDays,
    string? Search,
    int? Page,
    int? Size);

/// <summary>Query string of <c>GET /api/v1/inventory/goods-receipts</c>.</summary>
public sealed record GoodsReceiptsRequest(
    string? Status,
    uint? SupplierId,
    uint? LocationId,
    long? PoId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    int? Page,
    int? Size);

// ==================================================================== shared action bodies (inventory.v1.yaml)

/// <summary><c>VersionedAction</c>: an optimistic-lock guarded state change.</summary>
public sealed record VersionedActionRequest(uint RowVersion);

/// <summary><c>ReasonedVersionedAction</c>: a state change that must say why (spec §12.6).</summary>
public sealed record ReasonedActionRequest(uint RowVersion, ushort ReasonCodeId, string? Note);

/// <summary><c>ApprovalDecisionBody</c>: <c>APPROVED</c> | <c>REJECTED</c>.</summary>
public sealed record ApprovalDecisionRequest(uint RowVersion, string Decision, string? Comment);

/// <summary><c>Quantity</c> of common.v1.yaml — value plus the UoM the user typed it in.</summary>
public sealed record QuantityRequest(decimal Value, ushort UomId);

// ==================================================================== counts

/// <summary>Query string of <c>GET /api/v1/inventory/counts</c>.</summary>
public sealed record CountsRequest(
    string? Status,
    string? CountType,
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    int? Page,
    int? Size);

/// <summary>Body of <c>POST /api/v1/inventory/counts</c>.</summary>
public sealed record CountCreateRequest(
    uint LocationId,
    CountType CountType,
    List<uint>? CategoryIds,
    List<uint>? ProductIds,
    string? Note)
{
    public CreateCountCommand ToCommand() => new(LocationId, CountType, CategoryIds ?? [], ProductIds ?? [], Note);
}

/// <summary><c>CountLineInput</c> of inventory.v1.yaml.</summary>
public sealed record CountLineRequest(uint ProductId, long? BatchId, QuantityRequest? CountedQuantity, ushort? ReasonCodeId, string? Note);

/// <summary>Body of <c>POST /api/v1/inventory/counts/{id}/lines</c>.</summary>
public sealed record CountLinesSubmitRequest(uint RowVersion, List<CountLineRequest>? Lines);
