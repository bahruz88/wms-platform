namespace Wms.Inventory.Application.Dtos;

public sealed record GoodsReceiptLineDto(
    long Id,
    ushort LineNo,
    uint ProductId,
    long? PoLineId,
    decimal? OrderedQty,
    decimal ReceivedQty,
    decimal RejectedQty,
    ushort UomId,
    string? BatchNo,
    DateOnly? ProductionDate,
    DateOnly? ExpiryDate,
    decimal? UnitPrice,
    string? Currency,
    string? VarianceNote);

public sealed record GoodsReceiptDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    long? PoId,
    uint SupplierId,
    uint LocationId,
    decimal? TemperatureC,
    string QualityStatus,
    string? PackagingNote,
    string Status,
    long? MovementGroupId,
    DateTimeOffset CreatedAt,
    uint CreatedBy,
    uint RowVersion,
    IReadOnlyList<GoodsReceiptLineDto> Lines);
