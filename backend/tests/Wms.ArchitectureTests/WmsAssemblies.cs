using System.Reflection;

namespace Wms.ArchitectureTests;

/// <summary>Assembly lookup shared by the architecture tests.</summary>
public static class WmsAssemblies
{
    public static IReadOnlyList<string> ModuleNames { get; } =
        ["Identity", "MasterData", "Inventory", "Consumption", "Procurement", "Documents", "Notification", "Reporting", "Integration"];

    public static IReadOnlyList<string> InternalLayers { get; } = ["Domain", "Application", "Infrastructure", "Endpoints"];

    /// <summary>Allowed cross-module contract references (spec §5). Everything else is forbidden.</summary>
    public static IReadOnlyDictionary<string, string[]> AllowedContractDependencies { get; } =
        new Dictionary<string, string[]>(StringComparer.Ordinal)
        {
            ["Identity"] = [],
            ["MasterData"] = ["Identity"],
            ["Inventory"] = ["MasterData"],
            ["Consumption"] = ["MasterData", "Inventory"],
            ["Procurement"] = ["MasterData", "Inventory"],
            ["Documents"] = [],
            ["Notification"] = [],
            ["Reporting"] = ["MasterData", "Inventory"],
            ["Integration"] = [],
        };

    static WmsAssemblies()
    {
        // Every module assembly is reachable through the API host, which references all Endpoints projects.
        _ = typeof(Wms.Host.Api.ModuleRegistry);
        _ = typeof(Wms.Host.Migrator.MigrationRunner);

        foreach (var file in Directory.EnumerateFiles(AppContext.BaseDirectory, "Wms.*.dll"))
        {
            try
            {
                Assembly.Load(AssemblyName.GetAssemblyName(file));
            }
            catch (BadImageFormatException)
            {
                // Not a managed assembly; ignore.
            }
        }
    }

    public static IReadOnlyList<Assembly> All() => AppDomain.CurrentDomain
        .GetAssemblies()
        .Where(a => a.GetName().Name?.StartsWith("Wms.", StringComparison.Ordinal) == true)
        .OrderBy(a => a.GetName().Name, StringComparer.Ordinal)
        .ToList();

    public static Assembly Get(string simpleName) =>
        All().FirstOrDefault(a => string.Equals(a.GetName().Name, simpleName, StringComparison.Ordinal))
        ?? throw new InvalidOperationException($"Assembly '{simpleName}' is not loaded. Loaded: {string.Join(", ", All().Select(a => a.GetName().Name))}");

    public static Assembly Module(string module, string layer) => Get($"Wms.{module}.{layer}");
}
