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
            .WithName("GetBalances");
    }

    private static async Task<IResult> GetBalancesAsync([AsParameters] BalancesRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var page = new PageRequest(request.Page ?? 1, request.Size ?? PageRequest.DefaultSize);
        var result = await dispatcher.QueryAsync(new GetBalancesQuery(request.LocationId, request.ProductId, page), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
