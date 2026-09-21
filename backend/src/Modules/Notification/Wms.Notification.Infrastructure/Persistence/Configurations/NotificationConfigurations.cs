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
        builder.Property(x => x.RecipientRole).HasMaxLength(48).IsRequired();
        builder.Property(x => x.Channel).HasMaxLength(16).IsRequired();
        builder.Property(x => x.Severity).HasMySqlEnum<NotificationSeverity>();
        builder.HasIndex(x => new { x.TenantId, x.EventType, x.RecipientRole, x.Channel }).IsUnique().HasDatabaseName("uq_notif_rule");
    }
}
