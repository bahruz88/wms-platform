using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Identity.Domain.Entities;

namespace Wms.Identity.Infrastructure.Persistence;

/// <summary>Schema <c>iam</c> (spec §7): table prefix <c>iam_</c>.</summary>
public sealed class IdentityDbContext(
    DbContextOptions<IdentityDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "iam_";
    public const string MigrationsHistoryTable = "__ef_migrations_identity";

    public override string TablePrefix => Prefix;

    public DbSet<Tenant> Tenants => Set<Tenant>();

    public DbSet<User> Users => Set<User>();

    public DbSet<Role> Roles => Set<Role>();

    public DbSet<Permission> Permissions => Set<Permission>();

    public DbSet<RolePermission> RolePermissions => Set<RolePermission>();

    public DbSet<UserRole> UserRoles => Set<UserRole>();

    public DbSet<UserLocation> UserLocations => Set<UserLocation>();

    public DbSet<Delegation> Delegations => Set<Delegation>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(IdentityDbContext).Assembly);
}

public sealed class IdentityDbContextFactory : IDesignTimeDbContextFactory<IdentityDbContext>
{
    public IdentityDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<IdentityDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), IdentityDbContext.MigrationsHistoryTable);
        return new IdentityDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
