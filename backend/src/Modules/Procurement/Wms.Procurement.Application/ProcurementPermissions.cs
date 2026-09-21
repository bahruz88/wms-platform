namespace Wms.Procurement.Application;

public static class ProcurementPermissions
{
    public const string RequisitionCreate = "proc.pr.create";
    public const string RequisitionView = "proc.pr.view";
    public const string PurchaseOrderCreate = "proc.po.create";
    public const string PurchaseOrderView = "proc.po.view";

    /// <summary>Spec §7.1.</summary>
    public const string PurchaseOrderApprove = "proc.po.approve";

    public const string PurchaseOrderSend = "proc.po.send";
}
