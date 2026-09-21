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

public sealed class BatchRepository(InventoryDbContext db) : IBatchRepository
{
    public Task<Batch?> FindAsync(uint tenantId, uint productId, string batchNo, DateOnly? expiryDate, CancellationToken cancellationToken) =>
        db.Batches.FirstOrDefaultAsync(
            b => b.TenantId == tenantId && b.ProductId == productId && b.BatchNo == batchNo && b.ExpiryDate == expiryDate,
            cancellationToken);

    public void Add(Batch batch) => db.Batches.Add(batch);
}
