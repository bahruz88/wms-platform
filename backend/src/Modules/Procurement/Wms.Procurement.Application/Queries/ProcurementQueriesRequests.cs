using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Commands.Approvals;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.Application.Queries;

// ---------------------------------------------------------------- Requisitions

/// <summary><c>GET /api/v1/procurement/requisitions</c> (operationId <c>listRequisitions</c>).</summary>
public sealed record ListRequisitionsQuery(
    RequisitionStatus? Status,
    ProductType? ProductType,
    Priority? Priority,
    uint? RequesterLocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    PageRequest Page) : IQuery<PagedResult<RequisitionSummaryDto>>;

/// <summary><c>GET /requisitions/{id}</c>.</summary>
public sealed record GetRequisitionQuery(long RequisitionId) : IQuery<RequisitionDto>;

public sealed class ListRequisitionsQueryHandler(IProcurementQueries queries, ICurrentUser currentUser)
    : IQueryHandler<ListRequisitionsQuery, PagedResult<RequisitionSummaryDto>>
{
    public async Task<Result<PagedResult<RequisitionSummaryDto>>> HandleAsync(ListRequisitionsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        // Spec §16: a branch user only sees the requisitions of their own locations.
        var filter = new RequisitionFilter(
            query.Status, query.ProductType, query.Priority, query.RequesterLocationId,
            query.DateFrom, query.DateTo, query.Search, query.Sort, currentUser.LocationScope);
        return await queries.ListRequisitionsAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

public sealed class GetRequisitionQueryHandler(IProcurementQueries queries) : IQueryHandler<GetRequisitionQuery, RequisitionDto>
{
    public async Task<Result<RequisitionDto>> HandleAsync(GetRequisitionQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetRequisitionAsync(query.RequisitionId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.RequisitionNotFound(query.RequisitionId) : Result.Success(dto);
    }
}

// ---------------------------------------------------------------- RFQs

/// <summary><c>GET /rfqs</c>.</summary>
public sealed record ListRfqsQuery(
    RfqStatus? Status,
    uint? SupplierId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    PageRequest Page) : IQuery<PagedResult<RfqSummaryDto>>;

/// <summary><c>GET /rfqs/{id}</c>.</summary>
public sealed record GetRfqQuery(long RfqId) : IQuery<RfqDto>;

/// <summary><c>GET /rfqs/{id}/comparison</c>.</summary>
public sealed record GetRfqComparisonQuery(long RfqId) : IQuery<RfqComparisonDto>;

public sealed class RfqQueryHandlers(IProcurementQueries queries) :
    IQueryHandler<ListRfqsQuery, PagedResult<RfqSummaryDto>>,
    IQueryHandler<GetRfqQuery, RfqDto>,
    IQueryHandler<GetRfqComparisonQuery, RfqComparisonDto>
{
    public async Task<Result<PagedResult<RfqSummaryDto>>> HandleAsync(ListRfqsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new RfqFilter(query.Status, query.SupplierId, query.DateFrom, query.DateTo, query.Search, query.Sort);
        return await queries.ListRfqsAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<RfqDto>> HandleAsync(GetRfqQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetRfqAsync(query.RfqId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.RfqNotFound(query.RfqId) : Result.Success(dto);
    }

    public async Task<Result<RfqComparisonDto>> HandleAsync(GetRfqComparisonQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetRfqComparisonAsync(query.RfqId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.RfqNotFound(query.RfqId) : Result.Success(dto);
    }
}

// ---------------------------------------------------------------- Quotations

/// <summary><c>GET /quotations</c>.</summary>
public sealed record ListQuotationsQuery(
    long? RfqId,
    uint? SupplierId,
    bool? IsSelected,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Sort,
    PageRequest Page) : IQuery<PagedResult<QuotationSummaryDto>>;

/// <summary><c>GET /quotations/{id}</c>.</summary>
public sealed record GetQuotationQuery(long QuotationId) : IQuery<QuotationDto>;

public sealed class QuotationQueryHandlers(IProcurementQueries queries) :
    IQueryHandler<ListQuotationsQuery, PagedResult<QuotationSummaryDto>>,
    IQueryHandler<GetQuotationQuery, QuotationDto>
{
    public async Task<Result<PagedResult<QuotationSummaryDto>>> HandleAsync(ListQuotationsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new QuotationFilter(query.RfqId, query.SupplierId, query.IsSelected, query.DateFrom, query.DateTo, query.Sort);
        return await queries.ListQuotationsAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<QuotationDto>> HandleAsync(GetQuotationQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetQuotationAsync(query.QuotationId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.QuotationNotFound(query.QuotationId) : Result.Success(dto);
    }
}

// ---------------------------------------------------------------- Purchase orders

/// <summary><c>GET /purchase-orders</c>.</summary>
public sealed record ListPurchaseOrdersQuery(
    PurchaseOrderStatus? Status,
    uint? SupplierId,
    uint? DeliveryLocationId,
    ProductType? ProductType,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    string? Sort,
    PageRequest Page) : IQuery<PagedResult<PurchaseOrderSummaryDto>>;

/// <summary><c>GET /purchase-orders/open-for-receipt</c> — no price fields (spec §7.1).</summary>
public sealed record ListOpenPurchaseOrdersQuery(
    uint? SupplierId,
    uint? DeliveryLocationId,
    string? Search,
    PageRequest Page) : IQuery<PagedResult<OpenPurchaseOrderDto>>;

/// <summary><c>GET /purchase-orders/{id}</c>.</summary>
public sealed record GetPurchaseOrderQuery(long PurchaseOrderId) : IQuery<PurchaseOrderDetailDto>;

public sealed class PurchaseOrderQueryHandlers(IProcurementQueries queries, ICurrentUser currentUser) :
    IQueryHandler<ListPurchaseOrdersQuery, PagedResult<PurchaseOrderSummaryDto>>,
    IQueryHandler<ListOpenPurchaseOrdersQuery, PagedResult<OpenPurchaseOrderDto>>,
    IQueryHandler<GetPurchaseOrderQuery, PurchaseOrderDetailDto>
{
    public async Task<Result<PagedResult<PurchaseOrderSummaryDto>>> HandleAsync(ListPurchaseOrdersQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        // Spec §16: the order list is scoped by delivery location, like every other location-bearing list.
        var filter = new PurchaseOrderFilter(
            query.Status, query.SupplierId, query.DeliveryLocationId, query.ProductType,
            query.DateFrom, query.DateTo, query.Search, query.Sort, currentUser.LocationScope);
        return await queries.ListPurchaseOrdersAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<PagedResult<OpenPurchaseOrderDto>>> HandleAsync(ListOpenPurchaseOrdersQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new OpenPurchaseOrderFilter(
            query.SupplierId, query.DeliveryLocationId, query.Search, currentUser.LocationScope);
        return await queries.ListOpenPurchaseOrdersAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<PurchaseOrderDetailDto>> HandleAsync(GetPurchaseOrderQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetPurchaseOrderAsync(query.PurchaseOrderId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.PurchaseOrderNotFound(query.PurchaseOrderId) : Result.Success(dto);
    }
}

// ---------------------------------------------------------------- Approvals

/// <summary><c>GET /approvals/pending</c> — what the current user (directly or by delegation) must decide.</summary>
public sealed record ListPendingApprovalsQuery(ApprovalDocType? DocType, PageRequest Page) : IQuery<PagedResult<PendingApprovalDto>>;

/// <summary><c>GET /approvals/{id}</c>.</summary>
public sealed record GetApprovalQuery(long ApprovalId) : IQuery<ApprovalInstanceDto>;

/// <summary><c>GET /approval-rules</c>.</summary>
public sealed record ListApprovalRulesQuery(ApprovalDocType? DocType, bool? IsActive) : IQuery<IReadOnlyList<ApprovalRuleDto>>;

public sealed class ApprovalQueryHandlers(IProcurementQueries queries, ApprovalEngine approvalEngine, ICurrentUser currentUser) :
    IQueryHandler<ListPendingApprovalsQuery, PagedResult<PendingApprovalDto>>,
    IQueryHandler<GetApprovalQuery, ApprovalInstanceDto>,
    IQueryHandler<ListApprovalRulesQuery, IReadOnlyList<ApprovalRuleDto>>
{
    public async Task<Result<PagedResult<PendingApprovalDto>>> HandleAsync(ListPendingApprovalsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        var userId = currentUser.UserId;
        var ownRoles = await approvalEngine.ResolveRoleCodesAsync(userId, cancellationToken).ConfigureAwait(false);
        var delegations = await approvalEngine.ResolveDelegationsAsync(userId, cancellationToken).ConfigureAwait(false);
        var effective = ApprovalAuthorization.EffectiveRoleCodes(ownRoles, delegations);

        return await queries
            .ListPendingApprovalsAsync(query.DocType, effective, userId, query.Page, cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task<Result<ApprovalInstanceDto>> HandleAsync(GetApprovalQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetApprovalAsync(query.ApprovalId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.ApprovalNotFound(query.ApprovalId) : Result.Success(dto);
    }

    public async Task<Result<IReadOnlyList<ApprovalRuleDto>>> HandleAsync(ListApprovalRulesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.ListApprovalRulesAsync(query.DocType, query.IsActive, cancellationToken).ConfigureAwait(false));
    }
}

// ---------------------------------------------------------------- Price history

/// <summary><c>GET /price-history</c> — requires <c>master.product.view_cost</c>.</summary>
public sealed record ListPriceHistoryQuery(
    uint? ProductId,
    uint? SupplierId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    decimal? MinDiffPct,
    string? Sort,
    PageRequest Page) : IQuery<PagedResult<PriceHistoryEntryDto>>;

public sealed class ListPriceHistoryQueryHandler(IProcurementQueries queries)
    : IQueryHandler<ListPriceHistoryQuery, PagedResult<PriceHistoryEntryDto>>
{
    public async Task<Result<PagedResult<PriceHistoryEntryDto>>> HandleAsync(ListPriceHistoryQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new PriceHistoryFilter(query.ProductId, query.SupplierId, query.DateFrom, query.DateTo, query.MinDiffPct, query.Sort);
        return await queries.ListPriceHistoryAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}
