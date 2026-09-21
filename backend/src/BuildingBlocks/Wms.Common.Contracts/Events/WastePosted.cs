namespace Wms.Common.Contracts.Events;

/// <summary>Waste document posted to the ledger (V_WASTE). Consumers: Notification, Reporting.</summary>
public sealed record WastePosted(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long WasteId,
    string DocNo,
    uint LocationId,
    ushort ReasonCodeId,
    long MovementGroupId,
    decimal TotalQtyBase,
    decimal TotalCostBase) : IntegrationEvent(TenantId, OccurredAt);
