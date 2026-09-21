using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_location</c> (spec §8): physical AND virtual locations — the basis of the double-entry ledger (ADR-003).</summary>
public sealed class Location : Entity<uint>, ITenantEntity
{
    private Location()
    {
    }

    public uint TenantId { get; private set; }

    public uint? ParentId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public LocationType LocationType { get; private set; }

    public bool IsVirtual { get; private set; }

    public bool AllowsFood { get; private set; } = true;

    public bool AllowsNonFood { get; private set; } = true;

    public bool IsActive { get; private set; } = true;

    public static Result<Location> Create(uint tenantId, string code, string name, LocationType locationType, uint? parentId = null, bool allowsFood = true, bool allowsNonFood = true)
    {
        var normalizedCode = (code ?? string.Empty).Trim().ToUpperInvariant();
        if (normalizedCode.Length is 0 or > 32)
        {
            return MasterDataErrors.InvalidLocation("code must be 1..32 characters.");
        }

        return new Location
        {
            TenantId = tenantId,
            ParentId = parentId,
            Code = normalizedCode,
            Name = (name ?? string.Empty).Trim(),
            LocationType = locationType,
            IsVirtual = IsVirtualType(locationType),
            AllowsFood = allowsFood,
            AllowsNonFood = allowsNonFood,
        };
    }

    public static bool IsVirtualType(LocationType locationType) => locationType
        is LocationType.InTransit
        or LocationType.VSupplier
        or LocationType.VWaste
        or LocationType.VSample
        or LocationType.VAdjustment
        or LocationType.VConsumption;

    public void Deactivate() => IsActive = false;
}
