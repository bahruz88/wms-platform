using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Domain.Entities;

namespace Wms.Consumption.Infrastructure.Persistence;

/// <summary>Schema <c>cons</c> (ADR-012): table prefix <c>cons_</c>, own migrations folder and history table.</summary>
public sealed class ConsumptionDbContext(
    DbContextOptions<ConsumptionDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "cons_";
    public const string MigrationsHistoryTable = "__ef_migrations_consumption";

    public override string TablePrefix => Prefix;

    public DbSet<MenuItem> MenuItems => Set<MenuItem>();

    public DbSet<Recipe> Recipes => Set<Recipe>();

    public DbSet<RecipeLine> RecipeLines => Set<RecipeLine>();

    public DbSet<SalesImport> SalesImports => Set<SalesImport>();

    public DbSet<SalesLine> SalesLines => Set<SalesLine>();

    public DbSet<ConsumptionRun> Runs => Set<ConsumptionRun>();

    public DbSet<ConsumptionRunLine> RunLines => Set<ConsumptionRunLine>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ConsumptionDbContext).Assembly);
}

public sealed class ConsumptionDbContextFactory : IDesignTimeDbContextFactory<ConsumptionDbContext>
{
    public ConsumptionDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<ConsumptionDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), ConsumptionDbContext.MigrationsHistoryTable);
        return new ConsumptionDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
