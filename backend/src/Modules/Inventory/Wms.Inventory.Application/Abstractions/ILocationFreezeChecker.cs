namespace Wms.Inventory.Application.Abstractions;

/// <summary>Spec §12.7: while an <c>inv_count</c> is FROZEN for a location, RECEIPT/ISSUE/TRANSFER/WASTE/SAMPLE are rejected with <c>LOCATION_FROZEN</c>.</summary>
public interface ILocationFreezeChecker
{
    Task<bool> IsFrozenAsync(uint locationId, CancellationToken cancellationToken);
}
