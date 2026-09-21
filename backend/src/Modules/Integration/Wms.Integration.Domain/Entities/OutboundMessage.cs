using Wms.Common.Domain;

namespace Wms.Integration.Domain.Entities;

public enum OutboundStatus
{
    Pending,
    Sent,
    Failed,
    Skipped,
}

public static class IntegrationErrors
{
    public static Error InvalidMessage(string reason) => new("INVALID_INTEGRATION_MESSAGE", reason, 422);

    public static Error EndpointNotFound(string system) => new("INTEGRATION_ENDPOINT_NOT_FOUND", $"No active endpoint is configured for '{system}'.", 422);
}

/// <summary><c>intg_endpoint</c>: an external system such as 1C.</summary>
public sealed class IntegrationEndpoint : Entity<uint>, ITenantEntity
{
    public const string System1C = "1C";

    private IntegrationEndpoint()
    {
    }

    public uint TenantId { get; private set; }

    public string SystemCode { get; private set; } = string.Empty;

    public string BaseUrl { get; private set; } = string.Empty;

    public string? AuthRef { get; private set; }

    public bool IsActive { get; private set; } = true;

    public static IntegrationEndpoint Create(uint tenantId, string systemCode, string baseUrl, string? authRef = null)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(systemCode);
        ArgumentException.ThrowIfNullOrWhiteSpace(baseUrl);
        return new IntegrationEndpoint
        {
            TenantId = tenantId,
            SystemCode = systemCode.Trim().ToUpperInvariant(),
            BaseUrl = baseUrl.Trim(),
            AuthRef = authRef,
        };
    }

    public void Deactivate() => IsActive = false;
}

/// <summary><c>intg_outbound_message</c>: one integration event forwarded to an external system.</summary>
public sealed class OutboundMessage : Entity<long>, ITenantEntity
{
    public const int MaxErrorLength = 2000;

    private OutboundMessage()
    {
    }

    public uint TenantId { get; private set; }

    public string SystemCode { get; private set; } = string.Empty;

    /// <summary>De-duplication key: the integration event's <c>EventId</c>.</summary>
    public Guid EventId { get; private set; }

    public string EventType { get; private set; } = string.Empty;

    public string Payload { get; private set; } = string.Empty;

    public OutboundStatus Status { get; private set; } = OutboundStatus.Pending;

    public ushort AttemptCount { get; private set; }

    public string? LastError { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public DateTimeOffset? SentAt { get; private set; }

    public static Result<OutboundMessage> Create(uint tenantId, string systemCode, Guid eventId, string eventType, string payloadJson, DateTimeOffset createdAt)
    {
        if (eventId == Guid.Empty)
        {
            return IntegrationErrors.InvalidMessage("event_id is required for consumer de-duplication (spec §14.1).");
        }

        if (string.IsNullOrWhiteSpace(eventType) || string.IsNullOrWhiteSpace(payloadJson))
        {
            return IntegrationErrors.InvalidMessage("event_type and payload are required.");
        }

        return new OutboundMessage
        {
            TenantId = tenantId,
            SystemCode = systemCode,
            EventId = eventId,
            EventType = eventType,
            Payload = payloadJson,
            CreatedAt = createdAt,
        };
    }

    public void MarkSent(DateTimeOffset at)
    {
        Status = OutboundStatus.Sent;
        SentAt = at;
        LastError = null;
    }

    public void MarkFailed(string error)
    {
        ArgumentNullException.ThrowIfNull(error);
        Status = OutboundStatus.Failed;
        AttemptCount++;
        LastError = error.Length > MaxErrorLength ? error[..MaxErrorLength] : error;
    }

    public void MarkSkipped(string reason)
    {
        Status = OutboundStatus.Skipped;
        LastError = reason;
    }
}

/// <summary><c>intg_sync_cursor</c>: where the last master-data synchronisation stopped (Faza 4).</summary>
public sealed class SyncCursor : Entity<uint>, ITenantEntity
{
    private SyncCursor()
    {
    }

    public uint TenantId { get; private set; }

    public string SystemCode { get; private set; } = string.Empty;

    public string Resource { get; private set; } = string.Empty;

    public DateTimeOffset? LastSyncedAt { get; private set; }

    public string? LastCursor { get; private set; }

    public static SyncCursor Create(uint tenantId, string systemCode, string resource)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(systemCode);
        ArgumentException.ThrowIfNullOrWhiteSpace(resource);
        return new SyncCursor { TenantId = tenantId, SystemCode = systemCode, Resource = resource };
    }

    public void Advance(DateTimeOffset syncedAt, string? cursor)
    {
        LastSyncedAt = syncedAt;
        LastCursor = cursor;
    }
}
