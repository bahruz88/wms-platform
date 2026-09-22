using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.UnitTests;

/// <summary>Spec §10: the cheapest quotation wins by default, and any other choice must be justified in writing.</summary>
public sealed class QuotationRankingTests
{
    private const uint TenantId = 1;

    [Fact]
    public void The_cheapest_is_the_lowest_total_amount_base()
    {
        var quotations = new[]
        {
            new RankedQuotation(1, 1_200m),
            new RankedQuotation(2, 950m),
            new RankedQuotation(3, 1_000m),
        };

        Assert.Equal(2, QuotationRanking.CheapestQuotationId(quotations));
        Assert.True(QuotationRanking.IsCheapest(2, quotations));
        Assert.False(QuotationRanking.IsCheapest(3, quotations));
    }

    [Fact]
    public void A_quotation_without_a_comparable_amount_is_skipped()
    {
        var quotations = new[] { new RankedQuotation(1, null), new RankedQuotation(2, 500m) };

        Assert.Equal(2, QuotationRanking.CheapestQuotationId(quotations));
    }

    [Fact]
    public void A_tie_is_broken_by_the_lowest_id_so_the_answer_is_stable()
    {
        var quotations = new[] { new RankedQuotation(7, 100m), new RankedQuotation(3, 100m) };

        Assert.Equal(3, QuotationRanking.CheapestQuotationId(quotations));
    }

    [Fact]
    public void Selecting_the_cheapest_needs_no_note()
    {
        var justified = QuotationRanking.EnsureSelectionJustified(quotationId: 2, cheapestQuotationId: 2, selectionNote: null);

        Assert.True(justified.IsSuccess);
    }

    [Fact]
    public void Selecting_a_dearer_quotation_without_a_note_is_422_selection_note_required()
    {
        var justified = QuotationRanking.EnsureSelectionJustified(quotationId: 3, cheapestQuotationId: 2, selectionNote: "   ");

        Assert.True(justified.IsFailure);
        Assert.Equal("SELECTION_NOTE_REQUIRED", justified.Error.Code);
        Assert.Equal(422, justified.Error.Status);
    }

    [Fact]
    public void Selecting_a_dearer_quotation_with_a_note_is_allowed()
    {
        var justified = QuotationRanking.EnsureSelectionJustified(3, 2, "Çatdırılma müddəti 2 gün qısadır");

        Assert.True(justified.IsSuccess);
    }

    [Fact]
    public void With_nothing_to_compare_the_choice_is_unconstrained()
    {
        Assert.True(QuotationRanking.EnsureSelectionJustified(1, null, null).IsSuccess);
    }

    [Fact]
    public void The_aggregate_refuses_to_select_a_dearer_quotation_without_a_note()
    {
        var quotation = Quotation
            .Create(TenantId, rfqId: 5, supplierId: 9, "Q-1", new DateOnly(2026, 9, 1), null, "AZN", 1m, 3, null).Value;

        var selected = quotation.Select(isCheapest: false, selectionNote: null);

        Assert.True(selected.IsFailure);
        Assert.Equal("SELECTION_NOTE_REQUIRED", selected.Error.Code);
        Assert.False(quotation.IsSelected);
    }

    [Fact]
    public void The_aggregate_stores_the_note_when_a_dearer_quotation_is_chosen()
    {
        var quotation = Quotation
            .Create(TenantId, rfqId: 5, supplierId: 9, "Q-1", new DateOnly(2026, 9, 1), null, "AZN", 1m, 3, null).Value;

        var selected = quotation.Select(isCheapest: false, selectionNote: "Keyfiyyət sertifikatı var");

        Assert.True(selected.IsSuccess);
        Assert.True(quotation.IsSelected);
        Assert.Equal("Keyfiyyət sertifikatı var", quotation.SelectionNote);
    }

    [Fact]
    public void Unit_prices_are_normalised_to_the_base_uom_and_base_currency_before_they_are_compared()
    {
        // Supplier A quotes 24 AZN per box of 12; supplier B quotes 1.90 USD per piece at 1.70 AZN/USD.
        var boxes = Quotation.Create(TenantId, 1, 10, null, new DateOnly(2026, 9, 1), null, "AZN", 1m, null, null).Value;
        boxes.ReplaceLines([new QuotationLineDraft(ProductId: 5, Qty: 10m, UomId: 2, UnitPrice: 24m, UomFactorToBase: 12m, null, null)]);

        var pieces = Quotation.Create(TenantId, 1, 11, null, new DateOnly(2026, 9, 1), null, "USD", 1.70m, null, null).Value;
        pieces.ReplaceLines([new QuotationLineDraft(ProductId: 5, Qty: 120m, UomId: 1, UnitPrice: 1.90m, UomFactorToBase: 1m, null, null)]);

        Assert.Equal(2m, boxes.Lines[0].UnitPriceBase);
        Assert.Equal(3.23m, pieces.Lines[0].UnitPriceBase);
    }

    [Fact]
    public void The_lowest_cell_of_a_comparison_row_ignores_suppliers_who_did_not_quote_it()
    {
        var cells = new (long QuotationId, decimal? UnitPriceBase)[] { (1, null), (2, 4.10m), (3, 3.95m) };

        Assert.Equal(3, QuotationRanking.LowestUnitPriceQuotationId(cells));
    }
}
