using Wms.Common.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Services;

/// <summary>Picks the approval chain for a document by base amount and product type (spec §10, tested per §17.1).</summary>
public static class ApprovalRuleSelector
{
    public static Result<IReadOnlyList<ApprovalRule>> Select(
        IEnumerable<ApprovalRule> rules,
        ApprovalDocType docType,
        decimal amountBase,
        ApprovalProductType productType)
    {
        ArgumentNullException.ThrowIfNull(rules);

        var matching = Match(rules, docType, amountBase, productType);
        if (matching.Count == 0)
        {
            return ProcurementErrors.NoApprovalRule(amountBase);
        }

        return Result.Success(matching);
    }

    /// <summary>
    /// The matching chain without the "no rule" failure — used by the split-check control, which compares the
    /// length of two chains and treats "no chain" as zero steps.
    /// </summary>
    public static IReadOnlyList<ApprovalRule> Match(
        IEnumerable<ApprovalRule> rules,
        ApprovalDocType docType,
        decimal amountBase,
        ApprovalProductType productType)
    {
        ArgumentNullException.ThrowIfNull(rules);

        return rules
            .Where(r => r.Matches(docType, amountBase, productType))
            .OrderBy(r => r.StepNo)
            // A rule that names the exact product type beats an ANY rule for the same step.
            .ThenBy(r => r.ProductType == ApprovalProductType.Any ? 1 : 0)
            // Then the narrowest band wins, so a specific 0..1000 rule beats a catch-all 0..unlimited one.
            .ThenBy(r => r.MaxAmountBase ?? decimal.MaxValue)
            .ThenByDescending(r => r.MinAmountBase)
            .ThenBy(r => r.Id)
            .GroupBy(r => r.StepNo)
            .Select(g => g.First())
            .ToList();
    }

    /// <summary>Resolves an active delegation: returns the user who may actually decide on behalf of <paramref name="approverUserId"/>.</summary>
    public static uint ResolveApprover(uint approverUserId, IReadOnlyDictionary<uint, uint> activeDelegations)
    {
        ArgumentNullException.ThrowIfNull(activeDelegations);
        return activeDelegations.TryGetValue(approverUserId, out var substitute) ? substitute : approverUserId;
    }
}
