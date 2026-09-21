using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.UnitTests;

/// <summary>
/// ADR-012 invariant 4: the calculation takes the recipe version effective on the SALES date, and activating a
/// new version closes the previous one with <c>valid_to = valid_from − 1</c> so history never changes.
/// </summary>
public sealed class RecipeVersionTests
{
    private const uint Tenant = 1;
    private const uint MenuItem = 10;
    private const uint Lettuce = 100;
    private static readonly DateTimeOffset Now = new(2026, 9, 21, 8, 0, 0, TimeSpan.Zero);

    [Fact]
    public void Activating_a_second_version_closes_the_first_one_the_day_before()
    {
        var v1 = Draft(versionNo: 1, new DateOnly(2026, 1, 1));
        Assert.True(v1.Activate(new DateOnly(2026, 1, 1), previousActive: null).IsSuccess);

        var v2 = Draft(versionNo: 2, new DateOnly(2026, 6, 1));
        Assert.True(v2.Activate(new DateOnly(2026, 6, 1), previousActive: v1).IsSuccess);

        Assert.Equal(RecipeStatus.Archived, v1.Status);
        Assert.Equal(new DateOnly(2026, 5, 31), v1.ValidTo);
        Assert.Equal(RecipeStatus.Active, v2.Status);
        Assert.Null(v2.ValidTo);
    }

    [Theory]
    [InlineData("2026-01-01", true, false)]
    [InlineData("2026-05-31", true, false)]
    [InlineData("2026-06-01", false, true)]
    [InlineData("2026-09-21", false, true)]
    [InlineData("2025-12-31", false, false)]
    public void The_version_effective_on_a_date_is_the_one_whose_window_contains_it(string date, bool firstEffective, bool secondEffective)
    {
        var v1 = Draft(1, new DateOnly(2026, 1, 1));
        v1.Activate(new DateOnly(2026, 1, 1), null);
        var v2 = Draft(2, new DateOnly(2026, 6, 1));
        v2.Activate(new DateOnly(2026, 6, 1), v1);

        var businessDate = DateOnly.Parse(date, System.Globalization.CultureInfo.InvariantCulture);

        Assert.Equal(firstEffective, v1.IsEffectiveOn(businessDate));
        Assert.Equal(secondEffective, v2.IsEffectiveOn(businessDate));
    }

    [Fact]
    public void A_draft_version_is_never_effective()
    {
        var draft = Draft(1, new DateOnly(2026, 1, 1));

        Assert.False(draft.IsEffectiveOn(new DateOnly(2026, 9, 21)));
    }

    [Fact]
    public void An_empty_recipe_cannot_be_activated()
    {
        var recipe = Recipe.CreateDraft(Tenant, MenuItem, 1, new DateOnly(2026, 1, 1), 1m, null, Now, 7).Value;

        var result = recipe.Activate(new DateOnly(2026, 1, 1), null);

        Assert.True(result.IsFailure);
        Assert.Equal("RECIPE_EMPTY", result.Error.Code);
    }

    [Fact]
    public void An_active_version_cannot_be_activated_again()
    {
        var recipe = Draft(1, new DateOnly(2026, 1, 1));
        recipe.Activate(new DateOnly(2026, 1, 1), null);

        var result = recipe.Activate(new DateOnly(2026, 2, 1), null);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
    }

    [Fact]
    public void An_active_version_cannot_be_edited()
    {
        var recipe = Draft(1, new DateOnly(2026, 1, 1));
        recipe.Activate(new DateOnly(2026, 1, 1), null);

        var result = recipe.ReplaceLines([Line(1)]);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", result.Error.Code);
    }

    [Fact]
    public void A_new_version_may_not_start_before_the_one_it_replaces()
    {
        var v1 = Draft(1, new DateOnly(2026, 6, 1));
        v1.Activate(new DateOnly(2026, 6, 1), null);
        var v2 = Draft(2, new DateOnly(2026, 1, 1));

        var result = v2.Activate(new DateOnly(2026, 1, 1), v1);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_RECIPE_LINE", result.Error.Code);
    }

    [Fact]
    public void A_line_pointing_at_its_own_menu_item_is_a_cycle()
    {
        var recipe = Recipe.CreateDraft(Tenant, MenuItem, 1, new DateOnly(2026, 1, 1), 1m, null, Now, 7).Value;
        var self = RecipeLine.Create(Tenant, 1, ComponentType.SubRecipe, null, MenuItem, 1m, 9, 100m, false, 100m, null).Value;

        var result = recipe.ReplaceLines([self]);

        Assert.True(result.IsFailure);
        Assert.Equal("RECIPE_CYCLE", result.Error.Code);
    }

    [Fact]
    public void Duplicate_line_numbers_are_rejected()
    {
        var recipe = Recipe.CreateDraft(Tenant, MenuItem, 1, new DateOnly(2026, 1, 1), 1m, null, Now, 7).Value;

        var result = recipe.ReplaceLines([Line(1), Line(1)]);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_RECIPE_LINE", result.Error.Code);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-5)]
    [InlineData(101)]
    public void An_impossible_yield_percentage_is_rejected(int yieldPct)
    {
        var result = RecipeLine.Create(Tenant, 1, ComponentType.FoodProduct, Lettuce, null, 20m, 1, yieldPct, false, 100m, null);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_RECIPE_LINE", result.Error.Code);
    }

    [Fact]
    public void A_food_product_line_without_a_product_is_rejected()
    {
        var result = RecipeLine.Create(Tenant, 1, ComponentType.FoodProduct, null, null, 20m, 1, 100m, false, 100m, null);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_RECIPE_LINE", result.Error.Code);
    }

    [Fact]
    public void A_sub_recipe_line_without_a_menu_item_is_rejected()
    {
        var result = RecipeLine.Create(Tenant, 1, ComponentType.SubRecipe, null, null, 1m, 9, 100m, false, 100m, null);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_RECIPE_LINE", result.Error.Code);
    }

    [Fact]
    public void The_attach_rate_is_ignored_for_a_mandatory_component()
    {
        var line = RecipeLine.Create(Tenant, 1, ComponentType.FoodProduct, Lettuce, null, 20m, 1, 100m, isOptional: false, attachRatePct: 40m, null).Value;

        Assert.Equal(100m, line.AttachRatePct);
    }

    private static Recipe Draft(ushort versionNo, DateOnly validFrom)
    {
        var recipe = Recipe.CreateDraft(Tenant, MenuItem, versionNo, validFrom, 1m, null, Now, 7).Value;
        recipe.ReplaceLines([Line(1)]);
        return recipe;
    }

    private static RecipeLine Line(ushort lineNo) =>
        RecipeLine.Create(Tenant, lineNo, ComponentType.FoodProduct, Lettuce, null, 20m, 1, 100m, false, 100m, null).Value;
}
