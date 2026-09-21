using Wms.Identity.Domain;

namespace Wms.Identity.UnitTests;

/// <summary>Spec §7 / §7.1 — the <c>iam_permission</c> catalogue and the default role grants.</summary>
public sealed class PermissionCatalogTests
{
    [Fact]
    public void Codes_are_unique_and_well_formed()
    {
        var duplicates = PermissionCatalog.All
            .GroupBy(p => p.Code, StringComparer.Ordinal)
            .Where(g => g.Count() > 1)
            .Select(g => g.Key)
            .ToList();

        Assert.True(duplicates.Count == 0, $"duplicate permission codes: {string.Join(", ", duplicates)}");
        Assert.All(PermissionCatalog.All, p =>
        {
            // identity.v1.yaml PermissionCode: `<module>.<resource>.<operation>`.
            Assert.Matches("^[a-z]+\\.[a-z_]+\\.[a-z_]+$", p.Code);
            Assert.False(string.IsNullOrWhiteSpace(p.Module));
        });
    }

    [Fact]
    public void Every_system_role_gets_a_non_empty_grant_set()
    {
        foreach (var role in SystemRoles.All)
        {
            Assert.NotEmpty(PermissionCatalog.GrantsFor(role));
        }
    }

    [Fact]
    public void An_unknown_role_gets_nothing() => Assert.Empty(PermissionCatalog.GrantsFor("SOMETHING_ELSE"));

    [Fact]
    public void Expansion_only_ever_yields_catalogue_codes()
    {
        foreach (var role in SystemRoles.All)
        {
            Assert.All(PermissionCatalog.GrantsFor(role), code => Assert.Contains(code, PermissionCatalog.Codes));
        }
    }

    [Fact]
    public void The_warehouse_keeper_never_gets_the_cost_permission()
    {
        // Spec §7.1, TOR §3.1 and §40: the rule the UI relies on to drop the cost column entirely.
        var keeper = PermissionCatalog.GrantsFor(SystemRoles.WarehouseKeeper);

        Assert.DoesNotContain(PermissionCatalog.ProductViewCost, keeper);
        Assert.Contains("master.product.view", keeper);
    }

    [Fact]
    public void Only_the_branch_user_is_location_restricted()
    {
        // Spec §16: everybody else works company-wide, so they hold iam.location.view_all; the branch user
        // does not, which is what confines them to iam_user_location.
        Assert.DoesNotContain(PermissionCatalog.ViewAllLocations, PermissionCatalog.GrantsFor(SystemRoles.BranchUser));

        foreach (var role in SystemRoles.All.Where(r => r != SystemRoles.BranchUser))
        {
            Assert.Contains(PermissionCatalog.ViewAllLocations, PermissionCatalog.GrantsFor(role));
        }
    }

    [Fact]
    public void The_auditor_reads_everything_and_writes_nothing()
    {
        var auditor = PermissionCatalog.GrantsFor(SystemRoles.Auditor);

        Assert.Contains("inv.balance.view", auditor);
        Assert.Contains("inv.movement.view", auditor);
        Assert.Contains(PermissionCatalog.ProductViewCost, auditor);
        Assert.Contains("iam.audit.view", auditor);

        Assert.DoesNotContain("inv.receipt.post", auditor);
        Assert.DoesNotContain("inv.count.post", auditor);
        Assert.DoesNotContain("iam.user.manage", auditor);
        Assert.DoesNotContain("proc.po.approve", auditor);
    }

    [Fact]
    public void The_admin_holds_the_whole_catalogue() =>
        Assert.Equal(PermissionCatalog.Codes.Count, PermissionCatalog.GrantsFor(SystemRoles.Admin).Count);

    [Fact]
    public void Critical_permissions_of_spec_7_1_are_flagged()
    {
        string[] critical =
        [
            "master.product.view_cost", "inv.adjustment.approve", "inv.waste.approve",
            "proc.po.approve", "inv.movement.reverse",
        ];

        foreach (var code in critical)
        {
            var definition = PermissionCatalog.All.Single(p => p.Code == code);
            Assert.True(definition.IsCritical, $"'{code}' is listed as critical in spec §7.1");
        }
    }

    [Fact]
    public void The_warehouse_keeper_cannot_approve_its_own_kind_of_work()
    {
        var keeper = PermissionCatalog.GrantsFor(SystemRoles.WarehouseKeeper);

        Assert.DoesNotContain("inv.adjustment.approve", keeper);
        Assert.DoesNotContain("inv.waste.approve", keeper);
        Assert.DoesNotContain("inv.movement.reverse", keeper);
    }
}
