namespace Wms.Common.Contracts.Events;

public sealed record ConsumptionShortfallLine(uint ProductId, decimal TheoreticalQtyBase, decimal PostedQtyBase, decimal ShortfallQtyBase, ushort BaseUomId);

/// <summary>
/// Stock did not cover the theoretical consumption: the ledger took what was there and the remainder is
/// recorded, never hidden (ADR-012 invariant 3) — the earliest signal of an unrecorded receipt.
/// Consumers: Notification (branch + manager).
/// </summary>
public sealed record ConsumptionShortfallDetected(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long ConsumptionRunId,
    string DocNo,
    uint LocationId,
    DateOnly BusinessDate,
    IReadOnlyList<ConsumptionShortfallLine> Lines) : IntegrationEvent(TenantId, OccurredAt);
