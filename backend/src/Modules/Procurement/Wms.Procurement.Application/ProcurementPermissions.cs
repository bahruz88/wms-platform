namespace Wms.Procurement.Application;

/// <summary>Every <c>x-permission</c> declared by <c>contracts/openapi/procurement.v1.yaml</c>.</summary>
public static class ProcurementPermissions
{
    public const string RequisitionView = "proc.pr.view";
    public const string RequisitionCreate = "proc.pr.create";
    public const string RequisitionSubmit = "proc.pr.submit";
    public const string RequisitionReject = "proc.pr.reject";

    public const string RfqView = "proc.rfq.view";
    public const string RfqCreate = "proc.rfq.create";

    public const string QuotationView = "proc.quotation.view";
    public const string QuotationCreate = "proc.quotation.create";
    public const string QuotationSelect = "proc.quotation.select";

    public const string PurchaseOrderView = "proc.po.view";
    public const string PurchaseOrderCreate = "proc.po.create";
    public const string PurchaseOrderSubmit = "proc.po.submit";

    /// <summary>Spec §7.1.</summary>
    public const string PurchaseOrderApprove = "proc.po.approve";

    public const string PurchaseOrderSend = "proc.po.send";
    public const string PurchaseOrderClose = "proc.po.close";

    /// <summary>Price-free PO view for the warehouse keeper (<c>listOpenPurchaseOrdersForReceipt</c>).</summary>
    public const string PurchaseOrderViewForReceipt = "proc.po.view_for_receipt";

    public const string ApprovalView = "proc.approval.view";
    public const string ApprovalDecide = "proc.approval.decide";
    public const string ApprovalRuleView = "proc.approval_rule.view";
    public const string ApprovalRuleManage = "proc.approval_rule.manage";

    /// <summary>Price history is cost data — the warehouse keeper must not see it (spec §7.1).</summary>
    public const string ProductViewCost = "master.product.view_cost";
}
