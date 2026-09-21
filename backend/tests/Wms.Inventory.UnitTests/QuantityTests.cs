using Wms.Common.Domain;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §12.1: quantity conversion and rounding with MidpointRounding.AwayFromZero.</summary>
public sealed class QuantityTests
{
    [Theory]
    [InlineData("0.12345", 3, "0.123")]
    [InlineData("0.1235", 3, "0.124")]
    [InlineData("0.1225", 3, "0.123")]   // away from zero, NOT banker's rounding (which would give 0.122)
    [InlineData("2.5", 0, "3")]
    [InlineData("-2.5", 0, "-3")]        // away from zero is symmetric
    [InlineData("-0.1225", 3, "-0.123")]
    public void Of_rounds_away_from_zero(string input, int decimals, string expected)
    {
        var value = decimal.Parse(input, System.Globalization.CultureInfo.InvariantCulture);
        var quantity = Quantity.Of(value, decimals);

        Assert.Equal(decimal.Parse(expected, System.Globalization.CultureInfo.InvariantCulture), quantity.Value);
    }

    [Fact]
    public void Convert_multiplies_entered_qty_by_conversion_rate()
    {
        // 3 CASE, 1 CASE = 12 PCS, base UoM has 3 decimals.
        var qtyBase = Quantity.Convert(enteredQty: 3m, conversionRate: 12m, baseDecimals: 3);

        Assert.Equal(36.000m, qtyBase.Value);
    }

    [Fact]
    public void Convert_rounds_the_product_to_the_base_uom_decimals()
    {
        // 1 CASE = 0.3333 KG → 2 CASE = 0.6666 KG, rounded to 3 decimals = 0.667.
        var qtyBase = Quantity.Convert(enteredQty: 2m, conversionRate: 0.33330000m, baseDecimals: 3);

        Assert.Equal(0.667m, qtyBase.Value);
    }

    [Fact]
    public void Convert_rejects_a_non_positive_conversion_rate()
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => Quantity.Convert(1m, 0m, 3));
        Assert.Throws<ArgumentOutOfRangeException>(() => Quantity.Convert(1m, -1m, 3));
    }

    [Fact]
    public void Arithmetic_is_exact_with_decimal()
    {
        // The Excel artefact -23.50999999999999 (spec §1.4) cannot occur with decimal.
        var result = Quantity.Of(23.51m) - Quantity.Of(47.02m) + Quantity.Of(23.51m);

        Assert.Equal(0m, result.Value);
        Assert.True(result.IsZero);
    }

    [Fact]
    public void Money_keeps_four_decimals_and_rejects_a_bad_currency()
    {
        Assert.Equal(12.3457m, Money.Of(12.34565m, "AZN").Amount);
        Assert.True(Money.Create(1m, "XX").IsFailure);
        Assert.Equal("INVALID_CURRENCY", Money.Create(1m, "XX").Error.Code);
    }

    [Fact]
    public void Money_addition_rejects_mixed_currencies()
    {
        Assert.Throws<InvalidOperationException>(() => Money.Of(1m, "AZN") + Money.Of(1m, "USD"));
    }
}
