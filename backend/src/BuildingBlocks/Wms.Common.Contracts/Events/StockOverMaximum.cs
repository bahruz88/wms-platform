namespace Wms.Common.Contracts.Events;

/// <summary>Balance exceeded <c>max_stock</c>. Consumer: Notification.</summary>
public sealed record StockOverMaximum(
    uint TenantId,
    DateTimeOffset OccurredAt,
    uint ProductId,
    uint LocationId,
    decimal QtyOnHand,
    decimal MaxStock) : IntegrationEvent(TenantId, OccurredAt);
