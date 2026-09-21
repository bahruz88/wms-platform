using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Inventory.Application;
using Wms.Inventory.Application.Commands.GoodsReceipts;
using Wms.Inventory.Application.Queries.GoodsReceipts;
using Wms.Inventory.Contracts;

namespace Wms.Inventory.Endpoints;

public static class GoodsReceiptEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/goods-receipts", ListAsync)
            .RequirePermission(InventoryPermissions.ReceiptView)
            .WithName("listGoodsReceipts");

        group.MapPost("/goods-receipts", CreateAsync)
            .RequirePermission(InventoryPermissions.ReceiptCreate)
            .RequireIdempotencyKey()
            .WithName("CreateGoodsReceipt");

        group.MapGet("/goods-receipts/{id:long}", GetAsync)
            .RequirePermission(InventoryPermissions.ReceiptView)
            .WithName("GetGoodsReceipt");

        group.MapPost("/goods-receipts/{id:long}/post", PostAsync)
            .RequirePermission(InventoryPermissions.ReceiptPost)
            .RequireIdempotencyKey()
            .WithName("PostGoodsReceipt");
    }

    private static async Task<IResult> ListAsync([AsParameters] GoodsReceiptsRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var query = new ListGoodsReceiptsQuery(
            request.Status, request.SupplierId, request.LocationId, request.PoId,
            request.DateFrom, request.DateTo, request.Search,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(CreateGoodsReceiptRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.SendAsync(request.ToCommand(), cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(id => TypedResults.Created($"{InventoryRoutes.Prefix}/goods-receipts/{id}", new CreatedResponse(id)));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetGoodsReceiptQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> PostAsync(long id, HttpContext httpContext, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var idempotencyKey = IdempotencyKey.Require(httpContext);
        var result = await dispatcher.SendAsync(new PostGoodsReceiptCommand(id, idempotencyKey), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
