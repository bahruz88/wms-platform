using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

/// <summary><c>inv_balance</c> projection (spec §9.5). Composite PK starts with tenant_id.</summary>
public sealed class StockBalanceConfiguration : IEntityTypeConfiguration<StockBalance>
{
    public void Configure(EntityTypeBuilder<StockBalance> builder)
    {
        builder.ToTable("inv_balance");
        builder.HasKey(x => new { x.TenantId, x.ProductId, x.LocationId, x.BatchId });
        builder.Property(x => x.BatchId).HasDefaultValue(StockBalance.NoBatch);
        builder.Property(x => x.QtyOnHand).HasDefaultValue(0m);
        builder.Property(x => x.QtyReserved).HasDefaultValue(0m);
        builder.Property(x => x.AvgUnitCost).HasDefaultValue(0m);
        builder.HasIndex(x => new { x.TenantId, x.LocationId, x.ProductId }).HasDatabaseName("ix_bal_loc");
    }
}
