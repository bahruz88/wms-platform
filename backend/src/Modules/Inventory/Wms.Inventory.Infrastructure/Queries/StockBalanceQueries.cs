using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Queries;

public sealed class StockBalanceQueries(InventoryDbContext db) : IStockBalanceQueries
{
    public async Task<PagedResult<StockBalanceDto>> GetBalancesAsync(BalanceFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Balances.AsNoTracking();
        if (filter.LocationId is { } locationId)
        {
            query = query.Where(b => b.LocationId == locationId);
        }

        if (filter.ProductId is { } productId)
        {
            query = query.Where(b => b.ProductId == productId);
        }

        if (filter.VisibleLocationIds.Count > 0)
        {
            var visible = filter.VisibleLocationIds.ToArray();
            query = query.Where(b => visible.Contains(b.LocationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderBy(b => b.LocationId).ThenBy(b => b.ProductId).ThenBy(b => b.BatchId)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(b => new { b.ProductId, b.LocationId, b.BatchId, b.QtyOnHand, b.QtyReserved, b.AvgUnitCost, b.UpdatedAt })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows.Select(b => new StockBalanceDto(
            b.ProductId,
            b.LocationId,
            b.BatchId,
            b.QtyOnHand,
            b.QtyReserved,
            b.QtyOnHand - b.QtyReserved,
            includeCost ? b.AvgUnitCost : null,
            includeCost ? Quantity.Round(b.QtyOnHand * b.AvgUnitCost, Money.StorageDecimals) : null,
            b.UpdatedAt)).ToList();

        return new PagedResult<StockBalanceDto>(items, page.Page, page.Size, total);
    }
}
