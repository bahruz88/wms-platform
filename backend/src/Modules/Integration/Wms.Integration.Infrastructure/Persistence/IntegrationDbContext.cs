using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Integration.Domain.Entities;

namespace Wms.Integration.Infrastructure.Persistence;

/// <summary>Schema <c>intg</c> (spec §5): table prefix <c>intg_</c>.</summary>
public sealed class IntegrationDbContext(
    DbContextOptions<IntegrationDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "intg_";
    public const string MigrationsHistoryTable = "__ef_migrations_integration";

    public override string TablePrefix => Prefix;

    public DbSet<IntegrationEndpoint> Endpoints => Set<IntegrationEndpoint>();

    public DbSet<OutboundMessage> OutboundMessages => Set<OutboundMessage>();

    public DbSet<SyncCursor> SyncCursors => Set<SyncCursor>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(IntegrationDbContext).Assembly);
}

public sealed class IntegrationDbContextFactory : IDesignTimeDbContextFactory<IntegrationDbContext>
{
    public IntegrationDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<IntegrationDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), IntegrationDbContext.MigrationsHistoryTable);
        return new IntegrationDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
