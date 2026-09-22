using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.UnitTests;

/// <summary>
/// Spec §10 (<c>proc_split_check_log</c>, flagged there as an SoD risk): a buyer must not be able to stay
/// under an approval threshold by splitting one purchase into several small orders to the same supplier.
/// </summary>
public sealed class SplitCheckWindowTests
{
    private static readonly DateOnly DocDate = new(2026, 9, 21);

    private static readonly ApprovalRule[] TwoBandRules =
    [
        ApprovalRuleSelectorTests.Rule(step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER"),
        ApprovalRuleSelectorTests.Rule(step: 2, min: 5_000m, max: null, role: "ADMIN"),
    ];

    [Fact]
    public void The_window_is_inclusive_on_both_ends()
    {
        Assert.Equal(new DateOnly(2026, 8, 23), SplitCheckWindow.StartOf(DocDate, 30));
        Assert.Equal(DocDate, SplitCheckWindow.StartOf(DocDate, 1));
        Assert.Equal(DocDate, SplitCheckWindow.StartOf(DocDate, 0));
    }

    [Fact]
    public void A_single_large_order_is_not_a_split_even_though_it_needs_two_steps()
    {
        var outcome = SplitCheckWindow.Evaluate(TwoBandRules, ProductType.Food, DocDate, 30, newOrderAmountBase: 9_000m, priorAmountBase: 0m);

        Assert.False(outcome.IsTriggered);
        Assert.Equal(2, outcome.StepsForSingle);
        Assert.Equal(2, outcome.StepsForCumulative);
        Assert.Null(outcome.Warning);
    }

    [Fact]
    public void Several_small_orders_that_together_cross_the_threshold_are_flagged()
    {
        var outcome = SplitCheckWindow.Evaluate(TwoBandRules, ProductType.Food, DocDate, 30, newOrderAmountBase: 1_500m, priorAmountBase: 4_000m);

        Assert.True(outcome.IsTriggered);
        Assert.Equal(1, outcome.StepsForSingle);
        Assert.Equal(2, outcome.StepsForCumulative);
        Assert.Equal(5_500m, outcome.CumulativeAmountBase);
        Assert.Equal(new DateOnly(2026, 8, 23), outcome.WindowStart);
        Assert.Equal(DocDate, outcome.WindowEnd);
        Assert.NotNull(outcome.Warning);
    }

    [Fact]
    public void Staying_under_the_threshold_in_total_is_not_flagged()
    {
        var outcome = SplitCheckWindow.Evaluate(TwoBandRules, ProductType.Food, DocDate, 30, newOrderAmountBase: 500m, priorAmountBase: 1_000m);

        Assert.False(outcome.IsTriggered);
        Assert.Equal(1_500m, outcome.CumulativeAmountBase);
    }

    [Fact]
    public void Exactly_reaching_the_threshold_trips_the_control()
    {
        var outcome = SplitCheckWindow.Evaluate(TwoBandRules, ProductType.Food, DocDate, 30, newOrderAmountBase: 2_500m, priorAmountBase: 2_500m);

        Assert.True(outcome.IsTriggered);
        Assert.Equal(5_000m, outcome.CumulativeAmountBase);
    }

    [Fact]
    public void The_first_order_of_a_window_can_never_be_a_split()
    {
        var outcome = SplitCheckWindow.Evaluate(TwoBandRules, ProductType.NonFood, DocDate, 30, newOrderAmountBase: 4_999m, priorAmountBase: 0m);

        Assert.False(outcome.IsTriggered);
    }

    [Fact]
    public void Without_a_second_approval_band_nothing_can_be_circumvented()
    {
        ApprovalRule[] oneBand = [ApprovalRuleSelectorTests.Rule(step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER")];

        var outcome = SplitCheckWindow.Evaluate(oneBand, ProductType.Food, DocDate, 30, newOrderAmountBase: 1_000m, priorAmountBase: 90_000m);

        Assert.False(outcome.IsTriggered);
        Assert.Equal(1, outcome.StepsForSingle);
        Assert.Equal(1, outcome.StepsForCumulative);
    }

    [Fact]
    public void The_product_type_selects_which_bands_apply()
    {
        ApprovalRule[] foodOnly =
        [
            ApprovalRuleSelectorTests.Rule(step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER"),
            ApprovalRuleSelectorTests.Rule(step: 2, min: 5_000m, max: null, role: "FOOD_DIRECTOR", productType: ApprovalProductType.Food),
        ];

        var food = SplitCheckWindow.Evaluate(foodOnly, ProductType.Food, DocDate, 30, 1_500m, 4_000m);
        var nonFood = SplitCheckWindow.Evaluate(foodOnly, ProductType.NonFood, DocDate, 30, 1_500m, 4_000m);

        Assert.True(food.IsTriggered);
        Assert.False(nonFood.IsTriggered);
    }

    [Fact]
    public void The_log_row_keeps_the_window_the_amounts_and_both_step_counts()
    {
        var outcome = SplitCheckWindow.Evaluate(TwoBandRules, ProductType.Food, DocDate, 30, 1_500m, 4_000m);

        var log = SplitCheckLog.Record(
            tenantId: 1, supplierId: 7, outcome.WindowStart, outcome.WindowEnd, outcome.CumulativeAmountBase,
            triggeredAmountBase: 1_500m, triggeredPoId: null, outcome.StepsForSingle, outcome.StepsForCumulative,
            outcome.Warning, DateTimeOffset.UnixEpoch, createdBy: 3);
        log.AttachPurchaseOrder(42);

        Assert.Equal(7u, log.SupplierId);
        Assert.Equal(5_500m, log.CumulativeAmountBase);
        Assert.Equal(1_500m, log.TriggeredAmountBase);
        Assert.Equal(42, log.TriggeredPoId);
        Assert.Equal(1, log.StepsForSingle);
        Assert.Equal(2, log.StepsForCumulative);
    }
}
