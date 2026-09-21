using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

/// <summary><c>inv_count</c> (spec §9.6). See backend README §8.11 for the two columns added beyond the SPEC DDL.</summary>
public sealed class StockCountConfiguration : IEntityTypeConfiguration<StockCount>
{
    public void Configure(EntityTypeBuilder<StockCount> builder)
    {
        builder.ToTable("inv_count");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(StockCount.DocNoMaxLength).IsRequired();
        builder.Property(x => x.CountType).HasMySqlEnum<CountType>();
        builder.Property(x => x.Status).HasMySqlEnum<CountStatus>();
        builder.Property(x => x.Note).HasMaxLength(StockCount.NoteMaxLength);
        builder.Property(x => x.ScopeCategoryIds).HasMaxLength(StockCount.ScopeMaxLength);
        builder.Property(x => x.ScopeProductIds).HasMaxLength(StockCount.ScopeMaxLength);
        builder.Property(x => x.RequiresApproval).HasDefaultValue(false).ValueGeneratedNever();

        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_count");
        builder.HasIndex(x => new { x.TenantId, x.LocationId, x.Status }).HasDatabaseName("ix_count_loc");

        builder.HasMany(x => x.Lines)
            .WithOne()
            .HasForeignKey(l => l.CountId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class StockCountLineConfiguration : IEntityTypeConfiguration<StockCountLine>
{
    public void Configure(EntityTypeBuilder<StockCountLine> builder)
    {
        builder.ToTable("inv_count_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.VariancePct).HasPrecision(9, 4);
        builder.Property(x => x.Note).HasMaxLength(StockCountLine.NoteMaxLength);
        builder.Property(x => x.AvgUnitCost).HasDefaultValue(0m).ValueGeneratedNever();
        builder.Ignore(x => x.IsCounted);
        builder.Ignore(x => x.HasVariance);

        builder.HasIndex(x => new { x.TenantId, x.CountId, x.ProductId }).HasDatabaseName("ix_cl");
        builder.HasIndex(x => new { x.TenantId, x.CountId, x.ProductId, x.BatchId }).IsUnique().HasDatabaseName("uq_cl_line");
    }
}
