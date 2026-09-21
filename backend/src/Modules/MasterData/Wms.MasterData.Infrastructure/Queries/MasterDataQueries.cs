using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Paging;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.MasterData.Infrastructure.Queries;

/// <summary>Read side of the MasterData contract. Every query is <c>AsNoTracking</c> and tenant-filtered (spec §12.9).</summary>
public sealed class MasterDataQueries(MasterDataDbContext db, IClock clock) : IMasterDataQueries
{
    // ================================================================ products

    public async Task<PagedResult<ProductSummaryDto>> GetProductsAsync(ProductFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Products.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(p => p.Sku.Contains(search) || p.Name.Contains(search) || (p.Barcode != null && p.Barcode.Contains(search)));
        }

        if (!string.IsNullOrWhiteSpace(filter.Barcode))
        {
            var barcode = filter.Barcode.Trim();
            query = query.Where(p => p.Barcode == barcode);
        }

        if (filter.CategoryId is { } categoryId)
        {
            // Sub-categories are included: the materialised path of the parent prefixes every descendant.
            var scope = await CategoryScopeAsync(categoryId, cancellationToken).ConfigureAwait(false);
            if (scope.Count == 0)
            {
                return PagedResult<ProductSummaryDto>.Empty(page);
            }

            query = query.Where(p => scope.Contains(p.CategoryId));
        }

        if (filter.ProductType is { } productType)
        {
            var typed = await db.Categories.AsNoTracking()
                .Where(c => c.ProductType == productType)
                .Select(c => c.Id)
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);
            if (typed.Count == 0)
            {
                return PagedResult<ProductSummaryDto>.Empty(page);
            }

            query = query.Where(p => typed.Contains(p.CategoryId));
        }

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(p => p.DefaultSupplierId == supplierId);
        }

        if (filter.IsActive is { } isActive)
        {
            query = query.Where(p => p.IsActive == isActive);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        if (total == 0)
        {
            return PagedResult<ProductSummaryDto>.Empty(page);
        }

        var rows = await SortProducts(query, filter.Sort)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(p => new ProductRow(p.Id, p.Sku, p.Name, p.Barcode, p.BaseUomId, p.CategoryId, p.RequiresBatch, p.RequiresExpiry, p.IsActive))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var uomCodes = await UomCodesAsync(rows.ConvertAll(r => r.BaseUomId), cancellationToken).ConfigureAwait(false);
        var productTypes = await ProductTypesAsync(rows.ConvertAll(r => r.CategoryId), cancellationToken).ConfigureAwait(false);

        var items = rows.ConvertAll(p => new ProductSummaryDto(
            p.Id,
            p.Sku,
            p.Name,
            p.Barcode,
            p.BaseUomId,
            uomCodes.GetValueOrDefault(p.BaseUomId, string.Empty),
            productTypes.GetValueOrDefault(p.CategoryId, ProductType.Food),
            p.RequiresBatch,
            p.RequiresExpiry,
            p.IsActive));

        return new PagedResult<ProductSummaryDto>(items, page.Page, page.Size, total);
    }

    public async Task<ProductDetailDto?> GetProductAsync(uint productId, CancellationToken cancellationToken)
    {
        var product = await db.Products.AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == productId, cancellationToken)
            .ConfigureAwait(false);
        if (product is null)
        {
            return null;
        }

        var category = await db.Categories.AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == product.CategoryId, cancellationToken)
            .ConfigureAwait(false);

        var baseUomCode = await db.Uoms.AsNoTracking()
            .Where(u => u.Id == product.BaseUomId)
            .Select(u => u.Code)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        // The card shows the factors in force today; the history is behind GET /products/{id}/uoms.
        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var uoms = await LoadProductUomsAsync(productId, today, cancellationToken).ConfigureAwait(false);

        return new ProductDetailDto(
            product.Id,
            product.Sku,
            product.Name,
            product.Barcode,
            product.BaseUomId,
            baseUomCode ?? string.Empty,
            category?.ProductType ?? ProductType.Food,
            product.RequiresBatch,
            product.RequiresExpiry,
            product.IsActive,
            product.CategoryId,
            category?.Path ?? "/",
            product.Brand,
            product.DefaultSupplierId,
            product.MinStock,
            product.MaxStock,
            product.ReorderPoint,
            product.VatRate,
            product.IssueStrategy,
            product.ShelfLifeDays,
            product.ImageAttachmentId is > 0 ? product.ImageAttachmentId : null,
            uoms,
            new AuditFieldsDto(product.CreatedAt, product.CreatedBy, product.UpdatedAt, product.UpdatedBy, product.RowVersion));
    }

    public async Task<IReadOnlyList<ProductUomDto>?> GetProductUomsAsync(uint productId, DateOnly? asOf, CancellationToken cancellationToken)
    {
        var exists = await db.Products.AsNoTracking().AnyAsync(p => p.Id == productId, cancellationToken).ConfigureAwait(false);
        return exists ? await LoadProductUomsAsync(productId, asOf, cancellationToken).ConfigureAwait(false) : null;
    }

    // ================================================================ categories

    public async Task<IReadOnlyList<CategoryDto>> GetCategoriesAsync(ProductType? productType, CancellationToken cancellationToken)
    {
        var query = db.Categories.AsNoTracking();
        if (productType is { } type)
        {
            query = query.Where(c => c.ProductType == type);
        }

        var rows = await query.OrderBy(c => c.Path).ToListAsync(cancellationToken).ConfigureAwait(false);
        return rows.ConvertAll(ToDto);
    }

    public async Task<CategoryDto?> GetCategoryAsync(uint categoryId, CancellationToken cancellationToken)
    {
        var category = await db.Categories.AsNoTracking().FirstOrDefaultAsync(c => c.Id == categoryId, cancellationToken).ConfigureAwait(false);
        return category is null ? null : ToDto(category);
    }

    // ================================================================ units of measure

    public async Task<IReadOnlyList<UomDto>> GetUomsAsync(UomClass? uomClass, CancellationToken cancellationToken)
    {
        var query = db.Uoms.AsNoTracking();
        if (uomClass is { } unitClass)
        {
            query = query.Where(u => u.UomClass == unitClass);
        }

        var rows = await query.OrderBy(u => u.Code).ToListAsync(cancellationToken).ConfigureAwait(false);
        return rows.ConvertAll(u => new UomDto(u.Id, u.Code, u.Name, u.UomClass, u.Decimals));
    }

    public async Task<UomDto?> GetUomAsync(ushort uomId, CancellationToken cancellationToken)
    {
        var uom = await db.Uoms.AsNoTracking().FirstOrDefaultAsync(u => u.Id == uomId, cancellationToken).ConfigureAwait(false);
        return uom is null ? null : new UomDto(uom.Id, uom.Code, uom.Name, uom.UomClass, uom.Decimals);
    }

    // ================================================================ suppliers

    public async Task<PagedResult<SupplierSummaryDto>> GetSuppliersAsync(SupplierFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Suppliers.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(s => s.Code.Contains(search) || s.Name.Contains(search) || (s.TaxId != null && s.TaxId.Contains(search)));
        }

        if (filter.ApprovedFoodOnly == true)
        {
            query = query.Where(s => s.IsApprovedFoodSupplier);
        }

        if (filter.IsActive is { } isActive)
        {
            query = query.Where(s => s.IsActive == isActive);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        if (total == 0)
        {
            return PagedResult<SupplierSummaryDto>.Empty(page);
        }

        var rows = await SortSuppliers(query, filter.Sort)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(s => new SupplierSummaryDto(s.Id, s.Code, s.Name, s.TaxId, s.Currency, s.IsApprovedFoodSupplier, s.IsActive))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new PagedResult<SupplierSummaryDto>(rows, page.Page, page.Size, total);
    }

    public async Task<SupplierDetailDto?> GetSupplierAsync(uint supplierId, CancellationToken cancellationToken)
    {
        var supplier = await db.Suppliers.AsNoTracking()
            .Include(s => s.Certificates)
            .FirstOrDefaultAsync(s => s.Id == supplierId, cancellationToken)
            .ConfigureAwait(false);
        if (supplier is null)
        {
            return null;
        }

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        return new SupplierDetailDto(
            supplier.Id,
            supplier.Code,
            supplier.Name,
            supplier.TaxId,
            supplier.Currency,
            supplier.IsApprovedFoodSupplier,
            supplier.IsActive,
            supplier.ContactPerson,
            supplier.Phone,
            supplier.Email,
            supplier.Address,
            supplier.BankDetails,
            supplier.PaymentTerms,
            supplier.DeliveryTerms,
            supplier.Incoterms,
            ToCertificates(supplier, today),
            new AuditFieldsDto(supplier.CreatedAt, supplier.CreatedBy, supplier.UpdatedAt, supplier.UpdatedBy, supplier.RowVersion));
    }

    public async Task<IReadOnlyList<SupplierCertificateDto>?> GetSupplierCertificatesAsync(uint supplierId, CancellationToken cancellationToken)
    {
        var supplier = await db.Suppliers.AsNoTracking()
            .Include(s => s.Certificates)
            .FirstOrDefaultAsync(s => s.Id == supplierId, cancellationToken)
            .ConfigureAwait(false);

        return supplier is null ? null : ToCertificates(supplier, DateOnly.FromDateTime(clock.UtcNow.UtcDateTime));
    }

    // ================================================================ locations

    public async Task<IReadOnlyList<LocationDetailDto>> GetLocationsAsync(LocationFilter filter, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);

        var query = db.Locations.AsNoTracking();
        if (filter.LocationType is { } locationType)
        {
            query = query.Where(l => l.LocationType == locationType);
        }
        else if (!filter.IncludeVirtual)
        {
            // Virtual locations are ledger counter-accounts, not pickable places (spec §12.3).
            query = query.Where(l => !l.IsVirtual);
        }

        if (filter.ParentId is { } parentId)
        {
            query = query.Where(l => l.ParentId == parentId);
        }

        if (filter.IsActive is { } isActive)
        {
            query = query.Where(l => l.IsActive == isActive);
        }

        var rows = await query.OrderBy(l => l.Code).ToListAsync(cancellationToken).ConfigureAwait(false);
        return rows.ConvertAll(ToDto);
    }

    public async Task<LocationDetailDto?> GetLocationAsync(uint locationId, CancellationToken cancellationToken)
    {
        var location = await db.Locations.AsNoTracking().FirstOrDefaultAsync(l => l.Id == locationId, cancellationToken).ConfigureAwait(false);
        return location is null ? null : ToDto(location);
    }

    // ================================================================ currency rates

    public async Task<PagedResult<CurrencyRateDto>> GetCurrencyRatesAsync(CurrencyRateFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.CurrencyRates.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(filter.Currency))
        {
            var currency = filter.Currency.Trim().ToUpperInvariant();
            query = query.Where(r => r.Currency == currency);
        }

        if (filter.Date is { } date)
        {
            // Spec §12.5: exactly that day — an older rate is never substituted.
            query = query.Where(r => r.RateDate == date);
        }
        else
        {
            if (filter.DateFrom is { } from)
            {
                query = query.Where(r => r.RateDate >= from);
            }

            if (filter.DateTo is { } to)
            {
                query = query.Where(r => r.RateDate <= to);
            }
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        if (total == 0)
        {
            return PagedResult<CurrencyRateDto>.Empty(page);
        }

        var rows = await query
            .OrderByDescending(r => r.RateDate)
            .ThenBy(r => r.Currency)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(r => new CurrencyRateDto(r.Id, r.Currency, r.RateDate, r.RateToBase, r.Source))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new PagedResult<CurrencyRateDto>(rows, page.Page, page.Size, total);
    }

    public async Task<CurrencyRateDto?> GetCurrencyRateAsync(uint rateId, CancellationToken cancellationToken) =>
        await db.CurrencyRates.AsNoTracking()
            .Where(r => r.Id == rateId)
            .Select(r => new CurrencyRateDto(r.Id, r.Currency, r.RateDate, r.RateToBase, r.Source))
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

    // ================================================================ reason codes

    public async Task<IReadOnlyList<ReasonCodeDto>> GetReasonCodesAsync(ReasonGroup? reasonGroup, bool? isActive, CancellationToken cancellationToken)
    {
        var query = db.ReasonCodes.AsNoTracking();
        if (reasonGroup is { } group)
        {
            query = query.Where(r => r.ReasonGroup == group);
        }

        if (isActive is { } active)
        {
            query = query.Where(r => r.IsActive == active);
        }

        var rows = await query.OrderBy(r => r.Code).ToListAsync(cancellationToken).ConfigureAwait(false);
        return rows.ConvertAll(ToDto);
    }

    public async Task<ReasonCodeDto?> GetReasonCodeAsync(ushort reasonCodeId, CancellationToken cancellationToken)
    {
        var reasonCode = await db.ReasonCodes.AsNoTracking().FirstOrDefaultAsync(r => r.Id == reasonCodeId, cancellationToken).ConfigureAwait(false);
        return reasonCode is null ? null : ToDto(reasonCode);
    }

    // ================================================================ number sequences

    public async Task<IReadOnlyList<NumberSequenceDto>> GetNumberSequencesAsync(string? docType, CancellationToken cancellationToken)
    {
        var query = db.NumberSequences.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(docType))
        {
            var normalized = docType.Trim().ToUpperInvariant();
            query = query.Where(s => s.DocType == normalized);
        }

        var rows = await query
            .OrderBy(s => s.DocType)
            .ThenByDescending(s => s.Period)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows.ConvertAll(s => new NumberSequenceDto(s.Id, s.DocType, s.Prefix, s.Period, s.LastNumber, s.Padding, s.PreviewNext()));
    }

    // ================================================================ helpers

    /// <summary>Spec §6.4: MySQL has no <c>az</c> collation, so lists order by the precomputed <c>name_sort_key</c>.</summary>
    private static IQueryable<Product> SortProducts(IQueryable<Product> query, string? sort)
    {
        var (field, descending) = ParseSort(sort);
        return field switch
        {
            "SKU" => descending ? query.OrderByDescending(p => p.Sku) : query.OrderBy(p => p.Sku),
            "CREATEDAT" => descending ? query.OrderByDescending(p => p.CreatedAt) : query.OrderBy(p => p.CreatedAt),
            "BARCODE" => descending ? query.OrderByDescending(p => p.Barcode) : query.OrderBy(p => p.Barcode),
            _ => descending ? query.OrderByDescending(p => p.NameSortKey) : query.OrderBy(p => p.NameSortKey),
        };
    }

    private static IQueryable<Supplier> SortSuppliers(IQueryable<Supplier> query, string? sort)
    {
        var (field, descending) = ParseSort(sort);
        return field switch
        {
            "CODE" => descending ? query.OrderByDescending(s => s.Code) : query.OrderBy(s => s.Code),
            "CREATEDAT" => descending ? query.OrderByDescending(s => s.CreatedAt) : query.OrderBy(s => s.CreatedAt),
            _ => descending ? query.OrderByDescending(s => s.Name) : query.OrderBy(s => s.Name),
        };
    }

    /// <summary><c>field,asc|desc</c> (common.v1.yaml <c>Sort</c>); only the first term is honoured.</summary>
    private static (string Field, bool Descending) ParseSort(string? sort)
    {
        if (string.IsNullOrWhiteSpace(sort))
        {
            return (string.Empty, false);
        }

        var first = sort.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)[0];
        var parts = first.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        var field = parts.Length > 0 ? parts[0].ToUpperInvariant() : string.Empty;
        var descending = parts.Length > 1 && string.Equals(parts[1], "desc", StringComparison.OrdinalIgnoreCase);
        return (field, descending);
    }

    private async Task<HashSet<uint>> CategoryScopeAsync(uint categoryId, CancellationToken cancellationToken)
    {
        var path = await db.Categories.AsNoTracking()
            .Where(c => c.Id == categoryId)
            .Select(c => c.Path)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        if (path is null)
        {
            return [];
        }

        var prefix = path + "/";
        var ids = await db.Categories.AsNoTracking()
            .Where(c => c.Path == path || c.Path.StartsWith(prefix))
            .Select(c => c.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return [.. ids];
    }

    private async Task<Dictionary<ushort, string>> UomCodesAsync(IReadOnlyCollection<ushort> uomIds, CancellationToken cancellationToken)
    {
        if (uomIds.Count == 0)
        {
            return [];
        }

        var distinct = uomIds.Distinct().ToList();
        var rows = await db.Uoms.AsNoTracking()
            .Where(u => distinct.Contains(u.Id))
            .Select(u => new { u.Id, u.Code })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows.ToDictionary(u => u.Id, u => u.Code);
    }

    private async Task<Dictionary<uint, ProductType>> ProductTypesAsync(IReadOnlyCollection<uint> categoryIds, CancellationToken cancellationToken)
    {
        if (categoryIds.Count == 0)
        {
            return [];
        }

        var distinct = categoryIds.Distinct().ToList();
        var rows = await db.Categories.AsNoTracking()
            .Where(c => distinct.Contains(c.Id))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows.ToDictionary(c => c.Id, c => c.ProductType);
    }

    private async Task<IReadOnlyList<ProductUomDto>> LoadProductUomsAsync(uint productId, DateOnly? asOf, CancellationToken cancellationToken)
    {
        var query = db.ProductUoms.AsNoTracking().Where(u => u.ProductId == productId);
        if (asOf is { } date)
        {
            query = query.Where(u => u.ValidFrom <= date && (u.ValidTo == null || u.ValidTo >= date));
        }

        var rows = await query
            .OrderBy(u => u.UomId)
            .ThenBy(u => u.ValidFrom)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var codes = await UomCodesAsync(rows.ConvertAll(u => u.UomId), cancellationToken).ConfigureAwait(false);

        return rows.ConvertAll(u => new ProductUomDto(
            u.Id,
            u.ProductId,
            u.UomId,
            codes.GetValueOrDefault(u.UomId, string.Empty),
            u.FactorToBase,
            u.IsPurchaseDefault,
            u.IsIssueDefault,
            u.ValidFrom,
            u.ValidTo));
    }

    private static IReadOnlyList<SupplierCertificateDto> ToCertificates(Supplier supplier, DateOnly today) =>
        supplier.Certificates
            .OrderBy(c => c.ExpiryDate ?? DateOnly.MaxValue)
            .ThenBy(c => c.CertType, StringComparer.Ordinal)
            .Select(c => new SupplierCertificateDto(
                c.Id, supplier.Id, c.CertType, c.CertNumber, c.IssuedDate, c.ExpiryDate, c.AttachmentId, c.IsExpiredOn(today)))
            .ToList();

    private static CategoryDto ToDto(ProductCategory category) => new(
        category.Id,
        category.ParentId,
        category.Code,
        category.Name,
        category.ProductType,
        category.Path,
        category.DefaultIssueStrategy,
        category.IsActive,
        category.RowVersion);

    private static LocationDetailDto ToDto(Location location) => new(
        location.Id,
        location.ParentId,
        location.Code,
        location.Name,
        location.LocationType,
        location.IsVirtual,
        location.AllowsFood,
        location.AllowsNonFood,
        location.IsActive,
        location.RowVersion);

    private static ReasonCodeDto ToDto(ReasonCode reasonCode) => new(
        reasonCode.Id,
        reasonCode.Code,
        reasonCode.Name,
        reasonCode.ReasonGroup,
        reasonCode.RequiresApproval,
        reasonCode.RequiresPhoto,
        reasonCode.IsActive,
        reasonCode.RowVersion);

    private sealed record ProductRow(
        uint Id,
        string Sku,
        string Name,
        string? Barcode,
        ushort BaseUomId,
        uint CategoryId,
        bool RequiresBatch,
        bool RequiresExpiry,
        bool IsActive);
}
