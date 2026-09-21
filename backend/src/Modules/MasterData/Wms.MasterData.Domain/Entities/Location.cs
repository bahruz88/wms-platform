using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_location</c> (spec §8): physical AND virtual locations — the basis of the double-entry ledger (ADR-003).</summary>
public sealed class Location : Entity<uint>, ITenantEntity, IVersioned
{
    public const int CodeMaxLength = 32;
    public const int NameMaxLength = 200;

    private Location()
    {
    }

    public uint TenantId { get; private set; }

    public uint? ParentId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    /// <summary>Immutable after creation: the ledger posts against the location type (spec §12.3).</summary>
    public LocationType LocationType { get; private set; }

    public bool IsVirtual { get; private set; }

    public bool AllowsFood { get; private set; } = true;

    public bool AllowsNonFood { get; private set; } = true;

    public bool IsActive { get; private set; } = true;

    public uint RowVersion { get; private set; } = 1;

    public static Result<Location> Create(uint tenantId, string code, string name, LocationType locationType, uint? parentId = null, bool allowsFood = true, bool allowsNonFood = true)
    {
        var normalizedCode = NormalizeCode(code);
        if (normalizedCode.Length is 0 or > CodeMaxLength)
        {
            return MasterDataErrors.InvalidLocation("code must be 1..32 characters.");
        }

        var normalizedName = (name ?? string.Empty).Trim();
        if (normalizedName.Length is 0 or > NameMaxLength)
        {
            return MasterDataErrors.InvalidLocation("name must be 1..200 characters.");
        }

        return new Location
        {
            TenantId = tenantId,
            ParentId = parentId,
            Code = normalizedCode,
            Name = normalizedName,
            LocationType = locationType,
            IsVirtual = IsVirtualType(locationType),
            AllowsFood = allowsFood,
            AllowsNonFood = allowsNonFood,
        };
    }

    public static string NormalizeCode(string? code) => (code ?? string.Empty).Trim().ToUpperInvariant();

    public static bool IsVirtualType(LocationType locationType) => locationType
        is LocationType.InTransit
        or LocationType.VSupplier
        or LocationType.VWaste
        or LocationType.VSample
        or LocationType.VAdjustment
        or LocationType.VConsumption;

    public void BumpVersion() => RowVersion++;

    public Result Rename(string name)
    {
        var normalized = (name ?? string.Empty).Trim();
        if (normalized.Length is 0 or > NameMaxLength)
        {
            return MasterDataErrors.InvalidLocation("name must be 1..200 characters.");
        }

        Name = normalized;
        return Result.Success();
    }

    /// <summary>Spec §12.3: posted movements name this location type, so it is frozen once the row exists.</summary>
    public Result ChangeLocationType(LocationType? locationType)
    {
        if (locationType is not { } requested || requested == LocationType)
        {
            return Result.Success();
        }

        return MasterDataErrors.LocationTypeImmutable(LocationType.ToString(), requested.ToString());
    }

    public Result Reparent(uint? parentId)
    {
        if (parentId == Id && parentId is not null)
        {
            return MasterDataErrors.InvalidLocation("A location cannot be its own parent.");
        }

        ParentId = parentId;
        return Result.Success();
    }

    public void SetStorageRules(bool allowsFood, bool allowsNonFood)
    {
        AllowsFood = allowsFood;
        AllowsNonFood = allowsNonFood;
    }

    public void SetActive(bool isActive) => IsActive = isActive;

    public void Deactivate() => IsActive = false;
}
