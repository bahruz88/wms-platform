namespace Wms.Common.Application.Security;

/// <summary>
/// Which physical locations the current principal may see (spec §16: <c>iam_user_location</c>).
/// </summary>
/// <remarks>
/// The distinction between "restricted to nothing" and "not restricted at all" must be explicit. The previous
/// model carried a bare <c>IReadOnlyCollection&lt;uint&gt;</c> where an empty collection meant "unrestricted",
/// which made the whole filter fail-open: <c>iam_user_location</c> was empty for every user, so a branch user
/// saw both central warehouses and the other branches. Here an empty <see cref="LocationIds"/> on a
/// <see cref="IsRestricted"/> scope means <b>no</b> locations, and only the explicit
/// <see cref="Unrestricted"/> scope lifts the filter.
/// </remarks>
public sealed class LocationScope : IEquatable<LocationScope>
{
    /// <summary>The principal may see every location — granted only by <c>inv.location.view_all</c>.</summary>
    public static readonly LocationScope Unrestricted = new(isRestricted: false, []);

    /// <summary>A restricted principal with no <c>iam_user_location</c> rows: sees no physical location at all.</summary>
    public static readonly LocationScope Nothing = new(isRestricted: true, []);

    private LocationScope(bool isRestricted, uint[] locationIds)
    {
        IsRestricted = isRestricted;
        VisibleIds = locationIds;
        LocationIds = locationIds;
    }

    public bool IsRestricted { get; }

    public IReadOnlyCollection<uint> LocationIds { get; }

    /// <summary>Materialised array for EF <c>Contains</c> translation; never null, possibly empty.</summary>
    public uint[] VisibleIds { get; }

    public static LocationScope RestrictedTo(IEnumerable<uint>? locationIds)
    {
        if (locationIds is null)
        {
            return Nothing;
        }

        var ids = locationIds.Where(id => id != 0).Distinct().Order().ToArray();
        return ids.Length == 0 ? Nothing : new LocationScope(isRestricted: true, ids);
    }

    /// <summary>False for a restricted principal that was not granted this location.</summary>
    public bool Allows(uint locationId) => !IsRestricted || Array.IndexOf(VisibleIds, locationId) >= 0;

    /// <summary>True when every one of <paramref name="locationIds"/> is visible.</summary>
    public bool AllowsAll(IEnumerable<uint> locationIds)
    {
        ArgumentNullException.ThrowIfNull(locationIds);
        return !IsRestricted || locationIds.All(Allows);
    }

    public bool Equals(LocationScope? other) =>
        other is not null && IsRestricted == other.IsRestricted && VisibleIds.SequenceEqual(other.VisibleIds);

    public override bool Equals(object? obj) => Equals(obj as LocationScope);

    public override int GetHashCode()
    {
        var hash = new HashCode();
        hash.Add(IsRestricted);
        foreach (var id in VisibleIds)
        {
            hash.Add(id);
        }

        return hash.ToHashCode();
    }

    public override string ToString() =>
        IsRestricted ? $"restricted[{string.Join(',', VisibleIds)}]" : "unrestricted";
}
