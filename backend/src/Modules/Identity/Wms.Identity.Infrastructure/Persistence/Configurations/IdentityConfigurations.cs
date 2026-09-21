using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Identity.Domain.Entities;

namespace Wms.Identity.Infrastructure.Persistence.Configurations;

public sealed class TenantConfiguration : IEntityTypeConfiguration<Tenant>
{
    public void Configure(EntityTypeBuilder<Tenant> builder)
    {
        builder.ToTable("iam_tenant");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.DefaultCurrency).HasColumnType("char(3)").IsRequired();
        builder.Property(x => x.Timezone).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Locale).HasMaxLength(10).IsRequired();
        // Not tenant-scoped: iam_tenant IS the tenant, so uq_tenant_code has no tenant_id prefix (spec §7).
        builder.HasIndex(x => x.Code).IsUnique().HasDatabaseName("uq_tenant_code");
    }
}

public sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("iam_user");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.ExternalId).HasMaxLength(64).IsRequired();
        builder.Property(x => x.Username).HasMaxLength(100).IsRequired();
        builder.Property(x => x.FullName).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Email).HasMaxLength(200);
        builder.Property(x => x.Phone).HasMaxLength(32);
        builder.HasIndex(x => new { x.TenantId, x.Username }).IsUnique().HasDatabaseName("uq_user_username");
        builder.HasIndex(x => new { x.TenantId, x.ExternalId }).IsUnique().HasDatabaseName("uq_user_external");

        builder.HasMany(x => x.Roles).WithOne().HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Roles).HasField("_roles").UsePropertyAccessMode(PropertyAccessMode.Field);
        builder.HasMany(x => x.Locations).WithOne().HasForeignKey(l => l.UserId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Locations).HasField("_locations").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class RoleConfiguration : IEntityTypeConfiguration<Role>
{
    public void Configure(EntityTypeBuilder<Role> builder)
    {
        builder.ToTable("iam_role");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(48).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(120).IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_role_code");
    }
}

public sealed class PermissionConfiguration : IEntityTypeConfiguration<Permission>
{
    public void Configure(EntityTypeBuilder<Permission> builder)
    {
        builder.ToTable("iam_permission");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Module).HasMaxLength(32).IsRequired();
        // Global catalogue shared by all tenants: the unique key is the code alone (spec §7).
        builder.HasIndex(x => x.Code).IsUnique().HasDatabaseName("uq_perm_code");
    }
}

public sealed class RolePermissionConfiguration : IEntityTypeConfiguration<RolePermission>
{
    public void Configure(EntityTypeBuilder<RolePermission> builder)
    {
        builder.ToTable("iam_role_permission");
        builder.HasKey(x => new { x.RoleId, x.PermissionId });
    }
}

public sealed class UserRoleConfiguration : IEntityTypeConfiguration<UserRole>
{
    public void Configure(EntityTypeBuilder<UserRole> builder)
    {
        builder.ToTable("iam_user_role");
        builder.HasKey(x => new { x.UserId, x.RoleId });
    }
}

public sealed class UserLocationConfiguration : IEntityTypeConfiguration<UserLocation>
{
    public void Configure(EntityTypeBuilder<UserLocation> builder)
    {
        builder.ToTable("iam_user_location");
        builder.HasKey(x => new { x.UserId, x.LocationId });
    }
}

public sealed class DelegationConfiguration : IEntityTypeConfiguration<Delegation>
{
    public void Configure(EntityTypeBuilder<Delegation> builder)
    {
        builder.ToTable("iam_delegation");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Reason).HasMaxLength(300);
        builder.HasIndex(x => new { x.TenantId, x.FromUserId, x.ValidFrom, x.ValidTo }).HasDatabaseName("ix_deleg");
    }
}
