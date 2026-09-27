using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Application.Commands;

/// <summary><c>POST /rules</c> — a new delivery rule for one event type.</summary>
public sealed record CreateNotificationRuleCommand(
    string EventType,
    NotificationSeverity Severity,
    IReadOnlyList<string> Channels,
    string? TargetRoleCode,
    IReadOnlyList<uint> TargetUserIds,
    bool TargetLocationScoped,
    NotificationDigest Digest) : ICommand<uint>;

public sealed class CreateNotificationRuleCommandValidator : AbstractValidator<CreateNotificationRuleCommand>
{
    public CreateNotificationRuleCommandValidator()
    {
        RuleFor(c => c.EventType).NotEmpty().MaximumLength(120);
        RuleFor(c => c.Channels).NotEmpty();
        RuleFor(c => c.TargetRoleCode).MaximumLength(NotificationRule.RoleCodeMaxLength);
    }
}

public sealed class CreateNotificationRuleCommandHandler(
    INotificationRepository repository,
    INotificationUnitOfWork unitOfWork,
    ITenantContext tenantContext) : ICommandHandler<CreateNotificationRuleCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(CreateNotificationRuleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var rule = NotificationRule.Create(
            tenantContext.TenantId,
            command.EventType,
            command.Severity,
            command.Channels,
            command.TargetRoleCode,
            command.TargetUserIds,
            command.TargetLocationScoped,
            command.Digest);
        if (rule.IsFailure)
        {
            return rule.Error;
        }

        repository.AddRule(rule.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return rule.Value.Id;
    }
}

/// <summary><c>PUT /rules/{id}</c>.</summary>
public sealed record UpdateNotificationRuleCommand(
    uint Id,
    uint RowVersion,
    string EventType,
    NotificationSeverity Severity,
    IReadOnlyList<string> Channels,
    string? TargetRoleCode,
    IReadOnlyList<uint> TargetUserIds,
    bool TargetLocationScoped,
    NotificationDigest Digest,
    bool IsActive) : ICommand<uint>;

public sealed class UpdateNotificationRuleCommandValidator : AbstractValidator<UpdateNotificationRuleCommand>
{
    public UpdateNotificationRuleCommandValidator()
    {
        RuleFor(c => c.Id).GreaterThan(0u);
        RuleFor(c => c.EventType).NotEmpty().MaximumLength(120);
        RuleFor(c => c.Channels).NotEmpty();
        RuleFor(c => c.TargetRoleCode).MaximumLength(NotificationRule.RoleCodeMaxLength);
    }
}

public sealed class UpdateNotificationRuleCommandHandler(
    INotificationRepository repository,
    INotificationUnitOfWork unitOfWork) : ICommandHandler<UpdateNotificationRuleCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(UpdateNotificationRuleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        var rule = await repository.GetRuleAsync(command.Id, cancellationToken).ConfigureAwait(false);
        if (rule is null)
        {
            return NotificationErrors.RuleNotFound(command.Id);
        }

        if (rule.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var updated = rule.Update(
            command.EventType,
            command.Severity,
            command.Channels,
            command.TargetRoleCode,
            command.TargetUserIds,
            command.TargetLocationScoped,
            command.Digest,
            command.IsActive);
        if (updated.IsFailure)
        {
            return updated.Error;
        }

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return rule.Id;
    }
}

/// <summary><c>DELETE /rules/{id}</c> — a tenant rule is deactivated, a system rule refuses.</summary>
public sealed record DeleteNotificationRuleCommand(uint Id) : ICommand<uint>;

public sealed class DeleteNotificationRuleCommandHandler(
    INotificationRepository repository,
    INotificationUnitOfWork unitOfWork) : ICommandHandler<DeleteNotificationRuleCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(DeleteNotificationRuleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        var rule = await repository.GetRuleAsync(command.Id, cancellationToken).ConfigureAwait(false);
        if (rule is null)
        {
            return NotificationErrors.RuleNotFound(command.Id);
        }

        var deleted = rule.Delete();
        if (deleted.IsFailure)
        {
            return deleted.Error;
        }

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return rule.Id;
    }
}
