using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Entities;

namespace Wms.Consumption.Application.Commands.MenuItems;

/// <summary><c>PUT /api/v1/consumption/menu-items/{id}</c> (operationId <c>updateMenuItem</c>).</summary>
public sealed record UpdateMenuItemCommand(
    uint MenuItemId,
    string Code,
    string? PosCode,
    string Name,
    string? Category,
    bool IsSubRecipe,
    bool IsActive,
    uint RowVersion) : ICommand<MenuItemDto>;

public sealed class UpdateMenuItemCommandValidator : AbstractValidator<UpdateMenuItemCommand>
{
    public UpdateMenuItemCommandValidator()
    {
        RuleFor(c => c.MenuItemId).GreaterThan(0u);
        RuleFor(c => c.Code).NotEmpty().MaximumLength(MenuItem.CodeMaxLength);
        RuleFor(c => c.Name).NotEmpty().MaximumLength(MenuItem.NameMaxLength);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
    }
}

public sealed class UpdateMenuItemCommandHandler(
    IMenuItemRepository menuItems,
    IRecipeRepository recipes,
    IConsumptionUnitOfWork unitOfWork,
    ITenantContext tenantContext) : ICommandHandler<UpdateMenuItemCommand, MenuItemDto>
{
    public async Task<Result<MenuItemDto>> HandleAsync(UpdateMenuItemCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var item = await menuItems.GetAsync(command.MenuItemId, cancellationToken).ConfigureAwait(false);
        if (item is null)
        {
            return ConsumptionErrors.MenuItemNotFound(command.MenuItemId);
        }

        if (item.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var tenantId = tenantContext.TenantId;
        var code = command.Code.Trim().ToUpperInvariant();
        if (await menuItems.CodeExistsAsync(tenantId, code, item.Id, cancellationToken).ConfigureAwait(false))
        {
            return ConsumptionErrors.DuplicateCode(code);
        }

        var posCode = string.IsNullOrWhiteSpace(command.PosCode) ? null : command.PosCode.Trim();
        if (posCode is not null && await menuItems.PosCodeExistsAsync(tenantId, posCode, item.Id, cancellationToken).ConfigureAwait(false))
        {
            return ConsumptionErrors.DuplicatePosCode(posCode);
        }

        var updated = item.Update(code, posCode, command.Name, command.Category, command.IsSubRecipe, command.IsActive);
        if (updated.IsFailure)
        {
            return updated.Error;
        }

        unitOfWork.Audit.Record("cons_menu_item", item.Id, AuditAction.Update, new { code, command.Name, command.IsActive });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var active = await recipes.GetActiveAsync(item.Id, cancellationToken).ConfigureAwait(false);
        return MenuItemMapper.ToDto(item, active?.Id);
    }
}
