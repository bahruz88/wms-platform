using Wms.Identity.Domain.Entities;

namespace Wms.Identity.UnitTests;

/// <summary>Spec §7 — <c>iam_user</c>, its role/location sets and the pre-provisioning handshake.</summary>
public sealed class UserTests
{
    private static User NewUser(string externalId = "sub-1", string username = "keeper") =>
        User.Create(1, externalId, username, "Anbardar", "keeper@wms.local").Value;

    [Fact]
    public void Replacing_roles_is_a_full_replacement()
    {
        var user = NewUser();
        user.ReplaceRoles([1, 2, 2, 3]);
        Assert.Equal([1u, 2u, 3u], user.Roles.Select(r => r.RoleId));

        user.ReplaceRoles([4]);
        Assert.Equal([4u], user.Roles.Select(r => r.RoleId));

        user.ReplaceRoles([]);
        Assert.Empty(user.Roles);
    }

    [Fact]
    public void Replacing_locations_is_a_full_replacement()
    {
        var user = NewUser();
        user.ReplaceLocations([10, 11]);
        Assert.Equal([10u, 11u], user.Locations.Select(l => l.LocationId));

        user.ReplaceLocations([11]);
        Assert.Equal([11u], user.Locations.Select(l => l.LocationId));
    }

    [Fact]
    public void A_seeded_row_is_unclaimed_until_a_real_token_arrives()
    {
        var user = NewUser(User.UnclaimedExternalIdPrefix + "keeper");

        Assert.True(user.IsUnclaimed);
        Assert.True(user.ClaimExternalId("f47ac10b-58cc-4372-a567-0e02b2c3d479"));
        Assert.False(user.IsUnclaimed);
        Assert.Equal("f47ac10b-58cc-4372-a567-0e02b2c3d479", user.ExternalId);
    }

    [Fact]
    public void An_already_claimed_row_cannot_be_reassigned_to_another_subject()
    {
        var user = NewUser("f47ac10b-58cc-4372-a567-0e02b2c3d479");

        Assert.False(user.ClaimExternalId("11111111-2222-3333-4444-555555555555"));
        Assert.Equal("f47ac10b-58cc-4372-a567-0e02b2c3d479", user.ExternalId);
    }

    [Fact]
    public void Token_data_keeps_the_row_in_step_with_keycloak()
    {
        var user = NewUser();

        Assert.True(user.SyncFromToken("keeper2", "Yeni Anbardar", "new@wms.local"));
        Assert.Equal("keeper2", user.Username);
        Assert.Equal("Yeni Anbardar", user.FullName);
        Assert.Equal("new@wms.local", user.Email);

        Assert.False(user.SyncFromToken("keeper2", "Yeni Anbardar", "new@wms.local"));
    }

    [Fact]
    public void Update_validates_its_inputs()
    {
        var user = NewUser();

        Assert.True(user.Update("Yeni ad", null, null, isActive: false).IsSuccess);
        Assert.False(user.IsActive);
        Assert.Null(user.Email);

        var tooLong = user.Update(new string('x', 201), null, null, isActive: true);
        Assert.True(tooLong.IsFailure);
        Assert.Equal("INVALID_USER", tooLong.Error.Code);
    }

    [Fact]
    public void A_system_role_cannot_be_renamed()
    {
        var system = Role.Create(1, "ADMIN", "Administrator", isSystem: true);
        var custom = Role.Create(1, "STOCKTAKER", "Sayıcı");

        Assert.Equal("SYSTEM_ROLE_IMMUTABLE", system.Rename("Başqa ad").Error.Code);
        Assert.True(custom.Rename("Yeni ad").IsSuccess);
        Assert.Equal("Yeni ad", custom.Name);
    }

    [Fact]
    public void Revoking_a_delegation_closes_it_today_and_keeps_the_row()
    {
        var today = new DateOnly(2026, 9, 22);
        var delegation = Delegation
            .Create(1, 1, 2, new DateOnly(2026, 9, 1), new DateOnly(2026, 12, 31), "məzuniyyət", DateTimeOffset.UtcNow, 1)
            .Value;

        delegation.Revoke(today);

        Assert.Equal(today, delegation.ValidTo);
        Assert.True(delegation.IsActiveOn(today));
        Assert.False(delegation.IsActiveOn(today.AddDays(1)));
    }

    [Fact]
    public void Revoking_a_future_delegation_closes_it_before_it_opens()
    {
        var delegation = Delegation
            .Create(1, 1, 2, new DateOnly(2026, 10, 1), new DateOnly(2026, 10, 31), null, DateTimeOffset.UtcNow, 1)
            .Value;

        delegation.Revoke(new DateOnly(2026, 9, 22));

        Assert.False(delegation.IsActiveOn(new DateOnly(2026, 10, 1)));
    }

    [Fact]
    public void A_delegation_cannot_point_at_itself_or_run_backwards()
    {
        Assert.Equal(
            "INVALID_DELEGATION",
            Delegation.Create(1, 5, 5, new DateOnly(2026, 9, 1), new DateOnly(2026, 9, 2), null, DateTimeOffset.UtcNow, 1).Error.Code);
        Assert.Equal(
            "INVALID_DELEGATION",
            Delegation.Create(1, 5, 6, new DateOnly(2026, 9, 5), new DateOnly(2026, 9, 1), null, DateTimeOffset.UtcNow, 1).Error.Code);
    }

    [Fact]
    public void Overlap_detection_is_inclusive_on_both_ends()
    {
        var delegation = Delegation
            .Create(1, 1, 2, new DateOnly(2026, 9, 10), new DateOnly(2026, 9, 20), null, DateTimeOffset.UtcNow, 1)
            .Value;

        Assert.True(delegation.Overlaps(new DateOnly(2026, 9, 20), new DateOnly(2026, 9, 25)));
        Assert.True(delegation.Overlaps(new DateOnly(2026, 9, 1), new DateOnly(2026, 9, 10)));
        Assert.False(delegation.Overlaps(new DateOnly(2026, 9, 21), new DateOnly(2026, 9, 25)));
        Assert.False(delegation.Overlaps(new DateOnly(2026, 9, 1), new DateOnly(2026, 9, 9)));
    }
}
