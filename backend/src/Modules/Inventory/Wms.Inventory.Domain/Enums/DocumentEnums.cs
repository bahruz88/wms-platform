namespace Wms.Inventory.Domain.Enums;

/// <summary><c>inv_stock_request.status</c> (spec §9.6, TOR §16).</summary>
public enum StockRequestStatus
{
    Draft,
    Submitted,
    Picking,
    PartiallyIssued,
    Issued,
    Cancelled,
    Closed,
}

/// <summary><c>inv_issue.issue_type</c> (spec §9.6).</summary>
public enum IssueType
{
    /// <summary>Warehouse → branch.</summary>
    BranchIssue,

    /// <summary>Warehouse → warehouse or sub-location.</summary>
    WhTransfer,

    /// <summary>Branch → branch.</summary>
    BranchTransfer,
}

/// <summary><c>inv_issue.status</c>. The two-step IN_TRANSIT mechanism lives here (spec §12.3).</summary>
public enum IssueStatus
{
    Draft,
    Dispatched,
    Received,
    Discrepancy,
    Cancelled,
}

/// <summary><c>inv_waste.status</c> (spec §9.6, TOR §22).</summary>
public enum WasteStatus
{
    Draft,
    PendingApproval,
    Approved,
    Posted,
    Rejected,
}

/// <summary>Documents without a status column derive one from <c>movement_group_id</c>.</summary>
public enum SimpleDocStatus
{
    Draft,
    Posted,
    Cancelled,
}

/// <summary><c>inv_return_to_vendor.status</c> (spec §9.6).</summary>
public enum RtvStatus
{
    Draft,
    Sent,
    Accepted,
    Rejected,
    Closed,
}
