using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Application.Dtos;
using Wms.Identity.Domain;
using Wms.Identity.Domain.Entities;

namespace Wms.Identity.Application.Commands;

/// <summary><c>POST /api/v1/identity/delegations</c> (<c>createDelegation</c>).</summary>
public sealed record CreateDelegationCommand(uint? FromUserId, uint ToUserId, DateOnly ValidFrom, DateOnly ValidTo, string? Reason)
    : ICommand<DelegationDto>;

public sealed class CreateDelegationCommandValidator : AbstractValidator<CreateDelegationCommand>
{
    public CreateDelegationCommandValidator()
    {
        RuleFor(c => c.ToUserId).GreaterThan(0u);
        RuleFor(c => c.ValidFrom).NotEqual(default(DateOnly));
        RuleFor(c => c.ValidTo).NotEqual(default(DateOnly));
        RuleFor(c => c.Reason).MaximumLength(300);
    }
}

public sealed class CreateDelegationCommandHandler(
    IIdentityUnitOfWork unitOfWork,
    IDelegationRepository delegations,
    IUserRepository users,
    IIdentityQueries queries,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<CreateDelegationCommand, DelegationDto>
{
    public async Task<Result<DelegationDto>> HandleAsync(CreateDelegationCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var fromUserId = command.FromUserId ?? currentUser.UserId;
        if (fromUserId == 0)
        {
            return IdentityErrors.InvalidDelegation("The delegating user could not be resolved.");
        }

        // Contract: delegating on behalf of somebody else needs iam.delegation.manage.
        if (fromUserId != currentUser.UserId && !currentUser.HasPermission(IdentityPermissions.DelegationManage))
        {
            return CommonErrors.Forbidden(IdentityPermissions.DelegationManage);
        }

        if (await users.GetAsync(fromUserId, cancellationToken).ConfigureAwait(false) is null)
        {
            return IdentityErrors.UserNotFound(fromUserId);
        }

        if (await users.GetAsync(command.ToUserId, cancellationToken).ConfigureAwait(false) is null)
        {
            return IdentityErrors.UserNotFound(command.ToUserId);
        }

        var existing = await delegations.GetForUserAsync(fromUserId, cancellationToken).ConfigureAwait(false);
        if (existing.Any(d => d.Overlaps(command.ValidFrom, command.ValidTo)))
        {
            return IdentityErrors.DelegationOverlap();
        }

        var now = clock.UtcNow;
        var created = Delegation.Create(
            tenantContext.TenantId, fromUserId, command.ToUserId, command.ValidFrom, command.ValidTo, command.Reason, now, currentUser.UserId);
        if (created.IsFailure)
        {
            return created.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        delegations.Add(created.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            "iam_delegation",
            created.Value.Id,
            AuditAction.Create,
            new { fromUserId, command.ToUserId, command.ValidFrom, command.ValidTo });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        var today = DateOnly.FromDateTime(now.UtcDateTime);
        var dto = await queries.GetDelegationAsync(created.Value.Id, today, cancellationToken).ConfigureAwait(false);
        return dto is null ? IdentityErrors.DelegationNotFound(created.Value.Id) : dto;
    }
}

/// <summary><c>DELETE /api/v1/identity/delegations/{id}</c> (<c>revokeDelegation</c>) — closes it, never deletes the row.</summary>
public sealed record RevokeDelegationCommand(uint DelegationId) : ICommand<uint>;

public sealed class RevokeDelegationCommandHandler(
    IIdentityUnitOfWork unitOfWork,
    IDelegationRepository delegations,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<RevokeDelegationCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(RevokeDelegationCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var delegation = await delegations.GetAsync(command.DelegationId, cancellationToken).ConfigureAwait(false);
        if (delegation is null)
        {
            return IdentityErrors.DelegationNotFound(command.DelegationId);
        }

        if (delegation.FromUserId != currentUser.UserId && !currentUser.HasPermission(IdentityPermissions.DelegationManage))
        {
            return CommonErrors.Forbidden(IdentityPermissions.DelegationManage);
        }

        delegation.Revoke(DateOnly.FromDateTime(clock.UtcNow.UtcDateTime));

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("iam_delegation", delegation.Id, AuditAction.Update, new { action = "REVOKE", delegation.ValidTo });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return delegation.Id;
    }
}
