using Wms.Common.Domain;

namespace Wms.Notification.Domain.Entities;

/// <summary>Severity of an in-app notification.</summary>
public enum NotificationSeverity
{
    Info,
    Warning,
    Critical,
}

public static class NotificationErrors
{
    public static Error InvalidMessage(string reason) => new("INVALID_NOTIFICATION", reason, 422);
}

/// <summary>
/// <c>notif_message</c>: one in-app notification. <see cref="EventId"/> is unique per tenant so a redelivered
/// integration event never produces a duplicate (spec §14.1: consumers must be idempotent).
/// </summary>
public sealed class NotificationMessage : Entity<long>, ITenantEntity
{
    private NotificationMessage()
    {
    }

    public uint TenantId { get; private set; }

    /// <summary>De-duplication key: the integration event's <c>EventId</c>.</summary>
    public Guid EventId { get; private set; }

    public string EventType { get; private set; } = string.Empty;

    public uint? RecipientUserId { get; private set; }

    public string? RecipientRole { get; private set; }

    public string Channel { get; private set; } = "IN_APP";

    public NotificationSeverity Severity { get; private set; } = NotificationSeverity.Info;

    public string Title { get; private set; } = string.Empty;

    public string Body { get; private set; } = string.Empty;

    public DateTimeOffset CreatedAt { get; private set; }

    public DateTimeOffset? ReadAt { get; private set; }

    public static Result<NotificationMessage> Create(
        uint tenantId,
        Guid eventId,
        string eventType,
        string title,
        string body,
        DateTimeOffset createdAt,
        NotificationSeverity severity = NotificationSeverity.Info,
        uint? recipientUserId = null,
        string? recipientRole = null,
        string channel = "IN_APP")
    {
        if (string.IsNullOrWhiteSpace(title) || title.Length > 200)
        {
            return NotificationErrors.InvalidMessage("title must be 1..200 characters.");
        }

        if (recipientUserId is null && string.IsNullOrWhiteSpace(recipientRole))
        {
            return NotificationErrors.InvalidMessage("Either recipient_user_id or recipient_role is required.");
        }

        return new NotificationMessage
        {
            TenantId = tenantId,
            EventId = eventId,
            EventType = eventType,
            RecipientUserId = recipientUserId,
            RecipientRole = recipientRole,
            Channel = channel,
            Severity = severity,
            Title = title.Trim(),
            Body = body ?? string.Empty,
            CreatedAt = createdAt,
        };
    }

    public void MarkRead(DateTimeOffset at) => ReadAt ??= at;
}

/// <summary><c>notif_rule</c>: which event goes to which role over which channel (TOR §36 — parametric).</summary>
public sealed class NotificationRule : Entity<uint>, ITenantEntity
{
    private NotificationRule()
    {
    }

    public uint TenantId { get; private set; }

    public string EventType { get; private set; } = string.Empty;

    public string RecipientRole { get; private set; } = string.Empty;

    public string Channel { get; private set; } = "IN_APP";

    public NotificationSeverity Severity { get; private set; } = NotificationSeverity.Info;

    public bool IsActive { get; private set; } = true;

    public static NotificationRule Create(uint tenantId, string eventType, string recipientRole, string channel = "IN_APP", NotificationSeverity severity = NotificationSeverity.Info)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(eventType);
        ArgumentException.ThrowIfNullOrWhiteSpace(recipientRole);
        return new NotificationRule
        {
            TenantId = tenantId,
            EventType = eventType,
            RecipientRole = recipientRole,
            Channel = channel,
            Severity = severity,
        };
    }

    public void Deactivate() => IsActive = false;
}
