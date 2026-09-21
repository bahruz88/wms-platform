namespace Wms.MasterData.Contracts;

/// <summary>Product card as seen by other modules (no cost data).</summary>
public sealed record ProductDto(
    uint Id,
    string Sku,
    string Name,
    uint CategoryId,
    string ProductType,
    ushort BaseUomId,
    string BaseUomCode,
    byte BaseUomDecimals,
    bool RequiresBatch,
    bool RequiresExpiry,
    string IssueStrategy,
    ushort? ShelfLifeDays,
    decimal? MinStock,
    decimal? MaxStock,
    decimal? ReorderPoint,
    decimal VatRate,
    bool IsActive);
