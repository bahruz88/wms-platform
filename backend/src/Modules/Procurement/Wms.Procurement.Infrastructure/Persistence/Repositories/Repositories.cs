using System.Data;
using Microsoft.EntityFrameworkCore.Storage;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Infrastructure.Persistence.Repositories;

public sealed class ProcurementUnitOfWork(ProcurementDbContext db) : IProcurementUnitOfWork
{
    public IIntegrationEventOutbox Outbox => db;

    public IAuditTrail Audit => db;

    public async Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken)
    {
        var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, cancellationToken).ConfigureAwait(false);
        return new EfTransaction(transaction);
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);

    private sealed class EfTransaction(IDbContextTransaction transaction) : IUnitOfWorkTransaction
    {
        public Task CommitAsync(CancellationToken cancellationToken) => transaction.CommitAsync(cancellationToken);

        public Task RollbackAsync(CancellationToken cancellationToken) => transaction.RollbackAsync(cancellationToken);

        public ValueTask DisposeAsync() => transaction.DisposeAsync();
    }
}

public sealed class RequisitionRepository(ProcurementDbContext db) : IRequisitionRepository
{
    public Task<Requisition?> GetAsync(long requisitionId, CancellationToken cancellationToken) =>
        db.Requisitions.Include(r => r.Lines).FirstOrDefaultAsync(r => r.Id == requisitionId, cancellationToken);

    public async Task<IReadOnlyList<Requisition>> GetByLineIdsAsync(IReadOnlyCollection<long> requisitionLineIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(requisitionLineIds);
        if (requisitionLineIds.Count == 0)
        {
            return [];
        }

        var ids = requisitionLineIds.ToArray();
        var requisitionIds = await db.RequisitionLines.AsNoTracking()
            .Where(l => ids.Contains(l.Id))
            .Select(l => l.RequisitionId)
            .Distinct()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return await db.Requisitions
            .Include(r => r.Lines)
            .Where(r => requisitionIds.Contains(r.Id))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
    }

    public void Add(Requisition requisition) => db.Requisitions.Add(requisition);
}

public sealed class RfqRepository(ProcurementDbContext db) : IRfqRepository
{
    public Task<Rfq?> GetAsync(long rfqId, CancellationToken cancellationToken) =>
        db.Rfqs.Include(r => r.Lines).Include(r => r.Suppliers).FirstOrDefaultAsync(r => r.Id == rfqId, cancellationToken);

    public void Add(Rfq rfq) => db.Rfqs.Add(rfq);
}

public sealed class QuotationRepository(ProcurementDbContext db) : IQuotationRepository
{
    public Task<Quotation?> GetAsync(long quotationId, CancellationToken cancellationToken) =>
        db.Quotations.Include(q => q.Lines).FirstOrDefaultAsync(q => q.Id == quotationId, cancellationToken);

    public async Task<IReadOnlyList<Quotation>> GetByRfqAsync(long rfqId, CancellationToken cancellationToken) =>
        await db.Quotations.Include(q => q.Lines).Where(q => q.RfqId == rfqId).ToListAsync(cancellationToken).ConfigureAwait(false);

    public void Add(Quotation quotation) => db.Quotations.Add(quotation);
}

public sealed class PurchaseOrderRepository(ProcurementDbContext db) : IPurchaseOrderRepository
{
    /// <summary>Statuses that count towards the split-check window; a cancelled order never committed money.</summary>
    private static readonly PurchaseOrderStatus[] CountedStatuses =
    [
        PurchaseOrderStatus.Draft,
        PurchaseOrderStatus.PendingApproval,
        PurchaseOrderStatus.Approved,
        PurchaseOrderStatus.SentToSupplier,
        PurchaseOrderStatus.PartiallyReceived,
        PurchaseOrderStatus.FullyReceived,
        PurchaseOrderStatus.Closed,
    ];

    public Task<PurchaseOrder?> GetAsync(long purchaseOrderId, CancellationToken cancellationToken) =>
        db.PurchaseOrders.Include(p => p.Lines).FirstOrDefaultAsync(p => p.Id == purchaseOrderId, cancellationToken);

    public async Task<decimal> SumAmountBaseInWindowAsync(
        uint tenantId,
        uint supplierId,
        DateOnly windowStart,
        DateOnly windowEnd,
        long? excludePurchaseOrderId,
        CancellationToken cancellationToken)
    {
        var query = db.PurchaseOrders.AsNoTracking()
            .Where(p => p.TenantId == tenantId
                && p.SupplierId == supplierId
                && p.DocDate >= windowStart
                && p.DocDate <= windowEnd
                && CountedStatuses.Contains(p.Status));

        if (excludePurchaseOrderId is { } excluded)
        {
            query = query.Where(p => p.Id != excluded);
        }

        return await query.SumAsync(p => (decimal?)p.TotalAmountBase, cancellationToken).ConfigureAwait(false) ?? 0m;
    }

    public void Add(PurchaseOrder purchaseOrder) => db.PurchaseOrders.Add(purchaseOrder);
}

public sealed class ApprovalRuleRepository(ProcurementDbContext db) : IApprovalRuleRepository
{
    public Task<ApprovalRule?> GetAsync(uint ruleId, CancellationToken cancellationToken) =>
        db.ApprovalRules.FirstOrDefaultAsync(r => r.Id == ruleId, cancellationToken);

    public async Task<IReadOnlyList<ApprovalRule>> ListAsync(uint tenantId, ApprovalDocType docType, bool activeOnly, CancellationToken cancellationToken)
    {
        var query = db.ApprovalRules.AsNoTracking().Where(r => r.TenantId == tenantId && r.DocType == docType);
        if (activeOnly)
        {
            query = query.Where(r => r.IsActive);
        }

        return await query.OrderBy(r => r.StepNo).ThenBy(r => r.MinAmountBase).ToListAsync(cancellationToken).ConfigureAwait(false);
    }

    public void Add(ApprovalRule rule) => db.ApprovalRules.Add(rule);
}

public sealed class ApprovalInstanceRepository(ProcurementDbContext db) : IApprovalInstanceRepository
{
    public Task<ApprovalInstance?> GetAsync(long approvalId, CancellationToken cancellationToken) =>
        db.ApprovalInstances.Include(a => a.Steps).FirstOrDefaultAsync(a => a.Id == approvalId, cancellationToken);

    public Task<ApprovalInstance?> GetLatestForDocumentAsync(uint tenantId, ApprovalDocType docType, long docId, CancellationToken cancellationToken) =>
        db.ApprovalInstances
            .Include(a => a.Steps)
            .Where(a => a.TenantId == tenantId && a.DocType == docType && a.DocId == docId)
            .OrderByDescending(a => a.Id)
            .FirstOrDefaultAsync(cancellationToken);

    public void Add(ApprovalInstance instance) => db.ApprovalInstances.Add(instance);
}

public sealed class PriceHistoryRepository(ProcurementDbContext db) : IPriceHistoryRepository
{
    public async Task<decimal?> GetLastPriceBaseAsync(uint tenantId, uint productId, uint supplierId, DateOnly onDate, CancellationToken cancellationToken) =>
        await db.PriceHistory.AsNoTracking()
            .Where(p => p.TenantId == tenantId && p.ProductId == productId && p.SupplierId == supplierId && p.PriceDate <= onDate)
            .OrderByDescending(p => p.PriceDate)
            .ThenByDescending(p => p.Id)
            .Select(p => (decimal?)p.UnitPriceBase)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

    public async Task<IReadOnlyDictionary<uint, decimal>> GetLastPricesBaseAsync(
        uint tenantId,
        IReadOnlyCollection<uint> productIds,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(productIds);
        if (productIds.Count == 0)
        {
            return new Dictionary<uint, decimal>();
        }

        var ids = productIds.ToArray();
        var rows = await db.PriceHistory.AsNoTracking()
            .Where(p => p.TenantId == tenantId && ids.Contains(p.ProductId))
            .OrderByDescending(p => p.PriceDate)
            .ThenByDescending(p => p.Id)
            .Select(p => new { p.ProductId, p.UnitPriceBase })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var latest = new Dictionary<uint, decimal>();
        foreach (var row in rows)
        {
            latest.TryAdd(row.ProductId, row.UnitPriceBase);
        }

        return latest;
    }

    public void Add(PriceHistoryEntry entry) => db.PriceHistory.Add(entry);
}

public sealed class SplitCheckRepository(ProcurementDbContext db) : ISplitCheckRepository
{
    public void Add(SplitCheckLog log) => db.SplitCheckLogs.Add(log);
}
