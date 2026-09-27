using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Application.Queries;

/// <summary><c>GET /inbox/{id}</c> — one notification, only if it is addressed to the caller.</summary>
public sealed record GetNotificationQuery(long Id) : IQuery<NotificationDto>;

public sealed class GetNotificationQueryHandler(INotificationQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetNotificationQuery, NotificationDto>
{
    public async Task<Result<NotificationDto>> HandleAsync(GetNotificationQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries
            .GetAsync(query.Id, currentUser.UserId, currentUser.Roles, cancellationToken)
            .ConfigureAwait(false);

        // A notification addressed to someone else is not "forbidden", it is simply not in this
        // caller's inbox — saying 404 avoids confirming that the id exists at all.
        return dto is null ? NotificationErrors.MessageNotFound(query.Id) : dto;
    }
}

/// <summary><c>GET /inbox/unread-count</c> — the bell badge.</summary>
public sealed record GetUnreadCountQuery : IQuery<UnreadCountDto>;

public sealed class GetUnreadCountQueryHandler(INotificationQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetUnreadCountQuery, UnreadCountDto>
{
    public async Task<Result<UnreadCountDto>> HandleAsync(GetUnreadCountQuery query, CancellationToken cancellationToken) =>
        await queries.GetUnreadCountAsync(currentUser.UserId, currentUser.Roles, cancellationToken).ConfigureAwait(false);
}

/// <summary><c>GET /rules</c> — the tenant's delivery matrix.</summary>
public sealed record ListNotificationRulesQuery(bool? IsActive) : IQuery<IReadOnlyList<NotificationRuleDto>>;

public sealed class ListNotificationRulesQueryHandler(INotificationQueries queries)
    : IQueryHandler<ListNotificationRulesQuery, IReadOnlyList<NotificationRuleDto>>
{
    public async Task<Result<IReadOnlyList<NotificationRuleDto>>> HandleAsync(ListNotificationRulesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result<IReadOnlyList<NotificationRuleDto>>.Success(
            await queries.ListRulesAsync(query.IsActive, cancellationToken).ConfigureAwait(false));
    }
}
