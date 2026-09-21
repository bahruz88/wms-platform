namespace Wms.Inventory.Domain.Enums;

/// <summary><c>inv_goods_receipt.status</c>.</summary>
public enum ReceiptStatus
{
    Draft,
    Posted,
    Cancelled,
}

/// <summary><c>inv_goods_receipt.quality_status</c> (TOR §12).</summary>
public enum QualityStatus
{
    Accepted,
    PartiallyAccepted,
    Rejected,
}
