using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

public sealed class GoodsReceiptConfiguration : IEntityTypeConfiguration<GoodsReceipt>
{
    public void Configure(EntityTypeBuilder<GoodsReceipt> builder)
    {
        builder.ToTable("inv_goods_receipt");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(GoodsReceipt.DocNoMaxLength).IsRequired();
        builder.Property(x => x.TemperatureC).HasPrecision(6, 2);
        builder.Property(x => x.QualityStatus).HasMySqlEnum<QualityStatus>();
        builder.Property(x => x.PackagingNote).HasMaxLength(GoodsReceipt.PackagingNoteMaxLength);
        builder.Property(x => x.Status).HasMySqlEnum<ReceiptStatus>();
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_gr");

        builder.HasMany(x => x.Lines)
            .WithOne()
            .HasForeignKey(l => l.ReceiptId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class GoodsReceiptLineConfiguration : IEntityTypeConfiguration<GoodsReceiptLine>
{
    public void Configure(EntityTypeBuilder<GoodsReceiptLine> builder)
    {
        builder.ToTable("inv_goods_receipt_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.BatchNo).HasMaxLength(GoodsReceiptLine.BatchNoMaxLength);
        builder.Property(x => x.Currency).HasColumnType("char(3)");
        builder.Property(x => x.VarianceNote).HasMaxLength(GoodsReceiptLine.VarianceNoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.ReceiptId, x.LineNo }).IsUnique().HasDatabaseName("uq_grl");
    }
}
