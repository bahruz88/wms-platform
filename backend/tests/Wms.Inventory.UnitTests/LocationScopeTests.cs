using Wms.Common.Application.Security;

namespace Wms.Inventory.UnitTests;

/// <summary>
/// Spec §16 — the branch user's location filter.
/// </summary>
/// <remarks>
/// The whole restriction used to hang off a bare <c>IReadOnlyCollection&lt;uint&gt;</c> where "empty" meant
/// "unrestricted". <c>iam_user_location</c> was empty for every user, so the filter was fail-open and a
/// branch token listed both central warehouses and the other branches. These tests pin the replacement:
/// only an explicit <see cref="LocationScope.Unrestricted"/> lifts the filter, and a restricted scope with
/// no ids matches nothing.
/// </remarks>
public sealed class LocationScopeTests
{
    [Fact]
    public void An_empty_restricted_scope_allows_no_location()
    {
        var scope = LocationScope.RestrictedTo([]);

        Assert.True(scope.IsRestricted);
        Assert.Empty(scope.VisibleIds);
        Assert.False(scope.Allows(1));
        Assert.False(scope.Allows(9999));
    }

    [Fact]
    public void A_null_grant_list_is_restricted_to_nothing_not_to_everything()
    {
        var scope = LocationScope.RestrictedTo(null);

        Assert.True(scope.IsRestricted);
        Assert.False(scope.Allows(1));
    }

    [Fact]
    public void A_restricted_scope_allows_only_its_own_locations()
    {
        var scope = LocationScope.RestrictedTo([12, 7, 12]);

        Assert.True(scope.Allows(7));
        Assert.True(scope.Allows(12));
        Assert.False(scope.Allows(1));
        Assert.Equal([7u, 12u], scope.VisibleIds);
    }

    [Fact]
    public void The_unrestricted_scope_allows_everything()
    {
        Assert.False(LocationScope.Unrestricted.IsRestricted);
        Assert.True(LocationScope.Unrestricted.Allows(1));
        Assert.True(LocationScope.Unrestricted.Allows(uint.MaxValue));
    }

    [Fact]
    public void Zero_is_not_a_location_id()
    {
        var scope = LocationScope.RestrictedTo([0, 5]);

        Assert.Equal([5u], scope.VisibleIds);
        Assert.False(scope.Allows(0));
    }

    [Fact]
    public void AllowsAll_is_true_only_when_every_location_is_visible()
    {
        var scope = LocationScope.RestrictedTo([1, 2]);

        Assert.True(scope.AllowsAll([1, 2]));
        Assert.False(scope.AllowsAll([1, 3]));
        Assert.True(LocationScope.Unrestricted.AllowsAll([1, 3, 99]));
    }

    [Fact]
    public void Scopes_with_the_same_grants_are_equal()
    {
        Assert.Equal(LocationScope.RestrictedTo([2, 1]), LocationScope.RestrictedTo([1, 2]));
        Assert.NotEqual(LocationScope.Unrestricted, LocationScope.RestrictedTo([1]));

        // The crucial one: "restricted to nothing" is NOT the same value as "unrestricted".
        Assert.NotEqual(LocationScope.Unrestricted, LocationScope.Nothing);
    }
}
