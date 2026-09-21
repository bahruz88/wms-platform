namespace Wms.Inventory.Application.Dtos;

/// <summary>Mandatory audit block of every document (<c>AuditFields</c> in common.v1.yaml).</summary>
public sealed record AuditFieldsDto(
    DateTimeOffset CreatedAt,
    uint CreatedBy,
    DateTimeOffset? UpdatedAt,
    uint? UpdatedBy,
    uint RowVersion);

/// <summary><c>GoodsReceiptLine</c> of inventory.v1.yaml.</summary>
public sealed record GoodsReceiptLineDto(
    long Id,
    ushort LineNo,
    ProductRefDto Product,
    long? PoLineId,
    decimal? OrderedQty,
    decimal ReceivedQty,
    decimal RejectedQty,
    ushort UomId,
    string UomCode,
    decimal AcceptedQtyBase,
    string? BatchNo,
    long? BatchId,
    DateOnly? ProductionDate,
    DateOnly? ExpiryDate,
    decimal? UnitPrice,
    string? Currency,
    string? VarianceNote,
    decimal? VarianceQty);

/// <summary><c>GoodsReceiptSummary</c> of inventory.v1.yaml — the list-page row.</summary>
public sealed record GoodsReceiptSummaryDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    long? PoId,
    string? PoDocNo,
    uint SupplierId,
    string SupplierName,
    uint LocationId,
    string LocationName,
    string QualityStatus,
    string Status,
    bool HasVariance,
    int LineCount,
    uint RowVersion);

/// <summary><c>GoodsReceipt</c> of inventory.v1.yaml — summary plus lines and audit.</summary>
public sealed record GoodsReceiptDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    long? PoId,
    string? PoDocNo,
    uint SupplierId,
    string SupplierName,
    uint LocationId,
    string LocationName,
    string QualityStatus,
    string Status,
    bool HasVariance,
    int LineCount,
    uint RowVersion,
    decimal? TemperatureC,
    string? PackagingNote,
    long? MovementGroupId,
    DateTimeOffset? PostedAt,
    IReadOnlyList<GoodsReceiptLineDto> Lines,
    IReadOnlyList<long> AttachmentIds,
    AuditFieldsDto Audit);
