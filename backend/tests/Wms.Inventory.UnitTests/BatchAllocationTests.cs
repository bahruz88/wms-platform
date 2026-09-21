using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Domain.Services;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §12.4: FEFO / FIFO ordering and the exclusion of non-ACTIVE batches.</summary>
public sealed class BatchAllocationTests
{
    private static DateTimeOffset At(int day) => new(2026, 9, day, 0, 0, 0, TimeSpan.Zero);

    private static BatchCandidate Candidate(long id, string? expiry, int receivedDay, decimal available, BatchStatus status = BatchStatus.Active) =>
        new(id, status, expiry is null ? null : DateOnly.Parse(expiry, System.Globalization.CultureInfo.InvariantCulture), At(receivedDay), available);

    [Fact]
    public void Fefo_orders_by_expiry_date_first()
    {
        // The Excel case: an old (15.09.2026) and a new (February) batch mixed on one row — here FEFO picks the old one.
        var candidates = new[]
        {
            Candidate(2, "2027-02-01", receivedDay: 1, available: 50m),
            Candidate(1, "2026-09-15", receivedDay: 5, available: 50m),
        };

        var ordered = candidates.OrderBy(c => c, new BatchIssueComparer(IssueStrategy.Fefo)).Select(c => c.BatchId).ToList();

        Assert.Equal([1L, 2L], ordered);
    }

    [Fact]
    public void Fefo_breaks_ties_on_received_at()
    {
        var candidates = new[]
        {
            Candidate(2, "2026-12-01", receivedDay: 10, available: 5m),
            Candidate(1, "2026-12-01", receivedDay: 3, available: 5m),
        };

        var ordered = candidates.OrderBy(c => c, new BatchIssueComparer(IssueStrategy.Fefo)).Select(c => c.BatchId).ToList();

        Assert.Equal([1L, 2L], ordered);
    }

    [Fact]
    public void Fefo_places_batches_without_an_expiry_date_last()
    {
        var candidates = new[]
        {
            Candidate(1, null, receivedDay: 1, available: 5m),
            Candidate(2, "2027-01-01", receivedDay: 20, available: 5m),
        };

        var ordered = candidates.OrderBy(c => c, new BatchIssueComparer(IssueStrategy.Fefo)).Select(c => c.BatchId).ToList();

        Assert.Equal([2L, 1L], ordered);
    }

    [Fact]
    public void Fifo_ignores_the_expiry_date_and_orders_by_received_at()
    {
        var candidates = new[]
        {
            Candidate(1, "2026-10-01", receivedDay: 20, available: 5m),
            Candidate(2, "2027-01-01", receivedDay: 2, available: 5m),
        };

        var ordered = candidates.OrderBy(c => c, new BatchIssueComparer(IssueStrategy.Fifo)).Select(c => c.BatchId).ToList();

        Assert.Equal([2L, 1L], ordered);
    }

    [Fact]
    public void Allocate_splits_the_requested_quantity_across_batches_in_fefo_order()
    {
        var candidates = new[]
        {
            Candidate(1, "2026-10-01", receivedDay: 1, available: 30m),
            Candidate(2, "2026-11-01", receivedDay: 2, available: 100m),
        };

        var result = BatchAllocator.Allocate(candidates, requestedQty: 50m, IssueStrategy.Fefo);

        Assert.True(result.IsSuccess);
        Assert.Equal(2, result.Value.Count);
        Assert.Equal(new BatchAllocation(1, 30m), result.Value[0]);
        Assert.Equal(new BatchAllocation(2, 20m), result.Value[1]);
    }

    [Theory]
    [InlineData(BatchStatus.Blocked)]
    [InlineData(BatchStatus.Expired)]
    [InlineData(BatchStatus.Quarantine)]
    public void Allocate_never_uses_a_non_active_batch(BatchStatus status)
    {
        var candidates = new[]
        {
            Candidate(1, "2026-10-01", receivedDay: 1, available: 100m, status: status),
            Candidate(2, "2026-11-01", receivedDay: 2, available: 100m),
        };

        var result = BatchAllocator.Allocate(candidates, requestedQty: 40m, IssueStrategy.Fefo);

        Assert.True(result.IsSuccess);
        Assert.Single(result.Value);
        Assert.Equal(2L, result.Value[0].BatchId);
    }

    [Fact]
    public void Allocate_fails_when_the_allocatable_quantity_is_not_enough()
    {
        var candidates = new[] { Candidate(1, "2026-10-01", receivedDay: 1, available: 10m) };

        var result = BatchAllocator.Allocate(candidates, requestedQty: 25m, IssueStrategy.Fefo);

        Assert.True(result.IsFailure);
        Assert.Equal("INSUFFICIENT_STOCK", result.Error.Code);
    }
}
