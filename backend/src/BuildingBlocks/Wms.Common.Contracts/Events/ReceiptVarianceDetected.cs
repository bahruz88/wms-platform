namespace Wms.Common.Contracts.Events;

/// <summary>PO quantity differs from the received quantity (spec §12.8). Consumer: Notification.</summary>
public sealed record ReceiptVarianceDetected(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long ReceiptId,
    string DocNo,
    long? PurchaseOrderId,
    uint ProductId,
    decimal OrderedQty,
    decimal ReceivedQty,
    decimal VariancePct,
    string? VarianceNote) : IntegrationEvent(TenantId, OccurredAt);
