using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Infrastructure.Persistence.Configurations;

public sealed class RequisitionConfiguration : IEntityTypeConfiguration<Requisition>
{
    public void Configure(EntityTypeBuilder<Requisition> builder)
    {
        builder.ToTable("proc_requisition");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(Requisition.DocNoMaxLength).IsRequired();
        builder.Property(x => x.ProductType).HasMySqlEnum<ProductType>();
        builder.Property(x => x.Priority).HasMySqlEnum<Priority>();
        builder.Property(x => x.Status).HasMySqlEnum<RequisitionStatus>();
        builder.Property(x => x.Note).HasMaxLength(Requisition.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_pr");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.RequisitionId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class RequisitionLineConfiguration : IEntityTypeConfiguration<RequisitionLine>
{
    public void Configure(EntityTypeBuilder<RequisitionLine> builder)
    {
        builder.ToTable("proc_requisition_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Note).HasMaxLength(RequisitionLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.RequisitionId, x.LineNo }).IsUnique().HasDatabaseName("uq_prl");
    }
}

public sealed class PurchaseOrderConfiguration : IEntityTypeConfiguration<PurchaseOrder>
{
    public void Configure(EntityTypeBuilder<PurchaseOrder> builder)
    {
        builder.ToTable("proc_purchase_order");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(PurchaseOrder.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Currency).HasColumnType("char(3)").IsRequired();
        builder.Property(x => x.FxRate).HasPrecision(18, 8);
        builder.Property(x => x.Incoterms).HasMaxLength(16);
        builder.Property(x => x.Status).HasMySqlEnum<PurchaseOrderStatus>();
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_po");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.PoId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class PurchaseOrderLineConfiguration : IEntityTypeConfiguration<PurchaseOrderLine>
{
    public void Configure(EntityTypeBuilder<PurchaseOrderLine> builder)
    {
        builder.ToTable("proc_purchase_order_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.VatRate).HasPrecision(9, 4);
        builder.HasIndex(x => new { x.TenantId, x.PoId, x.LineNo }).IsUnique().HasDatabaseName("uq_pol");
    }
}

public sealed class ApprovalRuleConfiguration : IEntityTypeConfiguration<ApprovalRule>
{
    public void Configure(EntityTypeBuilder<ApprovalRule> builder)
    {
        builder.ToTable("proc_approval_rule");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocType).HasMaxLength(24).IsRequired();
        builder.Property(x => x.ProductType).HasMySqlEnum<ApprovalProductType>();
        builder.HasIndex(x => new { x.TenantId, x.DocType, x.ProductType, x.MinAmountBase }).HasDatabaseName("ix_rule");
    }
}

public sealed class ApprovalInstanceConfiguration : IEntityTypeConfiguration<ApprovalInstance>
{
    public void Configure(EntityTypeBuilder<ApprovalInstance> builder)
    {
        builder.ToTable("proc_approval_instance");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocType).HasMaxLength(24).IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<ApprovalStatus>();
        builder.HasIndex(x => new { x.TenantId, x.DocType, x.DocId }).HasDatabaseName("ix_ai");

        builder.HasMany(x => x.Steps).WithOne().HasForeignKey(s => s.InstanceId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Steps).HasField("_steps").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class ApprovalStepConfiguration : IEntityTypeConfiguration<ApprovalStep>
{
    public void Configure(EntityTypeBuilder<ApprovalStep> builder)
    {
        builder.ToTable("proc_approval_step");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Decision).HasMySqlEnum<ApprovalDecision>();
        builder.Property(x => x.Comment).HasMaxLength(ApprovalStep.CommentMaxLength);
        builder.HasIndex(x => new { x.InstanceId, x.StepNo }).HasDatabaseName("ix_as");
    }
}
