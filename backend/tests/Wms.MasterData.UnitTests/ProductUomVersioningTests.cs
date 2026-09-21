using Wms.MasterData.Domain.Entities;

namespace Wms.MasterData.UnitTests;

/// <summary>
/// Spec §12.1: <c>master_product_uom.factor_to_base</c> is never UPDATEd. A changed factor closes the open row
/// with <c>valid_to = validFrom − 1</c> and inserts a new one, so the <c>conversion_rate</c> frozen into posted
/// movements keeps matching the factor that was in force on the movement date.
/// </summary>
public sealed class ProductUomVersioningTests
{
    private const ushort BaseUomId = 1;  // G
    private const ushort CaseUomId = 2;  // CASE
    private static readonly DateOnly Start = new(2026, 1, 1);

    private static Product NewProduct() =>
        Product.Create(1, "CHK-001", "Toyuq döşü", categoryId: 7, BaseUomId, Start).Value;

    [Fact]
    public void Creation_opens_a_base_row_with_factor_one()
    {
        var product = NewProduct();

        var baseRow = Assert.Single(product.Uoms);
        Assert.Equal(BaseUomId, baseRow.UomId);
        Assert.Equal(1m, baseRow.FactorToBase);
        Assert.Equal(Start, baseRow.ValidFrom);
        Assert.Null(baseRow.ValidTo);
    }

    [Fact]
    public void A_changed_factor_closes_the_old_row_and_inserts_a_new_one()
    {
        var product = NewProduct();
        Assert.True(product.AddOrReplaceUom(CaseUomId, 12m, Start).IsSuccess);

        var changedFrom = new DateOnly(2026, 7, 1);
        var result = product.AddOrReplaceUom(CaseUomId, 24m, changedFrom);

        Assert.True(result.IsSuccess);

        var caseRows = product.Uoms.Where(u => u.UomId == CaseUomId).OrderBy(u => u.ValidFrom).ToList();
        Assert.Equal(2, caseRows.Count);

        // The historical row keeps its factor and is closed the day before the new one starts.
        Assert.Equal(12m, caseRows[0].FactorToBase);
        Assert.Equal(changedFrom.AddDays(-1), caseRows[0].ValidTo);

        // The new row carries the new factor and is open.
        Assert.Equal(24m, caseRows[1].FactorToBase);
        Assert.Equal(changedFrom, caseRows[1].ValidFrom);
        Assert.Null(caseRows[1].ValidTo);
        Assert.Same(caseRows[1], result.Value);
    }

    [Fact]
    public void The_factor_in_force_depends_on_the_movement_date()
    {
        var product = NewProduct();
        product.AddOrReplaceUom(CaseUomId, 12m, Start);
        product.AddOrReplaceUom(CaseUomId, 24m, new DateOnly(2026, 7, 1));

        Assert.Equal(12m, product.FactorOn(CaseUomId, new DateOnly(2026, 6, 30)));
        Assert.Equal(24m, product.FactorOn(CaseUomId, new DateOnly(2026, 7, 1)));
        Assert.Null(product.FactorOn(CaseUomId, new DateOnly(2025, 12, 31)));
    }

    [Fact]
    public void An_overlapping_validity_window_is_rejected()
    {
        var product = NewProduct();
        product.AddOrReplaceUom(CaseUomId, 12m, new DateOnly(2026, 3, 1));

        // Starting on or before the open row's valid_from would give two factors for the same day.
        var sameDay = product.AddOrReplaceUom(CaseUomId, 24m, new DateOnly(2026, 3, 1));
        var earlier = product.AddOrReplaceUom(CaseUomId, 24m, new DateOnly(2026, 2, 1));

        Assert.True(sameDay.IsFailure);
        Assert.Equal("UOM_VALIDITY_OVERLAP", sameDay.Error.Code);
        Assert.Equal(422, sameDay.Error.Status);
        Assert.True(earlier.IsFailure);
        Assert.Equal("UOM_VALIDITY_OVERLAP", earlier.Error.Code);

        Assert.Single(product.Uoms, u => u.UomId == CaseUomId);
    }

    [Fact]
    public void A_new_window_may_not_reopen_a_closed_one()
    {
        var product = NewProduct();
        product.AddOrReplaceUom(CaseUomId, 12m, new DateOnly(2026, 1, 1));
        product.AddOrReplaceUom(CaseUomId, 24m, new DateOnly(2026, 7, 1));

        // 2026-04-01 falls inside the closed 01.01 – 30.06 window.
        var result = product.AddOrReplaceUom(CaseUomId, 36m, new DateOnly(2026, 4, 1));

        Assert.True(result.IsFailure);
        Assert.Equal("UOM_VALIDITY_OVERLAP", result.Error.Code);
        Assert.Equal(2, product.Uoms.Count(u => u.UomId == CaseUomId));
    }

    [Fact]
    public void Re_adding_the_same_factor_moves_the_defaults_without_duplicating_the_row()
    {
        var product = NewProduct();
        product.AddOrReplaceUom(CaseUomId, 12m, Start);

        var result = product.AddOrReplaceUom(CaseUomId, 12m, new DateOnly(2026, 9, 1), isPurchaseDefault: true);

        Assert.True(result.IsSuccess);
        var row = Assert.Single(product.Uoms, u => u.UomId == CaseUomId);
        Assert.True(row.IsPurchaseDefault);
        Assert.Equal(Start, row.ValidFrom);
        Assert.Null(row.ValidTo);
    }

    [Fact]
    public void The_base_uom_factor_must_stay_one()
    {
        var product = NewProduct();

        var result = product.AddOrReplaceUom(BaseUomId, 1000m, new DateOnly(2026, 7, 1));

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_FACTOR", result.Error.Code);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public void A_non_positive_factor_is_rejected(int factor)
    {
        var product = NewProduct();

        var result = product.AddOrReplaceUom(CaseUomId, factor, Start);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_FACTOR", result.Error.Code);
    }

    [Fact]
    public void Only_one_row_per_uom_is_open_at_a_time()
    {
        var product = NewProduct();
        product.AddOrReplaceUom(CaseUomId, 12m, new DateOnly(2026, 1, 1));
        product.AddOrReplaceUom(CaseUomId, 24m, new DateOnly(2026, 4, 1));
        product.AddOrReplaceUom(CaseUomId, 48m, new DateOnly(2026, 8, 1));

        Assert.Equal(3, product.Uoms.Count(u => u.UomId == CaseUomId));
        Assert.Single(product.Uoms, u => u.UomId == CaseUomId && u.IsOpen);
        Assert.Equal(48m, product.FactorOn(CaseUomId, new DateOnly(2026, 8, 1)));
    }
}
