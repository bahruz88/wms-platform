using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Infrastructure.Persistence.Configurations;

public sealed class NotificationMessageConfiguration : IEntityTypeConfiguration<NotificationMessage>
{
    public void Configure(EntityTypeBuilder<NotificationMessage> builder)
    {
        builder.ToTable("notif_message");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.EventId).HasColumnType("char(36)");
        builder.Property(x => x.EventType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.RecipientRole).HasMaxLength(48);
        builder.Property(x => x.Channel).HasMaxLength(16).IsRequired();
        builder.Property(x => x.Severity).HasMySqlEnum<NotificationSeverity>();
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Body).HasMaxLength(2000).IsRequired();
        builder.Property(x => x.Link).HasMaxLength(300);
        builder.Property(x => x.EntityType).HasMaxLength(60);
        // Consumer idempotency (spec §14.1): one message per event per recipient.
        builder.HasIndex(x => new { x.TenantId, x.EventId, x.RecipientUserId, x.RecipientRole }).IsUnique().HasDatabaseName("uq_notif_event");
        builder.HasIndex(x => new { x.TenantId, x.RecipientUserId, x.ReadAt }).HasDatabaseName("ix_notif_inbox");
    }
}

public sealed class NotificationRuleConfiguration : IEntityTypeConfiguration<NotificationRule>
{
    public void Configure(EntityTypeBuilder<NotificationRule> builder)
    {
        builder.ToTable("notif_rule");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.EventType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.Severity).HasMySqlEnum<NotificationSeverity>();
        builder.Property(x => x.Channels).HasMaxLength(48).IsRequired();
        builder.Property(x => x.TargetRoleCode).HasMaxLength(NotificationRule.RoleCodeMaxLength);
        builder.Property(x => x.TargetUserIds).HasMaxLength(500);
        builder.Property(x => x.Digest).HasMySqlEnum<NotificationDigest>();
        // One rule per event per target: a duplicate would deliver the same alert twice.
        builder.HasIndex(x => new { x.TenantId, x.EventType, x.TargetRoleCode }).IsUnique().HasDatabaseName("uq_notif_rule");
    }
}

public sealed class NotificationDeviceConfiguration : IEntityTypeConfiguration<NotificationDevice>
{
    public void Configure(EntityTypeBuilder<NotificationDevice> builder)
    {
        builder.ToTable("notif_device");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DeviceId).HasMaxLength(NotificationDevice.DeviceIdMaxLength).IsRequired();
        builder.Property(x => x.Platform).HasMySqlEnum<DevicePlatform>();
        builder.Property(x => x.PushToken).HasMaxLength(NotificationDevice.PushTokenMaxLength).IsRequired();
        builder.Property(x => x.AppVersion).HasMaxLength(NotificationDevice.AppVersionMaxLength);
        // A handset registers once per user: re-registering refreshes the token instead of adding a row.
        builder.HasIndex(x => new { x.TenantId, x.UserId, x.DeviceId }).IsUnique().HasDatabaseName("uq_notif_device");
    }
}
