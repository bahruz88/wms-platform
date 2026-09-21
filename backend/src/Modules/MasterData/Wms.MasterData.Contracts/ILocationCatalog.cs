namespace Wms.MasterData.Contracts;

public interface ILocationCatalog
{
    Task<LocationDto?> GetAsync(long locationId, CancellationToken cancellationToken);

    /// <summary>The tenant's virtual location of the given <see cref="LocationTypes"/> value (e.g. <c>V_SUPPLIER</c>).</summary>
    Task<LocationDto?> GetVirtualAsync(string locationType, CancellationToken cancellationToken);
}
