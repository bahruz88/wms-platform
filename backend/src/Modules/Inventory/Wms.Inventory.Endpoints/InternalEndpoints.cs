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

        MapReporting(group);

        group.MapGet("/internal/locations/{locationId:long}/frozen",
                async (long locationId, IStockPostingService posting, CancellationToken cancellationToken) =>
                    Results.Ok(new { frozen = await posting.IsLocationFrozenAsync((uint)locationId, cancellationToken).ConfigureAwait(false) }))
            .WithName("InternalLocationFrozen")
            .ExcludeFromDescription();
    }

    /// <summary>
    /// Aggregations behind <see cref="IInventoryReportingSource"/>. They are POSTs because a report filter does
    /// not fit a query string safely, and they stay out of the OpenAPI document like every other
    /// <c>/internal/*</c> route (README §8.15).
    /// </summary>
    private static void MapReporting(RouteGroupBuilder group)
    {
        group.MapPost("/internal/reporting/dashboard",
                async (InventoryDashboardRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetDashboardAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportDashboard")
            .ExcludeFromDescription();

        group.MapPost("/internal/reporting/stock-balances",
                async (StockBalanceReportRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetStockBalancesAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportStockBalances")
            .ExcludeFromDescription();

        group.MapPost("/internal/reporting/batch-stock",
                async (BatchStockReportRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetBatchStockAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportBatchStock")
            .ExcludeFromDescription();

        group.MapPost("/internal/reporting/movements",
                async (MovementReportRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetMovementsAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportMovements")
            .ExcludeFromDescription();

        group.MapPost("/internal/reporting/movement-aggregate",
                async (MovementAggregateReportRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetMovementAggregateAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportMovementAggregate")
            .ExcludeFromDescription();

        group.MapPost("/internal/reporting/count-variances",
                async (CountVarianceReportRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetCountVariancesAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportCountVariances")
            .ExcludeFromDescription();

        group.MapPost("/internal/reporting/receipt-variances",
                async (ReceiptVarianceReportRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetReceiptVariancesAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportReceiptVariances")
            .ExcludeFromDescription();

        group.MapPost("/internal/reporting/stock-coverage",
                async (StockCoverageReportRequest request, IInventoryReportingSource source, CancellationToken cancellationToken) =>
                    Results.Ok(await source.GetStockCoverageAsync(request, cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReportStockCoverage")
            .ExcludeFromDescription();
    }
}
