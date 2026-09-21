namespace Wms.Inventory.Domain.Enums;

/// <summary><c>inv_count.count_type</c> (spec §9.6, TOR §21).</summary>
public enum CountType
{
    /// <summary>Every product/batch currently on the location.</summary>
    Full,

    /// <summary>A subset picked by category and/or product.</summary>
    Cycle,

    /// <summary>A handful of products.</summary>
    Spot,
}

/// <summary><c>inv_count.status</c>. The location stays frozen from FROZEN until POSTED or CANCELLED (spec §12.7).</summary>
public enum CountStatus
{
    Draft,
    Frozen,
    Counting,
    Review,
    Approved,
    Posted,
    Cancelled,
}
