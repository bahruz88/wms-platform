using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;

namespace Wms.Consumption.Application.Commands.Recipes;

/// <summary>
/// <c>POST /api/v1/consumption/recipes/{id}/activate</c> (operationId <c>activateRecipe</c>).
/// DRAFT -&gt; ACTIVE; the previous active version is closed with <c>valid_to = validFrom − 1</c> and ARCHIVED.
/// <c>validFrom</c> may be in the past but never before a day whose consumption is already posted
/// (<c>409 PERIOD_CLOSED</c>, invariant 4).
/// </summary>
public sealed record ActivateRecipeCommand(uint RecipeId, DateOnly ValidFrom, uint RowVersion) : ICommand<RecipeDto>;

public sealed class ActivateRecipeCommandValidator : AbstractValidator<ActivateRecipeCommand>
{
    public ActivateRecipeCommandValidator()
    {
        RuleFor(c => c.RecipeId).GreaterThan(0u);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
    }
}

public sealed class ActivateRecipeCommandHandler(
    IRecipeRepository recipes,
    IConsumptionRunRepository runs,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ITenantContext tenantContext) : ICommandHandler<ActivateRecipeCommand, RecipeDto>
{
    public async Task<Result<RecipeDto>> HandleAsync(ActivateRecipeCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var recipe = await recipes.GetAsync(command.RecipeId, cancellationToken).ConfigureAwait(false);
        if (recipe is null)
        {
            return ConsumptionErrors.RecipeNotFound(command.RecipeId);
        }

        if (recipe.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        // Invariant 4: a posted day must keep the recipe it was calculated with. Scoped to the menu item (and
        // anything that uses it as a sub-recipe) so an unrelated new item is not blocked by someone else's history.
        var lastPosted = await runs
            .LastPostedBusinessDateForMenuItemAsync(tenantContext.TenantId, recipe.MenuItemId, cancellationToken)
            .ConfigureAwait(false);
        if (lastPosted is { } posted && command.ValidFrom <= posted)
        {
            return ConsumptionErrors.PeriodClosed(command.ValidFrom);
        }

        var previous = await recipes.GetActiveAsync(recipe.MenuItemId, cancellationToken).ConfigureAwait(false);
        var activated = recipe.Activate(command.ValidFrom, previous?.Id == recipe.Id ? null : previous);
        if (activated.IsFailure)
        {
            return activated.Error;
        }

        unitOfWork.Audit.Record("cons_recipe", recipe.Id, AuditAction.Approve, new
        {
            recipe.MenuItemId,
            recipe.VersionNo,
            validFrom = command.ValidFrom,
            closedVersionId = previous?.Id,
        });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetRecipeAsync(recipe.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RecipeNotFound(recipe.Id) : Result.Success(dto);
    }
}
