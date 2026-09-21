using Wms.Common.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Domain.Entities;

/// <summary>
/// <c>cons_recipe</c> — one VERSION of a menu item's recipe, valid from <see cref="ValidFrom"/> to
/// <see cref="ValidTo"/> (inclusive). The calculation always picks the version effective on the sales
/// business date, never the current one, so past documents never change (invariant 4).
/// Lifecycle: DRAFT -&gt; ACTIVE (<see cref="Activate"/>, which closes the previous version) -&gt; ARCHIVED.
/// </summary>
public sealed class Recipe : AggregateRoot<uint>, ITenantEntity, IVersioned
{
    public const int NoteMaxLength = 1000;

    private readonly List<RecipeLine> _lines = [];

    private Recipe()
    {
    }

    public uint TenantId { get; private set; }

    public uint MenuItemId { get; private set; }

    public ushort VersionNo { get; private set; }

    /// <summary>Portions produced by one preparation. 1 for a sold menu item, more for a sub-recipe batch.</summary>
    public decimal YieldPortions { get; private set; } = 1m;

    public RecipeStatus Status { get; private set; } = RecipeStatus.Draft;

    public DateOnly ValidFrom { get; private set; }

    public DateOnly? ValidTo { get; private set; }

    public string? Note { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public uint CreatedBy { get; private set; }

    public uint RowVersion { get; private set; } = 1;

    public IReadOnlyList<RecipeLine> Lines => _lines.AsReadOnly();

    public void BumpVersion() => RowVersion++;

    public static Result<Recipe> CreateDraft(
        uint tenantId,
        uint menuItemId,
        ushort versionNo,
        DateOnly validFrom,
        decimal yieldPortions,
        string? note,
        DateTimeOffset createdAt,
        uint createdBy)
    {
        if (menuItemId == 0)
        {
            return ConsumptionErrors.InvalidRecipeLine("menu_item_id is required.");
        }

        if (versionNo == 0)
        {
            return ConsumptionErrors.InvalidRecipeLine("version_no must be positive.");
        }

        if (yieldPortions <= 0m)
        {
            return ConsumptionErrors.InvalidRecipeLine("yield_portions must be positive.");
        }

        return new Recipe
        {
            TenantId = tenantId,
            MenuItemId = menuItemId,
            VersionNo = versionNo,
            ValidFrom = validFrom,
            YieldPortions = yieldPortions,
            Status = RecipeStatus.Draft,
            Note = note is { Length: > NoteMaxLength } ? note[..NoteMaxLength] : note,
            CreatedAt = createdAt,
            CreatedBy = createdBy,
        };
    }

    /// <summary>Replaces all component lines. Only a DRAFT version may be edited; a change to an ACTIVE version needs a new version.</summary>
    public Result ReplaceLines(IEnumerable<RecipeLine> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != RecipeStatus.Draft)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(Recipe), Id, Status, RecipeStatus.Draft);
        }

        var replacement = lines.ToList();
        var duplicateLineNo = replacement.GroupBy(l => l.LineNo).FirstOrDefault(g => g.Count() > 1);
        if (duplicateLineNo is not null)
        {
            return ConsumptionErrors.InvalidRecipeLine($"line_no {duplicateLineNo.Key} appears more than once.");
        }

        if (replacement.Any(l => l.ComponentType == ComponentType.SubRecipe && l.SubMenuItemId == MenuItemId))
        {
            return ConsumptionErrors.RecipeCycle([MenuItemId, MenuItemId]);
        }

        _lines.Clear();
        _lines.AddRange(replacement);
        return Result.Success();
    }

    public Result UpdateHeader(decimal yieldPortions, string? note)
    {
        if (Status != RecipeStatus.Draft)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(Recipe), Id, Status, RecipeStatus.Draft);
        }

        if (yieldPortions <= 0m)
        {
            return ConsumptionErrors.InvalidRecipeLine("yield_portions must be positive.");
        }

        YieldPortions = yieldPortions;
        Note = note is { Length: > NoteMaxLength } ? note[..NoteMaxLength] : note;
        return Result.Success();
    }

    /// <summary>
    /// DRAFT -&gt; ACTIVE from <paramref name="validFrom"/>. The caller passes the currently active version so it can be
    /// closed with <c>valid_to = validFrom − 1 day</c> in the same transaction (branch-operations.md §3).
    /// </summary>
    public Result Activate(DateOnly validFrom, Recipe? previousActive)
    {
        if (Status != RecipeStatus.Draft)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(Recipe), Id, Status, RecipeStatus.Active);
        }

        if (_lines.Count == 0)
        {
            return ConsumptionErrors.RecipeEmpty(Id);
        }

        if (previousActive is not null)
        {
            if (previousActive.MenuItemId != MenuItemId || ReferenceEquals(previousActive, this))
            {
                return ConsumptionErrors.InvalidRecipeLine("The previous active version must be another version of the same menu item.");
            }

            if (previousActive.ValidFrom >= validFrom)
            {
                return ConsumptionErrors.InvalidRecipeLine(
                    $"valid_from {validFrom:yyyy-MM-dd} must be after the currently active version's valid_from {previousActive.ValidFrom:yyyy-MM-dd}.");
            }

            previousActive.Close(validFrom.AddDays(-1));
        }

        ValidFrom = validFrom;
        ValidTo = null;
        Status = RecipeStatus.Active;
        return Result.Success();
    }

    /// <summary>True when this version is the one in force on <paramref name="date"/> (invariant 4).</summary>
    public bool IsEffectiveOn(DateOnly date) =>
        Status != RecipeStatus.Draft && ValidFrom <= date && (ValidTo is null || ValidTo >= date);

    private void Close(DateOnly validTo)
    {
        ValidTo = validTo;
        Status = RecipeStatus.Archived;
    }
}
