namespace Wms.Procurement.Domain.Enums;

public enum ProductType
{
    Food,
    NonFood,
}

/// <summary><c>proc_approval_rule.product_type</c> allows ANY in addition to the product types.</summary>
public enum ApprovalProductType
{
    Food,
    NonFood,
    Any,
}

public enum Priority
{
    Low,
    Normal,
    High,
    Urgent,
}

/// <summary><c>proc_requisition.status</c>.</summary>
public enum RequisitionStatus
{
    Draft,
    Submitted,
    InProcurement,
    ConvertedToPo,
    Rejected,
    Cancelled,
    Closed,
}

/// <summary><c>proc_rfq.status</c>.</summary>
public enum RfqStatus
{
    Draft,
    Sent,
    Closed,
    Cancelled,
}

/// <summary><c>proc_purchase_order.status</c>.</summary>
public enum PurchaseOrderStatus
{
    Draft,
    PendingApproval,
    Approved,
    Rejected,
    SentToSupplier,
    PartiallyReceived,
    FullyReceived,
    Closed,
    Cancelled,
}

/// <summary><c>proc_approval_instance.status</c>.</summary>
public enum ApprovalStatus
{
    Pending,
    Approved,
    Rejected,
    Cancelled,
}

/// <summary><c>proc_approval_step.decision</c>.</summary>
public enum ApprovalDecision
{
    Pending,
    Approved,
    Rejected,
}

/// <summary><c>proc_approval_rule.doc_type</c> / <c>proc_approval_instance.doc_type</c> (spec §10, VARCHAR(24)).</summary>
public enum ApprovalDocType
{
    /// <summary>Purchase order.</summary>
    Po,

    /// <summary>Waste document approved in Inventory.</summary>
    Waste,

    /// <summary>Stock-count adjustment approved in Inventory.</summary>
    CountAdjust,
}

public static class ApprovalProductTypes
{
    /// <summary>Widens a document's product type into the rule's three-valued enum.</summary>
    public static ApprovalProductType From(ProductType productType) =>
        productType == ProductType.Food ? ApprovalProductType.Food : ApprovalProductType.NonFood;
}
