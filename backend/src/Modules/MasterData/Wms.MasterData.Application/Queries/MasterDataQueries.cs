using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Application.Queries;

// ==================================================================== products

/// <summary><c>GET /masterdata/products</c>.</summary>
public sealed record GetProductsQuery(ProductFilter Filter, PageRequest Page) : IQuery<PagedResult<ProductSummaryDto>>;

/// <summary><c>GET /masterdata/products/{id}</c>.</summary>
public sealed record GetProductQuery(uint ProductId) : IQuery<ProductDetailDto>;

/// <summary><c>GET /masterdata/products/{id}/uoms</c>.</summary>
public sealed record GetProductUomsQuery(uint ProductId, DateOnly? AsOf) : IQuery<IReadOnlyList<ProductUomDto>>;

public sealed class ProductQueryHandlers(IMasterDataQueries queries) :
    IQueryHandler<GetProductsQuery, PagedResult<ProductSummaryDto>>,
    IQueryHandler<GetProductQuery, ProductDetailDto>,
    IQueryHandler<GetProductUomsQuery, IReadOnlyList<ProductUomDto>>
{
    public async Task<Result<PagedResult<ProductSummaryDto>>> HandleAsync(GetProductsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetProductsAsync(query.Filter, query.Page, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<ProductDetailDto>> HandleAsync(GetProductQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var product = await queries.GetProductAsync(query.ProductId, cancellationToken).ConfigureAwait(false);
        return product is null ? MasterDataErrors.ProductNotFound(query.ProductId) : product;
    }

    public async Task<Result<IReadOnlyList<ProductUomDto>>> HandleAsync(GetProductUomsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var rows = await queries.GetProductUomsAsync(query.ProductId, query.AsOf, cancellationToken).ConfigureAwait(false);
        return rows is null ? MasterDataErrors.ProductNotFound(query.ProductId) : Result.Success(rows);
    }
}

// ==================================================================== categories

/// <summary><c>GET /masterdata/categories</c>.</summary>
public sealed record GetCategoriesQuery(ProductType? ProductType) : IQuery<IReadOnlyList<CategoryDto>>;

/// <summary><c>GET /masterdata/categories/{id}</c>.</summary>
public sealed record GetCategoryQuery(uint CategoryId) : IQuery<CategoryDto>;

public sealed class CategoryQueryHandlers(IMasterDataQueries queries) :
    IQueryHandler<GetCategoriesQuery, IReadOnlyList<CategoryDto>>,
    IQueryHandler<GetCategoryQuery, CategoryDto>
{
    public async Task<Result<IReadOnlyList<CategoryDto>>> HandleAsync(GetCategoriesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.GetCategoriesAsync(query.ProductType, cancellationToken).ConfigureAwait(false));
    }

    public async Task<Result<CategoryDto>> HandleAsync(GetCategoryQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var category = await queries.GetCategoryAsync(query.CategoryId, cancellationToken).ConfigureAwait(false);
        return category is null ? MasterDataErrors.CategoryNotFound(query.CategoryId) : category;
    }
}

// ==================================================================== units of measure

/// <summary><c>GET /masterdata/uoms</c>.</summary>
public sealed record GetUomsQuery(UomClass? UomClass) : IQuery<IReadOnlyList<UomDto>>;

/// <summary><c>GET /masterdata/uoms/{id}</c>.</summary>
public sealed record GetUomQuery(ushort UomId) : IQuery<UomDto>;

public sealed class UomQueryHandlers(IMasterDataQueries queries) :
    IQueryHandler<GetUomsQuery, IReadOnlyList<UomDto>>,
    IQueryHandler<GetUomQuery, UomDto>
{
    public async Task<Result<IReadOnlyList<UomDto>>> HandleAsync(GetUomsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.GetUomsAsync(query.UomClass, cancellationToken).ConfigureAwait(false));
    }

    public async Task<Result<UomDto>> HandleAsync(GetUomQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var uom = await queries.GetUomAsync(query.UomId, cancellationToken).ConfigureAwait(false);
        return uom is null ? MasterDataErrors.UomNotFound(query.UomId) : uom;
    }
}

// ==================================================================== suppliers

/// <summary><c>GET /masterdata/suppliers</c>.</summary>
public sealed record GetSuppliersQuery(SupplierFilter Filter, PageRequest Page) : IQuery<PagedResult<SupplierSummaryDto>>;

/// <summary><c>GET /masterdata/suppliers/{id}</c>.</summary>
public sealed record GetSupplierQuery(uint SupplierId) : IQuery<SupplierDetailDto>;

/// <summary><c>GET /masterdata/suppliers/{id}/certificates</c>.</summary>
public sealed record GetSupplierCertificatesQuery(uint SupplierId) : IQuery<IReadOnlyList<SupplierCertificateDto>>;

public sealed class SupplierQueryHandlers(IMasterDataQueries queries) :
    IQueryHandler<GetSuppliersQuery, PagedResult<SupplierSummaryDto>>,
    IQueryHandler<GetSupplierQuery, SupplierDetailDto>,
    IQueryHandler<GetSupplierCertificatesQuery, IReadOnlyList<SupplierCertificateDto>>
{
    public async Task<Result<PagedResult<SupplierSummaryDto>>> HandleAsync(GetSuppliersQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetSuppliersAsync(query.Filter, query.Page, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<SupplierDetailDto>> HandleAsync(GetSupplierQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var supplier = await queries.GetSupplierAsync(query.SupplierId, cancellationToken).ConfigureAwait(false);
        return supplier is null ? MasterDataErrors.SupplierNotFound(query.SupplierId) : supplier;
    }

    public async Task<Result<IReadOnlyList<SupplierCertificateDto>>> HandleAsync(GetSupplierCertificatesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var rows = await queries.GetSupplierCertificatesAsync(query.SupplierId, cancellationToken).ConfigureAwait(false);
        return rows is null ? MasterDataErrors.SupplierNotFound(query.SupplierId) : Result.Success(rows);
    }
}

// ==================================================================== locations

/// <summary><c>GET /masterdata/locations</c> — not paged (contract).</summary>
public sealed record GetLocationsQuery(LocationFilter Filter) : IQuery<IReadOnlyList<LocationDetailDto>>;

/// <summary><c>GET /masterdata/locations/{id}</c>.</summary>
public sealed record GetLocationQuery(uint LocationId) : IQuery<LocationDetailDto>;

public sealed class LocationQueryHandlers(IMasterDataQueries queries) :
    IQueryHandler<GetLocationsQuery, IReadOnlyList<LocationDetailDto>>,
    IQueryHandler<GetLocationQuery, LocationDetailDto>
{
    public async Task<Result<IReadOnlyList<LocationDetailDto>>> HandleAsync(GetLocationsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.GetLocationsAsync(query.Filter, cancellationToken).ConfigureAwait(false));
    }

    public async Task<Result<LocationDetailDto>> HandleAsync(GetLocationQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var location = await queries.GetLocationAsync(query.LocationId, cancellationToken).ConfigureAwait(false);
        return location is null ? MasterDataErrors.LocationNotFound(query.LocationId) : location;
    }
}

// ==================================================================== currency rates

/// <summary><c>GET /masterdata/currency-rates</c>. No fallback to an older rate (spec §12.5).</summary>
public sealed record GetCurrencyRatesQuery(CurrencyRateFilter Filter, PageRequest Page) : IQuery<PagedResult<CurrencyRateDto>>;

public sealed class CurrencyRateQueryHandler(IMasterDataQueries queries) : IQueryHandler<GetCurrencyRatesQuery, PagedResult<CurrencyRateDto>>
{
    public async Task<Result<PagedResult<CurrencyRateDto>>> HandleAsync(GetCurrencyRatesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetCurrencyRatesAsync(query.Filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

// ==================================================================== reason codes

/// <summary><c>GET /masterdata/reason-codes</c> — mandatory on every cancel, waste and adjustment body (spec §12.6).</summary>
public sealed record GetReasonCodesQuery(ReasonGroup? ReasonGroup, bool? IsActive) : IQuery<IReadOnlyList<ReasonCodeDto>>;

public sealed class ReasonCodeQueryHandler(IMasterDataQueries queries) : IQueryHandler<GetReasonCodesQuery, IReadOnlyList<ReasonCodeDto>>
{
    public async Task<Result<IReadOnlyList<ReasonCodeDto>>> HandleAsync(GetReasonCodesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.GetReasonCodesAsync(query.ReasonGroup, query.IsActive, cancellationToken).ConfigureAwait(false));
    }
}

// ==================================================================== number sequences

/// <summary><c>GET /masterdata/number-sequences</c> — read only, monitoring (spec Əlavə B).</summary>
public sealed record GetNumberSequencesQuery(string? DocType) : IQuery<IReadOnlyList<NumberSequenceDto>>;

public sealed class NumberSequenceQueryHandler(IMasterDataQueries queries) : IQueryHandler<GetNumberSequencesQuery, IReadOnlyList<NumberSequenceDto>>
{
    public async Task<Result<IReadOnlyList<NumberSequenceDto>>> HandleAsync(GetNumberSequencesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.GetNumberSequencesAsync(query.DocType, cancellationToken).ConfigureAwait(false));
    }
}
