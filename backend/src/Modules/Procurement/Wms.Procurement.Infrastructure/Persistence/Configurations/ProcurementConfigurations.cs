using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Infrastructure.Persistence;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Infrastructure.Persistence.Configurations;

public sealed class RequisitionConfiguration : IEntityTypeConfiguration<Requisition>
{
    public void Configure(EntityTypeBuilder<Requisition> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_requisition");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(Requisition.DocNoMaxLength).IsRequired();
        builder.Property(x => x.ProductType).HasMySqlEnum<ProductType>();
        builder.Property(x => x.Priority).HasMySqlEnum<Priority>();
        builder.Property(x => x.Status).HasMySqlEnum<RequisitionStatus>();
        builder.Property(x => x.Note).HasMaxLength(Requisition.NoteMaxLength);
        builder.Property(x => x.RejectComment).HasMaxLength(Requisition.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_pr");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.DocDate }).HasDatabaseName("ix_pr_status");
        builder.HasIndex(x => new { x.TenantId, x.RequesterLocationId, x.DocDate }).HasDatabaseName("ix_pr_location");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.RequisitionId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class RequisitionLineConfiguration : IEntityTypeConfiguration<RequisitionLine>
{
    public void Configure(EntityTypeBuilder<RequisitionLine> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_requisition_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Note).HasMaxLength(RequisitionLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.RequisitionId, x.LineNo }).IsUnique().HasDatabaseName("uq_prl");
        builder.HasIndex(x => new { x.TenantId, x.ProductId }).HasDatabaseName("ix_prl_product");
    }
}

public sealed class RfqConfiguration : IEntityTypeConfiguration<Rfq>
{
    public void Configure(EntityTypeBuilder<Rfq> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_rfq");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(Rfq.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<RfqStatus>();
        builder.Property(x => x.Note).HasMaxLength(Rfq.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_rfq");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.DocDate }).HasDatabaseName("ix_rfq_status");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.RfqId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
        builder.HasMany(x => x.Suppliers).WithOne().HasForeignKey(s => s.RfqId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Suppliers).HasField("_suppliers").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class RfqLineConfiguration : IEntityTypeConfiguration<RfqLine>
{
    public void Configure(EntityTypeBuilder<RfqLine> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_rfq_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Note).HasMaxLength(RfqLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.RfqId, x.LineNo }).IsUnique().HasDatabaseName("uq_rfql");
        builder.HasIndex(x => new { x.TenantId, x.RequisitionLineId }).HasDatabaseName("ix_rfql_pr_line");
    }
}

public sealed class RfqSupplierConfiguration : IEntityTypeConfiguration<RfqSupplier>
{
    public void Configure(EntityTypeBuilder<RfqSupplier> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_rfq_supplier");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.HasIndex(x => new { x.TenantId, x.RfqId, x.SupplierId }).IsUnique().HasDatabaseName("uq_rfqs");
    }
}

public sealed class QuotationConfiguration : IEntityTypeConfiguration<Quotation>
{
    public void Configure(EntityTypeBuilder<Quotation> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_quotation");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.QuoteNo).HasMaxLength(Quotation.QuoteNoMaxLength);
        builder.Property(x => x.Currency).HasColumnType("char(3)").IsRequired();
        builder.Property(x => x.FxRate).HasPrecision(18, 8);
        builder.Property(x => x.PaymentTerms).HasMaxLength(Quotation.PaymentTermsMaxLength);
        builder.Property(x => x.SelectionNote).HasMaxLength(Quotation.SelectionNoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.RfqId, x.SupplierId }).HasDatabaseName("ix_quote");
        builder.HasIndex(x => new { x.TenantId, x.SupplierId, x.QuoteDate }).HasDatabaseName("ix_quote_supplier");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.QuotationId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class QuotationLineConfiguration : IEntityTypeConfiguration<QuotationLine>
{
    public void Configure(EntityTypeBuilder<QuotationLine> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_quotation_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Note).HasMaxLength(QuotationLine.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.QuotationId, x.LineNo }).IsUnique().HasDatabaseName("uq_quotel");
        builder.HasIndex(x => new { x.TenantId, x.RfqLineId }).HasDatabaseName("ix_quotel_rfq_line");
    }
}

public sealed class PurchaseOrderConfiguration : IEntityTypeConfiguration<PurchaseOrder>
{
    public void Configure(EntityTypeBuilder<PurchaseOrder> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_purchase_order");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(PurchaseOrder.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Currency).HasColumnType("char(3)").IsRequired();
        builder.Property(x => x.FxRate).HasPrecision(18, 8);
        builder.Property(x => x.Incoterms).HasMaxLength(PurchaseOrder.IncotermsMaxLength);
        builder.Property(x => x.PaymentTerms).HasMaxLength(PurchaseOrder.PaymentTermsMaxLength);
        builder.Property(x => x.Note).HasMaxLength(PurchaseOrder.NoteMaxLength);
        builder.Property(x => x.RejectComment).HasMaxLength(PurchaseOrder.NoteMaxLength);
        builder.Property(x => x.SplitCheckWarning).HasMaxLength(PurchaseOrder.SplitCheckWarningMaxLength);
        builder.Property(x => x.ProductType).HasMySqlEnum<ProductType>();
        builder.Property(x => x.Status).HasMySqlEnum<PurchaseOrderStatus>();
        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_po");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.DocDate }).HasDatabaseName("ix_po_status");
        builder.HasIndex(x => new { x.TenantId, x.SupplierId, x.DocDate }).HasDatabaseName("ix_po_supplier");

        builder.HasMany(x => x.Lines).WithOne().HasForeignKey(l => l.PoId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class PurchaseOrderLineConfiguration : IEntityTypeConfiguration<PurchaseOrderLine>
{
    public void Configure(EntityTypeBuilder<PurchaseOrderLine> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_purchase_order_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.VatRate).HasPrecision(9, 4);
        builder.HasIndex(x => new { x.TenantId, x.PoId, x.LineNo }).IsUnique().HasDatabaseName("uq_pol");
        builder.HasIndex(x => new { x.TenantId, x.RequisitionLineId }).HasDatabaseName("ix_pol_pr_line");
    }
}

public sealed class ApprovalRuleConfiguration : IEntityTypeConfiguration<ApprovalRule>
{
    public void Configure(EntityTypeBuilder<ApprovalRule> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_approval_rule");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();

        // spec §10 keeps doc_type a VARCHAR(24), not a MySQL ENUM, so new document types need no DDL change.
        builder.Property(x => x.DocType)
            .HasConversion(new UpperSnakeCaseEnumConverter<ApprovalDocType>())
            .HasMaxLength(24)
            .IsRequired();
        builder.Property(x => x.ProductType).HasMySqlEnum<ApprovalProductType>();
        builder.Property(x => x.ApproverRoleCode).HasMaxLength(ApprovalRule.RoleCodeMaxLength).IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.DocType, x.ProductType, x.MinAmountBase }).HasDatabaseName("ix_rule");
    }
}

public sealed class ApprovalInstanceConfiguration : IEntityTypeConfiguration<ApprovalInstance>
{
    public void Configure(EntityTypeBuilder<ApprovalInstance> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_approval_instance");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocType)
            .HasConversion(new UpperSnakeCaseEnumConverter<ApprovalDocType>())
            .HasMaxLength(24)
            .IsRequired();
        builder.Property(x => x.DocNo).HasMaxLength(ApprovalInstance.DocNoMaxLength).IsRequired();
        builder.Property(x => x.RequestedByUsername).HasMaxLength(ApprovalInstance.UsernameMaxLength);
        builder.Property(x => x.Status).HasMySqlEnum<ApprovalStatus>();
        builder.HasIndex(x => new { x.TenantId, x.DocType, x.DocId }).HasDatabaseName("ix_ai");
        builder.HasIndex(x => new { x.TenantId, x.Status }).HasDatabaseName("ix_ai_status");

        builder.HasMany(x => x.Steps).WithOne().HasForeignKey(s => s.InstanceId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Steps).HasField("_steps").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class ApprovalStepConfiguration : IEntityTypeConfiguration<ApprovalStep>
{
    public void Configure(EntityTypeBuilder<ApprovalStep> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_approval_step");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.ApproverRoleCode).HasMaxLength(ApprovalRule.RoleCodeMaxLength).IsRequired();
        builder.Property(x => x.ApproverUsername).HasMaxLength(ApprovalInstance.UsernameMaxLength);
        builder.Property(x => x.DelegatedFromUsername).HasMaxLength(ApprovalInstance.UsernameMaxLength);
        builder.Property(x => x.Decision).HasMySqlEnum<ApprovalDecision>();
        builder.Property(x => x.Comment).HasMaxLength(ApprovalStep.CommentMaxLength);
        builder.HasIndex(x => new { x.InstanceId, x.StepNo }).HasDatabaseName("ix_as");
        builder.HasIndex(x => new { x.ApproverRoleCode, x.Decision }).HasDatabaseName("ix_as_pending");
    }
}

public sealed class PriceHistoryEntryConfiguration : IEntityTypeConfiguration<PriceHistoryEntry>
{
    public void Configure(EntityTypeBuilder<PriceHistoryEntry> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_price_history");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Currency).HasColumnType("char(3)").IsRequired();
        builder.Property(x => x.DiffPct).HasPrecision(9, 4);
        builder.HasIndex(x => new { x.TenantId, x.ProductId, x.SupplierId, x.PriceDate }).HasDatabaseName("ix_ph");
        builder.HasIndex(x => new { x.TenantId, x.PriceDate }).HasDatabaseName("ix_ph_date");
    }
}

public sealed class SplitCheckLogConfiguration : IEntityTypeConfiguration<SplitCheckLog>
{
    public void Configure(EntityTypeBuilder<SplitCheckLog> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.ToTable("proc_split_check_log");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Note).HasMaxLength(SplitCheckLog.NoteMaxLength);
        builder.HasIndex(x => new { x.TenantId, x.SupplierId, x.WindowStart }).HasDatabaseName("ix_split");
    }
}
