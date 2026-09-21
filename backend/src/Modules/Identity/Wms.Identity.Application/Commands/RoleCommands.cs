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

/// <summary><c>POST /api/v1/identity/roles</c> (<c>createRole</c>) — a custom role next to the six system roles.</summary>
public sealed record CreateRoleCommand(string Code, string Name, IReadOnlyList<string> Permissions) : ICommand<RoleDto>;

public sealed class CreateRoleCommandValidator : AbstractValidator<CreateRoleCommand>
{
    public CreateRoleCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Z][A-Z0-9_]{2,47}$")
            .WithMessage("code must match ^[A-Z][A-Z0-9_]{2,47}$.");
        RuleFor(c => c.Name).NotEmpty().MaximumLength(120);
    }
}

public sealed class CreateRoleCommandHandler(
    IIdentityUnitOfWork unitOfWork,
    IRoleRepository roles,
    IIdentityQueries queries,
    ITenantContext tenantContext) : ICommandHandler<CreateRoleCommand, RoleDto>
{
    public async Task<Result<RoleDto>> HandleAsync(CreateRoleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var code = command.Code.Trim().ToUpperInvariant();
        if (await roles.FindByCodeAsync(code, cancellationToken).ConfigureAwait(false) is not null)
        {
            return IdentityErrors.RoleAlreadyExists(code);
        }

        var unknown = command.Permissions.Where(p => !PermissionCatalog.Codes.Contains(p)).ToList();
        if (unknown.Count > 0)
        {
            return IdentityErrors.UnknownPermission(unknown);
        }

        if (RolePermissionRules.Check(code, command.Permissions) is { } violation)
        {
            return violation;
        }

        var role = Role.Create(tenantContext.TenantId, code, command.Name);
        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        roles.Add(role);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        await roles.ReplacePermissionsAsync(role.Id, command.Permissions, cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("iam_role", role.Id, AuditAction.Create, new { role.Code, role.Name, permissions = command.Permissions.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetRoleAsync(role.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? IdentityErrors.RoleNotFound(role.Id) : dto;
    }
}

/// <summary><c>PUT /api/v1/identity/roles/{id}/permissions</c> (<c>setRolePermissions</c>).</summary>
public sealed record SetRolePermissionsCommand(uint RoleId, IReadOnlyList<string> Permissions) : ICommand<RoleDto>;

public sealed class SetRolePermissionsCommandHandler(
    IIdentityUnitOfWork unitOfWork,
    IRoleRepository roles,
    IIdentityQueries queries,
    ITenantContext tenantContext) : ICommandHandler<SetRolePermissionsCommand, RoleDto>
{
    public async Task<Result<RoleDto>> HandleAsync(SetRolePermissionsCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var role = await roles.GetAsync(command.RoleId, cancellationToken).ConfigureAwait(false);
        if (role is null)
        {
            return IdentityErrors.RoleNotFound(command.RoleId);
        }

        var unknown = command.Permissions.Where(p => !PermissionCatalog.Codes.Contains(p)).ToList();
        if (unknown.Count > 0)
        {
            return IdentityErrors.UnknownPermission(unknown);
        }

        if (RolePermissionRules.Check(role.Code, command.Permissions) is { } violation)
        {
            return violation;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        await roles.ReplacePermissionsAsync(role.Id, command.Permissions, cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("iam_role", role.Id, AuditAction.Update, new { role.Code, permissions = command.Permissions });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetRoleAsync(role.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? IdentityErrors.RoleNotFound(role.Id) : dto;
    }
}

/// <summary>Rules a role's permission set must satisfy regardless of who edits it.</summary>
public static class RolePermissionRules
{
    public static Error? Check(string roleCode, IReadOnlyList<string> permissions)
    {
        ArgumentNullException.ThrowIfNull(permissions);
        if (!string.Equals(roleCode, SystemRoles.WarehouseKeeper, StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        // Spec §7.1, TOR §3.1 and §40 — this is the rule the UI relies on to drop the cost column entirely.
        return permissions.Contains(PermissionCatalog.ProductViewCost, StringComparer.OrdinalIgnoreCase)
            ? IdentityErrors.SegregationOfDuties(
                $"'{PermissionCatalog.ProductViewCost}' cannot be granted to {SystemRoles.WarehouseKeeper} (spec §7.1).")
            : null;
    }
}
