using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §12.1 (no negative stock) and §12.5 (moving average) applied through the balance projection.</summary>
public sealed class StockBalanceTests
{
    private const uint TenantId = 1;
    private const uint ProductId = 55;
    private const uint Warehouse = 10;
    private static readonly DateTimeOffset Now = new(2026, 9, 21, 10, 0, 0, TimeSpan.Zero);

    private static StockBalance NewBalance() => StockBalance.Open(TenantId, ProductId, Warehouse, StockBalance.NoBatch, Now);

    private static Movement MovementFor(decimal qtyBase, decimal? unitCost = null, uint locationId = Warehouse, long? batchId = null)
    {
        var group = MovementGroup.Create(
            new MovementGroupHeader(TenantId, DocType.Receipt, "GR-1", new DateOnly(2026, 9, 21), Now, 1, Guid.NewGuid()),
            [
                new MovementLineInput(ProductId, locationId, batchId, qtyBase, 1, 1m, 1, 4, unitCost),
                new MovementLineInput(ProductId, 900, batchId, -qtyBase, 1, 1m, 1, 4, unitCost),
            ]).Value;
        return group.Lines[0];
    }

    [Fact]
    public void Apply_increases_the_quantity_on_a_receipt()
    {
        var balance = NewBalance();

        var result = balance.Apply(MovementFor(100m), allowNegativeStock: false, Now);

        Assert.True(result.IsSuccess);
        Assert.Equal(100m, balance.QtyOnHand);
    }

    [Fact]
    public void Apply_rejects_an_issue_that_would_make_the_balance_negative()
    {
        var balance = NewBalance();
        balance.Apply(MovementFor(45m), allowNegativeStock: false, Now);

        var result = balance.Apply(MovementFor(-60m), allowNegativeStock: false, Now);

        Assert.True(result.IsFailure);
        Assert.Equal("INSUFFICIENT_STOCK", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
        Assert.Equal(45m, balance.QtyOnHand);
    }

    [Fact]
    public void Apply_allows_a_negative_balance_only_when_the_tenant_setting_says_so()
    {
        var balance = NewBalance();

        var result = balance.Apply(MovementFor(-10m), allowNegativeStock: true, Now);

        Assert.True(result.IsSuccess);
        Assert.Equal(-10m, balance.QtyOnHand);
    }

    [Fact]
    public void Apply_rejects_a_movement_that_belongs_to_another_key()
    {
        var balance = NewBalance();

        var result = balance.Apply(MovementFor(10m, locationId: 11), allowNegativeStock: false, Now);

        Assert.True(result.IsFailure);
        Assert.Equal("BALANCE_KEY_MISMATCH", result.Error.Code);
    }

    [Fact]
    public void Apply_updates_the_moving_average_cost_on_receipts_only()
    {
        var balance = NewBalance();

        balance.Apply(MovementFor(100m, unitCost: 10m), allowNegativeStock: false, Now);
        Assert.Equal(10m, balance.AvgUnitCost);

        // (100 × 10 + 100 × 20) / 200 = 15
        balance.Apply(MovementFor(100m, unitCost: 20m), allowNegativeStock: false, Now);
        Assert.Equal(15m, balance.AvgUnitCost);

        // An issue consumes at the current average and leaves it unchanged (spec §12.5).
        balance.Apply(MovementFor(-50m, unitCost: 15m), allowNegativeStock: false, Now);
        Assert.Equal(15m, balance.AvgUnitCost);
        Assert.Equal(150m, balance.QtyOnHand);
    }

    [Fact]
    public void Reserve_and_release_track_the_available_quantity()
    {
        var balance = NewBalance();
        balance.Apply(MovementFor(100m), allowNegativeStock: false, Now);

        Assert.True(balance.Reserve(30m, Now).IsSuccess);
        Assert.Equal(70m, balance.QtyAvailable());

        Assert.True(balance.Reserve(80m, Now).IsFailure);

        Assert.True(balance.Release(30m, Now).IsSuccess);
        Assert.Equal(100m, balance.QtyAvailable());
    }

    [Fact]
    public void StockBalance_exposes_no_public_setters()
    {
        // ADR-004: a balance may only change through Apply/Reserve/Release, never by assignment.
        var writable = typeof(StockBalance)
            .GetProperties()
            .Where(p => p.SetMethod is { IsPublic: true })
            .Select(p => p.Name)
            .ToList();

        Assert.Empty(writable);
    }
}
