using Wms.Inventory.Application.Abstractions;

namespace Wms.Inventory.Infrastructure.Persistence;

/// <summary>
/// Spec §12.7. TODO(Faza 1): query <c>inv_count WHERE location_id = @id AND status = 'FROZEN'</c> once the Count aggregate
/// is modelled; until then no location is frozen.
/// </summary>
public sealed class LocationFreezeChecker : ILocationFreezeChecker
{
    public Task<bool> IsFrozenAsync(uint locationId, CancellationToken cancellationToken) => Task.FromResult(false);
}
