using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.UnitTests;

/// <summary>Spec §10 / §12.6 / TOR §36: who may decide a step — the role holder, or the user they delegated to.</summary>
public sealed class ApprovalAuthorizationTests
{
    private const uint TenantId = 1;
    private const uint Requester = 100;
    private const uint Manager = 200;
    private const uint Deputy = 300;
    private const uint Stranger = 400;

    [Fact]
    public void The_role_holder_decides_directly_and_no_delegation_is_recorded()
    {
        var step = Step("PROCUREMENT_MANAGER");

        var authorized = ApprovalAuthorization.Authorize(step, Manager, ["PROCUREMENT_MANAGER"], [], Requester);

        Assert.True(authorized.IsSuccess);
        Assert.Equal(Manager, authorized.Value.ApproverUserId);
        Assert.Null(authorized.Value.DelegatedFromUserId);
    }

    [Fact]
    public void A_delegate_of_the_role_holder_may_decide_and_the_original_approver_is_recorded()
    {
        var step = Step("PROCUREMENT_MANAGER");
        var delegations = new[] { new ActiveDelegation(Manager, Deputy, ["PROCUREMENT_MANAGER"]) };

        var authorized = ApprovalAuthorization.Authorize(step, Deputy, ["BRANCH_USER"], delegations, Requester);

        Assert.True(authorized.IsSuccess);
        Assert.Equal(Deputy, authorized.Value.ApproverUserId);
        Assert.Equal(Manager, authorized.Value.DelegatedFromUserId);
    }

    [Fact]
    public void A_delegation_only_carries_the_roles_the_delegator_actually_holds()
    {
        var step = Step("ADMIN");
        var delegations = new[] { new ActiveDelegation(Manager, Deputy, ["PROCUREMENT_MANAGER"]) };

        var authorized = ApprovalAuthorization.Authorize(step, Deputy, ["BRANCH_USER"], delegations, Requester);

        Assert.True(authorized.IsFailure);
        Assert.Equal(403, authorized.Error.Status);
        Assert.Equal("FORBIDDEN", authorized.Error.Code);
    }

    [Fact]
    public void A_delegation_addressed_to_somebody_else_does_not_help()
    {
        var step = Step("PROCUREMENT_MANAGER");
        var delegations = new[] { new ActiveDelegation(Manager, Deputy, ["PROCUREMENT_MANAGER"]) };

        var authorized = ApprovalAuthorization.Authorize(step, Stranger, [], delegations, Requester);

        Assert.True(authorized.IsFailure);
    }

    [Fact]
    public void The_requester_can_never_decide_their_own_document_even_with_the_role()
    {
        var step = Step("PROCUREMENT_MANAGER");

        var authorized = ApprovalAuthorization.Authorize(step, Requester, ["PROCUREMENT_MANAGER", "ADMIN"], [], Requester);

        Assert.True(authorized.IsFailure);
        Assert.Equal("SELF_APPROVAL_FORBIDDEN", authorized.Error.Code);
        Assert.Equal(403, authorized.Error.Status);
    }

    [Fact]
    public void A_delegation_from_the_requester_cannot_be_used_to_approve_their_own_document()
    {
        var step = Step("PROCUREMENT_MANAGER");
        var delegations = new[] { new ActiveDelegation(Requester, Deputy, ["PROCUREMENT_MANAGER"]) };

        var authorized = ApprovalAuthorization.Authorize(step, Deputy, [], delegations, Requester);

        Assert.True(authorized.IsFailure);
        Assert.Equal("FORBIDDEN", authorized.Error.Code);
    }

    [Fact]
    public void Role_matching_is_case_insensitive()
    {
        var step = Step("PROCUREMENT_MANAGER");

        Assert.True(ApprovalAuthorization.Authorize(step, Manager, ["procurement_manager"], [], Requester).IsSuccess);
    }

    [Fact]
    public void Effective_role_codes_merge_own_roles_with_every_delegated_role()
    {
        var delegations = new[]
        {
            new ActiveDelegation(Manager, Deputy, ["PROCUREMENT_MANAGER"]),
            new ActiveDelegation(Stranger, Deputy, ["ADMIN", "PROCUREMENT_MANAGER"]),
        };

        var effective = ApprovalAuthorization.EffectiveRoleCodes(["BRANCH_USER"], delegations);

        Assert.Equal(3, effective.Count);
        Assert.Contains("BRANCH_USER", effective);
        Assert.Contains("PROCUREMENT_MANAGER", effective);
        Assert.Contains("ADMIN", effective);
    }

    [Fact]
    public void The_instance_records_the_delegation_on_the_step_it_decided()
    {
        var rules = new[] { ApprovalRuleSelectorTests.Rule(step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER") };
        var instance = ApprovalInstance.Start(TenantId, ApprovalDocType.Po, 5, "PO-2026-00001", 900m, Requester, rules).Value;

        var decided = instance.Decide(1, ApprovalDecision.Approved, Deputy, DateTimeOffset.UnixEpoch, Manager, "təsdiq");

        Assert.True(decided.IsSuccess);
        Assert.Equal(ApprovalStatus.Approved, instance.Status);
        Assert.Equal(Deputy, instance.Steps[0].ApproverUserId);
        Assert.Equal(Manager, instance.Steps[0].DelegatedFromUserId);
    }

    private static ApprovalStep Step(string roleCode)
    {
        var rules = new[] { ApprovalRuleSelectorTests.Rule(step: 1, min: 0m, max: null, role: roleCode) };
        var instance = ApprovalInstance.Start(TenantId, ApprovalDocType.Po, 1, "PO-2026-00001", 100m, Requester, rules);
        return instance.Value.Steps[0];
    }
}
