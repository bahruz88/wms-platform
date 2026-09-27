using Wms.Notification.Application.Abstractions;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Infrastructure.Persistence.Repositories;

public sealed class NotificationRepository(NotificationDbContext db) : INotificationRepository
{
    public Task<NotificationMessage?> GetMessageAsync(long id, uint userId, IReadOnlyCollection<string> roles, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roles);
        var roleCodes = roles.ToArray();
        return db.Messages
            .FirstOrDefaultAsync(
                m => m.Id == id && (m.RecipientUserId == userId || (m.RecipientRole != null && roleCodes.Contains(m.RecipientRole))),
                cancellationToken);
    }

    public async Task<int> MarkAllReadAsync(uint userId, IReadOnlyCollection<string> roles, DateTimeOffset at, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roles);
        var roleCodes = roles.ToArray();

        // A set-based update: an inbox left unread for a month can hold thousands of rows, and
        // loading them only to stamp one column would be pure waste.
        return await db.Messages
            .Where(m => m.ReadAt == null
                && (m.RecipientUserId == userId || (m.RecipientRole != null && roleCodes.Contains(m.RecipientRole))))
            .ExecuteUpdateAsync(s => s.SetProperty(m => m.ReadAt, at), cancellationToken)
            .ConfigureAwait(false);
    }

    public Task<NotificationRule?> GetRuleAsync(uint id, CancellationToken cancellationToken) =>
        db.Rules.FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

    public void AddRule(NotificationRule rule) => db.Rules.Add(rule);

    public Task<NotificationDevice?> GetDeviceAsync(uint userId, string deviceId, CancellationToken cancellationToken) =>
        db.Devices.FirstOrDefaultAsync(d => d.UserId == userId && d.DeviceId == deviceId, cancellationToken);

    public void AddDevice(NotificationDevice device) => db.Devices.Add(device);

    public void RemoveDevice(NotificationDevice device) => db.Devices.Remove(device);
}

public sealed class NotificationUnitOfWork(NotificationDbContext db) : INotificationUnitOfWork
{
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);
}

/// <summary>
/// Stands in for the procurement module when it is not deployed in this process.
///
/// The badge is a convenience, not a fact the inbox depends on, so a missing procurement module
/// reports zero pending approvals rather than failing the whole unread-count call.
/// </summary>
public sealed class NoPendingApprovalCounter : IPendingApprovalCounter
{
    public Task<int> CountForUserAsync(uint userId, CancellationToken cancellationToken) => Task.FromResult(0);
}
