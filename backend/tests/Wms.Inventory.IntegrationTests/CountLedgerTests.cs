using System.Data;
using Microsoft.EntityFrameworkCore;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.IntegrationTests;

/// <summary>
/// Spec §12.6 / §12.7 against real MySQL: the freeze snapshot, the location block and the <c>COUNT_ADJUST</c>
/// posting. The interesting part is transactional — <c>SELECT ... FOR UPDATE</c> over a whole location, and a
/// ledger group that has to balance to zero — so it cannot be proven with in-memory tests.
/// </summary>
[Collection(MySqlCollection.Name)]
[Trait("Category", "Integration")]
public sealed class CountLedgerTests(MySqlFixture fixture)
{
    private const uint TenantId = 1;

    // Tests in this collection share one MySQL container, so each takes its own location: a count left frozen by
    // one test would otherwise show up as a frozen location in another.
    private const uint Warehouse = 40;
    private const uint SecondWarehouse = 41;
    private const uint AdjustmentLocation = 902;
    private const uint SupplierLocation = 900;
    private const ushort BaseUom = 1;

    [Fact]
    public async Task Freeze_snapshots_the_balances_and_posting_writes_a_balanced_count_adjust_group()
    {
        var cancellationToken = TestCancellation.Token;
        var now = fixture.Clock.UtcNow;
        var productId = (uint)Random.Shared.Next(70_000, 79_999);
        var docNo = $"IC-2026-{Random.Shared.Next(10000, 99999)}";

        // ---------- opening stock so the count has something to look at
        await SeedOpeningStockAsync(productId, 120m, unitCost: 2.5m, cancellationToken);

        // ---------- freeze: book_qty is the balance at that instant
        await using var db = fixture.CreateContext();
        var count = StockCount.CreateDraft(TenantId, docNo, Warehouse, CountType.Spot, [], [productId], "integration").Value;

        await using (var freezeTx = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken))
        {
            var rows = await db.Balances
                .FromSqlInterpolated($"""
                    SELECT * FROM inv_balance
                    WHERE tenant_id = {TenantId} AND location_id = {Warehouse} AND product_id = {productId}
                    FOR UPDATE
                    """)
                .IgnoreQueryFilters()
                .ToListAsync(cancellationToken);

            var snapshot = rows.Select(r => new CountSnapshotRow(r.ProductId, r.BatchId, r.QtyOnHand, r.AvgUnitCost)).ToList();
            Assert.True(count.Freeze(snapshot, now).IsSuccess);

            db.Counts.Add(count);
            await db.SaveChangesAsync(cancellationToken);
            await freezeTx.CommitAsync(cancellationToken);
        }

        Assert.Equal(CountStatus.Frozen, count.Status);
        Assert.Equal(120m, count.Lines.Single().BookQty);

        // ---------- the location now reads as frozen, which is what blocks every other posting (spec §12.7)
        await using (var freezeCheck = fixture.CreateContext())
        {
            var frozen = await freezeCheck.Counts.AsNoTracking()
                .AnyAsync(c => c.LocationId == Warehouse && StockCount.FreezingStatuses.Contains(c.Status), cancellationToken);
            Assert.True(frozen);
        }

        // ---------- count 113 where the book said 120: a shortage of 7
        Assert.True(count.CountLine(productId, null, 113m, reasonCodeId: 4, note: "integration", countedBy: 7, now).IsSuccess);
        Assert.True(count.Submit(approvalThresholdPct: 2m).IsSuccess);
        Assert.True(count.RequiresApproval, "5.83 % is beyond the 2 % threshold and must ask for approval");
        Assert.True(count.Approve(approvedBy: 9, now).IsSuccess);
        await db.SaveChangesAsync(cancellationToken);

        // ---------- post: warehouse −7 / V_ADJUSTMENT +7
        var line = count.Lines.Single();
        long adjustGroupId;
        await using (var postTx = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken))
        {
            var group = MovementGroup.Create(
                new MovementGroupHeader(
                    TenantId, DocType.CountAdjust, docNo, new DateOnly(2026, 9, 21), now, 9, Guid.NewGuid(),
                    SourceDocType: "COUNT", SourceDocId: count.Id, ReasonCodeId: 4),
                [
                    new MovementLineInput(productId, Warehouse, null, line.VarianceQty!.Value, BaseUom, 1m, BaseUom, 4, line.AvgUnitCost),
                    new MovementLineInput(productId, AdjustmentLocation, null, -line.VarianceQty!.Value, BaseUom, 1m, BaseUom, 4, line.AvgUnitCost),
                ]).Value;

            db.MovementGroups.Add(group);
            await db.SaveChangesAsync(cancellationToken);

            foreach (var movement in group.Lines)
            {
                var balance = await LockAsync(db, movement.ProductId, movement.LocationId, cancellationToken)
                    ?? Track(db, StockBalance.Open(TenantId, movement.ProductId, movement.LocationId, StockBalance.NoBatch, now));
                Assert.True(balance.Apply(movement, movement.LocationId == AdjustmentLocation, now).IsSuccess);
            }

            Assert.True(count.MarkPosted(group.Id).IsSuccess);
            await db.SaveChangesAsync(cancellationToken);
            await postTx.CommitAsync(cancellationToken);
            adjustGroupId = group.Id;
        }

        // ---------- the balance now matches what was counted, and the group balances to zero (ADR-003)
        await using var verify = fixture.CreateContext();
        var warehouseBalance = await verify.Balances.AsNoTracking()
            .SingleAsync(b => b.ProductId == productId && b.LocationId == Warehouse, cancellationToken);
        Assert.Equal(113m, warehouseBalance.QtyOnHand);

        var adjustment = await verify.Balances.AsNoTracking()
            .SingleAsync(b => b.ProductId == productId && b.LocationId == AdjustmentLocation, cancellationToken);
        Assert.Equal(7m, adjustment.QtyOnHand);

        var groupSum = await verify.Movements.AsNoTracking()
            .Where(m => m.GroupId == adjustGroupId)
            .SumAsync(m => m.QtyBase, cancellationToken);
        Assert.Equal(0m, groupSum);

        // ---------- and the location is released
        var stillFrozen = await verify.Counts.AsNoTracking()
            .AnyAsync(c => c.LocationId == Warehouse && StockCount.FreezingStatuses.Contains(c.Status), cancellationToken);
        Assert.False(stillFrozen);
    }

    [Fact]
    public async Task A_count_line_with_a_variance_and_no_reason_code_never_reaches_the_database()
    {
        var cancellationToken = TestCancellation.Token;
        var now = fixture.Clock.UtcNow;
        var productId = (uint)Random.Shared.Next(80_000, 89_999);
        var docNo = $"IC-2026-{Random.Shared.Next(10000, 99999)}";

        await using var db = fixture.CreateContext();
        var count = StockCount.CreateDraft(TenantId, docNo, SecondWarehouse, CountType.Spot, [], [productId], null).Value;
        Assert.True(count.Freeze([new CountSnapshotRow(productId, 0, 50m, 1m)], now).IsSuccess);
        db.Counts.Add(count);
        await db.SaveChangesAsync(cancellationToken);

        // Spec §12.6: this is the guard that makes the Excel "+510" impossible.
        var rejected = count.CountLine(productId, null, 45m, reasonCodeId: null, note: null, countedBy: 7, now);
        Assert.True(rejected.IsFailure);
        Assert.Equal("REASON_CODE_REQUIRED", rejected.Error.Code);

        await using var verify = fixture.CreateContext();
        var stored = await verify.CountLines.AsNoTracking()
            .SingleAsync(l => l.CountId == count.Id, cancellationToken);
        Assert.Null(stored.CountedQty);
        Assert.Null(stored.VarianceQty);
    }

    private async Task SeedOpeningStockAsync(uint productId, decimal qty, decimal unitCost, CancellationToken cancellationToken)
    {
        await using var db = fixture.CreateContext();
        await using var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken);
        var now = fixture.Clock.UtcNow;

        var group = MovementGroup.Create(
            new MovementGroupHeader(
                TenantId, DocType.Opening, $"OPEN-{productId}", new DateOnly(2026, 9, 1), now, 7, Guid.NewGuid()),
            [
                new MovementLineInput(productId, SupplierLocation, null, -qty, BaseUom, 1m, BaseUom, 4, unitCost),
                new MovementLineInput(productId, Warehouse, null, qty, BaseUom, 1m, BaseUom, 4, unitCost),
            ]).Value;

        db.MovementGroups.Add(group);
        await db.SaveChangesAsync(cancellationToken);

        foreach (var movement in group.Lines)
        {
            var balance = Track(db, StockBalance.Open(TenantId, movement.ProductId, movement.LocationId, StockBalance.NoBatch, now));
            Assert.True(balance.Apply(movement, movement.LocationId == SupplierLocation, now).IsSuccess);
        }

        await db.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
    }

    private static StockBalance Track(Wms.Inventory.Infrastructure.Persistence.InventoryDbContext db, StockBalance balance)
    {
        db.Balances.Add(balance);
        return balance;
    }

    private static async Task<StockBalance?> LockAsync(
        Wms.Inventory.Infrastructure.Persistence.InventoryDbContext db,
        uint productId,
        uint locationId,
        CancellationToken cancellationToken)
    {
        var rows = await db.Balances
            .FromSqlInterpolated($"""
                SELECT * FROM inv_balance
                WHERE tenant_id = {TenantId} AND product_id = {productId}
                  AND location_id = {locationId} AND batch_id = 0
                FOR UPDATE
                """)
            .IgnoreQueryFilters()
            .ToListAsync(cancellationToken);
        return rows.SingleOrDefault();
    }
}
