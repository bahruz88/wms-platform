namespace Wms.Common.Contracts.Events;

/// <summary>Approval chain completed for a purchase order. Consumers: Notification, Integration.</summary>
public sealed record PurchaseOrderApproved(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long PurchaseOrderId,
    string DocNo,
    uint SupplierId,
    string Currency,
    decimal TotalAmount,
    decimal TotalAmountBase,
    uint ApprovedBy) : IntegrationEvent(TenantId, OccurredAt);
