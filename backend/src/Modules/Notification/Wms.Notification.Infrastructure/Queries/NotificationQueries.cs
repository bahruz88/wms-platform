using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Persistence;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Infrastructure.Persistence;

namespace Wms.Notification.Infrastructure.Queries;

public sealed class NotificationQueries(NotificationDbContext db) : INotificationQueries
{
    public async Task<PagedResult<NotificationDto>> GetForUserAsync(
        uint userId,
        IReadOnlyCollection<string> roles,
        bool unreadOnly,
        PageRequest page,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roles);
        ArgumentNullException.ThrowIfNull(page);

        var roleCodes = roles.ToArray();
        var query = db.Messages.AsNoTracking()
            .Where(m => m.RecipientUserId == userId || (m.RecipientRole != null && roleCodes.Contains(m.RecipientRole)));
        if (unreadOnly)
        {
            query = query.Where(m => m.ReadAt == null);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(m => m.CreatedAt)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(m => new { m.Id, m.EventType, m.Severity, m.Title, m.Body, m.CreatedAt, m.ReadAt })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows
            .Select(m => new NotificationDto(m.Id, m.EventType, UpperSnakeCaseEnum.Format(m.Severity), m.Title, m.Body, m.CreatedAt, m.ReadAt))
            .ToList();

        return new PagedResult<NotificationDto>(items, page.Page, page.Size, total);
    }
}
