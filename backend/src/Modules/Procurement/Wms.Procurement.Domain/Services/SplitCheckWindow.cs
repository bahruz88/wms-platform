using System.Globalization;
using Wms.Common.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Services;

/// <summary>Outcome of the PR-splitting control for one new purchase order.</summary>
public sealed record SplitCheckOutcome(
    bool IsTriggered,
    DateOnly WindowStart,
    DateOnly WindowEnd,
    decimal PriorAmountBase,
    decimal CumulativeAmountBase,
    byte StepsForSingle,
    byte StepsForCumulative,
    string? Warning);

/// <summary>
/// <c>proc_split_check_log</c> (spec §10, flagged there as a segregation-of-duties risk the TOR missed).
/// A requester can stay under an approval threshold by cutting one purchase into several small orders to the
/// same supplier. The control accumulates every order of that supplier over a rolling window and fires when the
/// cumulative amount would need a longer approval chain than the single new order does on its own.
/// </summary>
public static class SplitCheckWindow
{
    /// <summary>Length of the rolling window in days, unless the tenant configures another value.</summary>
    public const int DefaultWindowDays = 30;

    /// <summary>First day of the window ending on <paramref name="docDate"/> (inclusive on both ends).</summary>
    public static DateOnly StartOf(DateOnly docDate, int windowDays) =>
        docDate.AddDays(-(Math.Max(1, windowDays) - 1));

    public static SplitCheckOutcome Evaluate(
        IEnumerable<ApprovalRule> rules,
        ProductType productType,
        DateOnly docDate,
        int windowDays,
        decimal newOrderAmountBase,
        decimal priorAmountBase)
    {
        ArgumentNullException.ThrowIfNull(rules);

        var ruleList = rules as IReadOnlyList<ApprovalRule> ?? rules.ToList();
        var windowStart = StartOf(docDate, windowDays);
        var cumulative = Quantity.Round(priorAmountBase + newOrderAmountBase, Money.StorageDecimals);
        var ruleProductType = ApprovalProductTypes.From(productType);

        var stepsForSingle = (byte)ApprovalRuleSelector
            .Match(ruleList, ApprovalDocType.Po, newOrderAmountBase, ruleProductType).Count;
        var stepsForCumulative = (byte)ApprovalRuleSelector
            .Match(ruleList, ApprovalDocType.Po, cumulative, ruleProductType).Count;

        var triggered = priorAmountBase > 0m && stepsForCumulative > stepsForSingle;
        var warning = triggered
            ? string.Create(
                CultureInfo.InvariantCulture,
                $"PR bölünməsi şübhəsi: {windowStart:yyyy-MM-dd}..{docDate:yyyy-MM-dd} aralığında bu təchizatçı üzrə kumulyativ məbləğ {cumulative:0.00} AZN-dir və {stepsForCumulative} təsdiq addımı tələb edir; tək sifariş ({newOrderAmountBase:0.00} AZN) yalnız {stepsForSingle} addım tələb edir.")
            : null;

        return new SplitCheckOutcome(
            triggered,
            windowStart,
            docDate,
            Quantity.Round(priorAmountBase, Money.StorageDecimals),
            cumulative,
            stepsForSingle,
            stepsForCumulative,
            warning);
    }
}
