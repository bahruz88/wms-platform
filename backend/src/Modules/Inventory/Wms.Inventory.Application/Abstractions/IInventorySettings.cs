namespace Wms.Inventory.Application.Abstractions;

/// <summary>Typed access to <c>inv_setting</c> with the defaults of spec §9.1.</summary>
public interface IInventorySettings
{
    Task<string> GetAsync(string key, CancellationToken cancellationToken);

    Task<bool> GetBoolAsync(string key, CancellationToken cancellationToken);

    Task<decimal> GetDecimalAsync(string key, CancellationToken cancellationToken);

    Task<int> GetIntAsync(string key, CancellationToken cancellationToken);
}

/// <summary>Write side of <c>inv_setting</c>; returns the previous value (or the default) for the audit row.</summary>
public interface IInventorySettingWriter
{
    Task<string> SetAsync(string key, string value, CancellationToken cancellationToken);
}
