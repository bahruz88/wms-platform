using Wms.MasterData.Contracts;

namespace Wms.Reporting.Infrastructure.Reports;

/// <summary>
/// Product, location and supplier labels for a page of report rows. Reporting stores none of this: the labels
/// come from <c>Wms.MasterData.Contracts</c>, which is the only way ADR-001 lets it read the catalogue.
/// </summary>
public sealed class ReportReferenceData
{
    public static ReportReferenceData Empty { get; } = new(
        new Dictionary<uint, ProductDto>(),
        new Dictionary<uint, LocationDto>(),
        new Dictionary<uint, SupplierRefDto>());

    public ReportReferenceData(
        IReadOnlyDictionary<uint, ProductDto> products,
        IReadOnlyDictionary<uint, LocationDto> locations,
        IReadOnlyDictionary<uint, SupplierRefDto> suppliers)
    {
        Products = products;
        Locations = locations;
        Suppliers = suppliers;
    }

    public IReadOnlyDictionary<uint, ProductDto> Products { get; }

    public IReadOnlyDictionary<uint, LocationDto> Locations { get; }

    public IReadOnlyDictionary<uint, SupplierRefDto> Suppliers { get; }

    public ProductDto? Product(uint id) => Products.TryGetValue(id, out var product) ? product : null;

    public LocationDto? Location(uint id) => Locations.TryGetValue(id, out var location) ? location : null;

    public string? Sku(uint id) => Product(id)?.Sku;

    public string? ProductName(uint id) => Product(id)?.Name;

    public string? Uom(uint id) => Product(id)?.BaseUomCode;

    public string? LocationCode(uint id) => Location(id)?.Code;

    public string? LocationName(uint id) => Location(id)?.Name;

    public string? SupplierName(uint? id) =>
        id is { } value && Suppliers.TryGetValue(value, out var supplier) ? supplier.Name : null;
}

public interface IReportReferenceLoader
{
    Task<ReportReferenceData> LoadAsync(
        IEnumerable<uint> productIds,
        IEnumerable<uint> locationIds,
        IEnumerable<uint> supplierIds,
        CancellationToken cancellationToken);
}

/// <inheritdoc />
public sealed class ReportReferenceLoader(IProductCatalog products, ILocationCatalog locations, ISupplierCatalog suppliers)
    : IReportReferenceLoader
{
    /// <summary>
    /// The HTTP stubs of the catalogue contracts pass identifiers in the query string and overflow at roughly
    /// 1 300 of them (ROADMAP §4), so the lookups are chunked well below that.
    /// </summary>
    private const int ChunkSize = 200;

    public async Task<ReportReferenceData> LoadAsync(
        IEnumerable<uint> productIds,
        IEnumerable<uint> locationIds,
        IEnumerable<uint> supplierIds,
        CancellationToken cancellationToken)
    {
        var productMap = await LoadManyAsync(
            productIds,
            (ids, token) => products.GetManyAsync(ids, token),
            p => p.Id,
            cancellationToken).ConfigureAwait(false);

        var locationMap = await LoadManyAsync(
            locationIds,
            (ids, token) => locations.GetManyAsync(ids, token),
            l => l.Id,
            cancellationToken).ConfigureAwait(false);

        var supplierMap = await LoadManyAsync(
            supplierIds,
            (ids, token) => suppliers.GetManyAsync(ids, token),
            s => s.Id,
            cancellationToken).ConfigureAwait(false);

        return new ReportReferenceData(productMap, locationMap, supplierMap);
    }

    private static async Task<Dictionary<uint, T>> LoadManyAsync<T>(
        IEnumerable<uint> ids,
        Func<IReadOnlyCollection<uint>, CancellationToken, Task<IReadOnlyList<T>>> load,
        Func<T, uint> key,
        CancellationToken cancellationToken)
    {
        var distinct = ids.Where(id => id != 0).Distinct().ToList();
        var map = new Dictionary<uint, T>(distinct.Count);
        for (var offset = 0; offset < distinct.Count; offset += ChunkSize)
        {
            var chunk = distinct.Skip(offset).Take(ChunkSize).ToList();
            foreach (var item in await load(chunk, cancellationToken).ConfigureAwait(false))
            {
                map[key(item)] = item;
            }
        }

        return map;
    }
}
