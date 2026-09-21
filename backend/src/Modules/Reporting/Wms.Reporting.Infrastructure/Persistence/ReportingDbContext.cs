using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Reporting.Domain.Entities;

namespace Wms.Reporting.Infrastructure.Persistence;

/// <summary>Schema <c>rpt</c> (spec §5): table prefix <c>rpt_</c>. Read-model only.</summary>
public sealed class ReportingDbContext(
    DbContextOptions<ReportingDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "rpt_";
    public const string MigrationsHistoryTable = "__ef_migrations_reporting";

    public override string TablePrefix => Prefix;

    public DbSet<StockSnapshot> StockSnapshots => Set<StockSnapshot>();

    public DbSet<ReportDefinition> ReportDefinitions => Set<ReportDefinition>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ReportingDbContext).Assembly);
}

public sealed class ReportingDbContextFactory : IDesignTimeDbContextFactory<ReportingDbContext>
{
    public ReportingDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<ReportingDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), ReportingDbContext.MigrationsHistoryTable);
        return new ReportingDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
