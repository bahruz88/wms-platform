namespace Wms.Common.Contracts.Events;

public sealed record ConsumptionPostedLine(uint ProductId, decimal PostedQtyBase, decimal ShortfallQtyBase, ushort BaseUomId);

/// <summary>
/// A theoretical consumption document has been posted to the ledger: branch −qty / V_CONSUMPTION +qty
/// (ADR-012). Consumers: Reporting, Notification, Integration.
/// </summary>
public sealed record ConsumptionPosted(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long ConsumptionRunId,
    string DocNo,
    uint LocationId,
    DateOnly BusinessDate,
    long? MovementGroupId,
    decimal TotalPostedQtyBase,
    decimal TotalShortfallQtyBase,
    IReadOnlyList<ConsumptionPostedLine> Lines) : IntegrationEvent(TenantId, OccurredAt);
