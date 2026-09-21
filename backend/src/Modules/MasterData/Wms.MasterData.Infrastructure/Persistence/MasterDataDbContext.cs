using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Domain.Entities;

namespace Wms.MasterData.Infrastructure.Persistence;

/// <summary>Schema <c>master</c> (spec §8): table prefix <c>master_</c>.</summary>
public sealed class MasterDataDbContext(
    DbContextOptions<MasterDataDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "master_";
    public const string MigrationsHistoryTable = "__ef_migrations_masterdata";

    public override string TablePrefix => Prefix;

    public DbSet<Uom> Uoms => Set<Uom>();

    public DbSet<ProductCategory> Categories => Set<ProductCategory>();

    public DbSet<Product> Products => Set<Product>();

    public DbSet<ProductUom> ProductUoms => Set<ProductUom>();

    public DbSet<Supplier> Suppliers => Set<Supplier>();

    public DbSet<SupplierCertificate> SupplierCertificates => Set<SupplierCertificate>();

    public DbSet<Location> Locations => Set<Location>();

    public DbSet<CurrencyRate> CurrencyRates => Set<CurrencyRate>();

    public DbSet<ReasonCode> ReasonCodes => Set<ReasonCode>();

    public DbSet<NumberSequence> NumberSequences => Set<NumberSequence>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(MasterDataDbContext).Assembly);
}

public sealed class MasterDataDbContextFactory : IDesignTimeDbContextFactory<MasterDataDbContext>
{
    public MasterDataDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<MasterDataDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), MasterDataDbContext.MigrationsHistoryTable);
        return new MasterDataDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
