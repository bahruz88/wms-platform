namespace Wms.Common.Contracts.Events;

/// <summary>Inventory count variance approved and posted as COUNT_ADJUST. Consumers: Reporting, Integration.</summary>
public sealed record CountVarianceApproved(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long CountId,
    string DocNo,
    uint LocationId,
    uint ApprovedBy,
    long? AdjustGroupId,
    decimal TotalVarianceQty,
    decimal TotalVarianceCostBase) : IntegrationEvent(TenantId, OccurredAt);
