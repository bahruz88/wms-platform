using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.UnitTests;

/// <summary>Spec §10 / §17.1: the approval chain is chosen by document type, product type and AZN amount band.</summary>
public sealed class ApprovalRuleSelectorTests
{
    private const uint TenantId = 1;

    [Fact]
    public void An_amount_inside_one_band_selects_that_bands_single_step()
    {
        var rules = new[]
        {
            Rule(step: 1, min: 0m, max: 1_000m, role: "PROCUREMENT_MANAGER"),
            Rule(step: 1, min: 1_000.01m, max: null, role: "ADMIN"),
        };

        var chain = ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 750m, ApprovalProductType.Food);

        Assert.True(chain.IsSuccess);
        Assert.Single(chain.Value);
        Assert.Equal("PROCUREMENT_MANAGER", chain.Value[0].ApproverRoleCode);
    }

    [Fact]
    public void A_larger_amount_adds_the_second_step()
    {
        var rules = new[]
        {
            Rule(step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER"),
            Rule(step: 2, min: 5_000m, max: null, role: "ADMIN"),
        };

        var small = ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 4_999.99m, ApprovalProductType.NonFood);
        var large = ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 5_000m, ApprovalProductType.NonFood);

        Assert.Single(small.Value);
        Assert.Equal(2, large.Value.Count);
        Assert.Equal(new byte[] { 1, 2 }, large.Value.Select(r => r.StepNo).ToArray());
    }

    [Fact]
    public void Band_boundaries_are_inclusive_on_both_ends()
    {
        var rules = new[] { Rule(step: 1, min: 100m, max: 200m, role: "PROCUREMENT_MANAGER") };

        Assert.True(ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 100m, ApprovalProductType.Any).IsSuccess);
        Assert.True(ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 200m, ApprovalProductType.Any).IsSuccess);
        Assert.True(ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 200.01m, ApprovalProductType.Any).IsFailure);
    }

    [Fact]
    public void A_rule_naming_the_product_type_beats_an_any_rule_on_the_same_step()
    {
        var rules = new[]
        {
            Rule(step: 1, min: 0m, max: null, role: "GENERIC", productType: ApprovalProductType.Any),
            Rule(step: 1, min: 0m, max: null, role: "FOOD_MANAGER", productType: ApprovalProductType.Food),
        };

        var chain = ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 10m, ApprovalProductType.Food);

        Assert.Single(chain.Value);
        Assert.Equal("FOOD_MANAGER", chain.Value[0].ApproverRoleCode);
    }

    [Fact]
    public void A_rule_of_another_product_type_never_matches()
    {
        var rules = new[] { Rule(step: 1, min: 0m, max: null, role: "FOOD_MANAGER", productType: ApprovalProductType.Food) };

        var chain = ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 10m, ApprovalProductType.NonFood);

        Assert.True(chain.IsFailure);
        Assert.Equal("NO_APPROVAL_RULE", chain.Error.Code);
    }

    [Fact]
    public void A_rule_of_another_document_type_never_matches()
    {
        var rules = new[] { Rule(step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER", docType: ApprovalDocType.Waste) };

        Assert.True(ApprovalRuleSelector.Select(rules, ApprovalDocType.Po, 10m, ApprovalProductType.Any).IsFailure);
        Assert.True(ApprovalRuleSelector.Select(rules, ApprovalDocType.Waste, 10m, ApprovalProductType.Any).IsSuccess);
    }

    [Fact]
    public void An_inactive_rule_is_ignored()
    {
        var active = Rule(step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER");
        var inactive = Rule(step: 2, min: 0m, max: null, role: "ADMIN");
        inactive.Update(ApprovalDocType.Po, ApprovalProductType.Any, 0m, null, 2, 9, "ADMIN", isActive: false);

        var chain = ApprovalRuleSelector.Select([active, inactive], ApprovalDocType.Po, 10m, ApprovalProductType.Any);

        Assert.Single(chain.Value);
        Assert.Equal((byte)1, chain.Value[0].StepNo);
    }

    [Fact]
    public void No_matching_rule_is_a_422_with_the_contracts_error_field()
    {
        var chain = ApprovalRuleSelector.Select([], ApprovalDocType.Po, 10m, ApprovalProductType.Any);

        Assert.True(chain.IsFailure);
        Assert.Equal(422, chain.Error.Status);
        Assert.NotNull(chain.Error.Details);
        Assert.Equal(["Qayda tapılmadı"], chain.Error.Details!["approval"]);
    }

    [Fact]
    public void Match_returns_an_empty_chain_instead_of_failing()
    {
        Assert.Empty(ApprovalRuleSelector.Match([], ApprovalDocType.Po, 10m, ApprovalProductType.Any));
    }

    internal static ApprovalRule Rule(
        byte step,
        decimal min,
        decimal? max,
        string role,
        ApprovalProductType productType = ApprovalProductType.Any,
        ApprovalDocType docType = ApprovalDocType.Po)
    {
        var created = ApprovalRule.Create(TenantId, docType, step, approverRoleId: (uint)(step + 10), role, min, max, productType);
        Assert.True(created.IsSuccess, created.IsFailure ? created.Error.Message : string.Empty);
        return created.Value;
    }
}
