using Wms.Common.Application.Auditing;
using Wms.Common.Infrastructure.Audit;
using Wms.Common.Infrastructure.Outbox;

namespace Wms.Common.Infrastructure.Persistence;

/// <summary>
/// <c>common_outbox</c> and <c>common_audit_log</c> (spec §11). Every module context maps them so rows are written
/// inside the module's transaction; only <see cref="CommonDbContext"/> owns their migrations.
/// </summary>
public static class CommonTables
{
    public const string Prefix = "common_";
    public const string OutboxTable = "common_outbox";
    public const string AuditLogTable = "common_audit_log";

    public static void Configure(ModelBuilder modelBuilder, bool excludeFromMigrations)
    {
        ArgumentNullException.ThrowIfNull(modelBuilder);

        modelBuilder.Entity<OutboxMessage>(b =>
        {
            b.ToTable(OutboxTable, t => t.ExcludeFromMigrations(excludeFromMigrations));
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).ValueGeneratedOnAdd();
            b.Property(x => x.EventType).HasMaxLength(120).IsRequired();
            b.Property(x => x.Payload).HasColumnType("json").IsRequired();
            // Spec §11: attempt_count SMALLINT UNSIGNED NOT NULL DEFAULT 0.
            b.Property(x => x.AttemptCount).HasDefaultValue((ushort)0).ValueGeneratedNever();
            b.Property(x => x.LastError).HasColumnType("text");
            b.HasIndex(x => new { x.ProcessedAt, x.Id }).HasDatabaseName("ix_outbox_pending");
        });

        modelBuilder.Entity<AuditLogEntry>(b =>
        {
            b.ToTable(AuditLogTable, t => t.ExcludeFromMigrations(excludeFromMigrations));
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).ValueGeneratedOnAdd();
            b.Property(x => x.EntityType).HasMaxLength(80).IsRequired();
            b.Property(x => x.Action).HasMySqlEnum<AuditAction>();
            b.Property(x => x.Changes).HasColumnType("json");
            b.Property(x => x.IpAddress).HasMaxLength(45);
            b.HasIndex(x => new { x.TenantId, x.EntityType, x.EntityId, x.OccurredAt }).HasDatabaseName("ix_audit");
        });
    }
}
