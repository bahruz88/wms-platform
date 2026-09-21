namespace Wms.MasterData.Domain.Enums;

/// <summary><c>master_uom.uom_class</c>.</summary>
public enum UomClass
{
    Mass,
    Volume,
    Count,
}

/// <summary><c>master_product_category.product_type</c>.</summary>
public enum ProductType
{
    Food,
    NonFood,
}

/// <summary><c>master_product.issue_strategy</c> (spec §12.4).</summary>
public enum IssueStrategy
{
    Fefo,
    Fifo,
}

/// <summary><c>master_location.location_type</c> (spec §8). The <c>V_*</c> members are the virtual counter-accounts of the ledger (ADR-003).</summary>
public enum LocationType
{
    CentralWarehouse,
    SubLocation,
    Shelf,
    Restaurant,
    InTransit,
    VSupplier,
    VWaste,
    VSample,
    VAdjustment,

    /// <summary>ADR-012: counter-account of the branch consumption document.</summary>
    VConsumption,
}

/// <summary><c>master_reason_code.reason_group</c>.</summary>
public enum ReasonGroup
{
    Waste,
    Adjustment,
    Return,
    Sample,
    Transfer,
}
