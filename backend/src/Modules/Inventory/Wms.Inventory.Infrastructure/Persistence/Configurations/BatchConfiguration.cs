using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

public sealed class BatchConfiguration : IEntityTypeConfiguration<Batch>
{
    public void Configure(EntityTypeBuilder<Batch> builder)
    {
        builder.ToTable("inv_batch");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.BatchNo).HasMaxLength(Batch.BatchNoMaxLength).IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<BatchStatus>();
        builder.HasIndex(x => new { x.TenantId, x.ProductId, x.BatchNo, x.ExpiryDate }).IsUnique().HasDatabaseName("uq_batch");
        builder.HasIndex(x => new { x.TenantId, x.ProductId, x.Status, x.ExpiryDate, x.ReceivedAt }).HasDatabaseName("ix_batch_fefo");
    }
}
