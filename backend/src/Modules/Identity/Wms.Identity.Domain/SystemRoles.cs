namespace Wms.Identity.Domain;

/// <summary>Realm roles of the Keycloak realm <c>wms</c> (CONVENTIONS.md) mirrored into <c>iam_role</c>.</summary>
public static class SystemRoles
{
    public const string Admin = "ADMIN";
    public const string ProcurementOfficer = "PROCUREMENT_OFFICER";
    public const string ProcurementManager = "PROCUREMENT_MANAGER";
    public const string WarehouseKeeper = "WAREHOUSE_KEEPER";
    public const string BranchUser = "BRANCH_USER";
    public const string Auditor = "AUDITOR";

    public static IReadOnlyList<string> All { get; } =
        [Admin, ProcurementOfficer, ProcurementManager, WarehouseKeeper, BranchUser, Auditor];
}

/// <summary>Critical permission codes of spec §7.1.</summary>
public static class SystemPermissions
{
    public const string ProductViewCost = "master.product.view_cost";
    public const string AdjustmentApprove = "inv.adjustment.approve";
    public const string WasteApprove = "inv.waste.approve";
    public const string PurchaseOrderApprove = "proc.po.approve";
    public const string MovementReverse = "inv.movement.reverse";
}
