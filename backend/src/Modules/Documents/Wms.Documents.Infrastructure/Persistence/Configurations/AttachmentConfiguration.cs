using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Documents.Domain.Entities;

namespace Wms.Documents.Infrastructure.Persistence.Configurations;

public sealed class AttachmentConfiguration : IEntityTypeConfiguration<Attachment>
{
    public void Configure(EntityTypeBuilder<Attachment> builder)
    {
        // Shared table of spec §11: keeps the common_ prefix, owned by this module's migrations.
        builder.ToTable("common_attachment");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.EntityType).HasMaxLength(80).IsRequired();
        builder.Property(x => x.AttachmentType).HasMaxLength(48).IsRequired();
        builder.Property(x => x.FileName).HasMaxLength(300).IsRequired();
        builder.Property(x => x.ContentType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.StorageKey).HasMaxLength(500).IsRequired();
        builder.Property(x => x.ChecksumSha256).HasColumnType("char(64)").IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.EntityType, x.EntityId }).HasDatabaseName("ix_att");
    }
}
