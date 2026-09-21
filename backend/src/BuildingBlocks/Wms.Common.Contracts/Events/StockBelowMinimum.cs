namespace Wms.Common.Contracts.Events;

/// <summary>Balance dropped below <c>min_stock</c>. Consumer: Notification.</summary>
public sealed record StockBelowMinimum(
    uint TenantId,
    DateTimeOffset OccurredAt,
    uint ProductId,
    uint LocationId,
    decimal QtyOnHand,
    decimal MinStock) : IntegrationEvent(TenantId, OccurredAt);
