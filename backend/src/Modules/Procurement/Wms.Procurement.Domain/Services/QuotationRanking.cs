using Wms.Common.Domain;

namespace Wms.Procurement.Domain.Services;

/// <summary>One column of the comparison matrix, reduced to what the ranking needs.</summary>
public sealed record RankedQuotation(long QuotationId, decimal? TotalAmountBase);

/// <summary>
/// The "cheapest offer" rule of spec §10 / <c>procurement.v1.yaml</c>: the cheapest quotation of an RFQ is the
/// one with the lowest <c>total_amount_base</c>, and choosing any other one requires a written justification.
/// </summary>
public static class QuotationRanking
{
    /// <summary>
    /// The cheapest quotation of an RFQ, or <c>null</c> when nothing can be compared. A tie is broken by the
    /// lowest id so the answer is stable between calls.
    /// </summary>
    public static long? CheapestQuotationId(IEnumerable<RankedQuotation> quotations)
    {
        ArgumentNullException.ThrowIfNull(quotations);

        return quotations
            .Where(q => q.TotalAmountBase is >= 0m)
            .OrderBy(q => q.TotalAmountBase!.Value)
            .ThenBy(q => q.QuotationId)
            .Select(q => (long?)q.QuotationId)
            .FirstOrDefault();
    }

    public static bool IsCheapest(long quotationId, IEnumerable<RankedQuotation> quotations) =>
        CheapestQuotationId(quotations) == quotationId;

    /// <summary>
    /// <c>422 SELECTION_NOTE_REQUIRED</c> when a quotation other than the cheapest is selected without a note.
    /// When there is no comparable quotation at all, the choice is unconstrained.
    /// </summary>
    public static Result EnsureSelectionJustified(long quotationId, long? cheapestQuotationId, string? selectionNote)
    {
        if (cheapestQuotationId is null || cheapestQuotationId == quotationId)
        {
            return Result.Success();
        }

        return string.IsNullOrWhiteSpace(selectionNote)
            ? ProcurementErrors.SelectionNoteRequired()
            : Result.Success();
    }

    /// <summary>Per-row winner of the matrix: the lowest <c>unit_price_base</c> among the cells of one RFQ line.</summary>
    public static long? LowestUnitPriceQuotationId(IEnumerable<(long QuotationId, decimal? UnitPriceBase)> cells)
    {
        ArgumentNullException.ThrowIfNull(cells);

        return cells
            .Where(c => c.UnitPriceBase is >= 0m)
            .OrderBy(c => c.UnitPriceBase!.Value)
            .ThenBy(c => c.QuotationId)
            .Select(c => (long?)c.QuotationId)
            .FirstOrDefault();
    }
}
