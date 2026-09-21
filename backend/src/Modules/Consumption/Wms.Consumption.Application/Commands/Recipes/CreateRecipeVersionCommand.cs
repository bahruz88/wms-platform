using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Application.Commands.Recipes;

/// <summary><c>POST /api/v1/consumption/menu-items/{id}/recipes</c> (operationId <c>createRecipeVersion</c>). Always DRAFT.</summary>
public sealed record CreateRecipeVersionCommand(
    uint MenuItemId,
    DateOnly ValidFrom,
    decimal YieldPortions,
    uint? CopyFromRecipeId,
    string? Note,
    IReadOnlyList<RecipeComponentInput> Lines) : ICommand<RecipeDto>;

public sealed class CreateRecipeVersionCommandValidator : AbstractValidator<CreateRecipeVersionCommand>
{
    public CreateRecipeVersionCommandValidator()
    {
        RuleFor(c => c.MenuItemId).GreaterThan(0u);
        RuleFor(c => c.YieldPortions).GreaterThan(0m);
    }
}

public sealed class CreateRecipeVersionCommandHandler(
    IMenuItemRepository menuItems,
    IRecipeRepository recipes,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ITenantContext tenantContext,
    IClock clock,
    ICurrentUser currentUser) : ICommandHandler<CreateRecipeVersionCommand, RecipeDto>
{
    public async Task<Result<RecipeDto>> HandleAsync(CreateRecipeVersionCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var menuItem = await menuItems.GetAsync(command.MenuItemId, cancellationToken).ConfigureAwait(false);
        if (menuItem is null)
        {
            return ConsumptionErrors.MenuItemNotFound(command.MenuItemId);
        }

        var versionNo = await recipes.NextVersionNoAsync(command.MenuItemId, cancellationToken).ConfigureAwait(false);
        var draft = Recipe.CreateDraft(
            tenantId, command.MenuItemId, versionNo, command.ValidFrom, command.YieldPortions, command.Note, clock.UtcNow, currentUser.UserId);
        if (draft.IsFailure)
        {
            return draft.Error;
        }

        var inputs = command.Lines?.ToList() ?? [];
        if (inputs.Count == 0 && command.CopyFromRecipeId is { } copyFrom)
        {
            var source = await recipes.GetAsync(copyFrom, cancellationToken).ConfigureAwait(false);
            if (source is null)
            {
                return ConsumptionErrors.RecipeNotFound(copyFrom);
            }

            inputs = source.Lines
                .OrderBy(l => l.LineNo)
                .Select(l => new RecipeComponentInput(
                    l.LineNo, l.ComponentType, l.ProductId, l.SubMenuItemId, l.QtyPerPortion, l.UomId, l.YieldPct, l.IsOptional, l.AttachRatePct, l.Note))
                .ToList();
        }

        var built = await RecipeLineFactory.BuildAsync(tenantId, command.MenuItemId, inputs, menuItems, cancellationToken).ConfigureAwait(false);
        if (built.IsFailure)
        {
            return built.Error;
        }

        var replaced = draft.Value.ReplaceLines(built.Value);
        if (replaced.IsFailure)
        {
            return replaced.Error;
        }

        recipes.Add(draft.Value);
        unitOfWork.Audit.Record("cons_recipe", 0, AuditAction.Create, new { command.MenuItemId, versionNo, command.ValidFrom });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetRecipeAsync(draft.Value.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RecipeNotFound(draft.Value.Id) : Result.Success(dto);
    }
}

/// <summary>Validates and materialises recipe component lines, rejecting sub-recipe references that cannot work.</summary>
public static class RecipeLineFactory
{
    public static async Task<Result<List<RecipeLine>>> BuildAsync(
        uint tenantId,
        uint ownerMenuItemId,
        IReadOnlyList<RecipeComponentInput> inputs,
        IMenuItemRepository menuItems,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        ArgumentNullException.ThrowIfNull(menuItems);

        var lines = new List<RecipeLine>(inputs.Count);
        foreach (var input in inputs)
        {
            if (input.ComponentType == ComponentType.SubRecipe)
            {
                if (input.SubMenuItemId == ownerMenuItemId)
                {
                    return ConsumptionErrors.RecipeCycle([ownerMenuItemId, ownerMenuItemId]);
                }

                var sub = input.SubMenuItemId is { } subId
                    ? await menuItems.GetAsync(subId, cancellationToken).ConfigureAwait(false)
                    : null;
                if (sub is null)
                {
                    return ConsumptionErrors.MenuItemNotFound(input.SubMenuItemId ?? 0);
                }

                if (!sub.IsSubRecipe)
                {
                    return ConsumptionErrors.InvalidRecipeLine(
                        $"Line {input.LineNo}: menu item {sub.Id} is not flagged as a sub-recipe (is_sub_recipe = false).");
                }
            }

            var line = RecipeLine.Create(
                tenantId,
                input.LineNo,
                input.ComponentType,
                input.ProductId,
                input.SubMenuItemId,
                input.QtyPerPortion,
                input.UomId,
                input.YieldPct,
                input.IsOptional,
                input.AttachRatePct,
                input.Note);
            if (line.IsFailure)
            {
                return line.Error;
            }

            lines.Add(line.Value);
        }

        return lines;
    }
}
