using Wms.Common.Infrastructure.Modules;
using Wms.Consumption.Endpoints;
using Wms.Documents.Endpoints;
using Wms.Identity.Endpoints;
using Wms.Integration.Endpoints;
using Wms.Inventory.Endpoints;
using Wms.MasterData.Endpoints;
using Wms.Notification.Endpoints;
using Wms.Procurement.Endpoints;
using Wms.Reporting.Endpoints;

namespace Wms.Host.Api;

/// <summary>
/// Every module the image can host (spec §4.1). Which ones actually load is decided by the <c>Modules</c>
/// configuration key: <c>*</c> = all (on-prem single container), or a comma separated list of names.
/// </summary>
public static class ModuleRegistry
{
    public const string ConfigurationKey = "Modules";
    public const string All = "*";

    /// <summary>Declaration order = registration and endpoint mapping order.</summary>
    public static IReadOnlyList<IModule> AvailableModules { get; } =
    [
        new IdentityModule(),
        new MasterDataModule(),
        new InventoryModule(),
        new ConsumptionModule(),
        new ProcurementModule(),
        new DocumentsModule(),
        new NotificationModule(),
        new ReportingModule(),
        new IntegrationModule(),
    ];

    public static IReadOnlyList<string> AvailableNames { get; } = AvailableModules.Select(m => m.Name).ToList();

    /// <summary>
    /// Which modules' <c>*.Contracts</c> each module consumes (spec §5). With <c>ModuleTransport=InProcess</c> every
    /// dependency must be loaded in the same process; with <c>Http</c> the missing ones are reached over the network.
    /// </summary>
    public static IReadOnlyDictionary<string, string[]> ModuleDependencies { get; } =
        new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            ["identity"] = [],
            ["masterdata"] = ["identity"],
            ["inventory"] = ["masterdata"],
            ["consumption"] = ["inventory", "masterdata"],
            ["procurement"] = ["masterdata", "inventory"],
            ["documents"] = [],
            ["notification"] = [],
            ["reporting"] = [],
            ["integration"] = [],
        };

    /// <summary>
    /// Dependencies of the loaded modules that are NOT loaded here. With <c>InProcess</c> transport this must be
    /// empty, otherwise the contracts have no implementation at all.
    /// </summary>
    public static IReadOnlyList<string> MissingDependencies(IEnumerable<IModule> loaded)
    {
        ArgumentNullException.ThrowIfNull(loaded);
        var loadedNames = loaded.Select(m => m.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
        return loadedNames
            .SelectMany(name => ModuleDependencies.TryGetValue(name, out var deps) ? deps : [])
            .Where(dependency => !loadedNames.Contains(dependency))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .Order(StringComparer.Ordinal)
            .ToList();
    }

    /// <summary>Resolves the <c>--Modules=</c> value. An unknown name fails fast (no silently half-loaded process).</summary>
    public static IReadOnlyList<IModule> Resolve(string? enabled)
    {
        if (string.IsNullOrWhiteSpace(enabled) || enabled.Trim() == All)
        {
            return AvailableModules;
        }

        var requested = enabled
            .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(n => n.ToLowerInvariant())
            .ToList();

        var unknown = requested
            .Where(name => !AvailableNames.Contains(name, StringComparer.OrdinalIgnoreCase))
            .ToList();
        if (unknown.Count > 0)
        {
            throw new InvalidOperationException(
                $"Unknown module(s) in {ConfigurationKey}: {string.Join(", ", unknown)}. Available: {string.Join(", ", AvailableNames)}.");
        }

        // Keep the declaration order regardless of how the list was written.
        return AvailableModules.Where(m => requested.Contains(m.Name, StringComparer.OrdinalIgnoreCase)).ToList();
    }

    /// <summary>The modules NOT loaded here — their contracts are served over HTTP when <c>ModuleTransport=Http</c>.</summary>
    public static IReadOnlyList<IModule> Remaining(IEnumerable<IModule> loaded)
    {
        ArgumentNullException.ThrowIfNull(loaded);
        var loadedNames = loaded.Select(m => m.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
        return AvailableModules.Where(m => !loadedNames.Contains(m.Name)).ToList();
    }
}
