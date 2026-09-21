using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Dtos;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;

namespace Wms.Consumption.Application.Queries.Variance;

/// <summary>
/// <c>GET /variance</c> (operationId <c>getConsumptionVariance</c>) — the real product of the model
/// (branch-operations.md §7):
/// <code>
/// expected = opening + received − theoretical consumption − waste − sample ± transfers
/// variance = counted − expected
/// </code>
/// <c>opening</c> and <c>counted</c> are the ledger positions at the two ends of the period, so the variance is
/// exactly the net <c>COUNT_ADJUST</c> that had to be posted — the quantity the count could not explain.
/// <c>varianceValue</c> is omitted without <c>master.product.view_cost</c> (spec §16).
/// </summary>
public sealed record GetConsumptionVarianceQuery(
    uint? LocationId,
    uint? ProductId,
    DateOnly PeriodFrom,
    DateOnly PeriodTo,
    decimal? MinAbsVariancePct,
    PageRequest Page) : IQuery<VariancePageDto>;

public sealed class GetConsumptionVarianceQueryValidator : AbstractValidator<GetConsumptionVarianceQuery>
{
    public GetConsumptionVarianceQueryValidator()
    {
        RuleFor(q => q.PeriodTo).GreaterThanOrEqualTo(q => q.PeriodFrom);
        RuleFor(q => q.Page).NotNull();
    }
}

public sealed class GetConsumptionVarianceQueryHandler(
    IStockMovementReader movements,
    IProductCatalog products,
    ILocationCatalog locations,
    ICurrentUser currentUser) : IQueryHandler<GetConsumptionVarianceQuery, VariancePageDto>
{
    public async Task<Result<VariancePageDto>> HandleAsync(GetConsumptionVarianceQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        var includeCost = currentUser.HasPermission(ConsumptionPermissions.ViewCost);
        var flows = await movements
            .GetPeriodFlowsAsync(query.LocationId, query.ProductId, query.PeriodFrom, query.PeriodTo, cancellationToken)
            .ConfigureAwait(false);

        var visible = currentUser.LocationIds;
        var rows = new List<VarianceLineDto>();
        var productNames = new Dictionary<uint, ProductDto?>();
        var locationNames = new Dictionary<uint, string>();

        foreach (var flow in flows)
        {
            if (visible.Count > 0 && !visible.Contains(flow.LocationId))
            {
                continue;
            }

            var expected = flow.OpeningQty + flow.ReceivedQty - flow.ConsumedQty - flow.WasteQty - flow.SampleQty + flow.TransferNetQty;
            var variance = flow.ClosingQty - expected;
            var variancePct = expected == 0m ? 0m : Quantity.Round(variance / expected * 100m, 4);
            if (query.MinAbsVariancePct is { } threshold && Math.Abs(variancePct) < threshold)
            {
                continue;
            }

            if (!productNames.TryGetValue(flow.ProductId, out var product))
            {
                product = await products.GetAsync(flow.ProductId, cancellationToken).ConfigureAwait(false);
                productNames[flow.ProductId] = product;
            }

            if (!locationNames.TryGetValue(flow.LocationId, out var locationName))
            {
                var location = await locations.GetAsync(flow.LocationId, cancellationToken).ConfigureAwait(false);
                locationName = location?.Name ?? string.Empty;
                locationNames[flow.LocationId] = locationName;
            }

            rows.Add(new VarianceLineDto(
                flow.ProductId,
                product?.Sku ?? string.Empty,
                product?.Name ?? string.Empty,
                flow.LocationId,
                locationName,
                product?.BaseUomCode ?? string.Empty,
                flow.OpeningQty,
                flow.ReceivedQty,
                flow.ConsumedQty,
                flow.WasteQty,
                flow.SampleQty,
                flow.TransferNetQty,
                Quantity.Round(expected, Quantity.StorageDecimals),
                flow.ClosingQty,
                Quantity.Round(variance, Quantity.StorageDecimals),
                variancePct,
                includeCost ? Quantity.Round(variance * flow.AvgUnitCost, Money.StorageDecimals) : null));
        }

        var page = rows.Skip(query.Page.Skip).Take(query.Page.Size).ToList();
        return new VariancePageDto(page, query.Page.Page, query.Page.Size, rows.Count, query.PeriodFrom, query.PeriodTo);
    }
}
