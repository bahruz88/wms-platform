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

    public static Error InvalidRule(string reason) => new("INVALID_NOTIFICATION_RULE", reason, 422);

    public static Error InvalidDevice(string reason) => new("INVALID_DEVICE", reason, 422);

    public static Error RuleNotFound(uint id) => new("NOTIFICATION_RULE_NOT_FOUND", $"Notification rule {id} was not found.", 404);

    public static Error MessageNotFound(long id) => new("NOTIFICATION_NOT_FOUND", $"Notification {id} was not found.", 404);

    public static Error DeviceNotFound(string deviceId) => new("DEVICE_NOT_FOUND", $"Device '{deviceId}' was not found.", 404);

    /// <summary>A platform-seeded rule may be switched off, never retargeted or removed.</summary>
    public static Error SystemRuleLocked(uint id) => new("SYSTEM_RULE_LOCKED", $"Notification rule {id} is a system rule.", 409);
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

    /// <summary>In-app deep link, e.g. <c>/inventory/goods-receipts/311</c>; mobile uses the same path.</summary>
    public string? Link { get; private set; }

    public string? EntityType { get; private set; }

    public long? EntityId { get; private set; }

    /// <summary>The event's location, so a branch user is never shown another branch's alert.</summary>
    public uint? LocationId { get; private set; }

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
        string channel = "IN_APP",
        string? link = null,
        string? entityType = null,
        long? entityId = null,
        uint? locationId = null)
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
            Link = link,
            EntityType = entityType,
            EntityId = entityId,
            LocationId = locationId,
            CreatedAt = createdAt,
        };
    }

    public void MarkRead(DateTimeOffset at) => ReadAt ??= at;
}

/// <summary>How often a rule fires: immediately, or once a day as a digest.</summary>
public enum NotificationDigest
{
    Immediate,
    Daily,
}

public enum DevicePlatform
{
    Android,
    Ios,
}

/// <summary>
/// <c>notif_rule</c>: which event reaches whom, over which channel (TOR §36 — parametric).
///
/// Channels and target users are lists in the contract but single columns here: a rule is read on
/// every event and written by hand a few times a year, so a joined child table would cost a query
/// per event to save nothing. They are stored comma-separated and parsed through the accessors below.
/// </summary>
public sealed class NotificationRule : AuditableEntity<uint>, ITenantEntity
{
    public const int RoleCodeMaxLength = 48;

    private NotificationRule()
    {
    }

    public uint TenantId { get; private set; }

    public string EventType { get; private set; } = string.Empty;

    public NotificationSeverity Severity { get; private set; } = NotificationSeverity.Info;

    /// <summary>Comma-separated <c>IN_APP,EMAIL,PUSH</c>; read through <see cref="ChannelList"/>.</summary>
    public string Channels { get; private set; } = "IN_APP";

    public string? TargetRoleCode { get; private set; }

    /// <summary>Comma-separated user ids; read through <see cref="TargetUserIdList"/>.</summary>
    public string? TargetUserIds { get; private set; }

    /// <summary>When true the message only reaches users entitled to the event's location.</summary>
    public bool TargetLocationScoped { get; private set; } = true;

    public NotificationDigest Digest { get; private set; } = NotificationDigest.Immediate;

    /// <summary>Seeded by the platform. A system rule may be switched off but not deleted.</summary>
    public bool IsSystem { get; private set; }

    public bool IsActive { get; private set; } = true;

    public IReadOnlyList<string> ChannelList => Split(Channels);

    public IReadOnlyList<uint> TargetUserIdList =>
        Split(TargetUserIds).Select(v => uint.TryParse(v, out var id) ? id : 0u).Where(id => id > 0).ToList();

    public static Result<NotificationRule> Create(
        uint tenantId,
        string eventType,
        NotificationSeverity severity,
        IReadOnlyList<string> channels,
        string? targetRoleCode = null,
        IReadOnlyList<uint>? targetUserIds = null,
        bool targetLocationScoped = true,
        NotificationDigest digest = NotificationDigest.Immediate,
        bool isSystem = false)
    {
        var validated = Validate(eventType, channels, targetRoleCode);
        if (validated.IsFailure)
        {
            return validated.Error;
        }

        return new NotificationRule
        {
            TenantId = tenantId,
            EventType = eventType.Trim(),
            Severity = severity,
            Channels = Join(channels),
            TargetRoleCode = string.IsNullOrWhiteSpace(targetRoleCode) ? null : targetRoleCode.Trim(),
            TargetUserIds = targetUserIds is { Count: > 0 } ? string.Join(',', targetUserIds) : null,
            TargetLocationScoped = targetLocationScoped,
            Digest = digest,
            IsSystem = isSystem,
        };
    }

    public Result Update(
        string eventType,
        NotificationSeverity severity,
        IReadOnlyList<string> channels,
        string? targetRoleCode,
        IReadOnlyList<uint>? targetUserIds,
        bool targetLocationScoped,
        NotificationDigest digest,
        bool isActive)
    {
        var validated = Validate(eventType, channels, targetRoleCode);
        if (validated.IsFailure)
        {
            return validated.Error;
        }

        if (IsSystem && !string.Equals(EventType, eventType.Trim(), StringComparison.Ordinal))
        {
            // Retargeting a seeded rule would silently break the delivery the platform promises.
            return NotificationErrors.SystemRuleLocked(Id);
        }

        EventType = eventType.Trim();
        Severity = severity;
        Channels = Join(channels);
        TargetRoleCode = string.IsNullOrWhiteSpace(targetRoleCode) ? null : targetRoleCode.Trim();
        TargetUserIds = targetUserIds is { Count: > 0 } ? string.Join(',', targetUserIds) : null;
        TargetLocationScoped = targetLocationScoped;
        Digest = digest;
        IsActive = isActive;
        return Result.Success();
    }

    /// <summary>A system rule is switched off rather than removed, so the platform can switch it back on.</summary>
    public Result Delete()
    {
        if (IsSystem)
        {
            return NotificationErrors.SystemRuleLocked(Id);
        }

        IsActive = false;
        return Result.Success();
    }

    public void Deactivate() => IsActive = false;

    private static Result Validate(string eventType, IReadOnlyList<string> channels, string? targetRoleCode)
    {
        if (string.IsNullOrWhiteSpace(eventType) || eventType.Length > 120)
        {
            return NotificationErrors.InvalidRule("event_type must be 1..120 characters.");
        }

        if (channels is null || channels.Count == 0)
        {
            return NotificationErrors.InvalidRule("At least one channel is required.");
        }

        foreach (var channel in channels)
        {
            if (channel is not ("IN_APP" or "EMAIL" or "PUSH"))
            {
                return NotificationErrors.InvalidRule($"Unknown channel '{channel}'.");
            }
        }

        if (targetRoleCode is { Length: > RoleCodeMaxLength })
        {
            return NotificationErrors.InvalidRule($"target_role_code must be at most {RoleCodeMaxLength} characters.");
        }

        return Result.Success();
    }

    private static string Join(IReadOnlyList<string> values) =>
        string.Join(',', values.Select(v => v.Trim()).Where(v => v.Length > 0).Distinct(StringComparer.Ordinal));

    private static IReadOnlyList<string> Split(string? value) =>
        string.IsNullOrWhiteSpace(value)
            ? []
            : value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
}

/// <summary>
/// <c>notif_device</c>: one push target. The same person on two handsets is two rows; the same
/// handset re-registering updates its token in place, because a stale FCM token silently drops pushes.
/// </summary>
public sealed class NotificationDevice : AuditableEntity<long>, ITenantEntity
{
    public const int DeviceIdMaxLength = 128;
    public const int PushTokenMaxLength = 512;
    public const int AppVersionMaxLength = 32;

    private NotificationDevice()
    {
    }

    public uint TenantId { get; private set; }

    public uint UserId { get; private set; }

    public string DeviceId { get; private set; } = string.Empty;

    public DevicePlatform Platform { get; private set; }

    public string PushToken { get; private set; } = string.Empty;

    public string? AppVersion { get; private set; }

    public DateTimeOffset RegisteredAt { get; private set; }

    public static Result<NotificationDevice> Register(
        uint tenantId,
        uint userId,
        string deviceId,
        DevicePlatform platform,
        string pushToken,
        string? appVersion,
        DateTimeOffset at)
    {
        var validated = Validate(deviceId, pushToken, appVersion);
        if (validated.IsFailure)
        {
            return validated.Error;
        }

        return new NotificationDevice
        {
            TenantId = tenantId,
            UserId = userId,
            DeviceId = deviceId.Trim(),
            Platform = platform,
            PushToken = pushToken.Trim(),
            AppVersion = appVersion?.Trim(),
            RegisteredAt = at,
        };
    }

    public Result Refresh(DevicePlatform platform, string pushToken, string? appVersion, DateTimeOffset at)
    {
        var validated = Validate(DeviceId, pushToken, appVersion);
        if (validated.IsFailure)
        {
            return validated.Error;
        }

        Platform = platform;
        PushToken = pushToken.Trim();
        AppVersion = appVersion?.Trim();
        RegisteredAt = at;
        return Result.Success();
    }

    private static Result Validate(string deviceId, string pushToken, string? appVersion)
    {
        if (string.IsNullOrWhiteSpace(deviceId) || deviceId.Length > DeviceIdMaxLength)
        {
            return NotificationErrors.InvalidDevice($"device_id must be 1..{DeviceIdMaxLength} characters.");
        }

        if (string.IsNullOrWhiteSpace(pushToken) || pushToken.Length > PushTokenMaxLength)
        {
            return NotificationErrors.InvalidDevice($"push_token must be 1..{PushTokenMaxLength} characters.");
        }

        if (appVersion is { Length: > AppVersionMaxLength })
        {
            return NotificationErrors.InvalidDevice($"app_version must be at most {AppVersionMaxLength} characters.");
        }

        return Result.Success();
    }
}
