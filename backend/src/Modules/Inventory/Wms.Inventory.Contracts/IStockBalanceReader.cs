namespace Wms.Inventory.Contracts;

public sealed record StockLevelDto(uint ProductId, uint LocationId, decimal QtyOnHand, decimal QtyReserved, decimal QtyAvailable);

/// <summary>Read-only balance access for other modules (e.g. Procurement checks stock before a PO). Batch-level detail stays inside Inventory.</summary>
public interface IStockBalanceReader
{
    Task<StockLevelDto?> GetAsync(long productId, long locationId, CancellationToken cancellationToken);

    Task<IReadOnlyList<StockLevelDto>> GetByProductAsync(long productId, CancellationToken cancellationToken);
}
