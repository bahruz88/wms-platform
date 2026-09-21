using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;

namespace Wms.Consumption.Application.Commands.Recipes;

/// <summary><c>PUT /api/v1/consumption/recipes/{id}</c> (operationId <c>updateRecipe</c>). DRAFT only; lines are replaced wholesale.</summary>
public sealed record UpdateRecipeCommand(
    uint RecipeId,
    uint RowVersion,
    decimal YieldPortions,
    string? Note,
    IReadOnlyList<RecipeComponentInput> Lines) : ICommand<RecipeDto>;

public sealed class UpdateRecipeCommandValidator : AbstractValidator<UpdateRecipeCommand>
{
    public UpdateRecipeCommandValidator()
    {
        RuleFor(c => c.RecipeId).GreaterThan(0u);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Lines).NotNull();
    }
}

public sealed class UpdateRecipeCommandHandler(
    IRecipeRepository recipes,
    IMenuItemRepository menuItems,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ITenantContext tenantContext) : ICommandHandler<UpdateRecipeCommand, RecipeDto>
{
    public async Task<Result<RecipeDto>> HandleAsync(UpdateRecipeCommand command, CancellationToken cancellationToken)
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

        var header = recipe.UpdateHeader(command.YieldPortions, command.Note);
        if (header.IsFailure)
        {
            return header.Error;
        }

        var built = await RecipeLineFactory
            .BuildAsync(tenantContext.TenantId, recipe.MenuItemId, command.Lines, menuItems, cancellationToken)
            .ConfigureAwait(false);
        if (built.IsFailure)
        {
            return built.Error;
        }

        var replaced = recipe.ReplaceLines(built.Value);
        if (replaced.IsFailure)
        {
            return replaced.Error;
        }

        unitOfWork.Audit.Record("cons_recipe", recipe.Id, AuditAction.Update, new { recipe.MenuItemId, recipe.VersionNo, lineCount = built.Value.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetRecipeAsync(recipe.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RecipeNotFound(recipe.Id) : Result.Success(dto);
    }
}
