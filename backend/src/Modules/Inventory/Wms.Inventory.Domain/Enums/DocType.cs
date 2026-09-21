namespace Wms.Inventory.Domain.Enums;

/// <summary><c>inv_movement_group.doc_type</c> (spec §9.3). Stored as MySQL ENUM in UPPER_SNAKE form.</summary>
public enum DocType
{
    Receipt,
    Issue,
    Transfer,
    CountAdjust,
    Waste,
    Sample,
    Return,
    Opening,
    Reversal,

    /// <summary>ADR-012: theoretical branch consumption (RESTAURANT −qty / V_CONSUMPTION +qty).</summary>
    Consumption,
}
