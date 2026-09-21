using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.Infrastructure.Persistence;

/// <summary>
/// Spec §12.7: while an <c>inv_count</c> holds a location (FROZEN → APPROVED), every RECEIPT / ISSUE / TRANSFER /
/// WASTE / SAMPLE / CONSUMPTION posting on it is rejected with <c>409 LOCATION_FROZEN</c>. Posting or cancelling the
/// count lifts the block. The behaviour is switchable per tenant through
/// <c>inv_setting.block_transactions_during_count</c> (spec §9.1, TOR §36 — nothing hard-coded).
/// </summary>
public sealed class LocationFreezeChecker(InventoryDbContext db, IInventorySettings settings) : ILocationFreezeChecker
{
    public async Task<bool> IsFrozenAsync(uint locationId, CancellationToken cancellationToken)
    {
        if (locationId == 0)
        {
            return false;
        }

        if (!await settings.GetBoolAsync(InventorySettingKeys.BlockTransactionsDuringCount, cancellationToken).ConfigureAwait(false))
        {
            return false;
        }

        return await db.Counts.AsNoTracking()
            .AnyAsync(c => c.LocationId == locationId && StockCount.FreezingStatuses.Contains(c.Status), cancellationToken)
            .ConfigureAwait(false);
    }
}
