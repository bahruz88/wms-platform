using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;
using Wms.Consumption.Domain.Services;
using Wms.MasterData.Contracts;

namespace Wms.Consumption.Application.Queries.Recipes;

/// <summary>
/// <c>GET /recipes/{id}/explosion</c> (operationId <c>explodeRecipe</c>): what the given number of portions would
/// need. Takes nothing out of stock — this is the recipe editor's preview and the formula's test harness.
/// </summary>
public sealed record ExplodeRecipeQuery(uint RecipeId, decimal Portions, DateOnly? AsOfDate) : IQuery<RecipeExplosionDto>;

public sealed class ExplodeRecipeQueryValidator : AbstractValidator<ExplodeRecipeQuery>
{
    public ExplodeRecipeQueryValidator()
    {
        RuleFor(q => q.RecipeId).GreaterThan(0u);
        RuleFor(q => q.Portions).GreaterThan(0m);
    }
}

public sealed class ExplodeRecipeQueryHandler(
    IRecipeRepository recipes,
    IMenuItemRepository menuItems,
    IProductCatalog products,
    ITenantContext tenantContext,
    IClock clock) : IQueryHandler<ExplodeRecipeQuery, RecipeExplosionDto>
{
    public async Task<Result<RecipeExplosionDto>> HandleAsync(ExplodeRecipeQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var recipe = await recipes.GetAsync(query.RecipeId, cancellationToken).ConfigureAwait(false);
        if (recipe is null)
        {
            return ConsumptionErrors.RecipeNotFound(query.RecipeId);
        }

        if (recipe.Lines.Count == 0)
        {
            return ConsumptionErrors.RecipeEmpty(recipe.Id);
        }

        var asOf = query.AsOfDate ?? DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);

        // The root version is the one asked for; sub-recipes resolve to the version effective on asOf.
        var effective = new Dictionary<uint, BomRecipe>(
            await recipes.GetEffectiveBomAsync(tenantContext.TenantId, asOf, cancellationToken).ConfigureAwait(false))
        {
            [recipe.MenuItemId] = ToBom(recipe),
        };

        var productSource = await BuildProductSourceAsync(effective.Values, asOf, cancellationToken).ConfigureAwait(false);
        var explosion = BomExploder.Explode(recipe.MenuItemId, query.Portions, new InMemoryBomRecipeSource(effective), productSource);
        if (explosion.IsFailure)
        {
            return explosion.Error;
        }

        var menuItem = await menuItems.GetAsync(recipe.MenuItemId, cancellationToken).ConfigureAwait(false);
        var subNames = new Dictionary<uint, string>();
        foreach (var viaId in explosion.Value.Requirements.Select(r => r.ViaSubMenuItemId).OfType<uint>().Distinct())
        {
            var sub = await menuItems.GetAsync(viaId, cancellationToken).ConfigureAwait(false);
            if (sub is not null)
            {
                subNames[viaId] = sub.Name;
            }
        }

        var lines = new List<RecipeExplosionLineDto>(explosion.Value.Requirements.Count);
        foreach (var requirement in explosion.Value.Requirements)
        {
            var product = await products.GetAsync(requirement.ProductId, cancellationToken).ConfigureAwait(false);
            lines.Add(new RecipeExplosionLineDto(
                requirement.ProductId,
                product?.Sku ?? string.Empty,
                product?.Name ?? string.Empty,
                requirement.RequiredQtyBase,
                requirement.BaseUomId,
                product?.BaseUomCode ?? string.Empty,
                requirement.ViaSubMenuItemId is { } via ? subNames.GetValueOrDefault(via) : null,
                requirement.Depth));
        }

        return new RecipeExplosionDto(recipe.Id, menuItem?.Name ?? string.Empty, query.Portions, explosion.Value.MaxDepth, lines);
    }

    internal static BomRecipe ToBom(Recipe recipe) => new(
        recipe.Id,
        recipe.MenuItemId,
        recipe.YieldPortions,
        recipe.Lines
            .OrderBy(l => l.LineNo)
            .Select(l => new BomLine(
                l.LineNo, l.ComponentType, l.ProductId, l.SubMenuItemId, l.QtyPerPortion, l.UomId, l.YieldPct, l.IsOptional, l.AttachRatePct))
            .ToList());

    private async Task<InMemoryBomProductSource> BuildProductSourceAsync(
        IEnumerable<BomRecipe> effectiveRecipes,
        DateOnly asOf,
        CancellationToken cancellationToken)
    {
        var pairs = effectiveRecipes
            .SelectMany(r => r.Lines)
            .Where(l => l.ComponentType == ComponentType.FoodProduct && l.ProductId is > 0)
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
