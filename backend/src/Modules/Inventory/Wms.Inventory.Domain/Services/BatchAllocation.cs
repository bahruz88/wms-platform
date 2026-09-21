using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Services;

/// <summary>Candidate row for allocation: batch + its available balance at one location.</summary>
public sealed record BatchCandidate(long BatchId, BatchStatus Status, DateOnly? ExpiryDate, DateTimeOffset ReceivedAt, decimal QtyAvailable);

public sealed record BatchAllocation(long BatchId, decimal Qty);

/// <summary>
/// FEFO: earliest expiry first (batches without expiry last), ties broken by <c>received_at</c>; FIFO: <c>received_at</c> only (spec §12.4).
/// Mirrors the <c>ORDER BY CASE WHEN ? = 'FEFO' THEN b.expiry_date END ASC, b.received_at ASC</c> of the allocation SQL.
/// </summary>
public sealed class BatchIssueComparer(IssueStrategy strategy) : IComparer<BatchCandidate>
{
    public IssueStrategy Strategy { get; } = strategy;

    public int Compare(BatchCandidate? x, BatchCandidate? y)
    {
        if (ReferenceEquals(x, y))
        {
            return 0;
        }

        if (x is null)
        {
            return 1;
        }

        if (y is null)
        {
            return -1;
        }

        if (Strategy == IssueStrategy.Fefo)
        {
            var byExpiry = CompareExpiry(x.ExpiryDate, y.ExpiryDate);
            if (byExpiry != 0)
            {
                return byExpiry;
            }
        }

        var byReceived = x.ReceivedAt.CompareTo(y.ReceivedAt);
        return byReceived != 0 ? byReceived : x.BatchId.CompareTo(y.BatchId);
    }

    private static int CompareExpiry(DateOnly? x, DateOnly? y) => (x, y) switch
    {
        (null, null) => 0,
        (null, _) => 1,
        (_, null) => -1,
        _ => x.Value.CompareTo(y.Value),
    };
}

public static class BatchAllocator
{
    /// <summary>Allocates <paramref name="requestedQty"/> across ACTIVE batches with available stock in strategy order.</summary>
    public static Result<IReadOnlyList<BatchAllocation>> Allocate(IEnumerable<BatchCandidate> candidates, decimal requestedQty, IssueStrategy strategy)
    {
        ArgumentNullException.ThrowIfNull(candidates);
        if (requestedQty <= 0m)
        {
            return InventoryErrors.InvalidQuantity("Requested quantity must be positive.");
        }

        var ordered = candidates
            .Where(c => c.Status == BatchStatus.Active && c.QtyAvailable > 0m)
            .OrderBy(c => c, new BatchIssueComparer(strategy))
            .ToList();

        var remaining = requestedQty;
        var allocations = new List<BatchAllocation>();
        foreach (var candidate in ordered)
        {
            if (remaining <= 0m)
            {
                break;
            }

            var take = Math.Min(candidate.QtyAvailable, remaining);
            allocations.Add(new BatchAllocation(candidate.BatchId, take));
            remaining -= take;
        }

        if (remaining > 0m)
        {
            return InventoryErrors.InsufficientStockForAllocation(requestedQty - remaining, requestedQty);
        }

        return allocations;
    }
}
