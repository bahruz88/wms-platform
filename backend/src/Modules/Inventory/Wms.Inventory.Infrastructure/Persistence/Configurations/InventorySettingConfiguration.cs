using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Infrastructure.Persistence.Configurations;

public sealed class InventorySettingConfiguration : IEntityTypeConfiguration<InventorySetting>
{
    public void Configure(EntityTypeBuilder<InventorySetting> builder)
    {
        builder.ToTable("inv_setting");
        builder.HasKey(x => new { x.TenantId, x.Key });
        builder.Property(x => x.Key).HasColumnName("setting_key").HasMaxLength(64).IsRequired();
        builder.Property(x => x.Value).HasColumnName("setting_value").HasMaxLength(500).IsRequired();
    }
}
