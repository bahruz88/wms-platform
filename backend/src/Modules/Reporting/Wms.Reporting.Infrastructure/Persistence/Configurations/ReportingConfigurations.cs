using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Reporting.Domain.Entities;

namespace Wms.Reporting.Infrastructure.Persistence.Configurations;

public sealed class StockSnapshotConfiguration : IEntityTypeConfiguration<StockSnapshot>
{
    public void Configure(EntityTypeBuilder<StockSnapshot> builder)
    {
        builder.ToTable("rpt_stock_snapshot");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.HasIndex(x => new { x.TenantId, x.SnapshotDate, x.ProductId, x.LocationId }).IsUnique().HasDatabaseName("uq_rpt_snapshot");
        builder.HasIndex(x => new { x.TenantId, x.SnapshotDate, x.LocationId }).HasDatabaseName("ix_rpt_snapshot_loc");
    }
}

public sealed class ReportDefinitionConfiguration : IEntityTypeConfiguration<ReportDefinition>
{
    public void Configure(EntityTypeBuilder<ReportDefinition> builder)
    {
        builder.ToTable("rpt_report_definition");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(48).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Category).HasMaxLength(64).IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_rpt_report");
    }
}
