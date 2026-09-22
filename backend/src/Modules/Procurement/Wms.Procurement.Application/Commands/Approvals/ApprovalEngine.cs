using Wms.Common.Application.Abstractions;
using Wms.Common.Contracts.Events;
using Wms.Common.Domain;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.Application.Commands.Approvals;

/// <summary>What one decision changed: the step, and whether the whole chain finished.</summary>
public sealed record ApprovalDecisionOutcome(ApprovalInstance Instance, byte StepNo, bool IsFinalApproval, bool IsRejected);

/// <summary>
/// The parametric approval engine of spec §10 / TOR §10, §36. It owns three things:
/// picking the chain from <c>proc_approval_rule</c>, authorising the acting user against the current step
/// (role or in-force <c>iam_delegation</c>), and recording the decision on <c>proc_approval_step</c>.
/// What the decision means for the underlying document is the caller's business.
/// </summary>
public sealed class ApprovalEngine(
    IApprovalRuleRepository rules,
    IApprovalInstanceRepository instances,
    IApprovalDirectory directory,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock)
{
    /// <summary>Selects the chain for an amount and opens a <c>proc_approval_instance</c>.</summary>
    public async Task<Result<ApprovalInstance>> StartAsync(
        ApprovalDocType docType,
        long docId,
        string docNo,
        decimal amountBase,
        ApprovalProductType productType,
        uint requestedBy,
        CancellationToken cancellationToken)
    {
        var tenantId = tenantContext.TenantId;
        var candidates = await rules.ListAsync(tenantId, docType, activeOnly: true, cancellationToken).ConfigureAwait(false);

        var chain = ApprovalRuleSelector.Select(candidates, docType, amountBase, productType);
        if (chain.IsFailure)
        {
            return chain.Error;
        }

        // The requester's name is captured here, from the token, because the inbox has to say who is waiting
        // and Procurement may not read iam_user (spec §5).
        var instance = ApprovalInstance.Start(
            tenantId, docType, docId, docNo, amountBase, requestedBy, chain.Value, currentUser.Username);
        if (instance.IsFailure)
        {
            return instance.Error;
        }

        instances.Add(instance.Value);
        return instance;
    }

    /// <summary>
    /// Records the acting user's decision on the current step. <paramref name="expectedStepNo"/> (contract:
    /// <c>ApprovalDecision.expectedStepNo</c>) guards against deciding from a stale screen.
    /// </summary>
    public async Task<Result<ApprovalDecisionOutcome>> DecideAsync(
        ApprovalInstance instance,
        ApprovalDecision decision,
        string? comment,
        int? expectedStepNo,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(instance);

        var step = instance.CurrentPendingStep();
        if (step is null)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(ApprovalInstance), instance.Status.ToString(), decision.ToString());
        }

        if (expectedStepNo is { } expected && expected != step.StepNo)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(ApprovalStep), $"step {step.StepNo}", $"step {expected}");
        }

        var actingUserId = currentUser.UserId;
        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var ownRoles = await ResolveRoleCodesAsync(actingUserId, cancellationToken).ConfigureAwait(false);
        var delegations = await directory.GetDelegationsToAsync(actingUserId, today, cancellationToken).ConfigureAwait(false);

        var authorized = ApprovalAuthorization.Authorize(step, actingUserId, ownRoles, delegations, instance.RequestedBy);
        if (authorized.IsFailure)
        {
            return authorized.Error;
        }

        var decided = instance.Decide(
            step.StepNo,
            decision,
            authorized.Value.ApproverUserId,
            clock.UtcNow,
            authorized.Value.DelegatedFromUserId,
            comment,
            // Only the acting principal's own name is knowable here; a delegation records the id of the person
            // it came from, whose name the delegating user's own decision would have carried.
            authorized.Value.ApproverUserId == actingUserId ? currentUser.Username : null);
        if (decided.IsFailure)
        {
            return decided.Error;
        }

        return Result.Success(new ApprovalDecisionOutcome(
            instance,
            step.StepNo,
            instance.Status == ApprovalStatus.Approved,
            instance.Status == ApprovalStatus.Rejected));
    }

    /// <summary>
    /// Role codes of the acting user. The directory is the authority; when it knows nothing about the user
    /// (for example because <c>iam_user</c> is not populated yet) the realm roles from the token are used.
    /// </summary>
    public async Task<IReadOnlyCollection<string>> ResolveRoleCodesAsync(uint userId, CancellationToken cancellationToken)
    {
        var fromDirectory = await directory.GetRoleCodesAsync(userId, cancellationToken).ConfigureAwait(false);
        return fromDirectory.Count > 0 ? fromDirectory : currentUser.Roles;
    }

    public Task<IReadOnlyList<ActiveDelegation>> ResolveDelegationsAsync(uint userId, CancellationToken cancellationToken) =>
        directory.GetDelegationsToAsync(userId, DateOnly.FromDateTime(clock.UtcNow.UtcDateTime), cancellationToken);

    /// <summary>The <c>PurchaseOrderApproved</c> integration event of spec §14.2.</summary>
    public PurchaseOrderApproved BuildPurchaseOrderApproved(PurchaseOrder purchaseOrder)
    {
        ArgumentNullException.ThrowIfNull(purchaseOrder);
        return new PurchaseOrderApproved(
            purchaseOrder.TenantId,
            clock.UtcNow,
            purchaseOrder.Id,
            purchaseOrder.DocNo,
            purchaseOrder.SupplierId,
            purchaseOrder.Currency,
            purchaseOrder.TotalAmount,
            purchaseOrder.TotalAmountBase,
            currentUser.UserId);
    }
}
