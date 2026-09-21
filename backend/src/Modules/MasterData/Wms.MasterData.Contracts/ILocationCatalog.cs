namespace Wms.MasterData.Contracts;

public interface ILocationCatalog
{
    Task<LocationDto?> GetAsync(long locationId, CancellationToken cancellationToken);

    /// <summary>Bulk variant used to decorate document lines without an N+1 round trip. Unknown ids are omitted.</summary>
    Task<IReadOnlyList<LocationDto>> GetManyAsync(IReadOnlyCollection<uint> locationIds, CancellationToken cancellationToken);

    /// <summary>The tenant's virtual location of the given <see cref="LocationTypes"/> value (e.g. <c>V_SUPPLIER</c>).</summary>
    Task<LocationDto?> GetVirtualAsync(string locationType, CancellationToken cancellationToken);
}
