using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Infrastructure.Persistence;

/// <summary>Schema <c>inv</c> (spec §9): table prefix <c>inv_</c>, own migrations folder and history table.</summary>
public sealed class InventoryDbContext(
    DbContextOptions<InventoryDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "inv_";
    public const string MigrationsHistoryTable = "__ef_migrations_inventory";

    public override string TablePrefix => Prefix;

    public DbSet<InventorySetting> Settings => Set<InventorySetting>();

    public DbSet<Batch> Batches => Set<Batch>();

    public DbSet<MovementGroup> MovementGroups => Set<MovementGroup>();

    public DbSet<Movement> Movements => Set<Movement>();

    public DbSet<StockBalance> Balances => Set<StockBalance>();

    public DbSet<GoodsReceipt> GoodsReceipts => Set<GoodsReceipt>();

    public DbSet<GoodsReceiptLine> GoodsReceiptLines => Set<GoodsReceiptLine>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(InventoryDbContext).Assembly);
}

public sealed class InventoryDbContextFactory : IDesignTimeDbContextFactory<InventoryDbContext>
{
    public InventoryDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<InventoryDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), InventoryDbContext.MigrationsHistoryTable);
        return new InventoryDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
