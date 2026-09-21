using Wms.Common.Application.Security;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Infrastructure.Persistence.Repositories;

/// <summary>The only write path to <c>inv_balance</c> (spec §12.2): row lock first, then <see cref="StockBalance.Apply"/>.</summary>
public sealed class StockBalanceRepository(InventoryDbContext db) : IStockBalanceRepository
{
    [AllowCrossTenant("tenant_id is bound as a parameter inside the raw SQL; IgnoreQueryFilters only keeps EF from wrapping the FOR UPDATE statement in a derived table.")]
    public async Task<StockBalance> GetForUpdateAsync(
        uint tenantId,
        uint productId,
        uint locationId,
        long batchId,
        DateTimeOffset now,
        CancellationToken cancellationToken)
    {
        if (db.Database.CurrentTransaction is null)
        {
            throw new InvalidOperationException("GetForUpdateAsync must be called inside an explicit transaction (spec §12.2).");
        }

        var rows = await db.Balances
            .FromSqlInterpolated($"""
                SELECT * FROM inv_balance
                WHERE tenant_id = {tenantId} AND product_id = {productId}
                  AND location_id = {locationId} AND batch_id = {batchId}
                FOR UPDATE
                """)
            .IgnoreQueryFilters()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var balance = rows.SingleOrDefault();
        if (balance is not null)
        {
            return balance;
        }

        balance = StockBalance.Open(tenantId, productId, locationId, batchId, now);
        db.Balances.Add(balance);
        return balance;
    }

    [AllowCrossTenant("tenant_id is bound as a parameter inside the raw SQL; IgnoreQueryFilters only keeps EF from wrapping the FOR UPDATE statement in a derived table.")]
    public async Task<IReadOnlyList<StockBalance>> GetAllForUpdateAsync(
        uint tenantId,
        uint productId,
        uint locationId,
        CancellationToken cancellationToken)
    {
        if (db.Database.CurrentTransaction is null)
        {
            throw new InvalidOperationException("GetAllForUpdateAsync must be called inside an explicit transaction (spec §12.2).");
        }

        return await db.Balances
            .FromSqlInterpolated($"""
                SELECT * FROM inv_balance
                WHERE tenant_id = {tenantId} AND product_id = {productId} AND location_id = {locationId}
                ORDER BY batch_id
                FOR UPDATE
                """)
            .IgnoreQueryFilters()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
    }
}
