using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Infrastructure.Persistence.Configurations;

public sealed class UomConfiguration : IEntityTypeConfiguration<Uom>
{
    public void Configure(EntityTypeBuilder<Uom> builder)
    {
        builder.ToTable("master_uom");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(12).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(60).IsRequired();
        builder.Property(x => x.UomClass).HasMySqlEnum<UomClass>();
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_uom");
    }
}

public sealed class ProductCategoryConfiguration : IEntityTypeConfiguration<ProductCategory>
{
    public void Configure(EntityTypeBuilder<ProductCategory> builder)
    {
        builder.ToTable("master_product_category");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.Property(x => x.ProductType).HasMySqlEnum<ProductType>();
        builder.Property(x => x.Path).HasMaxLength(500).IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_cat");
    }
}

public sealed class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
        builder.ToTable("master_product");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Sku).HasMaxLength(48).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(250).IsRequired();
        builder.Property(x => x.NameSortKey).HasMaxLength(AzerbaijaniSortKey.MaxLength).IsRequired();
        builder.Property(x => x.Barcode).HasMaxLength(64);
        builder.Property(x => x.Brand).HasMaxLength(120);
        builder.Property(x => x.VatRate).HasPrecision(9, 4);
        builder.Property(x => x.IssueStrategy).HasMySqlEnum<IssueStrategy>();
        builder.Property(x => x.ImageKey).HasMaxLength(300);
        builder.HasIndex(x => new { x.TenantId, x.Sku }).IsUnique().HasDatabaseName("uq_product_sku");
        builder.HasIndex(x => new { x.TenantId, x.CategoryId }).HasDatabaseName("ix_product_cat");
        builder.HasIndex(x => new { x.TenantId, x.NameSortKey }).HasDatabaseName("ix_product_name");

        builder.HasMany(x => x.Uoms).WithOne().HasForeignKey(u => u.ProductId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Uoms).HasField("_uoms").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class ProductUomConfiguration : IEntityTypeConfiguration<ProductUom>
{
    public void Configure(EntityTypeBuilder<ProductUom> builder)
    {
        builder.ToTable("master_product_uom");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.FactorToBase).HasPrecision(18, 8);
        builder.HasIndex(x => new { x.TenantId, x.ProductId, x.UomId, x.ValidFrom }).IsUnique().HasDatabaseName("uq_puom");
    }
}

public sealed class SupplierConfiguration : IEntityTypeConfiguration<Supplier>
{
    public void Configure(EntityTypeBuilder<Supplier> builder)
    {
        builder.ToTable("master_supplier");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(250).IsRequired();
        builder.Property(x => x.TaxId).HasMaxLength(32);
        builder.Property(x => x.ContactPerson).HasMaxLength(150);
        builder.Property(x => x.Phone).HasMaxLength(64);
        builder.Property(x => x.Email).HasMaxLength(200);
        builder.Property(x => x.Address).HasMaxLength(500);
        builder.Property(x => x.BankDetails).HasMaxLength(500);
        builder.Property(x => x.Currency).HasColumnType("char(3)").IsRequired();
        builder.Property(x => x.PaymentTerms).HasMaxLength(200);
        builder.Property(x => x.DeliveryTerms).HasMaxLength(200);
        builder.Property(x => x.Incoterms).HasMaxLength(16);
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_supplier_code");

        builder.HasMany(x => x.Certificates).WithOne().HasForeignKey(c => c.SupplierId).OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(x => x.Certificates).HasField("_certificates").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}

public sealed class SupplierCertificateConfiguration : IEntityTypeConfiguration<SupplierCertificate>
{
    public void Configure(EntityTypeBuilder<SupplierCertificate> builder)
    {
        builder.ToTable("master_supplier_certificate");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.CertType).HasMaxLength(80).IsRequired();
        builder.Property(x => x.CertNumber).HasMaxLength(80);
        builder.HasIndex(x => new { x.TenantId, x.ExpiryDate }).HasDatabaseName("ix_cert_exp");
    }
}

public sealed class LocationConfiguration : IEntityTypeConfiguration<Location>
{
    public void Configure(EntityTypeBuilder<Location> builder)
    {
        builder.ToTable("master_location");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.LocationType).HasMySqlEnum<LocationType>();
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_loc_code");
        builder.HasIndex(x => new { x.TenantId, x.ParentId }).HasDatabaseName("ix_loc_parent");
    }
}

public sealed class CurrencyRateConfiguration : IEntityTypeConfiguration<CurrencyRate>
{
    public void Configure(EntityTypeBuilder<CurrencyRate> builder)
    {
        builder.ToTable("master_currency_rate");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Currency).HasColumnType("char(3)").IsRequired();
        builder.Property(x => x.RateToBase).HasPrecision(18, 8);
        builder.Property(x => x.Source).HasMaxLength(32).IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.Currency, x.RateDate }).IsUnique().HasDatabaseName("uq_rate");
    }
}

public sealed class ReasonCodeConfiguration : IEntityTypeConfiguration<ReasonCode>
{
    public void Configure(EntityTypeBuilder<ReasonCode> builder)
    {
        builder.ToTable("master_reason_code");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.Code).HasMaxLength(32).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
        builder.Property(x => x.ReasonGroup).HasMySqlEnum<ReasonGroup>();
        builder.HasIndex(x => new { x.TenantId, x.Code }).IsUnique().HasDatabaseName("uq_reason");
    }
}

public sealed class NumberSequenceConfiguration : IEntityTypeConfiguration<NumberSequence>
{
    public void Configure(EntityTypeBuilder<NumberSequence> builder)
    {
        builder.ToTable("master_number_sequence");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedOnAdd();
        builder.Property(x => x.DocType).HasMaxLength(24).IsRequired();
        builder.Property(x => x.Prefix).HasMaxLength(12).IsRequired();
        builder.Property(x => x.Period).HasMaxLength(8).IsRequired();
        builder.HasIndex(x => new { x.TenantId, x.DocType, x.Period }).IsUnique().HasDatabaseName("uq_seq");
    }
}
