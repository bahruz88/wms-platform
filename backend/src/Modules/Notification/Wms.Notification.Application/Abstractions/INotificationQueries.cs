using Wms.Common.Application.Paging;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Application.Abstractions;

/// <summary>One row of <c>listNotifications</c> / <c>getNotification</c>.</summary>
public sealed record NotificationDto(
    long Id,
    string EventType,
    string Severity,
    string Title,
    string? Body,
    string? Link,
    string? EntityType,
    long? EntityId,
    uint? LocationId,
    DateTimeOffset CreatedAt,
    bool IsRead,
    DateTimeOffset? ReadAt,
    Guid EventId);

/// <summary><c>getUnreadCount</c> — the figure behind the bell badge.</summary>
public sealed record UnreadCountDto(int Total, IReadOnlyDictionary<string, int> BySeverity, int PendingApprovals);

/// <summary>One row of <c>listNotificationRules</c>.</summary>
public sealed record NotificationRuleDto(
    uint Id,
    string EventType,
    string Severity,
    IReadOnlyList<string> Channels,
    string? TargetRoleCode,
    IReadOnlyList<uint> TargetUserIds,
    bool TargetLocationScoped,
    string Digest,
    bool IsSystem,
    bool IsActive,
    uint RowVersion);

public interface INotificationQueries
{
    /// <summary>Notifications addressed to the current user directly or through one of their roles.</summary>
    Task<PagedResult<NotificationDto>> GetForUserAsync(uint userId, IReadOnlyCollection<string> roles, bool unreadOnly, PageRequest page, CancellationToken cancellationToken);

    /// <summary>A single notification, but only if it is addressed to this caller.</summary>
    Task<NotificationDto?> GetAsync(long id, uint userId, IReadOnlyCollection<string> roles, CancellationToken cancellationToken);

    Task<UnreadCountDto> GetUnreadCountAsync(uint userId, IReadOnlyCollection<string> roles, CancellationToken cancellationToken);

    Task<IReadOnlyList<NotificationRuleDto>> ListRulesAsync(bool? isActive, CancellationToken cancellationToken);
}

/// <summary>Write side of the module: rules, devices and the read marks on messages.</summary>
public interface INotificationRepository
{
    Task<NotificationMessage?> GetMessageAsync(long id, uint userId, IReadOnlyCollection<string> roles, CancellationToken cancellationToken);

    /// <summary>Marks every unread message of this caller read; returns how many changed.</summary>
    Task<int> MarkAllReadAsync(uint userId, IReadOnlyCollection<string> roles, DateTimeOffset at, CancellationToken cancellationToken);

    Task<NotificationRule?> GetRuleAsync(uint id, CancellationToken cancellationToken);

    void AddRule(NotificationRule rule);

    Task<NotificationDevice?> GetDeviceAsync(uint userId, string deviceId, CancellationToken cancellationToken);

    void AddDevice(NotificationDevice device);

    void RemoveDevice(NotificationDevice device);
}

public interface INotificationUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}

/// <summary>
/// Pending approval steps for the badge. Procurement owns the number; the port keeps the dependency
/// one-way so the notification module never queries another module's tables.
/// </summary>
public interface IPendingApprovalCounter
{
    Task<int> CountForUserAsync(uint userId, CancellationToken cancellationToken);
}
