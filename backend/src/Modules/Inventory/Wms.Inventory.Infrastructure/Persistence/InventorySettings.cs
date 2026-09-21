using System.Globalization;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Infrastructure.Persistence;

/// <summary>Reads <c>inv_setting</c> once per request scope; falls back to the defaults of spec §9.1.</summary>
public sealed class InventorySettings(InventoryDbContext db) : IInventorySettings
{
    private Dictionary<string, string>? _cache;

    public async Task<string> GetAsync(string key, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(key);
        _cache ??= await db.Settings.AsNoTracking()
            .ToDictionaryAsync(s => s.Key, s => s.Value, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);

        if (_cache.TryGetValue(key, out var value))
        {
            return value;
        }

        return InventorySettingKeys.Defaults.TryGetValue(key, out var fallback)
            ? fallback
            : throw new InvalidOperationException($"Unknown inventory setting '{key}'.");
    }

    public async Task<bool> GetBoolAsync(string key, CancellationToken cancellationToken)
    {
        var raw = await GetAsync(key, cancellationToken).ConfigureAwait(false);
        return raw is "1" || raw.Equals("true", StringComparison.OrdinalIgnoreCase) || raw.Equals("yes", StringComparison.OrdinalIgnoreCase);
    }

    public async Task<decimal> GetDecimalAsync(string key, CancellationToken cancellationToken)
    {
        var raw = await GetAsync(key, cancellationToken).ConfigureAwait(false);
        return decimal.Parse(raw, NumberStyles.Number, CultureInfo.InvariantCulture);
    }

    public async Task<int> GetIntAsync(string key, CancellationToken cancellationToken)
    {
        var raw = await GetAsync(key, cancellationToken).ConfigureAwait(false);
        return int.Parse(raw, NumberStyles.Integer, CultureInfo.InvariantCulture);
    }
}
