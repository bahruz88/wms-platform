using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §9.2 / §15: batch creation and the status machine used by the ExpiryScanner job.</summary>
public sealed class BatchTests
{
    private static readonly DateTimeOffset Now = new(2026, 9, 21, 6, 0, 0, TimeSpan.Zero);

    private static Batch NewBatch(string? expiry = "2026-12-31") =>
        Batch.Create(1, 55, " LOT-A ", new DateOnly(2026, 9, 1), expiry is null ? null : DateOnly.Parse(expiry, System.Globalization.CultureInfo.InvariantCulture), 3, Now).Value;

    [Fact]
    public void Create_trims_the_batch_number_and_starts_active()
    {
        var batch = NewBatch();

        Assert.Equal("LOT-A", batch.BatchNo);
        Assert.Equal(BatchStatus.Active, batch.Status);
        Assert.True(batch.IsAllocatable());
    }

    [Fact]
    public void Create_rejects_an_expiry_before_the_production_date()
    {
        var result = Batch.Create(1, 55, "LOT-B", new DateOnly(2026, 9, 10), new DateOnly(2026, 9, 1), null, Now);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_BATCH", result.Error.Code);
    }

    [Fact]
    public void Create_rejects_an_empty_batch_number()
    {
        Assert.True(Batch.Create(1, 55, "   ", null, null, null, Now).IsFailure);
    }

    [Fact]
    public void IsExpiredOn_compares_against_the_expiry_date()
    {
        var batch = NewBatch("2026-09-15");

        Assert.True(batch.IsExpiredOn(new DateOnly(2026, 9, 21)));
        Assert.False(batch.IsExpiredOn(new DateOnly(2026, 9, 15)));
    }

    [Fact]
    public void MarkExpired_removes_the_batch_from_allocation()
    {
        var batch = NewBatch();

        Assert.True(batch.MarkExpired().IsSuccess);
        Assert.Equal(BatchStatus.Expired, batch.Status);
        Assert.False(batch.IsAllocatable());
    }

    [Fact]
    public void An_expired_batch_cannot_be_released_again()
    {
        var batch = NewBatch();
        batch.MarkExpired();

        var result = batch.Release();

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_BATCH_TRANSITION", result.Error.Code);
    }

    [Fact]
    public void Block_and_release_round_trip()
    {
        var batch = NewBatch();

        Assert.True(batch.Block().IsSuccess);
        Assert.False(batch.IsAllocatable());
        Assert.True(batch.Release().IsSuccess);
        Assert.True(batch.IsAllocatable());
    }
}
