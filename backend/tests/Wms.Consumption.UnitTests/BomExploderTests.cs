using Wms.Common.Domain;
using Wms.Consumption.Domain.Enums;
using Wms.Consumption.Domain.Services;

namespace Wms.Consumption.UnitTests;

/// <summary>
/// ADR-012 / branch-operations.md §3 — the explosion formula:
/// <c>required_base = portions x qty_per_portion / yield_portions x conversion_to_base / (yield_pct / 100)</c>.
/// Pure domain, no database.
/// </summary>
public sealed class BomExploderTests
{
    private const uint Sandwich = 10;
    private const uint Sauce = 20;
    private const uint Mayo = 30;

    private const uint Lettuce = 100;
    private const uint Chicken = 101;
    private const uint Oil = 102;
    private const uint Egg = 103;

    private const ushort Gram = 1;
    private const ushort Kilogram = 2;
    private const ushort Portion = 9;

    [Fact]
    public void A_single_ingredient_without_loss_multiplies_portions_by_the_recipe_quantity()
    {
        // 120 sandwiches x 20 g lettuce, factor 1 (recipe already in the base UoM), yield 100 %.
        var recipes = Recipes(Recipe(Sandwich, 1m, ProductLine(1, Lettuce, 20m, Gram)));

        var result = BomExploder.Explode(Sandwich, 120m, recipes, Products());

        Assert.True(result.IsSuccess);
        var line = Assert.Single(result.Value.Requirements);
        Assert.Equal(Lettuce, line.ProductId);
        Assert.Equal(2400.0000m, line.RequiredQtyBase);
        Assert.Equal(0, line.Depth);
        Assert.Null(line.ViaSubMenuItemId);
    }

    [Fact]
    public void The_yield_percentage_grosses_the_requirement_up_by_the_processing_loss()
    {
        // The document's own example: 8 % of the lettuce is trimmed, so 20 g on the recipe takes 21.74 g of stock.
        var recipes = Recipes(Recipe(Sandwich, 1m, ProductLine(1, Lettuce, 20m, Gram, yieldPct: 92m)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsSuccess);
        Assert.Equal(21.7391m, Assert.Single(result.Value.Requirements).RequiredQtyBase);
    }

    [Fact]
    public void The_conversion_factor_turns_the_recipe_unit_into_the_base_unit()
    {
        // 0.15 kg of chicken per portion, 1 kg = 1000 g, base UoM is the gram.
        var recipes = Recipes(Recipe(Sandwich, 1m, ProductLine(1, Chicken, 0.15m, Kilogram)));

        var result = BomExploder.Explode(Sandwich, 10m, recipes, Products());

        Assert.True(result.IsSuccess);
        Assert.Equal(1500.0000m, Assert.Single(result.Value.Requirements).RequiredQtyBase);
    }

    [Fact]
    public void An_optional_component_is_scaled_by_its_attach_rate()
    {
        var recipes = Recipes(Recipe(Sandwich, 1m, ProductLine(1, Lettuce, 10m, Gram, isOptional: true, attachRatePct: 40m)));

        var result = BomExploder.Explode(Sandwich, 100m, recipes, Products());

        Assert.True(result.IsSuccess);
        Assert.Equal(400.0000m, Assert.Single(result.Value.Requirements).RequiredQtyBase);
    }

    [Fact]
    public void Yield_portions_spreads_a_sub_recipe_batch_over_the_portions_it_produces()
    {
        // The sauce recipe makes 10 portions from 500 g oil; two portions of sauce therefore take 100 g.
        var recipes = Recipes(
            Recipe(Sandwich, 1m, SubRecipeLine(1, Sauce, 2m)),
            Recipe(Sauce, 10m, ProductLine(1, Oil, 500m, Gram)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsSuccess);
        var line = Assert.Single(result.Value.Requirements);
        Assert.Equal(Oil, line.ProductId);
        Assert.Equal(100.0000m, line.RequiredQtyBase);
        Assert.Equal(1, line.Depth);
        Assert.Equal(Sauce, line.ViaSubMenuItemId);
        Assert.Equal(1, result.Value.MaxDepth);
    }

    [Fact]
    public void Nested_sub_recipes_multiply_their_losses_along_the_chain()
    {
        // Sandwich -> 2 portions of sauce (yield 10) -> 1 portion of mayo (yield 4, 90 % yield) -> 200 g egg.
        var recipes = Recipes(
            Recipe(Sandwich, 1m, SubRecipeLine(1, Sauce, 2m)),
            Recipe(Sauce, 10m, SubRecipeLine(1, Mayo, 1m)),
            Recipe(Mayo, 4m, ProductLine(1, Egg, 200m, Gram, yieldPct: 90m)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsSuccess);
        var line = Assert.Single(result.Value.Requirements);
        // 1 x 2 / 10 = 0.2 sauce portions -> 0.2 x 1 / 4 = 0.05 mayo portions -> 0.05 x 200 / 0.9 = 11.1111 g.
        Assert.Equal(11.1111m, line.RequiredQtyBase);
        Assert.Equal(2, result.Value.MaxDepth);
    }

    [Fact]
    public void The_same_product_reached_twice_is_summed_once()
    {
        var recipes = Recipes(
            Recipe(Sandwich, 1m, ProductLine(1, Oil, 5m, Gram), SubRecipeLine(2, Sauce, 1m)),
            Recipe(Sauce, 1m, ProductLine(1, Oil, 7m, Gram)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsSuccess);
        var line = Assert.Single(result.Value.Requirements);
        Assert.Equal(12.0000m, line.RequiredQtyBase);
        Assert.Equal(0, line.Depth);
        Assert.Null(line.ViaSubMenuItemId);
    }

    [Fact]
    public void A_sub_recipe_cycle_is_rejected()
    {
        var recipes = Recipes(
            Recipe(Sandwich, 1m, SubRecipeLine(1, Sauce, 1m)),
            Recipe(Sauce, 1m, SubRecipeLine(1, Sandwich, 1m)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsFailure);
        Assert.Equal("RECIPE_CYCLE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Fact]
    public void A_recipe_that_references_itself_is_a_cycle_too()
    {
        var recipes = Recipes(Recipe(Sandwich, 1m, SubRecipeLine(1, Sandwich, 1m)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsFailure);
        Assert.Equal("RECIPE_CYCLE", result.Error.Code);
    }

    [Fact]
    public void Nesting_up_to_the_maximum_depth_is_accepted()
    {
        // Root at depth 0 plus five levels of sub-recipes is exactly the documented limit.
        var chain = BuildChain(BomExploder.MaxDepth);

        var result = BomExploder.Explode(1000, 1m, chain, Products());

        Assert.True(result.IsSuccess);
        Assert.Equal(BomExploder.MaxDepth, result.Value.MaxDepth);
    }

    [Fact]
    public void Nesting_deeper_than_the_maximum_is_rejected()
    {
        var chain = BuildChain(BomExploder.MaxDepth + 1);

        var result = BomExploder.Explode(1000, 1m, chain, Products());

        Assert.True(result.IsFailure);
        Assert.Equal("RECIPE_DEPTH_EXCEEDED", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Fact]
    public void A_missing_conversion_factor_stops_the_calculation()
    {
        var recipes = Recipes(Recipe(Sandwich, 1m, ProductLine(1, Lettuce, 20m, uomId: 77)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsFailure);
        Assert.Equal("UOM_FACTOR_MISSING", result.Error.Code);
    }

    [Fact]
    public void A_sub_recipe_without_an_effective_version_stops_the_calculation()
    {
        var recipes = Recipes(Recipe(Sandwich, 1m, SubRecipeLine(1, Sauce, 1m)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsFailure);
        Assert.Equal("RECIPE_EMPTY", result.Error.Code);
    }

    [Fact]
    public void An_empty_recipe_is_rejected()
    {
        var recipes = Recipes(new BomRecipe(1, Sandwich, 1m, []));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsFailure);
        Assert.Equal("RECIPE_EMPTY", result.Error.Code);
    }

    [Fact]
    public void Zero_or_negative_portions_are_rejected()
    {
        var recipes = Recipes(Recipe(Sandwich, 1m, ProductLine(1, Lettuce, 20m, Gram)));

        Assert.True(BomExploder.Explode(Sandwich, 0m, recipes, Products()).IsFailure);
        Assert.True(BomExploder.Explode(Sandwich, -3m, recipes, Products()).IsFailure);
    }

    [Fact]
    public void The_result_is_rounded_to_the_storage_scale_of_the_quantity_column()
    {
        // 1/3 of a gram must land on DECIMAL(18,4) exactly as Quantity.Round produces it.
        var recipes = Recipes(Recipe(Sandwich, 3m, ProductLine(1, Lettuce, 1m, Gram)));

        var result = BomExploder.Explode(Sandwich, 1m, recipes, Products());

        Assert.True(result.IsSuccess);
        Assert.Equal(Quantity.Round(1m / 3m, 4), Assert.Single(result.Value.Requirements).RequiredQtyBase);
    }

    private static InMemoryBomRecipeSource BuildChain(int depth)
    {
        // 1000 -> 1001 -> ... -> 1000+depth, the last level holding the only product line.
        var recipes = new List<BomRecipe>();
        for (var i = 0; i < depth; i++)
        {
            recipes.Add(Recipe((uint)(1000 + i), 1m, SubRecipeLine(1, (uint)(1001 + i), 1m)));
        }

        recipes.Add(Recipe((uint)(1000 + depth), 1m, ProductLine(1, Lettuce, 1m, Gram)));
        return Recipes([.. recipes]);
    }

    private static InMemoryBomRecipeSource Recipes(params BomRecipe[] recipes) =>
        new(recipes.ToDictionary(r => r.MenuItemId));

    private static BomRecipe Recipe(uint menuItemId, decimal yieldPortions, params BomLine[] lines) =>
        new(menuItemId, menuItemId, yieldPortions, lines);

    private static BomLine ProductLine(
        ushort lineNo,
        uint productId,
        decimal qtyPerPortion,
        ushort uomId,
        decimal yieldPct = 100m,
        bool isOptional = false,
        decimal attachRatePct = 100m) =>
        new(lineNo, ComponentType.FoodProduct, productId, null, qtyPerPortion, uomId, yieldPct, isOptional, attachRatePct);

    private static BomLine SubRecipeLine(ushort lineNo, uint subMenuItemId, decimal portions, decimal yieldPct = 100m) =>
        new(lineNo, ComponentType.SubRecipe, null, subMenuItemId, portions, Portion, yieldPct, false, 100m);

    private static InMemoryBomProductSource Products() => new(
        new Dictionary<uint, BomProduct>
        {
            [Lettuce] = new(Lettuce, Gram, 4),
            [Chicken] = new(Chicken, Gram, 4),
            [Oil] = new(Oil, Gram, 4),
            [Egg] = new(Egg, Gram, 4),
        },
        new Dictionary<(uint ProductId, ushort UomId), decimal>
        {
            [(Lettuce, Gram)] = 1m,
            [(Chicken, Gram)] = 1m,
            [(Chicken, Kilogram)] = 1000m,
            [(Oil, Gram)] = 1m,
            [(Egg, Gram)] = 1m,
        });
}
