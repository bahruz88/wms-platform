using Wms.Common.Domain;

namespace Wms.Consumption.Domain.Entities;

/// <summary>
/// <c>cons_menu_item</c> — the thing that is sold, not a stocked product. Products are its ingredients.
/// A menu item flagged <see cref="IsSubRecipe"/> is a semi-finished item prepared in the branch (a sauce,
/// a mix) that never appears on a receipt but is referenced by other recipes.
/// </summary>
public sealed class MenuItem : AuditableEntity<uint>, ITenantEntity, ISoftDeletable
{
    public const int CodeMaxLength = 48;
    public const int PosCodeMaxLength = 64;
    public const int NameMaxLength = 250;
    public const int CategoryMaxLength = 120;

    private MenuItem()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    /// <summary>Code used by the POS. Sales import lines are matched on it.</summary>
    public string? PosCode { get; private set; }

    public string Name { get; private set; } = string.Empty;

    /// <summary>Azerbaijani collation key (spec §6.4); the list endpoint orders by it.</summary>
    public string NameSortKey { get; private set; } = string.Empty;

    public string? Category { get; private set; }

    public bool IsSubRecipe { get; private set; }

    public bool IsActive { get; private set; } = true;

    public bool IsDeleted { get; private set; }

    public static Result<MenuItem> Create(uint tenantId, string code, string? posCode, string name, string? category, bool isSubRecipe)
    {
        var normalizedCode = (code ?? string.Empty).Trim().ToUpperInvariant();
        if (normalizedCode.Length is 0 or > CodeMaxLength)
        {
            return ConsumptionErrors.InvalidMenuItem($"code must be 1..{CodeMaxLength} characters.");
        }

        var normalizedName = (name ?? string.Empty).Trim();
        if (normalizedName.Length is 0 or > NameMaxLength)
        {
            return ConsumptionErrors.InvalidMenuItem($"name must be 1..{NameMaxLength} characters.");
        }

        var normalizedPos = Normalize(posCode, PosCodeMaxLength);
        if (posCode is not null && normalizedPos is null && posCode.Trim().Length > PosCodeMaxLength)
        {
            return ConsumptionErrors.InvalidMenuItem($"posCode must be at most {PosCodeMaxLength} characters.");
        }

        return new MenuItem
        {
            TenantId = tenantId,
            Code = normalizedCode,
            PosCode = normalizedPos,
            Name = normalizedName,
            NameSortKey = AzerbaijaniSortKey.Create(normalizedName),
            Category = Normalize(category, CategoryMaxLength),
            IsSubRecipe = isSubRecipe,
            IsActive = true,
        };
    }

    public Result Update(string code, string? posCode, string name, string? category, bool isSubRecipe, bool isActive)
    {
        var replacement = Create(TenantId, code, posCode, name, category, isSubRecipe);
        if (replacement.IsFailure)
        {
            return replacement.Error;
        }

        Code = replacement.Value.Code;
        PosCode = replacement.Value.PosCode;
        Name = replacement.Value.Name;
        NameSortKey = replacement.Value.NameSortKey;
        Category = replacement.Value.Category;
        IsSubRecipe = isSubRecipe;
        IsActive = isActive;
        return Result.Success();
    }

    public void SoftDelete() => IsDeleted = true;

    public void Restore() => IsDeleted = false;

    private static string? Normalize(string? value, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        var trimmed = value.Trim();
        return trimmed.Length > maxLength ? trimmed[..maxLength] : trimmed;
    }
}
