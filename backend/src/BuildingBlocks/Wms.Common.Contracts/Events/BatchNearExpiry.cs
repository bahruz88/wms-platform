namespace Wms.Common.Contracts.Events;

/// <summary>Raised by the ExpiryScanner job for batches inside the warning/critical window. Consumer: Notification.</summary>
public sealed record BatchNearExpiry(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long BatchId,
    uint ProductId,
    string BatchNo,
    DateOnly ExpiryDate,
    int DaysLeft,
    bool IsCritical,
    decimal QtyOnHand) : IntegrationEvent(TenantId, OccurredAt);
