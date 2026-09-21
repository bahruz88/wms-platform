using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Inventory.Application;
using Wms.Inventory.Application.Queries.Balances;

namespace Wms.Inventory.Endpoints;

public static class BalanceEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/balances", GetBalancesAsync)
            .RequirePermission(InventoryPermissions.BalanceView)
            .WithName("listBalances");

        group.MapGet("/balances/summary", GetSummaryAsync)
            .RequirePermission(InventoryPermissions.BalanceView)
            .WithName("getBalanceSummary");
    }

    private static async Task<IResult> GetBalancesAsync([AsParameters] BalancesRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var page = new PageRequest(request.Page ?? 1, request.Size ?? PageRequest.DefaultSize);
        var query = new GetBalancesQuery(
            request.LocationId, request.ProductId, request.BatchId, request.CategoryId,
            request.IncludeZero ?? false, request.BelowMin, request.ExpiringWithinDays, request.Search, page);
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> GetSummaryAsync(uint productId, uint? locationId, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetBalanceSummaryQuery(productId, locationId), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
