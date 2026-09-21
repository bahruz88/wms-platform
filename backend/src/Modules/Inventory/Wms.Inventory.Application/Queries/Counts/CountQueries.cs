using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Queries.Counts;

/// <summary><c>GET /api/v1/inventory/counts/{id}</c>.</summary>
public sealed record GetCountQuery(long CountId) : IQuery<CountDto>;

public sealed class GetCountQueryHandler(IStockCountQueries queries, ICurrentUser currentUser) : IQueryHandler<GetCountQuery, CountDto>
{
    public async Task<Result<CountDto>> HandleAsync(GetCountQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var includeCost = currentUser.HasPermission(InventoryPermissions.ViewCost);
        var dto = await queries.GetAsync(query.CountId, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? InventoryErrors.CountNotFound(query.CountId) : dto;
    }
}

/// <summary><c>GET /api/v1/inventory/counts</c>.</summary>
public sealed record ListCountsQuery(
    string? Status,
    string? CountType,
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    PageRequest Page) : IQuery<PagedResult<CountSummaryDto>>;

public sealed class ListCountsQueryHandler(IStockCountQueries queries, ICurrentUser currentUser)
    : IQueryHandler<ListCountsQuery, PagedResult<CountSummaryDto>>
{
    public async Task<Result<PagedResult<CountSummaryDto>>> HandleAsync(ListCountsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new CountFilter(query.Status, query.CountType, query.LocationId, query.DateFrom, query.DateTo, currentUser.LocationScope);
        return await queries.ListAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}
