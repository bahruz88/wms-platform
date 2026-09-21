using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

public sealed class MovementGroupConfiguration : IEntityTypeConfiguration<MovementGroup>
{
    public void Configure(EntityTypeBuilder<MovementGroup> builder)
    {
        builder.ToTable("inv_movement_group");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocType).HasMySqlEnum<DocType>();
        builder.Property(x => x.DocNo).HasMaxLength(MovementGroup.DocNoMaxLength).IsRequired();
        builder.Property(x => x.SourceDocType).HasMaxLength(24);
        builder.Property(x => x.Note).HasMaxLength(MovementGroup.NoteMaxLength);
        builder.Property(x => x.IdempotencyKey).HasColumnType("char(36)");

        builder.HasIndex(x => new { x.TenantId, x.DocType, x.DocNo }).IsUnique().HasDatabaseName("uq_mg_doc");
        builder.HasIndex(x => new { x.TenantId, x.IdempotencyKey }).IsUnique().HasDatabaseName("uq_mg_idem");
        builder.HasIndex(x => new { x.TenantId, x.SourceDocType, x.SourceDocId }).HasDatabaseName("ix_mg_src");

        builder.HasMany(x => x.Lines)
            .WithOne()
            .HasForeignKey(m => m.GroupId)
            .OnDelete(DeleteBehavior.Restrict);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}
