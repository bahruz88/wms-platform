using FluentValidation;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain.Services;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;

namespace Wms.Consumption.Application.Queries.Variance;

/// <summary>
/// <c>GET /portion-compliance</c> (operationId <c>getPortionCompliance</c>): what one portion of a menu item
/// really costs in ingredients, against what the recipe says. The actual figure derives from the variance
/// analysis (branch-operations.md §7): a product's actual usage is its theoretical consumption minus the
/// signed variance, attributed to menu items in proportion to the theoretical consumption each caused.
/// <c>compliancePct = recipeQty / actualQty x 100</c>; below 100 means portions are larger than the norm.
/// </summary>
public sealed record GetPortionComplianceQuery(
    uint? LocationId,
    uint? MenuItemId,
    DateOnly PeriodFrom,
    DateOnly PeriodTo,
    PageRequest Page) : IQuery<PagedResult<PortionComplianceLineDto>>;

public sealed class GetPortionComplianceQueryValidator : AbstractValidator<GetPortionComplianceQuery>
{
    public GetPortionComplianceQueryValidator()
    {
        RuleFor(q => q.PeriodTo).GreaterThanOrEqualTo(q => q.PeriodFrom);
        RuleFor(q => q.Page).NotNull();
    }
}

public sealed class GetPortionComplianceQueryHandler(
    IConsumptionQueries queries,
    IRecipeRepository recipes,
    IProductCatalog products,
    IStockMovementReader movements,
    Wms.Common.Application.Abstractions.ITenantContext tenantContext)
    : IQueryHandler<GetPortionComplianceQuery, PagedResult<PortionComplianceLineDto>>
{
    public async Task<Result<PagedResult<PortionComplianceLineDto>>> HandleAsync(
        GetPortionComplianceQuery query,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var sold = await queries
            .GetPortionsSoldAsync(query.LocationId, query.MenuItemId, query.PeriodFrom, query.PeriodTo, cancellationToken)
            .ConfigureAwait(false);
        if (sold.Count == 0)
        {
            return PagedResult<PortionComplianceLineDto>.Empty(query.Page);
        }

        // Recipe in force at the end of the period: the report compares a period against one norm.
        var effective = await recipes.GetEffectiveBomAsync(tenantId, query.PeriodTo, cancellationToken).ConfigureAwait(false);
        var recipeSource = new InMemoryBomRecipeSource(effective);
        var productSource = await BuildProductSourceAsync(effective.Values, query.PeriodTo, cancellationToken).ConfigureAwait(false);

        // Theoretical quantity each menu item caused, per product.
        var perPair = new List<(uint MenuItemId, string MenuItemName, uint ProductId, ushort BaseUomId, decimal RecipeQtyPerPortion, decimal PortionsSold)>();
        var theoreticalByProduct = new Dictionary<uint, decimal>();
        foreach (var (menuItemId, menuItemName, portionsSold) in sold)
        {
            if (portionsSold <= 0m || !effective.ContainsKey(menuItemId))
            {
                continue;
            }

            var explosion = BomExploder.Explode(menuItemId, 1m, recipeSource, productSource);
            if (explosion.IsFailure)
            {
                continue;
            }

            foreach (var requirement in explosion.Value.Requirements)
            {
                perPair.Add((menuItemId, menuItemName, requirement.ProductId, requirement.BaseUomId, requirement.RequiredQtyBase, portionsSold));
                theoreticalByProduct[requirement.ProductId] =
                    theoreticalByProduct.GetValueOrDefault(requirement.ProductId) + (requirement.RequiredQtyBase * portionsSold);
            }
        }

        if (perPair.Count == 0)
        {
            return PagedResult<PortionComplianceLineDto>.Empty(query.Page);
        }

        // Actual usage per product = theoretical consumption − the signed variance of the same period.
        var flows = await movements
            .GetPeriodFlowsAsync(query.LocationId, productId: null, query.PeriodFrom, query.PeriodTo, cancellationToken)
            .ConfigureAwait(false);
        var actualByProduct = new Dictionary<uint, decimal>();
        foreach (var flow in flows)
        {
            var expected = flow.OpeningQty + flow.ReceivedQty - flow.ConsumedQty - flow.WasteQty - flow.SampleQty + flow.TransferNetQty;
            var variance = flow.ClosingQty - expected;
            actualByProduct[flow.ProductId] = actualByProduct.GetValueOrDefault(flow.ProductId) + flow.ConsumedQty - variance;
        }

        var rows = new List<PortionComplianceLineDto>(perPair.Count);
        foreach (var pair in perPair.OrderBy(p => p.MenuItemId).ThenBy(p => p.ProductId))
        {
            var theoreticalTotal = theoreticalByProduct.GetValueOrDefault(pair.ProductId);
            if (theoreticalTotal <= 0m)
            {
                continue;
            }

            var pairTheoretical = pair.RecipeQtyPerPortion * pair.PortionsSold;
            var share = pairTheoretical / theoreticalTotal;
            var actualTotal = actualByProduct.TryGetValue(pair.ProductId, out var a) ? a : pairTheoretical;
            var actualPerPortion = Quantity.Round(share * actualTotal / pair.PortionsSold, Quantity.StorageDecimals);
            var compliance = actualPerPortion == 0m ? 0m : Quantity.Round(pair.RecipeQtyPerPortion / actualPerPortion * 100m, 4);

            var product = await products.GetAsync(pair.ProductId, cancellationToken).ConfigureAwait(false);
            rows.Add(new PortionComplianceLineDto(
                pair.MenuItemId,
                pair.MenuItemName,
                pair.ProductId,
                product?.Name ?? string.Empty,
                product?.BaseUomCode ?? string.Empty,
                pair.PortionsSold,
                pair.RecipeQtyPerPortion,
                actualPerPortion,
                compliance));
        }

        var page = rows.Skip(query.Page.Skip).Take(query.Page.Size).ToList();
        return new PagedResult<PortionComplianceLineDto>(page, query.Page.Page, query.Page.Size, rows.Count);
    }

    private async Task<InMemoryBomProductSource> BuildProductSourceAsync(
        IEnumerable<BomRecipe> effectiveRecipes,
        DateOnly asOf,
        CancellationToken cancellationToken)
    {
        var pairs = effectiveRecipes
            .SelectMany(r => r.Lines)
            .Where(l => l.ProductId is > 0)
            .Select(l => (ProductId: l.ProductId!.Value, l.UomId))
            .Distinct()
            .ToList();

        var productMap = new Dictionary<uint, BomProduct>();
        var factorMap = new Dictionary<(uint ProductId, ushort UomId), decimal>();
        foreach (var (productId, uomId) in pairs)
        {
            if (!productMap.ContainsKey(productId))
            {
                var product = await products.GetAsync(productId, cancellationToken).ConfigureAwait(false);
                if (product is not null)
                {
                    productMap[productId] = new BomProduct(product.Id, product.BaseUomId, product.BaseUomDecimals);
                }
            }

            var factor = await products.GetUomFactorAsync(productId, uomId, asOf, cancellationToken).ConfigureAwait(false);
            if (factor is > 0m)
            {
                factorMap[(productId, uomId)] = factor.Value;
            }
        }

        return new InMemoryBomProductSource(productMap, factorMap);
    }
}
