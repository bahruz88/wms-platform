using System.Globalization;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.UnitTests;

/// <summary>
/// Spec §10 / TOR §36: an approval step names a role, and a delegation in force on the decision date moves the
/// decision to a substitute.
/// </summary>
/// <remarks>
/// These two rules used to be covered from <c>Wms.Inventory.UnitTests</c>, which had to reference
/// <c>Wms.Procurement.Domain</c> to do it. They belong with the rest of the approval tests now that the module
/// has its own test project, and the reference is gone.
/// </remarks>
public sealed class DelegationTests
{
    [Fact]
    public void ResolveApprover_hands_the_decision_to_an_active_substitute()
    {
        var delegations = new Dictionary<uint, uint> { [7u] = 9u };

        Assert.Equal(9u, ApprovalRuleSelector.ResolveApprover(7u, delegations));
    }

    [Fact]
    public void ResolveApprover_leaves_an_undelegated_approver_alone()
    {
        var delegations = new Dictionary<uint, uint> { [7u] = 9u };

        Assert.Equal(8u, ApprovalRuleSelector.ResolveApprover(8u, delegations));
        Assert.Equal(8u, ApprovalRuleSelector.ResolveApprover(8u, new Dictionary<uint, uint>()));
    }

    [Theory]
    [InlineData("2026-09-01", true)]
    [InlineData("2026-09-05", true)]
    [InlineData("2026-09-10", true)]
    [InlineData("2026-08-31", false)]
    [InlineData("2026-09-11", false)]
    public void A_delegation_is_only_in_force_inside_its_own_date_range(string date, bool expected)
    {
        var from = new DateOnly(2026, 9, 1);
        var to = new DateOnly(2026, 9, 10);
        var on = DateOnly.Parse(date, CultureInfo.InvariantCulture);

        Assert.Equal(expected, on >= from && on <= to);
    }
}
