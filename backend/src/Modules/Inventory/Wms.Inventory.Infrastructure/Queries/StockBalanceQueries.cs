using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Queries;

public sealed class StockBalanceQueries(InventoryDbContext db, IReferenceDataLoader referenceData, IClock clock) : IStockBalanceQueries
{
    /// <summary>Safety net for the in-memory pass used by the master-data filters (category / search / belowMin).</summary>
    private const int MaterialiseCap = 20_000;

    public async Task<PagedResult<StockBalanceDto>> GetBalancesAsync(BalanceFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = Filter(db.Balances.AsNoTracking(), filter);

        if (filter.ExpiringWithinDays is { } days)
        {
            // Batch expiry lives in inv_batch, the same context — a join keeps the filter in SQL.
            var limit = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime).AddDays(days);
            query = from balance in query
                    join batch in db.Batches.AsNoTracking() on balance.BatchId equals batch.Id
                    where batch.ExpiryDate != null && batch.ExpiryDate <= limit
                    select balance;
        }

        // Category / free-text / below-minimum need the MasterData product row, so they are applied after decoration.
        var needsMasterDataFilter = filter.CategoryId is not null || filter.BelowMin == true || !string.IsNullOrWhiteSpace(filter.Search);
        var ordered = query.OrderBy(b => b.LocationId).ThenBy(b => b.ProductId).ThenBy(b => b.BatchId);

        if (!needsMasterDataFilter)
        {
            var total = await ordered.LongCountAsync(cancellationToken).ConfigureAwait(false);
            var rows = await ordered.Skip(page.Skip).Take(page.Size).ToListAsync(cancellationToken).ConfigureAwait(false);
            var items = await MapAsync(rows, includeCost, cancellationToken).ConfigureAwait(false);
            return new PagedResult<StockBalanceDto>(items, page.Page, page.Size, total);
        }

        var candidates = await ordered.Take(MaterialiseCap).ToListAsync(cancellationToken).ConfigureAwait(false);
        var decorated = await MapAsync(candidates, includeCost, cancellationToken).ConfigureAwait(false);
        var filtered = ApplyMasterDataFilters(decorated, filter, await ProductCategoriesAsync(candidates, cancellationToken).ConfigureAwait(false));
        var pageItems = filtered.Skip(page.Skip).Take(page.Size).ToList();
        return new PagedResult<StockBalanceDto>(pageItems, page.Page, page.Size, filtered.Count);
    }

    public async Task<BalanceSummaryDto?> GetSummaryAsync(
        uint productId,
        uint? locationId,
        LocationScope visibleLocations,
        bool includeCost,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(visibleLocations);

        var query = db.Balances.AsNoTracking().Where(b => b.ProductId == productId);
        if (locationId is { } location)
        {
            query = query.Where(b => b.LocationId == location);
        }

        if (visibleLocations.IsRestricted)
        {
            var visible = visibleLocations.VisibleIds;
            query = query.Where(b => visible.Contains(b.LocationId));
        }

        var rows = await query.ToListAsync(cancellationToken).ConfigureAwait(false);
        var refs = await referenceData
            .LoadAsync(ReferenceDataRequest.For(productIds: [productId], locationIds: rows.Select(r => r.LocationId)), cancellationToken)
            .ConfigureAwait(false);
        if (refs.Product(productId) is null)
        {
            return null;
        }

        var byLocation = rows
            .GroupBy(r => r.LocationId)
            .OrderBy(g => g.Key)
            .Select(g => new BalanceSummaryLocationDto(
                refs.LocationRef(g.Key),
                g.Sum(r => r.QtyOnHand),
                g.Sum(r => r.QtyReserved),
                g.Sum(r => r.QtyOnHand - r.QtyReserved)))
            .ToList();

        return new BalanceSummaryDto(
            refs.ProductRef(productId),
            rows.Sum(r => r.QtyOnHand),
            rows.Sum(r => r.QtyReserved),
            rows.Sum(r => r.QtyOnHand - r.QtyReserved),
            includeCost ? Quantity.Round(rows.Sum(r => r.QtyOnHand * r.AvgUnitCost), Money.StorageDecimals) : null,
            byLocation);
    }

    private static IQueryable<StockBalance> Filter(IQueryable<StockBalance> query, BalanceFilter filter)
    {
        if (filter.LocationId is { } locationId)
        {
            query = query.Where(b => b.LocationId == locationId);
        }

        if (filter.ProductId is { } productId)
        {
            query = query.Where(b => b.ProductId == productId);
        }

        if (filter.BatchId is { } batchId)
        {
            query = query.Where(b => b.BatchId == batchId);
        }

        if (!filter.IncludeZero)
        {
            query = query.Where(b => b.QtyOnHand != 0m || b.QtyReserved != 0m);
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(b => visible.Contains(b.LocationId));
        }

        return query;
    }

    private async Task<Dictionary<uint, uint>> ProductCategoriesAsync(IReadOnlyCollection<StockBalance> rows, CancellationToken cancellationToken)
    {
        var refs = await referenceData
            .LoadAsync(ReferenceDataRequest.For(productIds: rows.Select(r => r.ProductId)), cancellationToken)
            .ConfigureAwait(false);
        return refs.Products.ToDictionary(kv => kv.Key, kv => kv.Value.CategoryId);
    }

    private static List<StockBalanceDto> ApplyMasterDataFilters(
        IReadOnlyList<StockBalanceDto> rows,
        BalanceFilter filter,
        IReadOnlyDictionary<uint, uint> categories)
    {
        IEnumerable<StockBalanceDto> result = rows;
        if (filter.CategoryId is { } categoryId)
        {
            result = result.Where(r => categories.GetValueOrDefault(r.Product.Id) == categoryId);
        }

        if (filter.BelowMin == true)
        {
            result = result.Where(r => r.IsBelowMin);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var term = filter.Search.Trim();
            result = result.Where(r =>
                r.Product.Sku.Contains(term, StringComparison.OrdinalIgnoreCase)
                || r.Product.Name.Contains(term, StringComparison.OrdinalIgnoreCase));
        }

        return result.ToList();
    }

    private async Task<List<StockBalanceDto>> MapAsync(IReadOnlyList<StockBalance> rows, bool includeCost, CancellationToken cancellationToken)
    {
        if (rows.Count == 0)
        {
            return [];
        }

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: rows.Select(r => r.ProductId),
                locationIds: rows.Select(r => r.LocationId),
                batchIds: rows.Select(r => r.BatchId)),
            cancellationToken).ConfigureAwait(false);

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        return rows.Select(row =>
        {
            var product = refs.Product(row.ProductId);
            var batch = refs.BatchRef(row.BatchId);
            var minStock = product?.MinStock;
            return new StockBalanceDto(
                refs.ProductRef(row.ProductId),
                refs.LocationRef(row.LocationId),
                batch,
                row.QtyOnHand,
                row.QtyReserved,
                row.QtyOnHand - row.QtyReserved,
                product?.BaseUomId ?? 0,
                product?.BaseUomCode ?? string.Empty,
                includeCost ? row.AvgUnitCost : null,
                includeCost ? Quantity.Round(row.QtyOnHand * row.AvgUnitCost, Money.StorageDecimals) : null,
                minStock,
                minStock is { } min && row.QtyOnHand < min,
                batch?.ExpiryDate is { } expiry ? expiry.DayNumber - today.DayNumber : null,
                row.LastMovementId,
                row.UpdatedAt);
        }).ToList();
    }
}
