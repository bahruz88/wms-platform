using System.Reflection;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Paging;
using Wms.Common.Contracts;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.UnitTests;

/// <summary>Minimal in-memory doubles for the handler-level tests (no EF, no database).</summary>
internal static class TestIds
{
    /// <summary>Entities hide their surrogate key behind a protected setter; the fakes need one to key on.</summary>
    public static T WithId<T>(this T entity, object id)
    {
        var property = typeof(T).GetProperty("Id", BindingFlags.Public | BindingFlags.Instance)!;
        property.GetSetMethod(nonPublic: true)!.Invoke(entity, [id]);
        return entity;
    }
}

internal sealed class FakeTenantContext(uint tenantId = 1) : ITenantContext
{
    public uint TenantId { get; } = tenantId;

    public bool HasTenant => TenantId != 0;
}

internal sealed class FakeClock(DateTimeOffset? now = null) : IClock
{
    public DateTimeOffset UtcNow { get; } = now ?? new DateTimeOffset(2026, 9, 22, 8, 0, 0, TimeSpan.Zero);
}

internal sealed class FakeAuditTrail : IAuditTrail
{
    public List<(string EntityType, long EntityId, AuditAction Action)> Entries { get; } = [];

    public void Record(string entityType, long entityId, AuditAction action, object? changes = null) =>
        Entries.Add((entityType, entityId, action));
}

internal sealed class FakeOutbox : IIntegrationEventOutbox
{
    public List<IntegrationEvent> Events { get; } = [];

    public void Enqueue(IntegrationEvent integrationEvent) => Events.Add(integrationEvent);
}

internal sealed class FakeMasterDataUnitOfWork : IMasterDataUnitOfWork
{
    public FakeAuditTrail AuditTrail { get; } = new();

    public int SaveCount { get; private set; }

    public bool Committed { get; private set; }

    public IIntegrationEventOutbox Outbox { get; } = new FakeOutbox();

    public IAuditTrail Audit => AuditTrail;

    public Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken) =>
        Task.FromResult<IUnitOfWorkTransaction>(new FakeTransaction(this));

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken)
    {
        SaveCount++;
        return Task.FromResult(0);
    }

    private sealed class FakeTransaction(FakeMasterDataUnitOfWork owner) : IUnitOfWorkTransaction
    {
        public Task CommitAsync(CancellationToken cancellationToken)
        {
            owner.Committed = true;
            return Task.CompletedTask;
        }

        public Task RollbackAsync(CancellationToken cancellationToken) => Task.CompletedTask;

        public ValueTask DisposeAsync() => ValueTask.CompletedTask;
    }
}

internal sealed class FakeProductRepository : IProductRepository
{
    public List<Product> Products { get; } = [];

    public HashSet<string> TakenSkus { get; } = new(StringComparer.Ordinal);

    public Task<Product?> GetAsync(uint productId, CancellationToken cancellationToken) =>
        Task.FromResult(Products.Find(p => p.Id == productId));

    public Task<bool> SkuExistsAsync(string sku, uint? exceptProductId, CancellationToken cancellationToken) =>
        Task.FromResult(TakenSkus.Contains(sku) || Products.Exists(p => p.Sku == sku && p.Id != exceptProductId));

    public void Add(Product product) => Products.Add(product);
}

internal sealed class FakeProductCategoryRepository : IProductCategoryRepository
{
    public List<ProductCategory> Categories { get; } = [];

    public HashSet<string> TakenCodes { get; } = new(StringComparer.Ordinal);

    public Task<ProductCategory?> GetAsync(uint categoryId, CancellationToken cancellationToken) =>
        Task.FromResult(Categories.Find(c => c.Id == categoryId));

    public Task<bool> CodeExistsAsync(string code, uint? exceptCategoryId, CancellationToken cancellationToken) =>
        Task.FromResult(TakenCodes.Contains(code) || Categories.Exists(c => c.Code == code && c.Id != exceptCategoryId));

    public Task<IReadOnlyList<ProductCategory>> ListAsync(CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<ProductCategory>>(Categories);

    public void Add(ProductCategory category) => Categories.Add(category);
}

internal sealed class FakeUomRepository : IUomRepository
{
    public List<Uom> Uoms { get; } = [];

    public Task<Uom?> GetAsync(ushort uomId, CancellationToken cancellationToken) =>
        Task.FromResult(Uoms.Find(u => u.Id == uomId));

    public Task<bool> CodeExistsAsync(string code, CancellationToken cancellationToken) =>
        Task.FromResult(Uoms.Exists(u => u.Code == code));

    public void Add(Uom uom) => Uoms.Add(uom);
}

internal sealed class FakeSupplierRepository : ISupplierRepository
{
    public List<Supplier> Suppliers { get; } = [];

    public Task<Supplier?> GetAsync(uint supplierId, CancellationToken cancellationToken) =>
        Task.FromResult(Suppliers.Find(s => s.Id == supplierId));

    public Task<bool> CodeExistsAsync(string code, uint? exceptSupplierId, CancellationToken cancellationToken) =>
        Task.FromResult(Suppliers.Exists(s => s.Code == code && s.Id != exceptSupplierId));

    public void Add(Supplier supplier) => Suppliers.Add(supplier);
}

internal sealed class FakeLocationRepository : ILocationRepository
{
    public List<Location> Locations { get; } = [];

    public Task<Location?> GetAsync(uint locationId, CancellationToken cancellationToken) =>
        Task.FromResult(Locations.Find(l => l.Id == locationId));

    public Task<bool> CodeExistsAsync(string code, uint? exceptLocationId, CancellationToken cancellationToken) =>
        Task.FromResult(Locations.Exists(l => l.Code == code && l.Id != exceptLocationId));

    public Task<bool> VirtualTypeExistsAsync(LocationType locationType, CancellationToken cancellationToken) =>
        Task.FromResult(Locations.Exists(l => l.LocationType == locationType));

    public void Add(Location location) => Locations.Add(location);
}

internal sealed class FakeCurrencyRateRepository : ICurrencyRateRepository
{
    public List<CurrencyRate> Rates { get; } = [];

    public Task<CurrencyRate?> FindAsync(string currency, DateOnly rateDate, CancellationToken cancellationToken) =>
        Task.FromResult(Rates.Find(r => r.Currency == currency && r.RateDate == rateDate));

    public void Add(CurrencyRate rate) => Rates.Add(rate);
}

internal sealed class FakeReasonCodeRepository : IReasonCodeRepository
{
    public List<ReasonCode> ReasonCodes { get; } = [];

    public Task<ReasonCode?> GetAsync(ushort reasonCodeId, CancellationToken cancellationToken) =>
        Task.FromResult(ReasonCodes.Find(r => r.Id == reasonCodeId));

    public Task<bool> CodeExistsAsync(string code, ushort? exceptReasonCodeId, CancellationToken cancellationToken) =>
        Task.FromResult(ReasonCodes.Exists(r => r.Code == code && r.Id != exceptReasonCodeId));

    public void Add(ReasonCode reasonCode) => ReasonCodes.Add(reasonCode);
}

/// <summary>
/// Read port double. Only the reason-code list is implemented in memory — it is the one read whose filtering
/// semantics the handler tests assert; every other member is unreachable from those tests.
/// </summary>
internal sealed class FakeMasterDataQueries : IMasterDataQueries
{
    public List<ReasonCodeDto> ReasonCodes { get; } = [];

    public ReasonGroup? LastReasonGroup { get; private set; }

    public bool? LastIsActive { get; private set; }

    public Task<IReadOnlyList<ReasonCodeDto>> GetReasonCodesAsync(ReasonGroup? reasonGroup, bool? isActive, CancellationToken cancellationToken)
    {
        LastReasonGroup = reasonGroup;
        LastIsActive = isActive;

        IEnumerable<ReasonCodeDto> rows = ReasonCodes;
        if (reasonGroup is { } group)
        {
            rows = rows.Where(r => r.ReasonGroup == group);
        }

        if (isActive is { } active)
        {
            rows = rows.Where(r => r.IsActive == active);
        }

        return Task.FromResult<IReadOnlyList<ReasonCodeDto>>(rows.OrderBy(r => r.Code, StringComparer.Ordinal).ToList());
    }

    public Task<PagedResult<ProductSummaryDto>> GetProductsAsync(ProductFilter filter, PageRequest page, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<ProductDetailDto?> GetProductAsync(uint productId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<IReadOnlyList<ProductUomDto>?> GetProductUomsAsync(uint productId, DateOnly? asOf, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<IReadOnlyList<CategoryDto>> GetCategoriesAsync(ProductType? productType, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<CategoryDto?> GetCategoryAsync(uint categoryId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<IReadOnlyList<UomDto>> GetUomsAsync(UomClass? uomClass, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<UomDto?> GetUomAsync(ushort uomId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<PagedResult<SupplierSummaryDto>> GetSuppliersAsync(SupplierFilter filter, PageRequest page, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<SupplierDetailDto?> GetSupplierAsync(uint supplierId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<IReadOnlyList<SupplierCertificateDto>?> GetSupplierCertificatesAsync(uint supplierId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<IReadOnlyList<LocationDetailDto>> GetLocationsAsync(LocationFilter filter, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<LocationDetailDto?> GetLocationAsync(uint locationId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<PagedResult<CurrencyRateDto>> GetCurrencyRatesAsync(CurrencyRateFilter filter, PageRequest page, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<CurrencyRateDto?> GetCurrencyRateAsync(uint rateId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<ReasonCodeDto?> GetReasonCodeAsync(ushort reasonCodeId, CancellationToken cancellationToken) => throw new NotSupportedException();

    public Task<IReadOnlyList<NumberSequenceDto>> GetNumberSequencesAsync(string? docType, CancellationToken cancellationToken) => throw new NotSupportedException();
}
