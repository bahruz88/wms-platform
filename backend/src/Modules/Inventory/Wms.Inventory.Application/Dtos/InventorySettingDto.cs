using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Dtos;

/// <summary><c>InventorySetting</c> of inventory.v1.yaml.</summary>
public sealed record InventorySettingDto(
    string Key,
    string Value,
    string ValueType,
    IReadOnlyList<string>? AllowedValues,
    string Description)
{
    public static InventorySettingDto From(InventorySettingDefinition definition, string value)
    {
        ArgumentNullException.ThrowIfNull(definition);
        return new InventorySettingDto(
            definition.Key,
            value,
            definition.ValueType switch
            {
                SettingValueType.Int => "INT",
                SettingValueType.Decimal => "DECIMAL",
                SettingValueType.Bool => "BOOL",
                _ => "ENUM",
            },
            definition.AllowedValues,
            definition.Description);
    }
}
