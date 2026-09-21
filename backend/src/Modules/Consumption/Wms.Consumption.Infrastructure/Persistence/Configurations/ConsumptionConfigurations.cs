using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Infrastructure.Persistence.Configurations;

/// <summary><c>cons_menu_item</c> — branch-operations.md §4.</summary>
public sealed class MenuItemConfiguration : IEntityTypeConfiguration<MenuItem>
{
    public void Configure(EntityTypeBuilder<MenuItem> builder)
    {
        builder.ToTable("cons_menu_item");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(MenuItem.CodeMaxLength).IsRequired();
        builder.Property(x => x.PosCode).HasMaxLength(MenuItem.PosCodeMaxLength);
        builder.Property(x => x.Name).HasMaxLength(MenuItem.NameMaxLength).IsRequired();
        builder.Property(x => x.NameSortKey).HasMaxLength(AzerbaijaniSortKey.MaxLength).IsRequired();
        builder.Property(x => x.Category).HasMaxLength(MenuItem.CategoryMaxLength);
        builder.Property(x => x.IsSubRecipe).HasDefaultValue(false).ValueGeneratedNever();
        builder.Property(x => x.IsActive).HasDefaultValue(true).ValueGeneratedNever();

        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_menu_code");
        builder.HasIndex(x => new { x.TenantId, x.PosCode }).IsUnique().HasDatabaseName("uq_menu_pos");
        builder.HasIndex(x => new { x.TenantId, x.NameSortKey }).HasDatabaseName("ix_menu_name");
    }
}

/// <summary><c>cons_recipe</c> — one version, effective between <c>valid_from</c> and <c>valid_to</c>.</summary>
public sealed class RecipeConfiguration : IEntityTypeConfiguration<Recipe>
{
    public void Configure(EntityTypeBuilder<Recipe> builder)
    {
        builder.ToTable("cons_recipe");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.YieldPortions).HasPrecision(18, 4).HasDefaultValue(1.0000m).ValueGeneratedNever();
        builder.Property(x => x.Status).HasMySqlEnum<RecipeStatus>();
        builder.Property(x => x.Note).HasMaxLength(Recipe.NoteMaxLength);

        builder.HasIndex(x => new { x.TenantId, x.MenuItemId, x.VersionNo }).IsUnique().HasDatabaseName("uq_recipe_ver");
        builder.HasIndex(x => new { x.TenantId, x.MenuItemId, x.ValidFrom, x.ValidTo }).HasDatabaseName("ix_recipe_eff");

        builder.HasMany(x => x.Lines)
            .WithOne()
            .HasForeignKey(l => l.RecipeId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

/// <summary><c>cons_recipe_line</c>. Percentages are DECIMAL(9,4) (spec §6.3).</summary>
public sealed class RecipeLineConfiguration : IEntityTypeConfiguration<RecipeLine>
{
    public void Configure(EntityTypeBuilder<RecipeLine> builder)
    {
        builder.ToTable("cons_recipe_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.ComponentType).HasMySqlEnum<ComponentType>();
        builder.Property(x => x.QtyPerPortion).HasPrecision(18, 4);
        builder.Property(x => x.YieldPct).HasPrecision(9, 4).HasDefaultValue(100.0000m).ValueGeneratedNever();
        builder.Property(x => x.IsOptional).HasDefaultValue(false).ValueGeneratedNever();
        builder.Property(x => x.AttachRatePct).HasPrecision(9, 4).HasDefaultValue(100.0000m).ValueGeneratedNever();
        builder.Property(x => x.Note).HasMaxLength(RecipeLine.NoteMaxLength);

        // Spec §6.5 wins over the design DDL: every unique index starts with tenant_id (README §8.4).
        builder.HasIndex(x => new { x.TenantId, x.RecipeId, x.LineNo }).IsUnique().HasDatabaseName("uq_rline");
    }
}

/// <summary><c>cons_sales_import</c> — invariant 2: one document per (tenant, location, business_date).</summary>
public sealed class SalesImportConfiguration : IEntityTypeConfiguration<SalesImport>
{
    public void Configure(EntityTypeBuilder<SalesImport> builder)
    {
        builder.ToTable("cons_sales_import");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Source).HasMySqlEnum<SalesSource>();
        builder.Property(x => x.ExternalRef).HasMaxLength(SalesImport.ExternalRefMaxLength);
        builder.Property(x => x.Status).HasMySqlEnum<SalesImportStatus>();
        builder.Property(x => x.LineCount).HasDefaultValue((ushort)0).ValueGeneratedNever();
        builder.Property(x => x.GrossAmount).HasPrecision(18, 4);

        builder.HasIndex(x => new { x.TenantId, x.LocationId, x.BusinessDate }).IsUnique().HasDatabaseName("uq_sales_day");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.BusinessDate }).HasDatabaseName("ix_sales_status");

        builder.HasMany(x => x.Lines)
            .WithOne()
            .HasForeignKey(l => l.ImportId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

/// <summary><c>cons_sales_line</c>. An unrecognised POS code keeps its raw value (invariant 5).</summary>
public sealed class SalesLineConfiguration : IEntityTypeConfiguration<SalesLine>
{
    public void Configure(EntityTypeBuilder<SalesLine> builder)
    {
        builder.ToTable("cons_sales_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.RawPosCode).HasMaxLength(SalesLine.RawPosCodeMaxLength);
        builder.Property(x => x.QtySold).HasPrecision(18, 4);
        builder.Property(x => x.GrossAmount).HasPrecision(18, 4);
        builder.Ignore(x => x.IsMapped);

        builder.HasIndex(x => new { x.TenantId, x.ImportId, x.MenuItemId, x.RawPosCode }).IsUnique().HasDatabaseName("uq_sline");
    }
}

/// <summary><c>cons_run</c> — invariant 2: one theoretical-consumption document per (tenant, location, business_date).</summary>
public sealed class ConsumptionRunConfiguration : IEntityTypeConfiguration<ConsumptionRun>
{
    public void Configure(EntityTypeBuilder<ConsumptionRun> builder)
    {
        builder.ToTable("cons_run");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocNo).HasMaxLength(ConsumptionRun.DocNoMaxLength).IsRequired();
        builder.Property(x => x.Status).HasMySqlEnum<ConsumptionRunStatus>();
        builder.Property(x => x.ShortfallCount).HasDefaultValue((ushort)0).ValueGeneratedNever();
        builder.Property(x => x.UnmappedCount).HasDefaultValue((ushort)0).ValueGeneratedNever();

        // Not in the design DDL, required by the contract: ConsumptionRun.failureReason explains status FAILED.
        builder.Property(x => x.FailureReason).HasMaxLength(ConsumptionRun.FailureReasonMaxLength);

        builder.HasIndex(x => new { x.TenantId, x.DocNo }).IsUnique().HasDatabaseName("uq_run_doc");
        builder.HasIndex(x => new { x.TenantId, x.LocationId, x.BusinessDate }).IsUnique().HasDatabaseName("uq_run_day");
        builder.HasIndex(x => new { x.TenantId, x.Status, x.BusinessDate }).HasDatabaseName("ix_run_status");

        builder.HasMany(x => x.Lines)
            .WithOne()
            .HasForeignKey(l => l.RunId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Lines).HasField("_lines").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

/// <summary><c>cons_run_line</c>: theoretical, posted and shortfall quantity per product.</summary>
public sealed class ConsumptionRunLineConfiguration : IEntityTypeConfiguration<ConsumptionRunLine>
{
    public void Configure(EntityTypeBuilder<ConsumptionRunLine> builder)
    {
        builder.ToTable("cons_run_line");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.TheoreticalQtyBase).HasPrecision(18, 4);
        builder.Property(x => x.PostedQtyBase).HasPrecision(18, 4);
        builder.Property(x => x.ShortfallQtyBase).HasPrecision(18, 4).HasDefaultValue(0m).ValueGeneratedNever();
        builder.Property(x => x.UnitCost).HasPrecision(18, 4);

        builder.HasIndex(x => new { x.TenantId, x.RunId, x.ProductId }).IsUnique().HasDatabaseName("uq_rl");
    }
}
