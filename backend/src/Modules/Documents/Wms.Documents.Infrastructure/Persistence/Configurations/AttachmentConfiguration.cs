using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Documents.Domain;
using Wms.Documents.Domain.Entities;
using Wms.Documents.Domain.Enums;

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
        builder.Property(x => x.FileName).HasMaxLength(AttachmentPolicy.FileNameMaxLength).IsRequired();
        builder.Property(x => x.ContentType).HasMaxLength(120).IsRequired();
        builder.Property(x => x.StorageKey).HasMaxLength(AttachmentPolicy.StorageKeyMaxLength).IsRequired();

        // Spec §11 keeps this CHAR(64) NOT NULL; a PENDING row that has not been verified yet stores ''.
        builder.Property(x => x.ChecksumSha256).HasColumnType("char(64)").IsRequired();

        // Added by 20260922_Documents_AttachmentUpload: the presigned flow needs a row before the object exists.
        builder.Property(x => x.Status).HasMySqlEnum<AttachmentStatus>().IsRequired();
        builder.Property(x => x.ScanResult).HasMaxLength(200);

        builder.HasIndex(x => new { x.TenantId, x.EntityType, x.EntityId }).HasDatabaseName("ix_att");

        // Drives the orphan cleaner (spec §15) and keeps the "only READY rows are visible" reads cheap.
        builder.HasIndex(x => new { x.TenantId, x.Status, x.UploadedAt }).HasDatabaseName("ix_att_status");
    }
}
