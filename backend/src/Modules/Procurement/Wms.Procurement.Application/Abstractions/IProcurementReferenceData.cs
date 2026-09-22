using Wms.MasterData.Contracts;
using Wms.Procurement.Application.Dtos;

namespace Wms.Procurement.Application.Dtos;

/// <summary>
/// The master-data rows one page of procurement documents needs, fetched in one batch per kind so a 200-row page
/// costs a handful of calls instead of 800 (spec §13.4). Users come from the module's own read model because
/// Procurement may not reference Identity (spec §5).
/// </summary>
public sealed class ProcurementReferenceSet
{
    public static readonly ProcurementReferenceSet Empty = new(
        new Dictionary<uint, ProductDto>(),
        new Dictionary<uint, LocationDto>(),
        new Dictionary<ushort, UomRefDto>(),
        new Dictionary<uint, MasterData.Contracts.SupplierRefDto>(),
        new Dictionary<uint, UserRefDto>());

    public ProcurementReferenceSet(
        IReadOnlyDictionary<uint, ProductDto> products,
        IReadOnlyDictionary<uint, LocationDto> locations,
        IReadOnlyDictionary<ushort, UomRefDto> uoms,
        IReadOnlyDictionary<uint, MasterData.Contracts.SupplierRefDto> suppliers,
        IReadOnlyDictionary<uint, UserRefDto> users)
    {
        Products = products;
        Locations = locations;
        Uoms = uoms;
        Suppliers = suppliers;
        Users = users;
    }

    public IReadOnlyDictionary<uint, ProductDto> Products { get; }

    public IReadOnlyDictionary<uint, LocationDto> Locations { get; }

    public IReadOnlyDictionary<ushort, UomRefDto> Uoms { get; }

    public IReadOnlyDictionary<uint, MasterData.Contracts.SupplierRefDto> Suppliers { get; }

    public IReadOnlyDictionary<uint, UserRefDto> Users { get; }

    public ProductDto? Product(uint id) => Products.GetValueOrDefault(id);

    public ProductRefDto ProductRef(uint id) =>
        Products.TryGetValue(id, out var product) ? ProductRefDto.From(product) : ProductRefDto.Unknown(id);

    public LocationRefDto LocationRef(uint id) =>
        Locations.TryGetValue(id, out var location) ? LocationRefDto.From(location) : LocationRefDto.Unknown(id);

    public Dtos.SupplierRefDto SupplierRef(uint id) =>
        Suppliers.TryGetValue(id, out var supplier) ? Dtos.SupplierRefDto.From(supplier) : Dtos.SupplierRefDto.Unknown(id);

    public string UomCode(ushort id) => Uoms.TryGetValue(id, out var uom) ? uom.Code : string.Empty;

    public UserRefDto UserRef(uint id) => Users.TryGetValue(id, out var user) ? user : UserRefDto.Unknown(id);
}

/// <summary>What a query needs decorated. Empty collections are skipped, so callers pass only what they use.</summary>
public sealed record ProcurementReferenceRequest(
    IReadOnlyCollection<uint> ProductIds,
    IReadOnlyCollection<uint> LocationIds,
    IReadOnlyCollection<ushort> UomIds,
    IReadOnlyCollection<uint> SupplierIds,
    IReadOnlyCollection<uint> UserIds)
{
    public static ProcurementReferenceRequest For(
        IEnumerable<uint>? productIds = null,
        IEnumerable<uint>? locationIds = null,
        IEnumerable<ushort>? uomIds = null,
        IEnumerable<uint>? supplierIds = null,
        IEnumerable<uint>? userIds = null) => new(
            productIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            locationIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            uomIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            supplierIds?.Where(id => id != 0).Distinct().ToArray() ?? [],
            userIds?.Where(id => id != 0).Distinct().ToArray() ?? []);
}
