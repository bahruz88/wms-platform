namespace Wms.Inventory.Application.Dtos;

/// <summary>Balance row. <c>AvgUnitCost</c> / <c>TotalValue</c> are null (and absent from JSON) without <c>master.product.view_cost</c>.</summary>
public sealed record StockBalanceDto(
    uint ProductId,
    uint LocationId,
    long BatchId,
    decimal QtyOnHand,
    decimal QtyReserved,
    decimal QtyAvailable,
    decimal? AvgUnitCost,
    decimal? TotalValue,
    DateTimeOffset UpdatedAt);
