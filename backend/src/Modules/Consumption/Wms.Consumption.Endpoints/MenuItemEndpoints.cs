using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Consumption.Application;
using Wms.Consumption.Application.Commands.MenuItems;
using Wms.Consumption.Application.Queries;
using Wms.Consumption.Contracts;

namespace Wms.Consumption.Endpoints;

/// <summary>Operations <c>listMenuItems</c>, <c>createMenuItem</c>, <c>getMenuItem</c>, <c>updateMenuItem</c>.</summary>
public static class MenuItemEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/menu-items", ListAsync)
            .RequirePermission(ConsumptionPermissions.RecipeView)
            .WithName("listMenuItems");

        group.MapPost("/menu-items", CreateAsync)
            .RequirePermission(ConsumptionPermissions.RecipeManage)
            .RequireIdempotencyKey()
            .WithName("createMenuItem");

        group.MapGet("/menu-items/{id:int}", GetAsync)
            .RequirePermission(ConsumptionPermissions.RecipeView)
            .WithName("getMenuItem");

        group.MapPut("/menu-items/{id:int}", UpdateAsync)
            .RequirePermission(ConsumptionPermissions.RecipeManage)
            .WithName("updateMenuItem");
    }

    private static async Task<IResult> ListAsync(
        [AsParameters] MenuItemsRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var query = new GetMenuItemsQuery(
            request.Search, request.IsActive, request.IsSubRecipe, request.HasActiveRecipe,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(
        MenuItemCreateRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new CreateMenuItemCommand(request.Code, request.PosCode, request.Name, request.Category, request.IsSubRecipe ?? false);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ConsumptionRoutes.Prefix}/menu-items/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(uint id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetMenuItemQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> UpdateAsync(
        uint id,
        MenuItemUpdateRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new UpdateMenuItemCommand(
            id, request.Code, request.PosCode, request.Name, request.Category,
            request.IsSubRecipe ?? false, request.IsActive ?? true, request.RowVersion);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
