using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Queries.Documents;

/// <summary>Query-string shape shared by the document list endpoints.</summary>
public sealed record DocumentListQuery(
    string? Status,
    string? Kind,
    uint? LocationId,
    uint? SecondaryLocationId,
    uint? SupplierId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    PageRequest Page)
{
    public DocumentFilter ToFilter(LocationScope visibleLocations) =>
        new(Status, LocationId, DateFrom, DateTo, Search, visibleLocations)
        {
            Kind = Kind,
            SecondaryLocationId = SecondaryLocationId,
            SupplierId = SupplierId,
        };
}

// ==================================================================== stock requests

public sealed record GetStockRequestQuery(long RequestId) : IQuery<StockRequestDto>;

public sealed record ListStockRequestsQuery(DocumentListQuery Criteria) : IQuery<PagedResult<StockRequestSummaryDto>>;

public sealed class StockRequestQueryHandlers(IStockRequestQueries queries, ICurrentUser currentUser) :
    IQueryHandler<GetStockRequestQuery, StockRequestDto>,
    IQueryHandler<ListStockRequestsQuery, PagedResult<StockRequestSummaryDto>>
{
    public async Task<Result<StockRequestDto>> HandleAsync(GetStockRequestQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetAsync(query.RequestId, cancellationToken).ConfigureAwait(false);
        return dto is null ? InventoryErrors.DocumentNotFound("stock request", query.RequestId) : dto;
    }

    public async Task<Result<PagedResult<StockRequestSummaryDto>>> HandleAsync(ListStockRequestsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries
            .ListAsync(query.Criteria.ToFilter(currentUser.LocationScope), query.Criteria.Page, cancellationToken)
            .ConfigureAwait(false);
    }
}

// ==================================================================== issues

public sealed record GetIssueQuery(long IssueId) : IQuery<IssueDto>;

public sealed record ListIssuesQuery(DocumentListQuery Criteria) : IQuery<PagedResult<IssueSummaryDto>>;

public sealed class IssueQueryHandlers(IIssueQueries queries, ICurrentUser currentUser) :
    IQueryHandler<GetIssueQuery, IssueDto>,
    IQueryHandler<ListIssuesQuery, PagedResult<IssueSummaryDto>>
{
    public async Task<Result<IssueDto>> HandleAsync(GetIssueQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries
            .GetAsync(query.IssueId, currentUser.HasPermission(InventoryPermissions.ViewCost), cancellationToken)
            .ConfigureAwait(false);
        return dto is null ? InventoryErrors.DocumentNotFound("issue", query.IssueId) : dto;
    }

    public async Task<Result<PagedResult<IssueSummaryDto>>> HandleAsync(ListIssuesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries
            .ListAsync(query.Criteria.ToFilter(currentUser.LocationScope), query.Criteria.Page, cancellationToken)
            .ConfigureAwait(false);
    }
}

// ==================================================================== waste

public sealed record GetWasteQuery(long WasteId) : IQuery<WasteDto>;

public sealed record ListWasteQuery(DocumentListQuery Criteria) : IQuery<PagedResult<WasteSummaryDto>>;

public sealed class WasteQueryHandlers(IWasteQueries queries, ICurrentUser currentUser) :
    IQueryHandler<GetWasteQuery, WasteDto>,
    IQueryHandler<ListWasteQuery, PagedResult<WasteSummaryDto>>
{
    public async Task<Result<WasteDto>> HandleAsync(GetWasteQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries
            .GetAsync(query.WasteId, currentUser.HasPermission(InventoryPermissions.ViewCost), cancellationToken)
            .ConfigureAwait(false);
        return dto is null ? InventoryErrors.DocumentNotFound("waste", query.WasteId) : dto;
    }

    public async Task<Result<PagedResult<WasteSummaryDto>>> HandleAsync(ListWasteQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.ListAsync(
            query.Criteria.ToFilter(currentUser.LocationScope),
            query.Criteria.Page,
            currentUser.HasPermission(InventoryPermissions.ViewCost),
            cancellationToken).ConfigureAwait(false);
    }
}

// ==================================================================== samples

public sealed record GetSampleQuery(long SampleId) : IQuery<SampleDto>;

public sealed record ListSamplesQuery(DocumentListQuery Criteria) : IQuery<PagedResult<SampleSummaryDto>>;

public sealed class SampleQueryHandlers(ISampleQueries queries, ICurrentUser currentUser) :
    IQueryHandler<GetSampleQuery, SampleDto>,
    IQueryHandler<ListSamplesQuery, PagedResult<SampleSummaryDto>>
{
    public async Task<Result<SampleDto>> HandleAsync(GetSampleQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries
            .GetAsync(query.SampleId, currentUser.HasPermission(InventoryPermissions.ViewCost), cancellationToken)
            .ConfigureAwait(false);
        return dto is null ? InventoryErrors.DocumentNotFound("sample", query.SampleId) : dto;
    }

    public async Task<Result<PagedResult<SampleSummaryDto>>> HandleAsync(ListSamplesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries
            .ListAsync(query.Criteria.ToFilter(currentUser.LocationScope), query.Criteria.Page, cancellationToken)
            .ConfigureAwait(false);
    }
}

// ==================================================================== return to vendor

public sealed record GetReturnToVendorQuery(long ReturnId) : IQuery<ReturnToVendorDto>;

public sealed record ListReturnsToVendorQuery(DocumentListQuery Criteria) : IQuery<PagedResult<ReturnToVendorSummaryDto>>;

public sealed class ReturnToVendorQueryHandlers(IReturnToVendorQueries queries, ICurrentUser currentUser) :
    IQueryHandler<GetReturnToVendorQuery, ReturnToVendorDto>,
    IQueryHandler<ListReturnsToVendorQuery, PagedResult<ReturnToVendorSummaryDto>>
{
    public async Task<Result<ReturnToVendorDto>> HandleAsync(GetReturnToVendorQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries
            .GetAsync(query.ReturnId, currentUser.HasPermission(InventoryPermissions.ViewCost), cancellationToken)
            .ConfigureAwait(false);
        return dto is null ? InventoryErrors.DocumentNotFound("return to vendor", query.ReturnId) : dto;
    }

    public async Task<Result<PagedResult<ReturnToVendorSummaryDto>>> HandleAsync(ListReturnsToVendorQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.ListAsync(
            query.Criteria.ToFilter(currentUser.LocationScope),
            query.Criteria.Page,
            currentUser.HasPermission(InventoryPermissions.ViewCost),
            cancellationToken).ConfigureAwait(false);
    }
}

// ==================================================================== batches and the ledger

public sealed record GetBatchQuery(long BatchId) : IQuery<BatchDto>;

public sealed record ListBatchesQuery(BatchFilter Filter, PageRequest Page) : IQuery<PagedResult<BatchDto>>;

public sealed class BatchQueryHandlers(IBatchQueries queries, ICurrentUser currentUser) :
    IQueryHandler<GetBatchQuery, BatchDto>,
    IQueryHandler<ListBatchesQuery, PagedResult<BatchDto>>
{
    public async Task<Result<BatchDto>> HandleAsync(GetBatchQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetAsync(query.BatchId, currentUser.LocationScope, cancellationToken).ConfigureAwait(false);
        return dto is null ? InventoryErrors.BatchNotFound(query.BatchId) : dto;
    }

    public async Task<Result<PagedResult<BatchDto>>> HandleAsync(ListBatchesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = query.Filter with { VisibleLocations = currentUser.LocationScope };
        return await queries.ListAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

public sealed record ListMovementsQuery(
    uint? ProductId,
    uint? LocationId,
    long? BatchId,
    string? DocType,
    long? GroupId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    PageRequest Page) : IQuery<PagedResult<MovementDto>>;

public sealed record GetMovementGroupQuery(long GroupId) : IQuery<MovementGroupDto>;

public sealed class MovementQueryHandlers(IMovementQueries queries, ICurrentUser currentUser) :
    IQueryHandler<ListMovementsQuery, PagedResult<MovementDto>>,
    IQueryHandler<GetMovementGroupQuery, MovementGroupDto>
{
    public async Task<Result<PagedResult<MovementDto>>> HandleAsync(ListMovementsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new MovementFilter(
            query.ProductId, query.LocationId, query.BatchId, query.DocType, query.GroupId,
            query.DateFrom, query.DateTo, currentUser.LocationScope);
        return await queries
            .ListAsync(filter, query.Page, currentUser.HasPermission(InventoryPermissions.ViewCost), cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task<Result<MovementGroupDto>> HandleAsync(GetMovementGroupQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries
            .GetGroupAsync(query.GroupId, currentUser.HasPermission(InventoryPermissions.ViewCost), cancellationToken)
            .ConfigureAwait(false);
        return dto is null ? InventoryErrors.MovementGroupNotFound(query.GroupId) : dto;
    }
}
