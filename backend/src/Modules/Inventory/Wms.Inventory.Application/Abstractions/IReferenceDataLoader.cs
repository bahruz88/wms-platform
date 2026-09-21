using Wms.Inventory.Application.Dtos;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Abstractions;

/// <summary>
/// The master-data rows needed to render one page of inventory documents, fetched in one batch per kind so a
/// 200-row page costs a handful of queries instead of 800 (spec §13.4).
/// </summary>
public sealed class ReferenceDataSet
{
    public static readonly ReferenceDataSet Empty = new(
        new Dictionary<uint, ProductDto>(),
        new Dictionary<uint, LocationDto>(),
        new Dictionary<long, BatchRefDto>(),
        new Dictionary<ushort, UomRefDto>(),
        new Dictionary<uint, SupplierRefDto>());

    public ReferenceDataSet(
        IReadOnlyDictionary<uint, ProductDto> products,
        IReadOnlyDictionary<uint, LocationDto> locations,
        IReadOnlyDictionary<long, BatchRefDto> batches,
        IReadOnlyDictionary<ushort, UomRefDto> uoms,
        IReadOnlyDictionary<uint, SupplierRefDto> suppliers)
    {
        Products = products;
        Locations = locations;
        Batches = batches;
        Uoms = uoms;
        Suppliers = suppliers;
    }

    public IReadOnlyDictionary<uint, ProductDto> Products { get; }

    public IReadOnlyDictionary<uint, LocationDto> Locations { get; }

    public IReadOnlyDictionary<long, BatchRefDto> Batches { get; }

    public IReadOnlyDictionary<ushort, UomRefDto> Uoms { get; }

    public IReadOnlyDictionary<uint, SupplierRefDto> Suppliers { get; }

    public ProductDto? Product(uint id) => Products.GetValueOrDefault(id);

    public ProductRefDto ProductRef(uint id) =>
        Products.TryGetValue(id, out var product) ? ProductRefDto.From(product) : ProductRefDto.Unknown(id);

    public LocationRefDto LocationRef(uint id) =>
        Locations.TryGetValue(id, out var location) ? LocationRefDto.From(location) : LocationRefDto.Unknown(id);

    public string LocationName(uint id) => Locations.TryGetValue(id, out var location) ? location.Name : string.Empty;

    /// <summary><c>batch_id = 0</c> means "no batch" (spec §9.5) and maps to a JSON <c>null</c>.</summary>
    public BatchRefDto? BatchRef(long? id) => id is null or 0 ? null : Batches.GetValueOrDefault(id.Value);

    public string UomCode(ushort id) => Uoms.TryGetValue(id, out var uom) ? uom.Code : string.Empty;

    public string SupplierName(uint id) => Suppliers.TryGetValue(id, out var supplier) ? supplier.Name : string.Empty;
}

/// <summary>What a query needs decorated. Empty collections are skipped, so callers can pass only what they use.</summary>
public sealed record ReferenceDataRequest(
    IReadOnlyCollection<uint> ProductIds,
    IReadOnlyCollection<uint> LocationIds,
    IReadOnlyCollection<long> BatchIds,
    IReadOnlyCollection<ushort> UomIds,
    IReadOnlyCollection<uint> SupplierIds)
{
    public static ReferenceDataRequest For(
        IEnumerable<uint>? productIds = null,
        IEnumerable<uint>? locationIds = null,
        IEnumerable<long>? batchIds = null,
        IEnumerable<ushort>? uomIds = null,
        IEnumerable<uint>? supplierIds = null) => new(
            productIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            locationIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            batchIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            uomIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            supplierIds?.Where(id => id != 0).Distinct().ToArray() ?? []);
}

public interface IReferenceDataLoader
{
    Task<ReferenceDataSet> LoadAsync(ReferenceDataRequest request, CancellationToken cancellationToken);
}
