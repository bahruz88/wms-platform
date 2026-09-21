namespace Wms.Inventory.Application.Dtos;

/// <summary>
/// <c>Balance</c> of inventory.v1.yaml. <c>AvgUnitCost</c> / <c>TotalValue</c> are null (and absent from JSON)
/// without <c>master.product.view_cost</c>.
/// </summary>
public sealed record StockBalanceDto(
    ProductRefDto Product,
    LocationRefDto Location,
    BatchRefDto? Batch,
    decimal QtyOnHand,
    decimal QtyReserved,
    decimal QtyAvailable,
    ushort BaseUomId,
    string BaseUomCode,
    decimal? AvgUnitCost,
    decimal? TotalValue,
    decimal? MinStock,
    bool IsBelowMin,
    int? DaysToExpiry,
    long? LastMovementId,
    DateTimeOffset UpdatedAt);

/// <summary><c>BalanceSummary</c> of inventory.v1.yaml — one product across every visible location.</summary>
public sealed record BalanceSummaryLocationDto(LocationRefDto Location, decimal QtyOnHand, decimal QtyReserved, decimal QtyAvailable);

public sealed record BalanceSummaryDto(
    ProductRefDto Product,
    decimal QtyOnHand,
    decimal QtyReserved,
    decimal QtyAvailable,
    decimal? TotalValue,
    IReadOnlyList<BalanceSummaryLocationDto> ByLocation);
