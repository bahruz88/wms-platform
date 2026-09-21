using Wms.Common.Application.Paging;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Application.Abstractions;

/// <summary><c>GET /masterdata/products</c> filters.</summary>
public sealed record ProductFilter(
    string? Search,
    uint? CategoryId,
    ProductType? ProductType,
    uint? SupplierId,
    string? Barcode,
    bool? IsActive,
    string? Sort);

/// <summary><c>GET /masterdata/suppliers</c> filters.</summary>
public sealed record SupplierFilter(string? Search, bool? ApprovedFoodOnly, bool? IsActive, string? Sort);

/// <summary><c>GET /masterdata/locations</c> filters. The list is not paged (contract).</summary>
public sealed record LocationFilter(LocationType? LocationType, uint? ParentId, bool IncludeVirtual, bool? IsActive);

/// <summary><c>GET /masterdata/currency-rates</c> filters.</summary>
public sealed record CurrencyRateFilter(string? Currency, DateOnly? Date, DateOnly? DateFrom, DateOnly? DateTo);

public interface IMasterDataQueries
{
    // ---------------------------------------------------------------- products

    /// <summary>Ordered by <c>name_sort_key</c> so the Azerbaijani alphabet order is respected (spec §6.4).</summary>
    Task<PagedResult<ProductSummaryDto>> GetProductsAsync(ProductFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<ProductDetailDto?> GetProductAsync(uint productId, CancellationToken cancellationToken);

    /// <summary><paramref name="asOf"/> null ⇒ the whole history, otherwise only the rows valid on that date.</summary>
    Task<IReadOnlyList<ProductUomDto>?> GetProductUomsAsync(uint productId, DateOnly? asOf, CancellationToken cancellationToken);

    // ---------------------------------------------------------------- categories

    Task<IReadOnlyList<CategoryDto>> GetCategoriesAsync(ProductType? productType, CancellationToken cancellationToken);

    Task<CategoryDto?> GetCategoryAsync(uint categoryId, CancellationToken cancellationToken);

    // ---------------------------------------------------------------- units of measure

    Task<IReadOnlyList<UomDto>> GetUomsAsync(UomClass? uomClass, CancellationToken cancellationToken);

    Task<UomDto?> GetUomAsync(ushort uomId, CancellationToken cancellationToken);

    // ---------------------------------------------------------------- suppliers

    Task<PagedResult<SupplierSummaryDto>> GetSuppliersAsync(SupplierFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<SupplierDetailDto?> GetSupplierAsync(uint supplierId, CancellationToken cancellationToken);

    Task<IReadOnlyList<SupplierCertificateDto>?> GetSupplierCertificatesAsync(uint supplierId, CancellationToken cancellationToken);

    // ---------------------------------------------------------------- locations

    Task<IReadOnlyList<LocationDetailDto>> GetLocationsAsync(LocationFilter filter, CancellationToken cancellationToken);

    Task<LocationDetailDto?> GetLocationAsync(uint locationId, CancellationToken cancellationToken);

    // ---------------------------------------------------------------- currency rates

    Task<PagedResult<CurrencyRateDto>> GetCurrencyRatesAsync(CurrencyRateFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<CurrencyRateDto?> GetCurrencyRateAsync(uint rateId, CancellationToken cancellationToken);

    // ---------------------------------------------------------------- reason codes

    Task<IReadOnlyList<ReasonCodeDto>> GetReasonCodesAsync(ReasonGroup? reasonGroup, bool? isActive, CancellationToken cancellationToken);

    Task<ReasonCodeDto?> GetReasonCodeAsync(ushort reasonCodeId, CancellationToken cancellationToken);

    // ---------------------------------------------------------------- number sequences

    Task<IReadOnlyList<NumberSequenceDto>> GetNumberSequencesAsync(string? docType, CancellationToken cancellationToken);
}
