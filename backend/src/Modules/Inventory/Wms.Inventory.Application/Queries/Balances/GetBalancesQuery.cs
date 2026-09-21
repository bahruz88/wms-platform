using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Queries.Balances;

/// <summary><c>GET /api/v1/inventory/balances</c> (inventory.v1.yaml <c>listBalances</c>).</summary>
public sealed record GetBalancesQuery(
    uint? LocationId,
    uint? ProductId,
    long? BatchId,
    uint? CategoryId,
    bool IncludeZero,
    bool? BelowMin,
    int? ExpiringWithinDays,
    string? Search,
    PageRequest Page) : IQuery<PagedResult<StockBalanceDto>>;

public sealed class GetBalancesQueryValidator : AbstractValidator<GetBalancesQuery>
{
    public GetBalancesQueryValidator()
    {
        RuleFor(q => q.Page).NotNull();
        RuleFor(q => q.ExpiringWithinDays).GreaterThanOrEqualTo(0).When(q => q.ExpiringWithinDays.HasValue);
    }
}

public sealed class GetBalancesQueryHandler(IStockBalanceQueries queries, ICurrentUser currentUser) : IQueryHandler<GetBalancesQuery, PagedResult<StockBalanceDto>>
{
    public async Task<Result<PagedResult<StockBalanceDto>>> HandleAsync(GetBalancesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        // Branch users only see their own locations (spec §16); an empty set means unrestricted.
        var filter = new BalanceFilter(
            query.LocationId, query.ProductId, query.BatchId, query.CategoryId,
            query.IncludeZero, query.BelowMin, query.ExpiringWithinDays, query.Search, currentUser.LocationIds);
        var includeCost = currentUser.HasPermission(InventoryPermissions.ViewCost);
        return await queries.GetBalancesAsync(filter, query.Page, includeCost, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /api/v1/inventory/balances/summary</c> (inventory.v1.yaml <c>getBalanceSummary</c>).</summary>
public sealed record GetBalanceSummaryQuery(uint ProductId, uint? LocationId) : IQuery<BalanceSummaryDto>;

public sealed class GetBalanceSummaryQueryValidator : AbstractValidator<GetBalanceSummaryQuery>
{
    public GetBalanceSummaryQueryValidator() => RuleFor(q => q.ProductId).GreaterThan(0u);
}

public sealed class GetBalanceSummaryQueryHandler(IStockBalanceQueries queries, ICurrentUser currentUser) : IQueryHandler<GetBalanceSummaryQuery, BalanceSummaryDto>
{
    public async Task<Result<BalanceSummaryDto>> HandleAsync(GetBalanceSummaryQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var includeCost = currentUser.HasPermission(InventoryPermissions.ViewCost);
        var dto = await queries
            .GetSummaryAsync(query.ProductId, query.LocationId, currentUser.LocationIds, includeCost, cancellationToken)
            .ConfigureAwait(false);
        return dto is null ? InventoryErrors.ProductNotFound(query.ProductId) : dto;
    }
}
