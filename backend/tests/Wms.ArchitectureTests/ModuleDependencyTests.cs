using Wms.Host.Api;

namespace Wms.ArchitectureTests;

/// <summary>The host's dependency map must match the reference graph the assembly tests enforce (spec §5).</summary>
public sealed class ModuleDependencyTests
{
    private static readonly Dictionary<string, string> ModuleNamesByAssembly = new(StringComparer.OrdinalIgnoreCase)
    {
        ["Identity"] = "identity",
        ["MasterData"] = "masterdata",
        ["Inventory"] = "inventory",
        ["Consumption"] = "consumption",
        ["Procurement"] = "procurement",
        ["Documents"] = "documents",
        ["Notification"] = "notification",
        ["Reporting"] = "reporting",
        ["Integration"] = "integration",
    };

    [Fact]
    public void The_host_dependency_map_matches_the_allowed_contract_references()
    {
        foreach (var pair in ModuleNamesByAssembly)
        {
            var allowed = WmsAssemblies.AllowedContractDependencies[pair.Key]
                .Select(m => ModuleNamesByAssembly[m])
                .Order(StringComparer.Ordinal)
                .ToList();
            var declared = ModuleRegistry.ModuleDependencies[pair.Value].Order(StringComparer.Ordinal).ToList();

            Assert.Equal(allowed, declared);
        }
    }

    [Fact]
    public void A_full_deployment_has_no_missing_dependencies()
    {
        Assert.Empty(ModuleRegistry.MissingDependencies(ModuleRegistry.Resolve("*")));
    }

    [Theory]
    [InlineData("inventory", "masterdata")]
    [InlineData("procurement", "inventory,masterdata")]
    [InlineData("consumption", "inventory,masterdata")]
    [InlineData("inventory,consumption", "masterdata")]
    [InlineData("masterdata", "identity")]
    [InlineData("reporting", "inventory,masterdata")]
    public void A_partial_deployment_reports_the_modules_it_cannot_reach_in_process(string modules, string expected)
    {
        var missing = ModuleRegistry.MissingDependencies(ModuleRegistry.Resolve(modules));

        Assert.Equal(expected.Split(',').Order(StringComparer.Ordinal), missing);
    }

    [Theory]
    [InlineData("identity")]
    [InlineData("notification,integration")]
    [InlineData("documents")]
    public void A_self_contained_deployment_needs_no_remote_modules(string modules)
    {
        Assert.Empty(ModuleRegistry.MissingDependencies(ModuleRegistry.Resolve(modules)));
    }
}
