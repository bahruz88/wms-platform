using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Infrastructure.Audit;
using Wms.Common.Infrastructure.Outbox;

namespace Wms.Common.Infrastructure.Persistence;

/// <summary>Owns the migrations of the shared tables (<c>common_outbox</c>, <c>common_audit_log</c>) and serves the outbox publisher.</summary>
public sealed class CommonDbContext(DbContextOptions<CommonDbContext> options) : DbContext(options)
{
    public const string MigrationsHistoryTable = "__ef_migrations_common";

    public DbSet<OutboxMessage> Outbox => Set<OutboxMessage>();

    public DbSet<AuditLogEntry> AuditLog => Set<AuditLogEntry>();

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        ArgumentNullException.ThrowIfNull(optionsBuilder);
        optionsBuilder.UseSnakeCaseNamingConvention();
    }

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        ArgumentNullException.ThrowIfNull(configurationBuilder);
        ModuleDbContext.ApplyTypeConventions(configurationBuilder);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        CommonTables.Configure(modelBuilder, excludeFromMigrations: false);
    }
}

/// <summary>Design-time factory for <c>dotnet ef migrations add ... -c CommonDbContext</c>.</summary>
public sealed class CommonDbContextFactory : IDesignTimeDbContextFactory<CommonDbContext>
{
    public CommonDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<CommonDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), CommonDbContext.MigrationsHistoryTable);
        return new CommonDbContext(builder.Options);
    }
}
