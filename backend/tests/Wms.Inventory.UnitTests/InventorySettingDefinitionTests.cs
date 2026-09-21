using Wms.Inventory.Domain;

namespace Wms.Inventory.UnitTests;

/// <summary>
/// Spec §9.1 / TOR §36 — <c>inv_setting</c> is configuration, not code, so
/// <c>PUT /inventory/settings/{key}</c> has to validate per declared value type.
/// </summary>
public sealed class InventorySettingDefinitionTests
{
    private static InventorySettingDefinition Key(string key) => InventorySettingKeys.ByKey[key];

    [Fact]
    public void Every_documented_key_has_a_definition_and_a_default()
    {
        Assert.Equal(9, InventorySettingKeys.Definitions.Count);
        foreach (var definition in InventorySettingKeys.Definitions)
        {
            var normalized = definition.Normalize(definition.DefaultValue);
            Assert.True(normalized.IsSuccess, $"the default of '{definition.Key}' must itself be valid");
        }
    }

    [Theory]
    [InlineData("45", "45")]
    [InlineData(" 45 ", "45")]
    public void An_int_key_accepts_whole_numbers(string input, string expected)
    {
        var result = Key(InventorySettingKeys.ExpiryWarningDays).Normalize(input);

        Assert.True(result.IsSuccess);
        Assert.Equal(expected, result.Value);
    }

    [Theory]
    [InlineData("4.5")]
    [InlineData("abc")]
    [InlineData("")]
    [InlineData("-1")]
    [InlineData("4000")]
    public void An_int_key_rejects_anything_else(string input)
    {
        var result = Key(InventorySettingKeys.ExpiryWarningDays).Normalize(input);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_SETTING_VALUE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Theory]
    [InlineData("2.5", "2.5")]
    [InlineData("0", "0")]
    public void A_decimal_key_accepts_a_percentage(string input, string expected)
    {
        var result = Key(InventorySettingKeys.ReceiptOverTolerancePct).Normalize(input);

        Assert.True(result.IsSuccess);
        Assert.Equal(expected, result.Value);
    }

    [Theory]
    [InlineData("101")]
    [InlineData("-0.5")]
    [InlineData("2,5")]
    public void A_decimal_key_rejects_out_of_range_and_comma_separated_values(string input) =>
        Assert.True(Key(InventorySettingKeys.ReceiptOverTolerancePct).Normalize(input).IsFailure);

    [Theory]
    [InlineData("true", "true")]
    [InlineData("TRUE", "true")]
    [InlineData("1", "true")]
    [InlineData("yes", "true")]
    [InlineData("false", "false")]
    [InlineData("0", "false")]
    public void A_bool_key_normalises_to_true_or_false(string input, string expected)
    {
        var result = Key(InventorySettingKeys.AllowNegativeStock).Normalize(input);

        Assert.True(result.IsSuccess);
        Assert.Equal(expected, result.Value);
    }

    [Theory]
    [InlineData("maybe")]
    [InlineData("2")]
    public void A_bool_key_rejects_anything_else(string input) =>
        Assert.True(Key(InventorySettingKeys.AllowNegativeStock).Normalize(input).IsFailure);

    [Theory]
    [InlineData("FIFO", "FIFO")]
    [InlineData("moving_average", "MOVING_AVERAGE")]
    public void An_enum_key_accepts_only_its_declared_values(string input, string expected)
    {
        var result = Key(InventorySettingKeys.CostingMethod).Normalize(input);

        Assert.True(result.IsSuccess);
        Assert.Equal(expected, result.Value);
    }

    [Fact]
    public void An_enum_key_rejects_an_unknown_value()
    {
        var result = Key(InventorySettingKeys.CostingMethod).Normalize("LIFO");

        Assert.True(result.IsFailure);
        Assert.Contains("MOVING_AVERAGE", result.Error.Message, StringComparison.Ordinal);
    }

    [Fact]
    public void A_value_longer_than_the_column_is_rejected() =>
        Assert.True(Key(InventorySettingKeys.CostingMethod).Normalize(new string('x', 501)).IsFailure);
}
