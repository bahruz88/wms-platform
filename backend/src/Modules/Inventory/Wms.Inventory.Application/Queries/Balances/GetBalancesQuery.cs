using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;

namespace Wms.Inventory.Application.Queries.Balances;

/// <summary><c>GET /api/v1/inventory/balances?locationId=&amp;productId=&amp;page=&amp;size=</c> (spec §13.1).</summary>
public sealed record GetBalancesQuery(uint? LocationId, uint? ProductId, PageRequest Page) : IQuery<PagedResult<StockBalanceDto>>;

public sealed class GetBalancesQueryValidator : AbstractValidator<GetBalancesQuery>
{
    public GetBalancesQueryValidator()
    {
        RuleFor(q => q.Page).NotNull();
    }
}

public sealed class GetBalancesQueryHandler(IStockBalanceQueries queries, ICurrentUser currentUser) : IQueryHandler<GetBalancesQuery, PagedResult<StockBalanceDto>>
{
    public async Task<Result<PagedResult<StockBalanceDto>>> HandleAsync(GetBalancesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        // Branch users only see their own locations (spec §16); an empty set means unrestricted.
        var filter = new BalanceFilter(query.LocationId, query.ProductId, currentUser.LocationIds);
        var includeCost = currentUser.HasPermission(InventoryPermissions.ViewCost);
        return await queries.GetBalancesAsync(filter, query.Page, includeCost, cancellationToken).ConfigureAwait(false);
    }
}
