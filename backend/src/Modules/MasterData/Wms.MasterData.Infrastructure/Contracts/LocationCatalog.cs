using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Contracts;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.MasterData.Infrastructure.Contracts;

/// <summary>In-process <see cref="ILocationCatalog"/> (spec §4.2).</summary>
public sealed class LocationCatalog(MasterDataDbContext db) : ILocationCatalog
{
    public async Task<LocationDto?> GetAsync(long locationId, CancellationToken cancellationToken)
    {
        if (locationId is <= 0 or > uint.MaxValue)
        {
            return null;
        }

        var id = (uint)locationId;
        var location = await db.Locations.AsNoTracking().FirstOrDefaultAsync(l => l.Id == id, cancellationToken).ConfigureAwait(false);
        return Map(location);
    }

    public async Task<LocationDto?> GetVirtualAsync(string locationType, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(locationType);
        if (!TryParse(locationType, out var parsed) || !Location.IsVirtualType(parsed))
        {
            return null;
        }

        var location = await db.Locations.AsNoTracking()
            .Where(l => l.LocationType == parsed && l.IsActive)
            .OrderBy(l => l.Id)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
        return Map(location);
    }

    private static bool TryParse(string locationType, out LocationType parsed)
    {
        foreach (var candidate in Enum.GetValues<LocationType>())
        {
            if (string.Equals(UpperSnakeCaseEnum.Format(candidate), locationType, StringComparison.OrdinalIgnoreCase))
            {
                parsed = candidate;
                return true;
            }
        }

        parsed = default;
        return false;
    }

    private static LocationDto? Map(Location? location) => location is null
        ? null
        : new LocationDto(
            location.Id,
            location.Code,
            location.Name,
            UpperSnakeCaseEnum.Format(location.LocationType),
            location.ParentId,
            location.IsVirtual,
            location.AllowsFood,
            location.AllowsNonFood,
            location.IsActive);
}
