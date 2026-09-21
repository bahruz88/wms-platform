using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Infrastructure.Persistence.Repositories;

public sealed class GoodsReceiptRepository(InventoryDbContext db) : IGoodsReceiptRepository
{
    public Task<GoodsReceipt?> GetAsync(long receiptId, CancellationToken cancellationToken) =>
        db.GoodsReceipts.Include(r => r.Lines).FirstOrDefaultAsync(r => r.Id == receiptId, cancellationToken);

    public void Add(GoodsReceipt receipt) => db.GoodsReceipts.Add(receipt);
}

public sealed class MovementGroupRepository(InventoryDbContext db) : IMovementGroupRepository
{
    public Task<MovementGroup?> FindByIdempotencyKeyAsync(uint tenantId, Guid idempotencyKey, CancellationToken cancellationToken) =>
        db.MovementGroups.AsNoTracking()
            .FirstOrDefaultAsync(g => g.TenantId == tenantId && g.IdempotencyKey == idempotencyKey, cancellationToken);

    public Task<MovementGroup?> GetAsync(long groupId, CancellationToken cancellationToken) =>
        db.MovementGroups.Include(g => g.Lines).FirstOrDefaultAsync(g => g.Id == groupId, cancellationToken);

    public Task<bool> IsReversedAsync(uint tenantId, long groupId, CancellationToken cancellationToken) =>
        db.MovementGroups.AsNoTracking().AnyAsync(g => g.TenantId == tenantId && g.ReversesGroupId == groupId, cancellationToken);

    public void Add(MovementGroup group) => db.MovementGroups.Add(group);
}

public sealed class StockCountRepository(InventoryDbContext db) : IStockCountRepository
{
    public Task<StockCount?> GetAsync(long countId, CancellationToken cancellationToken) =>
        db.Counts.Include(c => c.Lines).FirstOrDefaultAsync(c => c.Id == countId, cancellationToken);

    public Task<StockCount?> FindOpenForLocationAsync(uint tenantId, uint locationId, CancellationToken cancellationToken) =>
        db.Counts.AsNoTracking()
            .Where(c => c.TenantId == tenantId && c.LocationId == locationId && StockCount.OpenStatuses.Contains(c.Status))
            .OrderByDescending(c => c.Id)
            .FirstOrDefaultAsync(cancellationToken);

    public void Add(StockCount count) => db.Counts.Add(count);
}

public sealed class BatchRepository(InventoryDbContext db) : IBatchRepository
{
    public Task<Batch?> FindAsync(uint tenantId, uint productId, string batchNo, DateOnly? expiryDate, CancellationToken cancellationToken) =>
        db.Batches.FirstOrDefaultAsync(
            b => b.TenantId == tenantId && b.ProductId == productId && b.BatchNo == batchNo && b.ExpiryDate == expiryDate,
            cancellationToken);

    public Task<Batch?> GetAsync(long batchId, CancellationToken cancellationToken) =>
        db.Batches.FirstOrDefaultAsync(b => b.Id == batchId, cancellationToken);

    public void Add(Batch batch) => db.Batches.Add(batch);
}

public sealed class StockRequestRepository(InventoryDbContext db) : IStockRequestRepository
{
    public Task<StockRequest?> GetAsync(long requestId, CancellationToken cancellationToken) =>
        db.StockRequests.Include(r => r.Lines).FirstOrDefaultAsync(r => r.Id == requestId, cancellationToken);

    public void Add(StockRequest request) => db.StockRequests.Add(request);
}

public sealed class IssueRepository(InventoryDbContext db) : IIssueRepository
{
    public Task<Issue?> GetAsync(long issueId, CancellationToken cancellationToken) =>
        db.Issues.Include(i => i.Lines).FirstOrDefaultAsync(i => i.Id == issueId, cancellationToken);

    public void Add(Issue issue) => db.Issues.Add(issue);
}

public sealed class WasteRepository(InventoryDbContext db) : IWasteRepository
{
    public Task<Waste?> GetAsync(long wasteId, CancellationToken cancellationToken) =>
        db.Wastes.Include(w => w.Lines).FirstOrDefaultAsync(w => w.Id == wasteId, cancellationToken);

    public void Add(Waste waste) => db.Wastes.Add(waste);
}

public sealed class SampleRepository(InventoryDbContext db) : ISampleRepository
{
    public Task<Sample?> GetAsync(long sampleId, CancellationToken cancellationToken) =>
        db.Samples.Include(s => s.Lines).FirstOrDefaultAsync(s => s.Id == sampleId, cancellationToken);

    public void Add(Sample sample) => db.Samples.Add(sample);
}

public sealed class ReturnToVendorRepository(InventoryDbContext db) : IReturnToVendorRepository
{
    public Task<ReturnToVendor?> GetAsync(long returnId, CancellationToken cancellationToken) =>
        db.ReturnsToVendor.Include(r => r.Lines).FirstOrDefaultAsync(r => r.Id == returnId, cancellationToken);

    public void Add(ReturnToVendor document) => db.ReturnsToVendor.Add(document);
}
