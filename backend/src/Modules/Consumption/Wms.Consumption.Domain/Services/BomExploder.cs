using Wms.Common.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Domain.Services;

/// <summary>One component of a recipe as the exploder sees it — no persistence types, no database.</summary>
public sealed record BomLine(
    ushort LineNo,
    ComponentType ComponentType,
    uint? ProductId,
    uint? SubMenuItemId,
    decimal QtyPerPortion,
    ushort UomId,
    decimal YieldPct,
    bool IsOptional,
    decimal AttachRatePct);

/// <summary>A recipe version already selected for the business date (invariant 4).</summary>
public sealed record BomRecipe(uint RecipeId, uint MenuItemId, decimal YieldPortions, IReadOnlyList<BomLine> Lines);

/// <summary>Base unit of a product, needed to turn a recipe quantity into a ledger quantity.</summary>
public sealed record BomProduct(uint ProductId, ushort BaseUomId, int BaseDecimals);

/// <summary>The recipe version in force on the business date for a menu item. Null = the menu item has no recipe.</summary>
public interface IBomRecipeSource
{
    BomRecipe? ForMenuItem(uint menuItemId);
}

/// <summary>Product master data frozen on the business date: base UoM and <c>factor_to_base</c> of the line's UoM.</summary>
public interface IBomProductSource
{
    BomProduct? GetProduct(uint productId);

    decimal? GetFactorToBase(uint productId, ushort uomId);
}

/// <summary>Dictionary-backed sources so the exploder can be unit tested without a database.</summary>
public sealed class InMemoryBomRecipeSource(IReadOnlyDictionary<uint, BomRecipe> recipesByMenuItem) : IBomRecipeSource
{
    public BomRecipe? ForMenuItem(uint menuItemId) =>
        recipesByMenuItem.TryGetValue(menuItemId, out var recipe) ? recipe : null;
}

public sealed class InMemoryBomProductSource(
    IReadOnlyDictionary<uint, BomProduct> products,
    IReadOnlyDictionary<(uint ProductId, ushort UomId), decimal> factors) : IBomProductSource
{
    public BomProduct? GetProduct(uint productId) => products.TryGetValue(productId, out var product) ? product : null;

    public decimal? GetFactorToBase(uint productId, ushort uomId) =>
        factors.TryGetValue((productId, uomId), out var factor) ? factor : null;
}

/// <summary>One product requirement produced by the explosion, already converted to the product's base UoM.</summary>
public sealed record BomRequirement(uint ProductId, ushort BaseUomId, decimal RequiredQtyBase, int Depth, uint? ViaSubMenuItemId);

public sealed record BomExplosion(IReadOnlyList<BomRequirement> Requirements, int MaxDepth);

/// <summary>
/// Recursive recipe (BOM) explosion — a pure domain service (branch-operations.md §3).
///
/// <code>
/// required_base = portions x qty_per_portion / yield_portions x conversion_to_base / (yield_pct / 100)
/// </code>
///
/// <list type="bullet">
/// <item><c>yield_pct</c> models the processing loss: 8 % of the lettuce is trimmed, so 20 g on the recipe
/// takes 21.74 g out of stock. Without it the theoretical figure is always below the physical one and the
/// variance report loses its meaning.</item>
/// <item><c>yield_portions</c> is how many portions one preparation produces. It is 1 for a sold menu item —
/// which is why the formula in the design document, written for sold items, does not show it — and greater
/// than 1 for a sub-recipe batch such as a sauce.</item>
/// <item>An optional component is scaled by <c>attach_rate_pct</c>: it is taken in that share of the orders.</item>
/// <item>A <see cref="ComponentType.SubRecipe"/> line's <c>qty_per_portion</c> counts PORTIONS of the sub-recipe;
/// its UoM carries no conversion because a sub-recipe is not a stocked product.</item>
/// <item>A cycle (A -&gt; B -&gt; A) is rejected, and nesting deeper than <see cref="MaxDepth"/> is rejected.</item>
/// </list>
/// </summary>
public static class BomExploder
{
    /// <summary>Root recipe is depth 0; a component nested deeper than this fails with RECIPE_DEPTH_EXCEEDED.</summary>
    public const int MaxDepth = 5;

    public static Result<BomExplosion> Explode(
        uint menuItemId,
        decimal portions,
        IBomRecipeSource recipes,
        IBomProductSource products)
    {
        ArgumentNullException.ThrowIfNull(recipes);
        ArgumentNullException.ThrowIfNull(products);

        if (portions <= 0m)
        {
            return ConsumptionErrors.InvalidSalesLine("portions must be positive.");
        }

        var accumulator = new Dictionary<uint, Accumulated>();
        var path = new List<uint>();
        var deepest = 0;

        var visited = Visit(menuItemId, portions, depth: 0, recipes, products, accumulator, path, ref deepest);
        if (visited.IsFailure)
        {
            return visited.Error;
        }

        var requirements = accumulator
            .OrderBy(kv => kv.Key)
            .Select(kv => new BomRequirement(
                kv.Key,
                kv.Value.BaseUomId,
                Quantity.Round(kv.Value.Qty, Math.Min(kv.Value.BaseDecimals, Quantity.StorageDecimals)),
                kv.Value.Depth,
                kv.Value.ViaSubMenuItemId))
            .ToList();

        return new BomExplosion(requirements, deepest);
    }

    private static Result Visit(
        uint menuItemId,
        decimal portions,
        int depth,
        IBomRecipeSource recipes,
        IBomProductSource products,
        Dictionary<uint, Accumulated> accumulator,
        List<uint> path,
        ref int deepest)
    {
        if (path.Contains(menuItemId))
        {
            return ConsumptionErrors.RecipeCycle([.. path, menuItemId]);
        }

        if (depth > MaxDepth)
        {
            return ConsumptionErrors.RecipeDepthExceeded(MaxDepth, [.. path, menuItemId]);
        }

        var recipe = recipes.ForMenuItem(menuItemId);
        if (recipe is null)
        {
            // Only reachable for a sub-recipe component: the caller checks the root before exploding.
            return ConsumptionErrors.SubRecipeMissing(menuItemId);
        }

        if (recipe.Lines.Count == 0)
        {
            return ConsumptionErrors.RecipeEmpty(recipe.RecipeId);
        }

        if (recipe.YieldPortions <= 0m)
        {
            return ConsumptionErrors.InvalidRecipeLine($"Recipe {recipe.RecipeId}: yield_portions must be positive.");
        }

        deepest = Math.Max(deepest, depth);
        path.Add(menuItemId);
        try
        {
            foreach (var line in recipe.Lines)
            {
                if (line.YieldPct <= 0m)
                {
                    return ConsumptionErrors.InvalidRecipeLine($"Recipe {recipe.RecipeId} line {line.LineNo}: yield_pct must be positive.");
                }

                // portions x qty_per_portion / yield_portions, scaled by the attach rate, then grossed up by the loss.
                var required = portions * line.QtyPerPortion / recipe.YieldPortions;
                if (line.IsOptional)
                {
                    required *= line.AttachRatePct / 100m;
                }

                required /= line.YieldPct / 100m;
                if (required == 0m)
                {
                    continue;
                }

                if (line.ComponentType == ComponentType.SubRecipe)
                {
                    var subMenuItemId = line.SubMenuItemId!.Value;
                    var subDepth = depth + 1;
                    var nested = Visit(subMenuItemId, required, subDepth, recipes, products, accumulator, path, ref deepest);
                    if (nested.IsFailure)
                    {
                        return nested;
                    }

                    continue;
                }

                var productId = line.ProductId!.Value;
                var product = products.GetProduct(productId);
                if (product is null)
                {
                    return ConsumptionErrors.ProductNotFound(productId);
                }

                var factor = products.GetFactorToBase(productId, line.UomId);
                if (factor is not > 0m)
                {
                    return ConsumptionErrors.UomFactorMissing(productId, line.UomId);
                }

                Accumulate(accumulator, product, required * factor.Value, depth, depth == 0 ? null : menuItemId);
            }

            return Result.Success();
        }
        finally
        {
            path.RemoveAt(path.Count - 1);
        }
    }

    private static void Accumulate(Dictionary<uint, Accumulated> accumulator, BomProduct product, decimal qty, int depth, uint? viaSubMenuItemId)
    {
        if (accumulator.TryGetValue(product.ProductId, out var existing))
        {
            accumulator[product.ProductId] = existing with
            {
                Qty = existing.Qty + qty,
                Depth = Math.Min(existing.Depth, depth),
                ViaSubMenuItemId = depth < existing.Depth ? viaSubMenuItemId : existing.ViaSubMenuItemId,
            };
            return;
        }

        accumulator[product.ProductId] = new Accumulated(qty, product.BaseUomId, product.BaseDecimals, depth, viaSubMenuItemId);
    }

    private sealed record Accumulated(decimal Qty, ushort BaseUomId, int BaseDecimals, int Depth, uint? ViaSubMenuItemId);
}
