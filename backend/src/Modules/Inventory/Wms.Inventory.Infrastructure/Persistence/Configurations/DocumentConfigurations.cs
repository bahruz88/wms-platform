using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

/// <summary><c>inv_stock_request</c> (spec §9.6, TOR §16).</summary>
public sealed class StockRequestConfiguration : IEntityTypeConfiguration<StockRequest>
{
    public void Configure(EntityTypeBuilder<StockRequest> builder)
    {
        builder.ToTable("inv_stock_request");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(StockRequest.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<StockRequestStatus>();
        builder.Property(x => x.Note).HasMaxLength(StockRequest.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_sr");
        builder.HasIndex(x => new { x.TenantId, x.ToLocationId, x.Status }).HasDatabaseName("ix_sr_to");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.RequestId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class StockRequestLineConfiguration : IEntityTypeConfiguration<StockRequestLine>
{
    public void Configure(EntityTypeBuilder<StockRequestLine> builder)
    {
        builder.ToTable("inv_stock_request_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.IssuedQty).HasDefaultValue(0m).ValueGeneratedNever();
        builder.Property(x => x.Note).HasMaxLength(StockRequestLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.RequestId, x.LineNo }).IsUnique().HasDatabaseName("uq_srl");
    }
}

/// <summary><c>inv_issue</c> (spec §9.6) — the two-step IN_TRANSIT document.</summary>
public sealed class IssueConfiguration : IEntityTypeConfiguration<Issue>
{
    public void Configure(EntityTypeBuilder<Issue> builder)
    {
        builder.ToTable("inv_issue");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(Issue.DocNoMaxLength).IsRequired();
        builder.Property(x => x.IssueType).HasMySqlEnum<IssueType>();
        builder.Property(x => x.Status).HasMySqlEnum<IssueStatus>();
        builder.Property(x => x.Note).HasMaxLength(Issue.NoteMaxLength);
        builder.Ignore(x => x.HasDiscrepancy);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_issue");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.ToLocationId }).HasDatabaseName("ix_issue_status");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.IssueId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class IssueLineConfiguration : IEntityTypeConfiguration<IssueLine>
{
    public void Configure(EntityTypeBuilder<IssueLine> builder)
    {
        builder.ToTable("inv_issue_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.QtyBase).HasDefaultValue(0m).ValueGeneratedNever();
        builder.Property(x => x.BatchOverrideNote).HasMaxLength(IssueLine.NoteMaxLength);
        builder.Property(x => x.DiscrepancyNote).HasMaxLength(IssueLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.IssueId, x.LineNo }).IsUnique().HasDatabaseName("uq_isl");
    }
}

/// <summary><c>inv_waste</c> (spec §9.6, TOR §22).</summary>
public sealed class WasteConfiguration : IEntityTypeConfiguration<Waste>
{
    public void Configure(EntityTypeBuilder<Waste> builder)
    {
        builder.ToTable("inv_waste");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(Waste.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<WasteStatus>();
        builder.Property(x => x.Note).HasMaxLength(Waste.NoteMaxLength);
        builder.Property(x => x.ApprovalComment).HasMaxLength(Waste.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_waste");
        builder.HasIndex(x => new { x.TenantId, x.LocationId, x.Status }).HasDatabaseName("ix_waste_loc");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.WasteId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class WasteLineConfiguration : IEntityTypeConfiguration<WasteLine>
{
    public void Configure(EntityTypeBuilder<WasteLine> builder)
    {
        builder.ToTable("inv_waste_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.QtyBase).HasDefaultValue(0m).ValueGeneratedNever();
        builder.Property(x => x.Note).HasMaxLength(WasteLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.WasteId, x.LineNo }).IsUnique().HasDatabaseName("uq_wl");
    }
}

/// <summary><c>inv_sample</c> (spec §9.6, TOR §23).</summary>
public sealed class SampleConfiguration : IEntityTypeConfiguration<Sample>
{
    public void Configure(EntityTypeBuilder<Sample> builder)
    {
        builder.ToTable("inv_sample");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(Sample.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Authority).HasMaxLength(Sample.AuthorityMaxLength).IsRequired();
        builder.Property(x => x.Purpose).HasMaxLength(Sample.PurposeMaxLength);
        builder.Ignore(x => x.Status);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_sample");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.SampleId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class SampleLineConfiguration : IEntityTypeConfiguration<SampleLine>
{
    public void Configure(EntityTypeBuilder<SampleLine> builder)
    {
        builder.ToTable("inv_sample_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.QtyBase).HasDefaultValue(0m).ValueGeneratedNever();
        builder.Property(x => x.Note).HasMaxLength(SampleLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.SampleId, x.LineNo }).IsUnique().HasDatabaseName("uq_sml");
    }
}

/// <summary><c>inv_return_to_vendor</c> (spec §9.6).</summary>
public sealed class ReturnToVendorConfiguration : IEntityTypeConfiguration<ReturnToVendor>
{
    public void Configure(EntityTypeBuilder<ReturnToVendor> builder)
    {
        builder.ToTable("inv_return_to_vendor");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(ReturnToVendor.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<RtvStatus>();
        builder.Property(x => x.Outcome).HasMaxLength(16);
        builder.Property(x => x.OutcomeNote).HasMaxLength(ReturnToVendor.NoteMaxLength);
        builder.Property(x => x.Note).HasMaxLength(ReturnToVendor.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_rtv");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.ReturnId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class ReturnToVendorLineConfiguration : IEntityTypeConfiguration<ReturnToVendorLine>
{
    public void Configure(EntityTypeBuilder<ReturnToVendorLine> builder)
    {
        builder.ToTable("inv_return_to_vendor_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.QtyBase).HasDefaultValue(0m).ValueGeneratedNever();
        builder.Property(x => x.Note).HasMaxLength(ReturnToVendorLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.ReturnId, x.LineNo }).IsUnique().HasDatabaseName("uq_rtvl");
    }
}
