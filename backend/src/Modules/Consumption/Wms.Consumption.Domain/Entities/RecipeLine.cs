using Wms.Common.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Domain.Entities;

/// <summary>
/// <c>cons_recipe_line</c> — one component of a recipe version. Either a warehouse product
/// (<see cref="ComponentType.FoodProduct"/>) or another menu item prepared in the branch
/// (<see cref="ComponentType.SubRecipe"/>), never both.
/// </summary>
public sealed class RecipeLine : Entity<uint>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private RecipeLine()
    {
    }

    public uint TenantId { get; private set; }

    public uint RecipeId { get; private set; }

    public ushort LineNo { get; private set; }

    public ComponentType ComponentType { get; private set; }

    public uint? ProductId { get; private set; }

    public uint? SubMenuItemId { get; private set; }

    public decimal QtyPerPortion { get; private set; }

    public ushort UomId { get; private set; }

    /// <summary>Processing yield in percent: 8 % of the lettuce is trimmed away -&gt; 92.</summary>
    public decimal YieldPct { get; private set; } = 100m;

    public bool IsOptional { get; private set; }

    /// <summary>How often an optional component is actually taken, in percent. Ignored unless <see cref="IsOptional"/>.</summary>
    public decimal AttachRatePct { get; private set; } = 100m;

    public string? Note { get; private set; }

    public static Result<RecipeLine> Create(
        uint tenantId,
        ushort lineNo,
        ComponentType componentType,
        uint? productId,
        uint? subMenuItemId,
        decimal qtyPerPortion,
        ushort uomId,
        decimal yieldPct,
        bool isOptional,
        decimal attachRatePct,
        string? note)
    {
        if (lineNo == 0)
        {
            return ConsumptionErrors.InvalidRecipeLine("line_no must be positive.");
        }

        if (qtyPerPortion <= 0m)
        {
            return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: qty_per_portion must be positive.");
        }

        if (uomId == 0)
        {
            return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: uom_id is required.");
        }

        if (yieldPct is <= 0m or > 100m)
        {
            return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: yield_pct must be in (0, 100].");
        }

        if (attachRatePct is < 0m or > 100m)
        {
            return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: attach_rate_pct must be in [0, 100].");
        }

        switch (componentType)
        {
            case ComponentType.FoodProduct when productId is null or 0:
                return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: product_id is required for FOOD_PRODUCT.");
            case ComponentType.FoodProduct when subMenuItemId is not null:
                return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: sub_menu_item_id must be null for FOOD_PRODUCT.");
            case ComponentType.SubRecipe when subMenuItemId is null or 0:
                return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: sub_menu_item_id is required for SUB_RECIPE.");
            case ComponentType.SubRecipe when productId is not null:
                return ConsumptionErrors.InvalidRecipeLine($"Line {lineNo}: product_id must be null for SUB_RECIPE.");
            default:
                break;
        }

        return new RecipeLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            ComponentType = componentType,
            ProductId = componentType == ComponentType.FoodProduct ? productId : null,
            SubMenuItemId = componentType == ComponentType.SubRecipe ? subMenuItemId : null,
            QtyPerPortion = qtyPerPortion,
            UomId = uomId,
            YieldPct = yieldPct,
            IsOptional = isOptional,
            AttachRatePct = isOptional ? attachRatePct : 100m,
            Note = note is { Length: > NoteMaxLength } ? note[..NoteMaxLength] : note,
        };
    }
}
