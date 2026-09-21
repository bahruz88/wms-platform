using Wms.Inventory.Contracts;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Contracts;

/// <summary>In-process implementation of <see cref="IStockBalanceReader"/> (batch rows aggregated per product/location).</summary>
public sealed class StockBalanceReader(InventoryDbContext db) : IStockBalanceReader
{
    public async Task<StockLevelDto?> GetAsync(long productId, long locationId, CancellationToken cancellationToken)
    {
        if (productId is <= 0 or > uint.MaxValue || locationId is <= 0 or > uint.MaxValue)
        {
            return null;
        }

        var product = (uint)productId;
        var location = (uint)locationId;
        var rows = await db.Balances.AsNoTracking()
            .Where(b => b.ProductId == product && b.LocationId == location)
            .Select(b => new { b.QtyOnHand, b.QtyReserved })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        if (rows.Count == 0)
        {
            return null;
        }

        var onHand = rows.Sum(r => r.QtyOnHand);
        var reserved = rows.Sum(r => r.QtyReserved);
        return new StockLevelDto(product, location, onHand, reserved, onHand - reserved);
    }

    public async Task<IReadOnlyList<StockLevelDto>> GetByProductAsync(long productId, CancellationToken cancellationToken)
    {
        if (productId is <= 0 or > uint.MaxValue)
        {
            return [];
        }

        var product = (uint)productId;
        var rows = await db.Balances.AsNoTracking()
            .Where(b => b.ProductId == product)
            .GroupBy(b => b.LocationId)
            .Select(g => new { LocationId = g.Key, OnHand = g.Sum(b => b.QtyOnHand), Reserved = g.Sum(b => b.QtyReserved) })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows.Select(r => new StockLevelDto(product, r.LocationId, r.OnHand, r.Reserved, r.OnHand - r.Reserved)).ToList();
    }
}
