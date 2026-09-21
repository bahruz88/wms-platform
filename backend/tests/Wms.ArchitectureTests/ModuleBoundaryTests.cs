using System.Reflection;
using NetArchTest.Rules;

namespace Wms.ArchitectureTests;

/// <summary>
/// Spec §17.4 rule 1 / ADR-001: a module may only see another module through its <c>*.Contracts</c> assembly,
/// and only the pairs listed in spec §5.
/// </summary>
public sealed class ModuleBoundaryTests
{
    public static TheoryData<string, string> ModuleLayers()
    {
        var data = new TheoryData<string, string>();
        foreach (var module in WmsAssemblies.ModuleNames)
        {
            foreach (var layer in WmsAssemblies.InternalLayers)
            {
                data.Add(module, layer);
            }
        }

        return data;
    }

    [Theory]
    [MemberData(nameof(ModuleLayers))]
    public void A_module_never_references_another_modules_non_contracts_assembly(string module, string layer)
    {
        var assembly = WmsAssemblies.Module(module, layer);

        var forbidden = assembly.GetReferencedAssemblies()
            .Select(a => a.Name)
            .OfType<string>()
            .Where(name => WmsAssemblies.ModuleNames.Any(other =>
                !string.Equals(other, module, StringComparison.Ordinal)
                && name.StartsWith($"Wms.{other}.", StringComparison.Ordinal)
                && !name.EndsWith(".Contracts", StringComparison.Ordinal)))
            .ToList();

        Assert.True(forbidden.Count == 0, $"Wms.{module}.{layer} references internal assemblies of other modules: {string.Join(", ", forbidden)}");
    }

    [Theory]
    [MemberData(nameof(ModuleLayers))]
    public void A_module_only_references_the_contracts_allowed_by_the_specification(string module, string layer)
    {
        var assembly = WmsAssemblies.Module(module, layer);
        var allowed = WmsAssemblies.AllowedContractDependencies[module];

        var referencedModules = assembly.GetReferencedAssemblies()
            .Select(a => a.Name)
            .OfType<string>()
            .Where(name => name.EndsWith(".Contracts", StringComparison.Ordinal))
            .Select(name => name.Split('.')[1])
            .Where(other => WmsAssemblies.ModuleNames.Contains(other, StringComparer.Ordinal)
                && !string.Equals(other, module, StringComparison.Ordinal))
            .Distinct(StringComparer.Ordinal)
            .ToList();

        var violations = referencedModules.Except(allowed, StringComparer.Ordinal).ToList();

        Assert.True(
            violations.Count == 0,
            $"Wms.{module}.{layer} depends on {string.Join(", ", violations)}.Contracts; spec §5 allows only: {(allowed.Length == 0 ? "(none)" : string.Join(", ", allowed))}");
    }

    [Fact]
    public void Inventory_does_not_depend_on_procurement()
    {
        // The literal example of spec §17.4.
        var result = Types.InAssembly(WmsAssemblies.Module("Inventory", "Application"))
            .ShouldNot()
            .HaveDependencyOnAny("Wms.Procurement.Domain", "Wms.Procurement.Application", "Wms.Procurement.Infrastructure")
            .GetResult();

        Assert.True(result.IsSuccessful, Describe(result));
    }

    [Theory]
    [MemberData(nameof(ModuleLayers))]
    public void A_contracts_assembly_only_depends_on_common_contracts(string module, string layer)
    {
        if (!string.Equals(layer, WmsAssemblies.InternalLayers[0], StringComparison.Ordinal))
        {
            return; // Run the Contracts check once per module.
        }

        var contracts = WmsAssemblies.Module(module, "Contracts");
        var forbidden = contracts.GetReferencedAssemblies()
            .Select(a => a.Name)
            .OfType<string>()
            .Where(name => name.StartsWith("Wms.", StringComparison.Ordinal) && name != "Wms.Common.Contracts")
            .ToList();

        Assert.True(forbidden.Count == 0, $"Wms.{module}.Contracts must only reference Wms.Common.Contracts, but references: {string.Join(", ", forbidden)}");
    }

    [Theory]
    [InlineData("Domain")]
    public void A_domain_assembly_only_depends_on_common_domain(string layer)
    {
        foreach (var module in WmsAssemblies.ModuleNames)
        {
            var assembly = WmsAssemblies.Module(module, layer);
            var forbidden = assembly.GetReferencedAssemblies()
                .Select(a => a.Name)
                .OfType<string>()
                .Where(name => name.StartsWith("Wms.", StringComparison.Ordinal) && name != "Wms.Common.Domain")
                .ToList();

            Assert.True(forbidden.Count == 0, $"Wms.{module}.Domain must only reference Wms.Common.Domain, but references: {string.Join(", ", forbidden)}");
        }
    }

    [Fact]
    public void No_domain_or_application_assembly_references_entity_framework()
    {
        foreach (var module in WmsAssemblies.ModuleNames)
        {
            foreach (var layer in new[] { "Domain", "Application" })
            {
                var referenced = WmsAssemblies.Module(module, layer)
                    .GetReferencedAssemblies()
                    .Select(a => a.Name)
                    .OfType<string>()
                    .Where(name => name.StartsWith("Microsoft.EntityFrameworkCore", StringComparison.Ordinal))
                    .ToList();

                Assert.True(referenced.Count == 0, $"Wms.{module}.{layer} must stay persistence-ignorant, but references: {string.Join(", ", referenced)}");
            }
        }
    }

    private static string Describe(TestResult result) =>
        result.FailingTypeNames is null ? "no details" : string.Join(", ", result.FailingTypeNames);
}
