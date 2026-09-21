using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Notification.Application.Abstractions;

namespace Wms.Notification.Application.Queries;

/// <summary><c>GET /api/v1/notifications</c> — the caller's own in-app notifications.</summary>
public sealed record GetMyNotificationsQuery(bool UnreadOnly, PageRequest Page) : IQuery<PagedResult<NotificationDto>>;

public sealed class GetMyNotificationsQueryHandler(INotificationQueries queries, ICurrentUser currentUser) : IQueryHandler<GetMyNotificationsQuery, PagedResult<NotificationDto>>
{
    public async Task<Result<PagedResult<NotificationDto>>> HandleAsync(GetMyNotificationsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries
            .GetForUserAsync(currentUser.UserId, currentUser.Roles, query.UnreadOnly, query.Page, cancellationToken)
            .ConfigureAwait(false);
    }
}
