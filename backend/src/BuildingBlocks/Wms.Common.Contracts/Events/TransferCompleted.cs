namespace Wms.Common.Contracts.Events;

/// <summary>Branch confirmed an in-transit transfer (IN_TRANSIT → branch). Consumer: Notification.</summary>
public sealed record TransferCompleted(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long IssueId,
    string DocNo,
    uint FromLocationId,
    uint ToLocationId,
    long ReceiptGroupId,
    bool HasDiscrepancy) : IntegrationEvent(TenantId, OccurredAt);
