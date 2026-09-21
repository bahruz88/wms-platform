using Wms.Identity.Application.Commands;
using Wms.Identity.Domain;
using Wms.Identity.Domain.Entities;

namespace Wms.Identity.UnitTests;

/// <summary>Spec §7.1 — the <c>WAREHOUSE_KEEPER</c> / <c>master.product.view_cost</c> rule, on both write paths.</summary>
public sealed class SegregationOfDutiesTests
{
    private static Role Role(string code) => Wms.Identity.Domain.Entities.Role.Create(1, code, code, isSystem: true);

    [Fact]
    public void Granting_cost_to_the_warehouse_keeper_role_is_refused()
    {
        var error = RolePermissionRules.Check(SystemRoles.WarehouseKeeper, ["master.product.view", PermissionCatalog.ProductViewCost]);

        Assert.NotNull(error);
        Assert.Equal("SEGREGATION_OF_DUTIES", error.Code);
        Assert.Equal(422, error.Status);
    }

    [Fact]
    public void The_warehouse_keeper_role_may_still_hold_the_plain_view_permission() =>
        Assert.Null(RolePermissionRules.Check(SystemRoles.WarehouseKeeper, ["master.product.view", "inv.receipt.post"]));

    [Fact]
    public void Another_role_may_hold_the_cost_permission() =>
        Assert.Null(RolePermissionRules.Check(SystemRoles.ProcurementOfficer, [PermissionCatalog.ProductViewCost]));

    [Fact]
    public void Combining_the_keeper_role_with_a_cost_granting_role_is_refused()
    {
        // The rule has to hold for the user as a whole, not only for one role in isolation: PROCUREMENT_OFFICER
        // legitimately sees cost, so keeper + officer would hand the warehouse the cost column through the back door.
        var error = SegregationOfDuties.CheckRoleCombination(
            [Role(SystemRoles.WarehouseKeeper), Role(SystemRoles.ProcurementOfficer)],
            ["master.product.view", PermissionCatalog.ProductViewCost]);

        Assert.NotNull(error);
        Assert.Equal("SEGREGATION_OF_DUTIES", error.Code);
    }

    [Fact]
    public void The_keeper_role_alone_is_accepted() =>
        Assert.Null(SegregationOfDuties.CheckRoleCombination(
            [Role(SystemRoles.WarehouseKeeper)],
            PermissionCatalog.GrantsFor(SystemRoles.WarehouseKeeper)));

    [Fact]
    public void A_user_without_the_keeper_role_is_not_affected() =>
        Assert.Null(SegregationOfDuties.CheckRoleCombination(
            [Role(SystemRoles.ProcurementManager)],
            [PermissionCatalog.ProductViewCost]));
}
