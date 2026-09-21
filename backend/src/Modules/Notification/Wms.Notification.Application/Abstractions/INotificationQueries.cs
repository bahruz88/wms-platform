using Wms.Common.Application.Paging;

namespace Wms.Notification.Application.Abstractions;

public sealed record NotificationDto(
    long Id,
    string EventType,
    string Severity,
    string Title,
    string Body,
    DateTimeOffset CreatedAt,
    DateTimeOffset? ReadAt);

public interface INotificationQueries
{
    /// <summary>Notifications addressed to the current user directly or through one of their roles.</summary>
    Task<PagedResult<NotificationDto>> GetForUserAsync(uint userId, IReadOnlyCollection<string> roles, bool unreadOnly, PageRequest page, CancellationToken cancellationToken);
}
