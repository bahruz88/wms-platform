namespace Wms.Inventory.Domain.Enums;

/// <summary><c>inv_batch.status</c> (spec §9.2). Only <see cref="Active"/> batches are allocatable (spec §12.4).</summary>
public enum BatchStatus
{
    Active,
    Blocked,
    Expired,
    Quarantine,
}
