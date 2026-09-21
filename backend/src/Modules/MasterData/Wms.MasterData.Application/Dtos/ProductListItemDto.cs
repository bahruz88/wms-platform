namespace Wms.MasterData.Application.Dtos;

public sealed record ProductListItemDto(
    uint Id,
    string Sku,
    string Name,
    uint CategoryId,
    ushort BaseUomId,
    bool RequiresBatch,
    bool RequiresExpiry,
    string IssueStrategy,
    decimal? MinStock,
    decimal? MaxStock,
    bool IsActive);

public sealed record LocationListItemDto(
    uint Id,
    string Code,
    string Name,
    string LocationType,
    uint? ParentId,
    bool IsVirtual,
    bool IsActive);
