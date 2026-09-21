using System.Globalization;
using Wms.Common.Domain;

namespace Wms.Inventory.Domain;

/// <summary>Value domain of an <c>inv_setting</c> key, as inventory.v1.yaml declares it.</summary>
public enum SettingValueType
{
    Int,
    Decimal,
    Bool,
    Enum,
}

/// <summary>
/// One <c>inv_setting</c> key with its type, default and — for <see cref="SettingValueType.Enum"/> — the
/// values it accepts. Spec §9.1 and TOR §36 insist these parameters must not be hard-coded, which is only
/// true once they can be read and written through the product; this definition is what makes
/// <c>PUT /inventory/settings/{key}</c> able to validate per type instead of storing any string.
/// </summary>
public sealed record InventorySettingDefinition(
    string Key,
    SettingValueType ValueType,
    string DefaultValue,
    string Description,
    IReadOnlyList<string>? AllowedValues = null,
    decimal? Minimum = null,
    decimal? Maximum = null)
{
    public Result<string> Normalize(string? raw)
    {
        var value = (raw ?? string.Empty).Trim();
        if (value.Length == 0)
        {
            return InventoryErrors.InvalidSettingValue(Key, "value must not be empty.");
        }

        if (value.Length > 500)
        {
            return InventoryErrors.InvalidSettingValue(Key, "value must be at most 500 characters.");
        }

        switch (ValueType)
        {
            case SettingValueType.Int:
                if (!int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var i))
                {
                    return InventoryErrors.InvalidSettingValue(Key, "value must be a whole number.");
                }

                return CheckRange(i, i.ToString(CultureInfo.InvariantCulture));

            case SettingValueType.Decimal:
                // Deliberately no AllowThousands: "2,5" is a typo for "2.5" in an az-AZ interface, not 25.
                const NumberStyles DecimalStyles = NumberStyles.AllowLeadingSign | NumberStyles.AllowDecimalPoint;
                if (!decimal.TryParse(value, DecimalStyles, CultureInfo.InvariantCulture, out var d))
                {
                    return InventoryErrors.InvalidSettingValue(Key, "value must be a decimal number using '.' as the separator.");
                }

                return CheckRange(d, d.ToString(CultureInfo.InvariantCulture));

            case SettingValueType.Bool:
                return value.ToUpperInvariant() switch
                {
                    "TRUE" or "1" or "YES" => Result.Success("true"),
                    "FALSE" or "0" or "NO" => Result.Success("false"),
                    _ => InventoryErrors.InvalidSettingValue(Key, "value must be true or false."),
                };

            case SettingValueType.Enum:
                var allowed = AllowedValues ?? [];
                var match = allowed.FirstOrDefault(a => string.Equals(a, value, StringComparison.OrdinalIgnoreCase));
                return match is null
                    ? InventoryErrors.InvalidSettingValue(Key, $"value must be one of: {string.Join(", ", allowed)}.")
                    : Result.Success(match);

            default:
                return InventoryErrors.InvalidSettingValue(Key, "unsupported value type.");
        }
    }

    private Result<string> CheckRange(decimal parsed, string normalized)
    {
        if (Minimum is { } min && parsed < min)
        {
            return InventoryErrors.InvalidSettingValue(Key, $"value must be at least {min.ToString(CultureInfo.InvariantCulture)}.");
        }

        if (Maximum is { } max && parsed > max)
        {
            return InventoryErrors.InvalidSettingValue(Key, $"value must be at most {max.ToString(CultureInfo.InvariantCulture)}.");
        }

        return Result.Success(normalized);
    }
}
