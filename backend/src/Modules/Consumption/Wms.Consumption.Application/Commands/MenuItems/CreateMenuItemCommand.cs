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

/// <summary><c>POST /api/v1/consumption/menu-items</c> (operationId <c>createMenuItem</c>).</summary>
public sealed record CreateMenuItemCommand(string Code, string? PosCode, string Name, string? Category, bool IsSubRecipe)
    : ICommand<MenuItemDto>;

public sealed class CreateMenuItemCommandValidator : AbstractValidator<CreateMenuItemCommand>
{
    public CreateMenuItemCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().MaximumLength(MenuItem.CodeMaxLength);
        RuleFor(c => c.Name).NotEmpty().MaximumLength(MenuItem.NameMaxLength);
        RuleFor(c => c.PosCode).MaximumLength(MenuItem.PosCodeMaxLength);
        RuleFor(c => c.Category).MaximumLength(MenuItem.CategoryMaxLength);
    }
}

public sealed class CreateMenuItemCommandHandler(
    IMenuItemRepository menuItems,
    IConsumptionUnitOfWork unitOfWork,
    ITenantContext tenantContext) : ICommandHandler<CreateMenuItemCommand, MenuItemDto>
{
    public async Task<Result<MenuItemDto>> HandleAsync(CreateMenuItemCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var code = command.Code.Trim().ToUpperInvariant();
        if (await menuItems.CodeExistsAsync(tenantId, code, exceptId: null, cancellationToken).ConfigureAwait(false))
        {
            return ConsumptionErrors.DuplicateCode(code);
        }

        var posCode = string.IsNullOrWhiteSpace(command.PosCode) ? null : command.PosCode.Trim();
        if (posCode is not null && await menuItems.PosCodeExistsAsync(tenantId, posCode, exceptId: null, cancellationToken).ConfigureAwait(false))
        {
            return ConsumptionErrors.DuplicatePosCode(posCode);
        }

        var created = MenuItem.Create(tenantId, code, posCode, command.Name, command.Category, command.IsSubRecipe);
        if (created.IsFailure)
        {
            return created.Error;
        }

        menuItems.Add(created.Value);
        unitOfWork.Audit.Record("cons_menu_item", 0, AuditAction.Create, new { code, command.Name, command.IsSubRecipe });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return MenuItemMapper.ToDto(created.Value, activeRecipeId: null);
    }
}

public static class MenuItemMapper
{
    public static MenuItemDto ToDto(MenuItem item, uint? activeRecipeId)
    {
        ArgumentNullException.ThrowIfNull(item);
        return new MenuItemDto(
            item.Id,
            item.Code,
            item.PosCode,
            item.Name,
            item.Category,
            item.IsSubRecipe,
            item.IsActive,
            activeRecipeId,
            item.RowVersion,
            new AuditDto(item.CreatedAt, item.CreatedBy, item.UpdatedAt, item.UpdatedBy, item.RowVersion));
    }
}
