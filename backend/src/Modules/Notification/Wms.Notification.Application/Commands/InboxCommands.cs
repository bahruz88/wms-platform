using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Application.Commands;

/// <summary><c>POST /inbox/{id}/read</c>. Idempotent: a message already read stays as it was.</summary>
public sealed record MarkNotificationReadCommand(long Id) : ICommand<long>;

public sealed class MarkNotificationReadCommandHandler(
    INotificationRepository repository,
    INotificationUnitOfWork unitOfWork,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<MarkNotificationReadCommand, long>
{
    public async Task<Result<long>> HandleAsync(MarkNotificationReadCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        var message = await repository
            .GetMessageAsync(command.Id, currentUser.UserId, currentUser.Roles, cancellationToken)
            .ConfigureAwait(false);
        if (message is null)
        {
            return NotificationErrors.MessageNotFound(command.Id);
        }

        // MarkRead keeps the first timestamp, so re-reading never rewrites history.
        message.MarkRead(clock.UtcNow);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return message.Id;
    }
}

/// <summary><c>POST /inbox/read-all</c> — returns how many messages changed.</summary>
public sealed record MarkAllNotificationsReadCommand : ICommand<int>;

public sealed class MarkAllNotificationsReadCommandHandler(
    INotificationRepository repository,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<MarkAllNotificationsReadCommand, int>
{
    public async Task<Result<int>> HandleAsync(MarkAllNotificationsReadCommand command, CancellationToken cancellationToken) =>
        await repository
            .MarkAllReadAsync(currentUser.UserId, currentUser.Roles, clock.UtcNow, cancellationToken)
            .ConfigureAwait(false);
}
