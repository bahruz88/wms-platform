namespace Wms.Common.Contracts.Events;

/// <summary>Raised by the ExpiryScanner job when a batch passes its expiry date. Consumers: Notification, Inventory (block).</summary>
public sealed record BatchExpired(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long BatchId,
    uint ProductId,
    string BatchNo,
    DateOnly ExpiryDate,
    decimal QtyOnHand) : IntegrationEvent(TenantId, OccurredAt);
