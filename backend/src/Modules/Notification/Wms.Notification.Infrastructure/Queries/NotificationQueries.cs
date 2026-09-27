using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Persistence;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Domain.Entities;
using Wms.Notification.Infrastructure.Persistence;

namespace Wms.Notification.Infrastructure.Queries;

public sealed class NotificationQueries(NotificationDbContext db, IPendingApprovalCounter approvals) : INotificationQueries
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

        var query = Addressed(userId, roles);
        if (unreadOnly)
        {
            query = query.Where(m => m.ReadAt == null);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(m => m.CreatedAt)
            .Skip(page.Skip)
            .Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new PagedResult<NotificationDto>(rows.Select(Map).ToList(), page.Page, page.Size, total);
    }

    public async Task<NotificationDto?> GetAsync(long id, uint userId, IReadOnlyCollection<string> roles, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roles);
        var row = await Addressed(userId, roles)
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken)
            .ConfigureAwait(false);
        return row is null ? null : Map(row);
    }

    public async Task<UnreadCountDto> GetUnreadCountAsync(uint userId, IReadOnlyCollection<string> roles, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roles);

        var bySeverity = await Addressed(userId, roles)
            .Where(m => m.ReadAt == null)
            .GroupBy(m => m.Severity)
            .Select(g => new { Severity = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        // The contract requires all three keys, so a severity with nothing unread reports zero
        // rather than being missing — a client should not have to guess at an absent key.
        var counts = new Dictionary<string, int>(StringComparer.Ordinal)
        {
            ["INFO"] = 0,
            ["WARNING"] = 0,
            ["CRITICAL"] = 0,
        };
        foreach (var row in bySeverity)
        {
            counts[UpperSnakeCaseEnum.Format(row.Severity)] = row.Count;
        }

        var pending = await approvals.CountForUserAsync(userId, cancellationToken).ConfigureAwait(false);
        return new UnreadCountDto(counts.Values.Sum(), counts, pending);
    }

    public async Task<IReadOnlyList<NotificationRuleDto>> ListRulesAsync(bool? isActive, CancellationToken cancellationToken)
    {
        var query = db.Rules.AsNoTracking();
        if (isActive is { } active)
        {
            query = query.Where(r => r.IsActive == active);
        }

        var rows = await query
            .OrderBy(r => r.EventType)
            .ThenBy(r => r.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows.Select(r => new NotificationRuleDto(
            r.Id,
            r.EventType,
            UpperSnakeCaseEnum.Format(r.Severity),
            r.ChannelList,
            r.TargetRoleCode,
            r.TargetUserIdList,
            r.TargetLocationScoped,
            UpperSnakeCaseEnum.Format(r.Digest),
            r.IsSystem,
            r.IsActive,
            r.RowVersion)).ToList();
    }

    /// <summary>Messages addressed to this user directly or through one of their roles.</summary>
    private IQueryable<NotificationMessage> Addressed(uint userId, IReadOnlyCollection<string> roles)
    {
        var roleCodes = roles.ToArray();
        return db.Messages.AsNoTracking()
            .Where(m => m.RecipientUserId == userId || (m.RecipientRole != null && roleCodes.Contains(m.RecipientRole)));
    }

    private static NotificationDto Map(NotificationMessage m) => new(
        m.Id,
        m.EventType,
        UpperSnakeCaseEnum.Format(m.Severity),
        m.Title,
        string.IsNullOrEmpty(m.Body) ? null : m.Body,
        m.Link,
        m.EntityType,
        m.EntityId,
        m.LocationId,
        m.CreatedAt,
        m.ReadAt is not null,
        m.ReadAt,
        m.EventId);
}
