using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Abstractions;

public interface IRequisitionRepository
{
    Task<Requisition?> GetAsync(long requisitionId, CancellationToken cancellationToken);

    /// <summary>Loads several requisitions with their lines so one PO can be assembled from many PRs (spec §12.8).</summary>
    Task<IReadOnlyList<Requisition>> GetByLineIdsAsync(IReadOnlyCollection<long> requisitionLineIds, CancellationToken cancellationToken);

    void Add(Requisition requisition);
}

public interface IRfqRepository
{
    Task<Rfq?> GetAsync(long rfqId, CancellationToken cancellationToken);

    void Add(Rfq rfq);
}

public interface IQuotationRepository
{
    Task<Quotation?> GetAsync(long quotationId, CancellationToken cancellationToken);

    /// <summary>Every quotation of one RFQ, tracked — the ranking and the "one selection per RFQ" rule need them all.</summary>
    Task<IReadOnlyList<Quotation>> GetByRfqAsync(long rfqId, CancellationToken cancellationToken);

    void Add(Quotation quotation);
}

public interface IPurchaseOrderRepository
{
    Task<PurchaseOrder?> GetAsync(long purchaseOrderId, CancellationToken cancellationToken);

    /// <summary>Total base amount of this supplier's purchase orders inside a rolling window (the split-check control).</summary>
    Task<decimal> SumAmountBaseInWindowAsync(
        uint tenantId,
        uint supplierId,
        DateOnly windowStart,
        DateOnly windowEnd,
        long? excludePurchaseOrderId,
        CancellationToken cancellationToken);

    void Add(PurchaseOrder purchaseOrder);
}

public interface IApprovalRuleRepository
{
    Task<ApprovalRule?> GetAsync(uint ruleId, CancellationToken cancellationToken);

    /// <summary>Active rules of one document type, used both by the selector and by the overlap check.</summary>
    Task<IReadOnlyList<ApprovalRule>> ListAsync(uint tenantId, ApprovalDocType docType, bool activeOnly, CancellationToken cancellationToken);

    void Add(ApprovalRule rule);
}

public interface IApprovalInstanceRepository
{
    Task<ApprovalInstance?> GetAsync(long approvalId, CancellationToken cancellationToken);

    /// <summary>The newest instance of one document — the <c>approval</c> block of a PO.</summary>
    Task<ApprovalInstance?> GetLatestForDocumentAsync(uint tenantId, ApprovalDocType docType, long docId, CancellationToken cancellationToken);

    void Add(ApprovalInstance instance);
}

public interface IPriceHistoryRepository
{
    /// <summary>Last known base price of a product × supplier pair strictly before (or on) <paramref name="onDate"/>.</summary>
    Task<decimal?> GetLastPriceBaseAsync(uint tenantId, uint productId, uint supplierId, DateOnly onDate, CancellationToken cancellationToken);

    /// <summary>Last known base price per product for one supplier — the <c>prevPriceBase</c> column of the comparison.</summary>
    Task<IReadOnlyDictionary<uint, decimal>> GetLastPricesBaseAsync(
        uint tenantId,
        IReadOnlyCollection<uint> productIds,
        CancellationToken cancellationToken);

    void Add(PriceHistoryEntry entry);
}

public interface ISplitCheckRepository
{
    void Add(SplitCheckLog log);
}
