using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Integration.Domain.Entities;

namespace Wms.Integration.Infrastructure.Persistence.Configurations;

public sealed class IntegrationEndpointConfiguration : IEntityTypeConfiguration<IntegrationEndpoint>
{
    public void Configure(EntityTypeBuilder<IntegrationEndpoint> builder)
    {
        builder.ToTable("intg_endpoint");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.SystemCode).HasMaxLength(32).IsRequired();
        builder.Property(x => x.BaseUrl).HasMaxLength(500).IsRequired();
        builder.Property(x => x.AuthRef).HasMaxLength(200);
        builder.HasIndex(x => new { x.TenantId, x.SystemCode }).IsUnique().HasDatabaseName("uq_intg_endpoint");
    }
}

public sealed class OutboundMessageConfiguration : IEntityTypeConfiguration<OutboundMessage>
{
    public void Configure(EntityTypeBuilder<OutboundMessage> builder)
    {
        builder.ToTable("intg_outbound_message");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.SystemCode).HasMaxLength(32).IsRequired();
        builder.Property(x => x.EventId).HasColumnType("char(36)");
        builder.Property(x => x.EventType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.Payload).HasColumnType("json").IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<OutboundStatus>();
        builder.Property(x => x.LastError).HasColumnType("text");
        // Consumer idempotency (spec §14.1).
        builder.HasIndex(x => new { x.TenantId, x.SystemCode, x.EventId }).IsUnique().HasDatabaseName("uq_intg_event");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.Id }).HasDatabaseName("ix_intg_pending");
    }
}

public sealed class SyncCursorConfiguration : IEntityTypeConfiguration<SyncCursor>
{
    public void Configure(EntityTypeBuilder<SyncCursor> builder)
    {
        builder.ToTable("intg_sync_cursor");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.SystemCode).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Resource).HasMaxLength(64).IsRequired();
        builder.Property(x => x.LastCursor).HasMaxLength(200);
        builder.HasIndex(x => new { x.TenantId, x.SystemCode, x.Resource }).IsUnique().HasDatabaseName("uq_intg_cursor");
    }
}
