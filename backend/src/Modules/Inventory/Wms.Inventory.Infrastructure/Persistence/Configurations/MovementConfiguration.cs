using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

/// <summary>
/// <c>inv_movement</c> — append-only ledger (spec §9.4). The DB user of the API only gets SELECT, INSERT on it.
/// NOTE: the spec's <c>PARTITION BY RANGE (YEAR(posted_at))</c> is not expressible in EF Core and is added by hand
/// in the initial migration (see README); the spec's <c>uq_mv_line</c> is prefixed with tenant_id per §6.5.
/// </summary>
public sealed class MovementConfiguration : IEntityTypeConfiguration<Movement>
{
    public void Configure(EntityTypeBuilder<Movement> builder)
    {
        builder.ToTable("inv_movement");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.ConversionRate).HasPrecision(18, 8);
        builder.Property(x => x.FxRate).HasPrecision(18, 8);
        builder.Property(x => x.Currency).HasColumnType("char(3)");

        builder.HasIndex(x => new { x.TenantId, x.GroupId, x.LineNo }).IsUnique().HasDatabaseName("uq_mv_line");
        builder.HasIndex(x => new { x.TenantId, x.ProductId, x.LocationId, x.BatchId, x.Id }).HasDatabaseName("ix_mv_balance");
        builder.HasIndex(x => new { x.TenantId, x.PostedAt }).HasDatabaseName("ix_mv_posted");
    }
}
