using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

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
        builder.Property(x => x.Description).HasMaxLength(1000);
        builder.Property(x => x.Category).HasMaxLength(64).IsRequired();
        builder.Property(x => x.TorRef).HasMaxLength(32);
        builder.Property(x => x.SupportedFormats).HasMaxLength(64).IsRequired();
        builder.Property(x => x.ParametersJson).HasColumnType("json").IsRequired();
        builder.Property(x => x.ColumnsJson).HasColumnType("json").IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_rpt_report");
        builder.HasIndex(x => new { x.TenantId, x.Category, x.SortOrder }).HasDatabaseName("ix_rpt_report_cat");
    }
}

/// <summary><c>rpt_export_job</c> (reporting.v1.yaml Exports).</summary>
public sealed class ExportJobConfiguration : IEntityTypeConfiguration<ExportJob>
{
    public void Configure(EntityTypeBuilder<ExportJob> builder)
    {
        builder.ToTable("rpt_export_job");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.ReportCode).HasMaxLength(48).IsRequired();
        builder.Property(x => x.Format).HasMySqlEnum<ExportFormat>();
        builder.Property(x => x.Status).HasMySqlEnum<ExportStatus>();
        builder.Property(x => x.FileName).HasMaxLength(200);
        builder.Property(x => x.StorageKey).HasMaxLength(500);
        builder.Property(x => x.ErrorMessage).HasMaxLength(1000);
        builder.Property(x => x.ParametersJson).HasColumnType("json").IsRequired();
        builder.Property(x => x.LocationScopeJson).HasColumnType("json");
        builder.Property(x => x.Locale).HasMaxLength(16);
        builder.Property(x => x.IdempotencyKey).HasColumnType("char(36)").HasMaxLength(36);
        builder.HasIndex(x => new { x.TenantId, x.RequestedBy, x.IdempotencyKey }).IsUnique().HasDatabaseName("uq_rpt_export_idem");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.RequestedAt }).HasDatabaseName("ix_rpt_export_status");
        builder.HasIndex(x => new { x.TenantId, x.RequestedBy, x.RequestedAt }).HasDatabaseName("ix_rpt_export_user");
    }
}
