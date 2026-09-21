using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Consumption.Application;
using Wms.Consumption.Application.Commands.Recipes;
using Wms.Consumption.Application.Queries;
using Wms.Consumption.Application.Queries.Recipes;
using Wms.Consumption.Contracts;

namespace Wms.Consumption.Endpoints;

/// <summary>
/// Operations <c>listRecipeVersions</c>, <c>createRecipeVersion</c>, <c>getRecipe</c>, <c>updateRecipe</c>,
/// <c>activateRecipe</c>, <c>explodeRecipe</c>.
/// </summary>
public static class RecipeEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/menu-items/{id:int}/recipes", ListVersionsAsync)
            .RequirePermission(ConsumptionPermissions.RecipeView)
            .WithName("listRecipeVersions");

        group.MapPost("/menu-items/{id:int}/recipes", CreateVersionAsync)
            .RequirePermission(ConsumptionPermissions.RecipeManage)
            .RequireIdempotencyKey()
            .WithName("createRecipeVersion");

        group.MapGet("/recipes/{id:int}", GetAsync)
            .RequirePermission(ConsumptionPermissions.RecipeView)
            .WithName("getRecipe");

        group.MapPut("/recipes/{id:int}", UpdateAsync)
            .RequirePermission(ConsumptionPermissions.RecipeManage)
            .WithName("updateRecipe");

        group.MapPost("/recipes/{id:int}/activate", ActivateAsync)
            .RequirePermission(ConsumptionPermissions.RecipeManage)
            .RequireIdempotencyKey()
            .WithName("activateRecipe");

        group.MapGet("/recipes/{id:int}/explosion", ExplodeAsync)
            .RequirePermission(ConsumptionPermissions.RecipeView)
            .WithName("explodeRecipe");
    }

    private static async Task<IResult> ListVersionsAsync(uint id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetRecipeVersionsQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateVersionAsync(
        uint id,
        RecipeVersionCreateRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new CreateRecipeVersionCommand(
            id,
            request.ValidFrom,
            request.YieldPortions ?? 1m,
            request.CopyFromRecipeId,
            request.Note,
            (request.Lines ?? []).Select(l => l.ToInput()).ToList());
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ConsumptionRoutes.Prefix}/recipes/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(uint id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetRecipeQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> UpdateAsync(
        uint id,
        RecipeUpdateRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new UpdateRecipeCommand(
            id, request.RowVersion, request.YieldPortions ?? 1m, request.Note,
            (request.Lines ?? []).Select(l => l.ToInput()).ToList());
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ActivateAsync(
        uint id,
        RecipeActivateRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher
            .SendAsync(new ActivateRecipeCommand(id, request.ValidFrom, request.RowVersion), cancellationToken)
            .ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ExplodeAsync(
        uint id,
        [AsParameters] RecipeExplosionRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var result = await dispatcher
            .QueryAsync(new ExplodeRecipeQuery(id, request.Portions ?? 1m, request.AsOfDate), cancellationToken)
            .ConfigureAwait(false);
        return result.ToOk();
    }
}
