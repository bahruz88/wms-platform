using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Application.Commands;

/// <summary>
/// <c>POST /devices</c> — registers this handset for push.
///
/// Re-registering the same handset refreshes its token rather than adding a row: FCM and APNs
/// rotate tokens, and pushing to a stale one fails silently, so the newest token has to win.
/// </summary>
public sealed record RegisterDeviceCommand(
    string DeviceId,
    DevicePlatform Platform,
    string PushToken,
    string? AppVersion) : ICommand<long>;

public sealed class RegisterDeviceCommandValidator : AbstractValidator<RegisterDeviceCommand>
{
    public RegisterDeviceCommandValidator()
    {
        RuleFor(c => c.DeviceId).NotEmpty().MaximumLength(NotificationDevice.DeviceIdMaxLength);
        RuleFor(c => c.PushToken).NotEmpty().MaximumLength(NotificationDevice.PushTokenMaxLength);
        RuleFor(c => c.AppVersion).MaximumLength(NotificationDevice.AppVersionMaxLength);
    }
}

public sealed class RegisterDeviceCommandHandler(
    INotificationRepository repository,
    INotificationUnitOfWork unitOfWork,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<RegisterDeviceCommand, long>
{
    public async Task<Result<long>> HandleAsync(RegisterDeviceCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var existing = await repository
            .GetDeviceAsync(currentUser.UserId, command.DeviceId, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null)
        {
            var refreshed = existing.Refresh(command.Platform, command.PushToken, command.AppVersion, clock.UtcNow);
            if (refreshed.IsFailure)
            {
                return refreshed.Error;
            }

            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            return existing.Id;
        }

        var device = NotificationDevice.Register(
            tenantContext.TenantId,
            currentUser.UserId,
            command.DeviceId,
            command.Platform,
            command.PushToken,
            command.AppVersion,
            clock.UtcNow);
        if (device.IsFailure)
        {
            return device.Error;
        }

        repository.AddDevice(device.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return device.Value.Id;
    }
}

/// <summary><c>DELETE /devices/{deviceId}</c> — on sign-out, so the handset stops receiving push.</summary>
public sealed record UnregisterDeviceCommand(string DeviceId) : ICommand<string>;

public sealed class UnregisterDeviceCommandHandler(
    INotificationRepository repository,
    INotificationUnitOfWork unitOfWork,
    ICurrentUser currentUser) : ICommandHandler<UnregisterDeviceCommand, string>
{
    public async Task<Result<string>> HandleAsync(UnregisterDeviceCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        var device = await repository
            .GetDeviceAsync(currentUser.UserId, command.DeviceId, cancellationToken)
            .ConfigureAwait(false);
        if (device is null)
        {
            return NotificationErrors.DeviceNotFound(command.DeviceId);
        }

        repository.RemoveDevice(device);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return command.DeviceId;
    }
}
