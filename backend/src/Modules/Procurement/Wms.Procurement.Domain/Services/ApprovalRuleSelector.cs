using Wms.Common.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Services;

/// <summary>Picks the approval chain for a document by base amount and product type (spec §10, tested per §17.1).</summary>
public static class ApprovalRuleSelector
{
    public static Result<IReadOnlyList<ApprovalRule>> Select(
        IEnumerable<ApprovalRule> rules,
        string docType,
        decimal amountBase,
        ApprovalProductType productType)
    {
        ArgumentNullException.ThrowIfNull(rules);
        ArgumentException.ThrowIfNullOrWhiteSpace(docType);

        var matching = rules
            .Where(r => r.Matches(docType, amountBase, productType))
            .OrderBy(r => r.StepNo)
            // A rule that names the exact product type beats an ANY rule for the same step.
            .ThenBy(r => r.ProductType == ApprovalProductType.Any ? 1 : 0)
            .GroupBy(r => r.StepNo)
            .Select(g => g.First())
            .ToList();

        if (matching.Count == 0)
        {
            return ProcurementErrors.NoApprovalRule(amountBase);
        }

        return matching;
    }

    /// <summary>Resolves an active delegation: returns the user who may actually decide on behalf of <paramref name="approverUserId"/>.</summary>
    public static uint ResolveApprover(uint approverUserId, IReadOnlyDictionary<uint, uint> activeDelegations)
    {
        ArgumentNullException.ThrowIfNull(activeDelegations);
        return activeDelegations.TryGetValue(approverUserId, out var delegate_) ? delegate_ : approverUserId;
    }
}
