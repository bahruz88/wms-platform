namespace Wms.Inventory.Application;

/// <summary>Permission codes of the module (<c>iam_permission.code</c>, spec §7).</summary>
public static class InventoryPermissions
{
    public const string ReceiptCreate = "inv.receipt.create";
    public const string ReceiptPost = "inv.receipt.post";
    public const string ReceiptView = "inv.receipt.view";
    public const string BalanceView = "inv.balance.view";
    public const string BatchView = "inv.batch.view";
    public const string AdjustmentApprove = "inv.adjustment.approve";
    public const string WasteApprove = "inv.waste.approve";
    public const string MovementReverse = "inv.movement.reverse";

    /// <summary>Owned by MasterData but enforced here: without it cost fields are omitted from DTOs (spec §16).</summary>
    public const string ViewCost = "master.product.view_cost";
}
