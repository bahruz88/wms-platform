using Wms.Host.Api;

namespace Wms.ArchitectureTests;

/// <summary>Spec §4.1: <c>--Modules=</c> resolution, including fail-fast on an unknown name.</summary>
public sealed class ModuleRegistryTests
{
    [Fact]
    public void All_nine_modules_of_the_specification_are_registered()
    {
        // Eight from spec §5 plus Consumption (ADR-012), deployed together with wms-inventory.
        Assert.Equal(9, ModuleRegistry.AvailableModules.Count);
        Assert.Equal(
            ["identity", "masterdata", "inventory", "consumption", "procurement", "documents", "notification", "reporting", "integration"],
            ModuleRegistry.AvailableNames);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("*")]
    [InlineData(" * ")]
    public void A_star_or_empty_value_loads_every_module(string? value)
    {
        Assert.Equal(ModuleRegistry.AvailableModules.Count, ModuleRegistry.Resolve(value).Count);
    }

    [Fact]
    public void A_comma_list_loads_exactly_those_modules_in_declaration_order()
    {
        var modules = ModuleRegistry.Resolve("inventory,masterdata");

        Assert.Equal(["masterdata", "inventory"], modules.Select(m => m.Name));
    }

    [Fact]
    public void Names_are_case_and_whitespace_insensitive()
    {
        Assert.Single(ModuleRegistry.Resolve("  Inventory  "));
    }

    [Fact]
    public void An_unknown_module_name_fails_fast()
    {
        var exception = Assert.Throws<InvalidOperationException>(() => ModuleRegistry.Resolve("inventory,warehouse"));

        Assert.Contains("warehouse", exception.Message, StringComparison.Ordinal);
    }

    [Fact]
    public void Remaining_returns_the_modules_that_must_be_reached_over_http()
    {
        var loaded = ModuleRegistry.Resolve("inventory");

        var remaining = ModuleRegistry.Remaining(loaded).Select(m => m.Name).ToList();

        Assert.DoesNotContain("inventory", remaining);
        Assert.Contains("masterdata", remaining);
        Assert.Contains("consumption", remaining);
        Assert.Equal(8, remaining.Count);
    }

    [Fact]
    public void Every_module_maps_a_route_group_matching_its_name()
    {
        // CONVENTIONS.md: --Modules name ↔ /api/v1/<route prefix>.
        var expected = new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["identity"] = "/api/v1/identity",
            ["masterdata"] = "/api/v1/masterdata",
            ["inventory"] = "/api/v1/inventory",
            ["consumption"] = "/api/v1/consumption",
            ["procurement"] = "/api/v1/procurement",
            ["documents"] = "/api/v1/documents",
            ["notification"] = "/api/v1/notifications",
            ["reporting"] = "/api/v1/reporting",
            ["integration"] = "/api/v1/integration",
        };

        Assert.Equal(expected.Keys.OrderBy(k => k, StringComparer.Ordinal), ModuleRegistry.AvailableNames.OrderBy(k => k, StringComparer.Ordinal));
    }
}
