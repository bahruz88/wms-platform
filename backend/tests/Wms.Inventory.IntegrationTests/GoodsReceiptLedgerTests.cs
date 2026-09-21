using System.Data;
using Microsoft.EntityFrameworkCore;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.IntegrationTests;

/// <summary>
/// Spec §17.2: receipt → balance increase → the ledger sums to zero. Exercises the one allowed transaction path
/// of spec §12.2 against real MySQL, including <c>SELECT ... FOR UPDATE</c>.
/// </summary>
[Collection(MySqlCollection.Name)]
[Trait("Category", "Integration")]
public sealed class GoodsReceiptLedgerTests(MySqlFixture fixture)
{
    private const uint TenantId = 1;
    private const uint ProductId = 55;
    private const uint Warehouse = 10;
    private const uint SupplierLocation = 900;
    private const ushort BaseUom = 1;

    [Fact]
    public async Task Posting_a_receipt_increases_the_balance_and_keeps_the_ledger_at_zero()
    {
        var cancellationToken = TestCancellation.Token;
        var docNo = $"GR-2026-{Random.Shared.Next(10000, 99999)}";
        var now = fixture.Clock.UtcNow;

        await using var db = fixture.CreateContext();
        await using var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken);

        // 1. Double-entry group: V_SUPPLIER −100, warehouse +100 (spec §12.3).
        var group = MovementGroup.Create(
            new MovementGroupHeader(TenantId, DocType.Receipt, docNo, new DateOnly(2026, 9, 21), now, 7, Guid.NewGuid()),
            [
                new MovementLineInput(ProductId, SupplierLocation, null, -100m, BaseUom, 1m, BaseUom, 4, 10m, "AZN", 1m),
                new MovementLineInput(ProductId, Warehouse, null, 100m, BaseUom, 1m, BaseUom, 4, 10m, "AZN", 1m),
            ]).Value;

        db.MovementGroups.Add(group);
        await db.SaveChangesAsync(cancellationToken);

        // 2. Lock and update each balance row inside the same transaction (spec §12.2).
        foreach (var movement in group.Lines)
        {
            var balance = await LockBalanceAsync(db, movement.LocationId, cancellationToken)
                ?? StockBalance.Open(TenantId, ProductId, movement.LocationId, StockBalance.NoBatch, now);
            if (balance.QtyOnHand == 0m && db.Entry(balance).State == EntityState.Detached)
            {
                db.Balances.Add(balance);
            }

            var allowNegative = movement.LocationId == SupplierLocation;
            Assert.True(balance.Apply(movement, allowNegative, now).IsSuccess);
        }

        await db.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        // 3. The warehouse balance grew by 100 with an average cost of 10.
        await using var verify = fixture.CreateContext();
        var warehouseBalance = await verify.Balances.AsNoTracking()
            .SingleAsync(b => b.ProductId == ProductId && b.LocationId == Warehouse, cancellationToken);
        Assert.Equal(100m, warehouseBalance.QtyOnHand);
        Assert.Equal(10m, warehouseBalance.AvgUnitCost);

        // 4. ADR-003 invariant: SUM(qty_base) GROUP BY group_id is always 0.
        var groupSum = await verify.Movements.AsNoTracking()
            .Where(m => m.GroupId == group.Id)
            .SumAsync(m => m.QtyBase, cancellationToken);
        Assert.Equal(0m, groupSum);

        // 5. ADR-004: the balance equals SUM(inv_movement.qty_base) for the same key.
        var ledgerQty = await verify.Movements.AsNoTracking()
            .Where(m => m.ProductId == ProductId && m.LocationId == Warehouse)
            .SumAsync(m => m.QtyBase, cancellationToken);
        Assert.Equal(warehouseBalance.QtyOnHand, ledgerQty);
    }

    [Fact]
    public async Task The_idempotency_key_is_unique_per_tenant()
    {
        // Spec §13.2 / uq_mg_idem: a repeated key must not create a second document.
        var cancellationToken = TestCancellation.Token;
        var key = Guid.NewGuid();
        var now = fixture.Clock.UtcNow;

        await using var db = fixture.CreateContext();
        db.MovementGroups.Add(Group($"GR-A-{Random.Shared.Next(10000, 99999)}", key, now));
        await db.SaveChangesAsync(cancellationToken);

        await using var second = fixture.CreateContext();
        second.MovementGroups.Add(Group($"GR-B-{Random.Shared.Next(10000, 99999)}", key, now));

        await Assert.ThrowsAsync<DbUpdateException>(() => second.SaveChangesAsync(cancellationToken));
    }

    private static MovementGroup Group(string docNo, Guid idempotencyKey, DateTimeOffset now) =>
        MovementGroup.Create(
            new MovementGroupHeader(TenantId, DocType.Receipt, docNo, new DateOnly(2026, 9, 21), now, 7, idempotencyKey),
            [
                new MovementLineInput(ProductId, SupplierLocation, null, -5m, BaseUom, 1m, BaseUom, 4),
                new MovementLineInput(ProductId, Warehouse, null, 5m, BaseUom, 1m, BaseUom, 4),
            ]).Value;

    private static async Task<StockBalance?> LockBalanceAsync(Microsoft.EntityFrameworkCore.DbContext context, uint locationId, CancellationToken cancellationToken)
    {
        var db = (Wms.Inventory.Infrastructure.Persistence.InventoryDbContext)context;
        var rows = await db.Balances
            .FromSqlInterpolated($"""
                SELECT * FROM inv_balance
                WHERE tenant_id = {TenantId} AND product_id = {ProductId}
                  AND location_id = {locationId} AND batch_id = {StockBalance.NoBatch}
                FOR UPDATE
                """)
            .IgnoreQueryFilters()
            .ToListAsync(cancellationToken);
        return rows.SingleOrDefault();
    }
}
