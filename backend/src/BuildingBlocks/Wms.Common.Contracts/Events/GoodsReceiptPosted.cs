namespace Wms.Common.Contracts.Events;

public sealed record GoodsReceiptPostedLine(
    uint ProductId,
    long? BatchId,
    decimal QtyBase,
    ushort BaseUomId,
    decimal? UnitCostBase);

/// <summary>Raised when a goods receipt is posted to the ledger. Consumers: Notification, Reporting, Integration (1C).</summary>
public sealed record GoodsReceiptPosted(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long ReceiptId,
    string DocNo,
    long? PurchaseOrderId,
    uint SupplierId,
    uint LocationId,
    long MovementGroupId,
    IReadOnlyList<GoodsReceiptPostedLine> Lines) : IntegrationEvent(TenantId, OccurredAt);
