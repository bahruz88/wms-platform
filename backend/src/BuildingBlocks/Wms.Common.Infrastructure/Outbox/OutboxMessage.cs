namespace Wms.Common.Infrastructure.Outbox;

/// <summary>Row of <c>common_outbox</c> (spec §11, §14.1). Deliberately not an <c>ITenantEntity</c>: the publisher reads all tenants.</summary>
public sealed class OutboxMessage
{
    public const int MaxErrorLength = 4000;

    private OutboxMessage()
    {
    }

    public long Id { get; private set; }

    public uint TenantId { get; private set; }

    public string EventType { get; private set; } = string.Empty;

    public string Payload { get; private set; } = string.Empty;

    public DateTimeOffset OccurredAt { get; private set; }

    public DateTimeOffset? ProcessedAt { get; private set; }

    public ushort AttemptCount { get; private set; }

    public string? LastError { get; private set; }

    public static OutboxMessage Create(uint tenantId, string eventType, string payloadJson, DateTimeOffset occurredAt)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(eventType);
        ArgumentException.ThrowIfNullOrWhiteSpace(payloadJson);
        return new OutboxMessage
        {
            TenantId = tenantId,
            EventType = eventType.Length > 120 ? eventType[..120] : eventType,
            Payload = payloadJson,
            OccurredAt = occurredAt,
        };
    }

    public void MarkProcessed(DateTimeOffset at)
    {
        ProcessedAt = at;
        LastError = null;
    }

    public void MarkFailed(string error)
    {
        ArgumentNullException.ThrowIfNull(error);
        AttemptCount++;
        LastError = error.Length > MaxErrorLength ? error[..MaxErrorLength] : error;
    }
}
