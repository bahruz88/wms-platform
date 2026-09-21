using Wms.Inventory.Contracts;

namespace Wms.Inventory.Endpoints;

/// <summary>Module-to-module endpoints backing <see cref="IStockBalanceReader"/> over HTTP (spec §4.2).</summary>
public static class InternalEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/internal/stock-levels/{productId:long}/{locationId:long}",
                async (long productId, long locationId, IStockBalanceReader reader, CancellationToken cancellationToken) =>
                {
                    var level = await reader.GetAsync(productId, locationId, cancellationToken).ConfigureAwait(false);
                    return level is null ? Results.NotFound() : Results.Ok(level);
                })
            .WithName("InternalStockLevel")
            .ExcludeFromDescription();

        group.MapGet("/internal/stock-levels/{productId:long}",
                async (long productId, IStockBalanceReader reader, CancellationToken cancellationToken) =>
                    Results.Ok(await reader.GetByProductAsync(productId, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalStockLevelsByProduct")
            .ExcludeFromDescription();

        // Write side used by Consumption when the two modules run in different containers (ModuleTransport=Http).
        group.MapPost("/internal/consumption-postings",
                async (ConsumptionPostingRequest request, IStockPostingService posting, CancellationToken cancellationToken) =>
                    Results.Ok(await posting.PostConsumptionAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalConsumptionPosting")
            .ExcludeFromDescription();

        group.MapPost("/internal/reversals",
                async (StockReversalRequest request, IStockPostingService posting, CancellationToken cancellationToken) =>
                    Results.Ok(await posting.ReverseAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReversal")
            .ExcludeFromDescription();

        group.MapGet("/internal/period-flows",
                async (uint? locationId, uint? productId, DateOnly periodFrom, DateOnly periodTo, IStockMovementReader reader, CancellationToken cancellationToken) =>
                    Results.Ok(await reader.GetPeriodFlowsAsync(locationId, productId, periodFrom, periodTo, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalPeriodFlows")
            .ExcludeFromDescription();

        group.MapGet("/internal/locations/{locationId:long}/frozen",
                async (long locationId, IStockPostingService posting, CancellationToken cancellationToken) =>
                    Results.Ok(new { frozen = await posting.IsLocationFrozenAsync((uint)locationId, cancellationToken).ConfigureAwait(false) }))
            .WithName("InternalLocationFrozen")
            .ExcludeFromDescription();
    }
}
