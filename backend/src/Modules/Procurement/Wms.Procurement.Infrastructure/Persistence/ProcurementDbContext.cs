using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Procurement.Domain.Entities;

namespace Wms.Procurement.Infrastructure.Persistence;

/// <summary>Schema <c>proc</c> (spec §10): table prefix <c>proc_</c>.</summary>
public sealed class ProcurementDbContext(
    DbContextOptions<ProcurementDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "proc_";
    public const string MigrationsHistoryTable = "__ef_migrations_procurement";

    public override string TablePrefix => Prefix;

    public DbSet<Requisition> Requisitions => Set<Requisition>();

    public DbSet<RequisitionLine> RequisitionLines => Set<RequisitionLine>();

    public DbSet<Rfq> Rfqs => Set<Rfq>();

    public DbSet<RfqLine> RfqLines => Set<RfqLine>();

    public DbSet<RfqSupplier> RfqSuppliers => Set<RfqSupplier>();

    public DbSet<Quotation> Quotations => Set<Quotation>();

    public DbSet<QuotationLine> QuotationLines => Set<QuotationLine>();

    public DbSet<PurchaseOrder> PurchaseOrders => Set<PurchaseOrder>();

    public DbSet<PurchaseOrderLine> PurchaseOrderLines => Set<PurchaseOrderLine>();

    public DbSet<ApprovalRule> ApprovalRules => Set<ApprovalRule>();

    public DbSet<ApprovalInstance> ApprovalInstances => Set<ApprovalInstance>();

    public DbSet<ApprovalStep> ApprovalSteps => Set<ApprovalStep>();

    public DbSet<PriceHistoryEntry> PriceHistory => Set<PriceHistoryEntry>();

    public DbSet<SplitCheckLog> SplitCheckLogs => Set<SplitCheckLog>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ProcurementDbContext).Assembly);
}

public sealed class ProcurementDbContextFactory : IDesignTimeDbContextFactory<ProcurementDbContext>
{
    public ProcurementDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<ProcurementDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), ProcurementDbContext.MigrationsHistoryTable);
        return new ProcurementDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
