using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Application.Abstractions;

public interface IGoodsReceiptRepository
{
    Task<GoodsReceipt?> GetAsync(long receiptId, CancellationToken cancellationToken);

    void Add(GoodsReceipt receipt);
}

public interface IMovementGroupRepository
{
    Task<MovementGroup?> FindByIdempotencyKeyAsync(uint tenantId, Guid idempotencyKey, CancellationToken cancellationToken);

    /// <summary>Loads a posted group with its lines, tracked, so a storno can be built from it (spec §12.6).</summary>
    Task<MovementGroup?> GetAsync(long groupId, CancellationToken cancellationToken);

    /// <summary>True when a REVERSAL group already reverses <paramref name="groupId"/>.</summary>
    Task<bool> IsReversedAsync(uint tenantId, long groupId, CancellationToken cancellationToken);

    void Add(MovementGroup group);
}

public interface IBatchRepository
{
    Task<Batch?> FindAsync(uint tenantId, uint productId, string batchNo, DateOnly? expiryDate, CancellationToken cancellationToken);

    Task<Batch?> GetAsync(long batchId, CancellationToken cancellationToken);

    void Add(Batch batch);
}

public interface IStockCountRepository
{
    Task<StockCount?> GetAsync(long countId, CancellationToken cancellationToken);

    /// <summary>The open (DRAFT..APPROVED) count of a location, if any — one location may only have one at a time.</summary>
    Task<StockCount?> FindOpenForLocationAsync(uint tenantId, uint locationId, CancellationToken cancellationToken);

    void Add(StockCount count);
}

public interface IStockRequestRepository
{
    Task<StockRequest?> GetAsync(long requestId, CancellationToken cancellationToken);

    void Add(StockRequest request);
}

public interface IIssueRepository
{
    Task<Issue?> GetAsync(long issueId, CancellationToken cancellationToken);

    void Add(Issue issue);
}

public interface IWasteRepository
{
    Task<Waste?> GetAsync(long wasteId, CancellationToken cancellationToken);

    void Add(Waste waste);
}

public interface ISampleRepository
{
    Task<Sample?> GetAsync(long sampleId, CancellationToken cancellationToken);

    void Add(Sample sample);
}

public interface IReturnToVendorRepository
{
    Task<ReturnToVendor?> GetAsync(long returnId, CancellationToken cancellationToken);

    void Add(ReturnToVendor document);
}

/// <summary>The ONLY access path to <c>inv_balance</c> rows for writing (spec §12.2, ADR-004).</summary>
public interface IStockBalanceRepository
{
    /// <summary>Loads the row with <c>SELECT ... FOR UPDATE</c>, creating (and tracking) an empty row when none exists. Must be called inside a transaction.</summary>
    Task<StockBalance> GetForUpdateAsync(uint tenantId, uint productId, uint locationId, long batchId, DateTimeOffset now, CancellationToken cancellationToken);

    /// <summary>
    /// Locks EVERY batch row of one product at one location with <c>SELECT ... FOR UPDATE</c> before the caller
    /// decides how much it can take (spec §12.2, §12.4). Must be called inside a transaction.
    /// </summary>
    Task<IReadOnlyList<StockBalance>> GetAllForUpdateAsync(uint tenantId, uint productId, uint locationId, CancellationToken cancellationToken);

    /// <summary>
    /// Locks and returns every balance row of one location — the snapshot an inventory count freezes into
    /// <c>book_qty</c> (spec §12.7). <paramref name="productIds"/> narrows it to a CYCLE/SPOT scope; empty means all.
    /// Must be called inside a transaction.
    /// </summary>
    Task<IReadOnlyList<StockBalance>> GetLocationForUpdateAsync(uint tenantId, uint locationId, IReadOnlyCollection<uint> productIds, CancellationToken cancellationToken);
}
