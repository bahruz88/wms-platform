using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Infrastructure.Persistence;

/// <summary>Schema <c>notif</c> (spec §5): table prefix <c>notif_</c>.</summary>
public sealed class NotificationDbContext(
    DbContextOptions<NotificationDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "notif_";
    public const string MigrationsHistoryTable = "__ef_migrations_notification";

    public override string TablePrefix => Prefix;

    public DbSet<NotificationMessage> Messages => Set<NotificationMessage>();

    public DbSet<NotificationRule> Rules => Set<NotificationRule>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(NotificationDbContext).Assembly);
}

public sealed class NotificationDbContextFactory : IDesignTimeDbContextFactory<NotificationDbContext>
{
    public NotificationDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<NotificationDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), NotificationDbContext.MigrationsHistoryTable);
        return new NotificationDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
