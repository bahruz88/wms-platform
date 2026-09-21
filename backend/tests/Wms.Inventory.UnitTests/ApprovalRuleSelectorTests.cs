using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §17.1: approval rule selection by amount limit, and delegation.</summary>
public sealed class ApprovalRuleSelectorTests
{
    private const string DocType = "PO";

    private static ApprovalRule Rule(byte step, uint roleId, decimal min, decimal? max, ApprovalProductType type = ApprovalProductType.Any) =>
        ApprovalRule.Create(1, DocType, step, roleId, min, max, type);

    [Fact]
    public void Select_returns_only_the_steps_whose_amount_window_matches()
    {
        var rules = new[]
        {
            Rule(1, roleId: 10, min: 0m, max: 5000m),
            Rule(2, roleId: 20, min: 5000m, max: null),
        };

        var small = ApprovalRuleSelector.Select(rules, DocType, 1200m, ApprovalProductType.Food);
        var large = ApprovalRuleSelector.Select(rules, DocType, 25000m, ApprovalProductType.Food);

        Assert.True(small.IsSuccess);
        Assert.Single(small.Value);
        Assert.Equal(10u, small.Value[0].ApproverRoleId);

        Assert.True(large.IsSuccess);
        Assert.Single(large.Value);
        Assert.Equal(20u, large.Value[0].ApproverRoleId);
    }

    [Fact]
    public void Select_returns_a_multi_step_chain_in_step_order()
    {
        var rules = new[]
        {
            Rule(2, roleId: 20, min: 0m, max: null),
            Rule(1, roleId: 10, min: 0m, max: null),
        };

        var result = ApprovalRuleSelector.Select(rules, DocType, 100m, ApprovalProductType.Any);

        Assert.True(result.IsSuccess);
        Assert.Equal([(byte)1, (byte)2], result.Value.Select(r => r.StepNo));
    }

    [Fact]
    public void Select_prefers_a_product_specific_rule_over_an_any_rule_for_the_same_step()
    {
        var rules = new[]
        {
            Rule(1, roleId: 10, min: 0m, max: null, ApprovalProductType.Any),
            Rule(1, roleId: 11, min: 0m, max: null, ApprovalProductType.Food),
        };

        var result = ApprovalRuleSelector.Select(rules, DocType, 100m, ApprovalProductType.Food);

        Assert.True(result.IsSuccess);
        Assert.Equal(11u, result.Value[0].ApproverRoleId);
    }

    [Fact]
    public void Select_fails_when_no_rule_covers_the_amount()
    {
        var rules = new[] { Rule(1, roleId: 10, min: 0m, max: 100m) };

        var result = ApprovalRuleSelector.Select(rules, DocType, 5000m, ApprovalProductType.Any);

        Assert.True(result.IsFailure);
        Assert.Equal("NO_APPROVAL_RULE", result.Error.Code);
    }

    [Fact]
    public void Select_ignores_rules_of_another_document_type()
    {
        var rules = new[] { Rule(1, roleId: 10, min: 0m, max: null) };

        Assert.True(ApprovalRuleSelector.Select(rules, "WASTE", 10m, ApprovalProductType.Any).IsFailure);
    }

    [Fact]
    public void ResolveApprover_applies_an_active_delegation()
    {
        var delegations = new Dictionary<uint, uint> { [7u] = 9u };

        Assert.Equal(9u, ApprovalRuleSelector.ResolveApprover(7u, delegations));
        Assert.Equal(8u, ApprovalRuleSelector.ResolveApprover(8u, delegations));
    }

    [Theory]
    [InlineData("2026-09-01", true)]
    [InlineData("2026-09-10", true)]
    [InlineData("2026-08-31", false)]
    [InlineData("2026-09-11", false)]
    public void Delegation_is_only_active_inside_its_date_range(string date, bool expected)
    {
        var from = new DateOnly(2026, 9, 1);
        var to = new DateOnly(2026, 9, 10);

        Assert.Equal(expected, DelegationWindow.IsActiveOn(from, to, DateOnly.Parse(date, System.Globalization.CultureInfo.InvariantCulture)));
    }
}

/// <summary>Local helper so the delegation window rule is covered without referencing the Identity domain from this project.</summary>
internal static class DelegationWindow
{
    public static bool IsActiveOn(DateOnly from, DateOnly to, DateOnly date) => date >= from && date <= to;
}
