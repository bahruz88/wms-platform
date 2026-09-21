namespace Wms.Common.Contracts.Events;

/// <summary>A new purchase price differs from the previous one (spec TOR §25). Consumers: Notification, Reporting.</summary>
public sealed record PriceChanged(
    uint TenantId,
    DateTimeOffset OccurredAt,
    uint ProductId,
    uint SupplierId,
    DateOnly PriceDate,
    string Currency,
    decimal UnitPrice,
    decimal UnitPriceBase,
    decimal? PreviousUnitPriceBase,
    decimal? DiffAmount,
    decimal? DiffPct) : IntegrationEvent(TenantId, OccurredAt);
