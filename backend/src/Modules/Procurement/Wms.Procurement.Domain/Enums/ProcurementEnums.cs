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
