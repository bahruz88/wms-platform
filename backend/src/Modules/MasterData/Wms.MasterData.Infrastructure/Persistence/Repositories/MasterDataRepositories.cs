using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Infrastructure.Persistence.Repositories;

public sealed class ProductRepository(MasterDataDbContext db) : IProductRepository
{
    public Task<Product?> GetAsync(uint productId, CancellationToken cancellationToken) =>
        db.Products.Include(p => p.Uoms).FirstOrDefaultAsync(p => p.Id == productId, cancellationToken);

    public Task<bool> SkuExistsAsync(string sku, uint? exceptProductId, CancellationToken cancellationToken) =>
        db.Products
            .IgnoreQueryFilters()
            .Where(p => p.TenantId == db.CurrentTenantId && p.Sku == sku)
            .AnyAsync(p => exceptProductId == null || p.Id != exceptProductId, cancellationToken);

    public void Add(Product product) => db.Products.Add(product);
}

public sealed class ProductCategoryRepository(MasterDataDbContext db) : IProductCategoryRepository
{
    public Task<ProductCategory?> GetAsync(uint categoryId, CancellationToken cancellationToken) =>
        db.Categories.FirstOrDefaultAsync(c => c.Id == categoryId, cancellationToken);

    public Task<bool> CodeExistsAsync(string code, uint? exceptCategoryId, CancellationToken cancellationToken) =>
        db.Categories.AnyAsync(c => c.Code == code && (exceptCategoryId == null || c.Id != exceptCategoryId), cancellationToken);

    public async Task<IReadOnlyList<ProductCategory>> ListAsync(CancellationToken cancellationToken) =>
        await db.Categories.OrderBy(c => c.Path).ToListAsync(cancellationToken).ConfigureAwait(false);

    public void Add(ProductCategory category) => db.Categories.Add(category);
}

public sealed class UomRepository(MasterDataDbContext db) : IUomRepository
{
    public Task<Uom?> GetAsync(ushort uomId, CancellationToken cancellationToken) =>
        db.Uoms.FirstOrDefaultAsync(u => u.Id == uomId, cancellationToken);

    public Task<bool> CodeExistsAsync(string code, CancellationToken cancellationToken) =>
        db.Uoms.AnyAsync(u => u.Code == code, cancellationToken);

    public void Add(Uom uom) => db.Uoms.Add(uom);
}

public sealed class SupplierRepository(MasterDataDbContext db) : ISupplierRepository
{
    public Task<Supplier?> GetAsync(uint supplierId, CancellationToken cancellationToken) =>
        db.Suppliers.Include(s => s.Certificates).FirstOrDefaultAsync(s => s.Id == supplierId, cancellationToken);

    public Task<bool> CodeExistsAsync(string code, uint? exceptSupplierId, CancellationToken cancellationToken) =>
        db.Suppliers
            .IgnoreQueryFilters()
            .Where(s => s.TenantId == db.CurrentTenantId && s.Code == code)
            .AnyAsync(s => exceptSupplierId == null || s.Id != exceptSupplierId, cancellationToken);

    public void Add(Supplier supplier) => db.Suppliers.Add(supplier);
}

public sealed class LocationRepository(MasterDataDbContext db) : ILocationRepository
{
    public Task<Location?> GetAsync(uint locationId, CancellationToken cancellationToken) =>
        db.Locations.FirstOrDefaultAsync(l => l.Id == locationId, cancellationToken);

    public Task<bool> CodeExistsAsync(string code, uint? exceptLocationId, CancellationToken cancellationToken) =>
        db.Locations.AnyAsync(l => l.Code == code && (exceptLocationId == null || l.Id != exceptLocationId), cancellationToken);

    public Task<bool> VirtualTypeExistsAsync(LocationType locationType, CancellationToken cancellationToken) =>
        db.Locations.AnyAsync(l => l.LocationType == locationType, cancellationToken);

    public void Add(Location location) => db.Locations.Add(location);
}

public sealed class CurrencyRateRepository(MasterDataDbContext db) : ICurrencyRateRepository
{
    public Task<CurrencyRate?> FindAsync(string currency, DateOnly rateDate, CancellationToken cancellationToken) =>
        db.CurrencyRates.FirstOrDefaultAsync(r => r.Currency == currency && r.RateDate == rateDate, cancellationToken);

    public void Add(CurrencyRate rate) => db.CurrencyRates.Add(rate);
}

public sealed class ReasonCodeRepository(MasterDataDbContext db) : IReasonCodeRepository
{
    public Task<ReasonCode?> GetAsync(ushort reasonCodeId, CancellationToken cancellationToken) =>
        db.ReasonCodes.FirstOrDefaultAsync(r => r.Id == reasonCodeId, cancellationToken);

    public Task<bool> CodeExistsAsync(string code, ushort? exceptReasonCodeId, CancellationToken cancellationToken) =>
        db.ReasonCodes.AnyAsync(r => r.Code == code && (exceptReasonCodeId == null || r.Id != exceptReasonCodeId), cancellationToken);

    public void Add(ReasonCode reasonCode) => db.ReasonCodes.Add(reasonCode);
}
