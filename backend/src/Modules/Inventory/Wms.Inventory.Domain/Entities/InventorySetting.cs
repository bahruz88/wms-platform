using Wms.Common.Domain;

namespace Wms.Inventory.Domain.Entities;

/// <summary>Row of <c>inv_setting</c> (PK tenant_id + setting_key).</summary>
public sealed class InventorySetting : ITenantEntity
{
    private InventorySetting()
    {
    }

    public uint TenantId { get; private set; }

    public string Key { get; private set; } = string.Empty;

    public string Value { get; private set; } = string.Empty;

    public static InventorySetting Create(uint tenantId, string key, string value)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(key);
        ArgumentNullException.ThrowIfNull(value);
        return new InventorySetting { TenantId = tenantId, Key = key, Value = value };
    }

    public void Update(string value)
    {
        ArgumentNullException.ThrowIfNull(value);
        Value = value;
    }
}
