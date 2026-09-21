using Wms.MasterData.Domain.Entities;

namespace Wms.MasterData.Application.Abstractions;

/// <summary>
/// Write-side access to the <c>master</c> aggregates. Every method is tenant-scoped by the DbContext query
/// filter (spec §12.9); the repositories never take a tenant id from the caller.
/// </summary>
public interface IProductRepository
{
    /// <summary>Loads the product with its whole UoM history, tracked.</summary>
    Task<Product?> GetAsync(uint productId, CancellationToken cancellationToken);

    Task<bool> SkuExistsAsync(string sku, uint? exceptProductId, CancellationToken cancellationToken);

    void Add(Product product);
}

public interface IProductCategoryRepository
{
    Task<ProductCategory?> GetAsync(uint categoryId, CancellationToken cancellationToken);

    Task<bool> CodeExistsAsync(string code, uint? exceptCategoryId, CancellationToken cancellationToken);

    /// <summary>Every category of the tenant, tracked — the tree is small and re-pathing needs the descendants.</summary>
    Task<IReadOnlyList<ProductCategory>> ListAsync(CancellationToken cancellationToken);

    void Add(ProductCategory category);
}

public interface IUomRepository
{
    Task<Uom?> GetAsync(ushort uomId, CancellationToken cancellationToken);

    Task<bool> CodeExistsAsync(string code, CancellationToken cancellationToken);

    void Add(Uom uom);
}

public interface ISupplierRepository
{
    Task<Supplier?> GetAsync(uint supplierId, CancellationToken cancellationToken);

    Task<bool> CodeExistsAsync(string code, uint? exceptSupplierId, CancellationToken cancellationToken);

    void Add(Supplier supplier);
}

public interface ILocationRepository
{
    Task<Location?> GetAsync(uint locationId, CancellationToken cancellationToken);

    Task<bool> CodeExistsAsync(string code, uint? exceptLocationId, CancellationToken cancellationToken);

    /// <summary>Spec §12.3: exactly one counter-account per virtual location type.</summary>
    Task<bool> VirtualTypeExistsAsync(Domain.Enums.LocationType locationType, CancellationToken cancellationToken);

    void Add(Location location);
}

public interface ICurrencyRateRepository
{
    Task<CurrencyRate?> FindAsync(string currency, DateOnly rateDate, CancellationToken cancellationToken);

    void Add(CurrencyRate rate);
}

public interface IReasonCodeRepository
{
    Task<ReasonCode?> GetAsync(ushort reasonCodeId, CancellationToken cancellationToken);

    Task<bool> CodeExistsAsync(string code, ushort? exceptReasonCodeId, CancellationToken cancellationToken);

    void Add(ReasonCode reasonCode);
}
