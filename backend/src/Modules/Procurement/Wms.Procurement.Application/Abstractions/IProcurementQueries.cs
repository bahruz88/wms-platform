using Wms.Common.Application.Paging;
using Wms.Common.Application.Security;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Contracts;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Abstractions;

public sealed record RequisitionFilter(
    RequisitionStatus? Status,
    ProductType? ProductType,
    Priority? Priority,
    uint? RequesterLocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    LocationScope VisibleLocations);

/// <remarks>
/// <c>proc_rfq</c> carries no location of its own — a price enquiry is raised centrally and names suppliers,
/// not branches — so there is nothing for a <see cref="LocationScope"/> to filter here, and the endpoint is
/// gated by <c>proc.rfq.view</c>, which no branch role holds. Listed as exempt in
/// <c>LocationScopeTests.NotLocationScoped</c>.
/// </remarks>
public sealed record RfqFilter(
    RfqStatus? Status,
    uint? SupplierId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort);

/// <remarks>Supplier offers hang off an RFQ, not off a location — see <see cref="RfqFilter"/>.</remarks>
public sealed record QuotationFilter(
    long? RfqId,
    uint? SupplierId,
    bool? IsSelected,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Sort);

public sealed record PurchaseOrderFilter(
    PurchaseOrderStatus? Status,
    uint? SupplierId,
    uint? DeliveryLocationId,
    ProductType? ProductType,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    LocationScope VisibleLocations);

public sealed record OpenPurchaseOrderFilter(
    uint? SupplierId,
    uint? DeliveryLocationId,
    string? Search,
    LocationScope VisibleLocations);

/// <remarks>
/// <c>proc_price_history</c> is product x supplier cost data with no location column, and the endpoint demands
/// <c>master.product.view_cost</c> — which spec §7.1 denies the keeper and the branch user outright. Exempt in
/// <c>LocationScopeTests.NotLocationScoped</c>.
/// </remarks>
public sealed record PriceHistoryFilter(
    uint? ProductId,
    uint? SupplierId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    decimal? MinDiffPct,
    string? Sort);

/// <summary>Read side of the module (spec Əlavə A: queries never track entities).</summary>
public interface IProcurementQueries
{
    Task<PagedResult<RequisitionSummaryDto>> ListRequisitionsAsync(RequisitionFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<RequisitionDto?> GetRequisitionAsync(long requisitionId, CancellationToken cancellationToken);

    Task<PagedResult<RfqSummaryDto>> ListRfqsAsync(RfqFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<RfqDto?> GetRfqAsync(long rfqId, CancellationToken cancellationToken);

    Task<RfqComparisonDto?> GetRfqComparisonAsync(long rfqId, CancellationToken cancellationToken);

    Task<PagedResult<QuotationSummaryDto>> ListQuotationsAsync(QuotationFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<QuotationDto?> GetQuotationAsync(long quotationId, CancellationToken cancellationToken);

    Task<PagedResult<PurchaseOrderSummaryDto>> ListPurchaseOrdersAsync(PurchaseOrderFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<PagedResult<OpenPurchaseOrderDto>> ListOpenPurchaseOrdersAsync(OpenPurchaseOrderFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<PurchaseOrderDetailDto?> GetPurchaseOrderAsync(long purchaseOrderId, CancellationToken cancellationToken);

    Task<ApprovalInstanceDto?> GetApprovalAsync(long approvalId, CancellationToken cancellationToken);

    /// <summary>Open steps whose approver role is in <paramref name="roleCodes"/>; delegation is resolved by the handler.</summary>
    Task<PagedResult<PendingApprovalDto>> ListPendingApprovalsAsync(
        ApprovalDocType? docType,
        IReadOnlyCollection<string> roleCodes,
        uint actingUserId,
        PageRequest page,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<ApprovalRuleDto>> ListApprovalRulesAsync(ApprovalDocType? docType, bool? isActive, CancellationToken cancellationToken);

    Task<ApprovalRuleDto?> GetApprovalRuleAsync(uint ruleId, CancellationToken cancellationToken);

    Task<PagedResult<PriceHistoryEntryDto>> ListPriceHistoryAsync(PriceHistoryFilter filter, PageRequest page, CancellationToken cancellationToken);

    /// <summary>Backs <see cref="IPurchaseOrderReader"/> so Inventory can pre-fill a goods receipt (spec §12.8).</summary>
    Task<Contracts.PurchaseOrderDto?> GetPurchaseOrderContractAsync(long purchaseOrderId, CancellationToken cancellationToken);
}
