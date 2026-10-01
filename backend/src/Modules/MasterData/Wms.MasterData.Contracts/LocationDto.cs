namespace Wms.MasterData.Contracts;

/// <summary>Values of <c>master_location.location_type</c> (spec §8). Virtual locations are the counter-accounts of the ledger (ADR-003).</summary>
public static class LocationTypes
{
    public const string CentralWarehouse = "CENTRAL_WAREHOUSE";
    public const string SubLocation = "SUB_LOCATION";
    public const string Shelf = "SHELF";
    public const string Restaurant = "RESTAURANT";
    public const string InTransit = "IN_TRANSIT";
    public const string VSupplier = "V_SUPPLIER";
    public const string VWaste = "V_WASTE";
    public const string VSample = "V_SAMPLE";
    public const string VAdjustment = "V_ADJUSTMENT";

    /// <summary>Counter-account of a branch consumption document (ADR-012).</summary>
    public const string VConsumption = "V_CONSUMPTION";

    /// <summary>
    /// The types that are virtual (<c>is_virtual = 1</c>) — the same set as <c>Location.IsVirtualType</c>, which a
    /// MasterData unit test pins. A module outside MasterData uses it to tell physical stock from the
    /// counter-accounts without reading <c>master_location</c>.
    /// </summary>
    public static IReadOnlyList<string> Virtual { get; } = [InTransit, VSupplier, VWaste, VSample, VAdjustment, VConsumption];
}

public sealed record LocationDto(
    uint Id,
    string Code,
    string Name,
    string LocationType,
    uint? ParentId,
    bool IsVirtual,
    bool AllowsFood,
    bool AllowsNonFood,
    bool IsActive);
