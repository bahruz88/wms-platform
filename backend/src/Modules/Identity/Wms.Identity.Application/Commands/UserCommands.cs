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

/// <summary>
/// Segregation of duties (spec §7.1, TOR §3.1 and §40): a <c>WAREHOUSE_KEEPER</c> must never end up holding
/// <c>master.product.view_cost</c> — neither by adding it to the system role, nor by combining that role with
/// another one that grants it.
/// </summary>
public static class SegregationOfDuties
{
    public static Error? CheckRoleCombination(IReadOnlyList<Role> roles, IReadOnlyList<string> effectivePermissions)
    {
        ArgumentNullException.ThrowIfNull(roles);
        ArgumentNullException.ThrowIfNull(effectivePermissions);

        var holdsKeeper = roles.Any(r => string.Equals(r.Code, SystemRoles.WarehouseKeeper, StringComparison.OrdinalIgnoreCase));
        if (!holdsKeeper)
        {
            return null;
        }

        var seesCost = effectivePermissions.Contains(PermissionCatalog.ProductViewCost, StringComparer.OrdinalIgnoreCase);
        return seesCost
            ? IdentityErrors.SegregationOfDuties(
                $"A user holding {SystemRoles.WarehouseKeeper} must not also hold a role granting "
                + $"'{PermissionCatalog.ProductViewCost}' (spec §7.1).")
            : null;
    }
}

// ==================================================================== create

/// <summary><c>POST /api/v1/identity/users</c> (<c>createUser</c>) — links an existing Keycloak subject to the tenant.</summary>
public sealed record CreateUserCommand(
    string ExternalId,
    string Username,
    string FullName,
    string? Email,
    string? Phone,
    IReadOnlyList<uint> RoleIds,
    IReadOnlyList<uint> LocationIds) : ICommand<UserDetailDto>;

public sealed class CreateUserCommandValidator : AbstractValidator<CreateUserCommand>
{
    public CreateUserCommandValidator()
    {
        RuleFor(c => c.ExternalId).NotEmpty().MaximumLength(64);
        RuleFor(c => c.Username).NotEmpty().MaximumLength(100);
        RuleFor(c => c.FullName).NotEmpty().MaximumLength(200);
        RuleFor(c => c.Email).MaximumLength(200);
        RuleFor(c => c.Phone).MaximumLength(32);
    }
}

public sealed class CreateUserCommandHandler(
    IIdentityUnitOfWork unitOfWork,
    IUserRepository users,
    IRoleRepository roles,
    IIdentityQueries queries,
    ITenantContext tenantContext) : ICommandHandler<CreateUserCommand, UserDetailDto>
{
    public async Task<Result<UserDetailDto>> HandleAsync(CreateUserCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        if (await users.ExistsAsync(command.Username, command.ExternalId, cancellationToken).ConfigureAwait(false))
        {
            return IdentityErrors.UserAlreadyExists("username/external_id", command.Username);
        }

        var roleIds = command.RoleIds.Distinct().ToList();
        var resolved = await roles.GetManyAsync(roleIds, cancellationToken).ConfigureAwait(false);
        if (resolved.Count != roleIds.Count)
        {
            var missing = roleIds.Except(resolved.Select(r => r.Id)).First();
            return IdentityErrors.RoleNotFound(missing);
        }

        var permissions = await roles.GetPermissionCodesAsync(roleIds, cancellationToken).ConfigureAwait(false);
        if (SegregationOfDuties.CheckRoleCombination(resolved, permissions) is { } violation)
        {
            return violation;
        }

        var created = User.Create(tenantContext.TenantId, command.ExternalId, command.Username, command.FullName, command.Email, command.Phone);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var user = created.Value;
        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        users.Add(user);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        user.ReplaceRoles(roleIds);
        user.ReplaceLocations(command.LocationIds);
        unitOfWork.Audit.Record("iam_user", user.Id, AuditAction.Create, new { user.Username, user.ExternalId, roles = roleIds, locations = command.LocationIds });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetUserAsync(user.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? IdentityErrors.UserNotFound(user.Id) : dto;
    }
}

// ==================================================================== update / roles / locations

/// <summary><c>PUT /api/v1/identity/users/{id}</c> (<c>updateUser</c>).</summary>
public sealed record UpdateUserCommand(uint UserId, string FullName, string? Email, string? Phone, bool IsActive, uint RowVersion)
    : ICommand<UserDetailDto>;

public sealed class UpdateUserCommandValidator : AbstractValidator<UpdateUserCommand>
{
    public UpdateUserCommandValidator()
    {
        RuleFor(c => c.UserId).GreaterThan(0u);
        RuleFor(c => c.FullName).NotEmpty().MaximumLength(200);
    }
}

/// <summary><c>PUT /api/v1/identity/users/{id}/roles</c> (<c>setUserRoles</c>).</summary>
public sealed record SetUserRolesCommand(uint UserId, IReadOnlyList<uint> RoleIds, uint RowVersion) : ICommand<UserDetailDto>;

/// <summary><c>PUT /api/v1/identity/users/{id}/locations</c> (<c>setUserLocations</c>).</summary>
public sealed record SetUserLocationsCommand(uint UserId, IReadOnlyList<uint> LocationIds, uint RowVersion) : ICommand<UserDetailDto>;

public sealed class UserWriteHandler(
    IIdentityUnitOfWork unitOfWork,
    IUserRepository users,
    IRoleRepository roles,
    IIdentityQueries queries,
    IPrincipalCache principalCache,
    ITenantContext tenantContext) :
    ICommandHandler<UpdateUserCommand, UserDetailDto>,
    ICommandHandler<SetUserRolesCommand, UserDetailDto>,
    ICommandHandler<SetUserLocationsCommand, UserDetailDto>
{
    public Task<Result<UserDetailDto>> HandleAsync(UpdateUserCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(
            command.UserId,
            command.RowVersion,
            user => user.Update(command.FullName, command.Email, command.Phone, command.IsActive),
            user => new { user.Username, user.FullName, user.IsActive },
            cancellationToken);
    }

    public Task<Result<UserDetailDto>> HandleAsync(SetUserRolesCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        var roleIds = command.RoleIds.Distinct().ToList();
        return ApplyAsync(
            command.UserId,
            command.RowVersion,
            user =>
            {
                user.ReplaceRoles(roleIds);
                return Result.Success();
            },
            user => new { user.Username, roles = roleIds },
            cancellationToken,
            async ct =>
            {
                var resolved = await roles.GetManyAsync(roleIds, ct).ConfigureAwait(false);
                if (resolved.Count != roleIds.Count)
                {
                    return IdentityErrors.RoleNotFound(roleIds.Except(resolved.Select(r => r.Id)).First());
                }

                var permissions = await roles.GetPermissionCodesAsync(roleIds, ct).ConfigureAwait(false);
                return SegregationOfDuties.CheckRoleCombination(resolved, permissions);
            });
    }

    public Task<Result<UserDetailDto>> HandleAsync(SetUserLocationsCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        var locationIds = command.LocationIds.Distinct().ToList();
        return ApplyAsync(
            command.UserId,
            command.RowVersion,
            user =>
            {
                user.ReplaceLocations(locationIds);
                return Result.Success();
            },
            user => new { user.Username, locations = locationIds },
            cancellationToken);
    }

    private async Task<Result<UserDetailDto>> ApplyAsync(
        uint userId,
        uint rowVersion,
        Func<User, Result> mutate,
        Func<User, object> auditPayload,
        CancellationToken cancellationToken,
        Func<CancellationToken, Task<Error?>>? precondition = null)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var user = await users.GetAsync(userId, cancellationToken).ConfigureAwait(false);
        if (user is null)
        {
            return IdentityErrors.UserNotFound(userId);
        }

        if (user.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (precondition is not null && await precondition(cancellationToken).ConfigureAwait(false) is { } error)
        {
            return error;
        }

        var mutated = mutate(user);
        if (mutated.IsFailure)
        {
            return mutated.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("iam_user", user.Id, AuditAction.Update, auditPayload(user));
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        // A role or location change must take effect on the next request, not after the cache TTL.
        await principalCache.InvalidateAsync(user.TenantId, user.ExternalId, cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetUserAsync(user.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? IdentityErrors.UserNotFound(user.Id) : dto;
    }
}
