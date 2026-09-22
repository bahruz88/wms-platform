using Wms.Common.Domain;
using Wms.Procurement.Domain.Entities;

namespace Wms.Procurement.Domain.Services;

/// <summary>Who ends up recorded on the step: the acting user, plus the role holder they stood in for.</summary>
public sealed record ApproverIdentity(uint ApproverUserId, uint? DelegatedFromUserId);

/// <summary>A delegation that is in force on the decision date (<c>iam_delegation</c>, spec §7).</summary>
public sealed record ActiveDelegation(uint FromUserId, uint ToUserId, IReadOnlyCollection<string> FromUserRoleCodes);

/// <summary>
/// Decides whether a user may act on an approval step (spec §10, §12.6, TOR §36):
/// <list type="number">
/// <item>the person who raised the document never decides on it — separation of duties;</item>
/// <item>a user holding the step's approver role decides directly;</item>
/// <item>otherwise an in-force delegation from someone who holds that role lets the delegate decide,
/// and the original approver is recorded in <c>delegated_from_user_id</c>.</item>
/// </list>
/// </summary>
public static class ApprovalAuthorization
{
    public static Result<ApproverIdentity> Authorize(
        ApprovalStep step,
        uint actingUserId,
        IReadOnlyCollection<string> actingUserRoleCodes,
        IReadOnlyCollection<ActiveDelegation> delegationsToActingUser,
        uint requestedBy)
    {
        ArgumentNullException.ThrowIfNull(step);
        ArgumentNullException.ThrowIfNull(actingUserRoleCodes);
        ArgumentNullException.ThrowIfNull(delegationsToActingUser);

        // Rule 1 — separation of duties. A user id of 0 means the token carried no iam_user.id yet; in that case
        // the check cannot be made and is not silently passed off as satisfied, it simply does not match.
        if (actingUserId != 0 && actingUserId == requestedBy)
        {
            return ProcurementErrors.SelfApprovalForbidden();
        }

        if (HoldsRole(actingUserRoleCodes, step.ApproverRoleCode))
        {
            return new ApproverIdentity(actingUserId, null);
        }

        // Rule 3 — a delegation only carries the roles the delegating user actually holds.
        foreach (var delegation in delegationsToActingUser)
        {
            if (delegation.ToUserId != actingUserId || delegation.FromUserId == requestedBy)
            {
                continue;
            }

            if (HoldsRole(delegation.FromUserRoleCodes, step.ApproverRoleCode))
            {
                return new ApproverIdentity(actingUserId, delegation.FromUserId);
            }
        }

        return ProcurementErrors.NotAnApprover(step.ApproverRoleCode);
    }

    /// <summary>The role codes a user can decide with: their own plus every role delegated to them.</summary>
    public static IReadOnlyCollection<string> EffectiveRoleCodes(
        IReadOnlyCollection<string> ownRoleCodes,
        IReadOnlyCollection<ActiveDelegation> delegationsToUser)
    {
        ArgumentNullException.ThrowIfNull(ownRoleCodes);
        ArgumentNullException.ThrowIfNull(delegationsToUser);

        var codes = new HashSet<string>(ownRoleCodes, StringComparer.OrdinalIgnoreCase);
        foreach (var delegation in delegationsToUser)
        {
            codes.UnionWith(delegation.FromUserRoleCodes);
        }

        return codes;
    }

    private static bool HoldsRole(IReadOnlyCollection<string> roleCodes, string required) =>
        roleCodes.Contains(required, StringComparer.OrdinalIgnoreCase);
}
