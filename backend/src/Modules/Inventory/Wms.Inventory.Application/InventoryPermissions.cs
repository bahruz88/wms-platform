namespace Wms.Inventory.Application;

/// <summary>Permission codes of the module (<c>iam_permission.code</c>, spec §7).</summary>
public static class InventoryPermissions
{
    public const string ReceiptCreate = "inv.receipt.create";
    public const string ReceiptPost = "inv.receipt.post";
    public const string ReceiptView = "inv.receipt.view";
    public const string BalanceView = "inv.balance.view";
    public const string BatchView = "inv.batch.view";
    public const string BatchManage = "inv.batch.manage";
    public const string RequestView = "inv.request.view";
    public const string RequestCreate = "inv.request.create";
    public const string IssueView = "inv.issue.view";
    public const string IssueCreate = "inv.issue.create";
    public const string IssueDispatch = "inv.issue.dispatch";
    /// <summary>
    /// Confirming the receipt of a dispatched issue or transfer. inventory.v1.yaml gates
    /// <c>confirmIssueReceipt</c> with <c>inv.issue.confirm</c>; the service used to demand
    /// <c>inv.transfer.confirm</c>, so the contract and the running system disagreed. The contract wins.
    /// </summary>
    public const string IssueConfirm = "inv.issue.confirm";
    public const string WasteView = "inv.waste.view";
    public const string WasteCreate = "inv.waste.create";
    public const string WastePost = "inv.waste.post";
    public const string SampleView = "inv.sample.view";
    public const string SampleCreate = "inv.sample.create";
    public const string SamplePost = "inv.sample.post";
    // inventory.v1.yaml spells the return-to-vendor permissions inv.rtv.*; the service used inv.return.*.
    public const string ReturnView = "inv.rtv.view";
    public const string ReturnCreate = "inv.rtv.create";
    public const string ReturnPost = "inv.rtv.post";
    public const string MovementView = "inv.movement.view";
    public const string CountView = "inv.count.view";
    public const string CountCreate = "inv.count.create";
    public const string CountFreeze = "inv.count.freeze";
    public const string CountEnter = "inv.count.enter";
    public const string CountPost = "inv.count.post";
    public const string AdjustmentApprove = "inv.adjustment.approve";
    public const string WasteApprove = "inv.waste.approve";
    public const string MovementReverse = "inv.movement.reverse";
    public const string SettingsView = "inv.settings.view";
    public const string SettingsManage = "inv.settings.manage";

    /// <summary>Owned by MasterData but enforced here: without it cost fields are omitted from DTOs (spec §16).</summary>
    public const string ViewCost = "master.product.view_cost";
}
