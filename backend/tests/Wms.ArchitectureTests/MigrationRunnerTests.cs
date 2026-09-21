using Wms.Host.Migrator;

namespace Wms.ArchitectureTests;

/// <summary>Spec §18.3: the migrator covers every module context and the common tables come first.</summary>
public sealed class MigrationRunnerTests
{
    [Fact]
    public void Every_module_db_context_is_migrated()
    {
        var names = MigrationRunner.ContextTypes.Select(t => t.Name).ToList();

        // CommonDbContext + one per module (nine modules including Consumption, ADR-012).
        Assert.Equal(WmsAssemblies.ModuleNames.Count + 1, names.Count);
        Assert.Equal("CommonDbContext", names[0]);
        foreach (var module in WmsAssemblies.ModuleNames)
        {
            var expected = module == "MasterData" ? "MasterDataDbContext" : $"{module}DbContext";
            Assert.Contains(expected, names);
        }
    }

    [Fact]
    public void Contexts_are_distinct()
    {
        Assert.Equal(MigrationRunner.ContextTypes.Count, MigrationRunner.ContextTypes.Distinct().Count());
    }
}
