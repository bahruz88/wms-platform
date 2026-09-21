using Wms.Common.Infrastructure.Tenancy;

namespace Wms.ArchitectureTests;

/// <summary>
/// Spec §7.1 and §16 — the bootstrap role → permission map. These tests exist because the wildcard matcher used to
/// require the pattern and the permission to have the same number of segments, which silently reduced the auditor's
/// <c>*.view</c> to two-segment codes: <c>audit.view</c> matched, <c>inv.balance.view</c> did not, and the auditor
/// got a 403 on every screen they are supposed to be able to read.
/// </summary>
public sealed class RolePermissionMapTests
{
    private const string Admin = "ADMIN";
    private const string ProcurementOfficer = "PROCUREMENT_OFFICER";
    private const string ProcurementManager = "PROCUREMENT_MANAGER";
    private const string WarehouseKeeper = "WAREHOUSE_KEEPER";
    private const string BranchUser = "BRANCH_USER";
    private const string Auditor = "AUDITOR";

    private static bool Allows(string role, string permission) => RolePermissionMap.Allows([role], permission);

    // ================================================================ the matcher itself

    [Theory]
    [InlineData("*", "audit.view")]
    [InlineData("*", "inv.balance.view")]
    [InlineData("*", "a.b.c.d.e")]
    [InlineData("*.view", "audit.view")]
    [InlineData("*.view", "inv.balance.view")]
    [InlineData("*.view", "inv.receipt.line.view")]
    [InlineData("*.view_cost", "master.product.view_cost")]
    [InlineData("inv.*", "inv.balance.view")]
    [InlineData("inv.*.view", "inv.balance.view")]
    [InlineData("inv.*.view", "inv.receipt.line.view")]
    [InlineData("proc.pr.*", "proc.pr.create")]
    [InlineData("doc.attachment.*", "doc.attachment.upload")]
    [InlineData("inv.balance.view", "inv.balance.view")]
    [InlineData("INV.BALANCE.VIEW", "inv.balance.view")]
    public void Matches_accepts(string pattern, string permission) =>
        Assert.True(RolePermissionMap.Matches(pattern, permission), $"'{pattern}' should match '{permission}'");

    [Theory]
    [InlineData("*.view", "inv.receipt.post")]
    [InlineData("*.view", "master.product.view_cost")]        // view_cost is a separate permission (spec §7.1)
    [InlineData("master.product.view", "master.product.view_cost")]
    [InlineData("inv.*.view", "proc.po.view")]
    [InlineData("proc.pr.*", "proc.po.create")]
    [InlineData("inv.balance.view", "inv.balance")]
    [InlineData("inv.balance.view", "inv.balance.view.extra")]
    [InlineData("inv.*", "inv")]                              // '*' needs at least one segment
    [InlineData("*", "")]
    public void Matches_rejects(string pattern, string permission) =>
        Assert.False(RolePermissionMap.Matches(pattern, permission), $"'{pattern}' should not match '{permission}'");

    // ================================================================ AUDITOR — the regression this suite is named for

    [Theory]
    [InlineData("inv.balance.view")]
    [InlineData("inv.movement.view")]
    [InlineData("inv.batch.view")]
    [InlineData("inv.count.view")]
    [InlineData("inv.receipt.view")]
    [InlineData("inv.issue.view")]
    [InlineData("inv.waste.view")]
    [InlineData("master.product.view")]
    [InlineData("master.product.view_cost")]
    [InlineData("master.supplier.view")]
    [InlineData("master.location.view")]
    [InlineData("proc.po.view")]
    [InlineData("cons.variance.view")]
    [InlineData("doc.attachment.view")]
    [InlineData("audit.view")]
    [InlineData("rpt.stock.run")]
    [InlineData("rpt.export")]
    public void Auditor_can_read_the_whole_system(string permission) =>
        Assert.True(Allows(Auditor, permission), $"AUDITOR must hold '{permission}' (screen map: ledger, audit log, reports, export)");

    [Theory]
    [InlineData("inv.receipt.create")]
    [InlineData("inv.receipt.post")]
    [InlineData("inv.count.post")]
    [InlineData("inv.movement.reverse")]
    [InlineData("inv.adjustment.approve")]
    [InlineData("proc.po.approve")]
    [InlineData("master.product.manage")]
    [InlineData("iam.user.manage")]
    public void Auditor_can_change_nothing(string permission) =>
        Assert.False(Allows(Auditor, permission), $"AUDITOR is read-only and must not hold '{permission}'");

    // ================================================================ WAREHOUSE_KEEPER

    [Theory]
    [InlineData("inv.receipt.create")]
    [InlineData("inv.receipt.post")]
    [InlineData("inv.count.create")]
    [InlineData("inv.count.freeze")]
    [InlineData("inv.count.enter")]
    [InlineData("inv.count.post")]
    [InlineData("inv.issue.create")]
    [InlineData("inv.issue.dispatch")]
    [InlineData("inv.waste.create")]
    [InlineData("inv.sample.create")]
    [InlineData("inv.rtv.create")]
    [InlineData("inv.batch.manage")]
    [InlineData("inv.balance.view")]
    [InlineData("master.product.view")]
    public void Warehouse_keeper_can_run_the_warehouse(string permission) =>
        Assert.True(Allows(WarehouseKeeper, permission), $"WAREHOUSE_KEEPER must hold '{permission}'");

    [Fact]
    public void Warehouse_keeper_never_sees_cost()
    {
        // Spec §7.1, TOR §3.1 and §40: this is the segregation-of-duties rule the UI relies on to drop the column.
        Assert.False(Allows(WarehouseKeeper, "master.product.view_cost"));
        Assert.True(Allows(WarehouseKeeper, "master.product.view"));
    }

    [Theory]
    [InlineData("inv.adjustment.approve")]
    [InlineData("inv.waste.approve")]
    [InlineData("inv.movement.reverse")]
    [InlineData("proc.po.approve")]
    public void Warehouse_keeper_cannot_approve_its_own_work(string permission) =>
        Assert.False(Allows(WarehouseKeeper, permission), $"WAREHOUSE_KEEPER must not hold '{permission}' (segregation of duties)");

    [Theory]
    [InlineData(WarehouseKeeper)]
    [InlineData(BranchUser)]
    public void An_operational_role_may_only_delete_its_own_attachments(string role)
    {
        // doc.attachment.manage is what lets a holder delete somebody ELSE's upload. The roles below were
        // granted the doc.attachment.* wildcard, which quietly swept it up the moment the code was added to
        // the catalogue - a branch user could then delete the warehouse's invoice scan.
        Assert.False(Allows(role, "doc.attachment.manage"), $"{role} must not hold 'doc.attachment.manage'");
        Assert.True(Allows(role, "doc.attachment.upload"));
        Assert.True(Allows(role, "doc.attachment.view"));
        Assert.True(Allows(role, "doc.attachment.delete"));
    }

    // ================================================================ BRANCH_USER

    [Theory]
    [InlineData("inv.request.create")]
    [InlineData("inv.issue.confirm")]
    [InlineData("inv.waste.create")]
    [InlineData("inv.count.enter")]
    [InlineData("inv.balance.view")]
    public void Branch_user_can_run_a_branch(string permission) =>
        Assert.True(Allows(BranchUser, permission), $"BRANCH_USER must hold '{permission}'");

    [Theory]
    [InlineData("inv.receipt.post")]
    [InlineData("inv.issue.dispatch")]
    [InlineData("inv.count.freeze")]
    [InlineData("master.product.view_cost")]
    [InlineData("proc.po.create")]
    public void Branch_user_cannot_act_as_the_warehouse(string permission) =>
        Assert.False(Allows(BranchUser, permission), $"BRANCH_USER must not hold '{permission}'");

    // ================================================================ PROCUREMENT roles

    [Theory]
    [InlineData("proc.pr.create")]
    [InlineData("proc.rfq.send")]
    [InlineData("proc.quotation.select")]
    [InlineData("proc.po.create")]
    [InlineData("proc.po.send")]
    [InlineData("master.product.view_cost")]
    [InlineData("master.supplier.manage")]
    [InlineData("inv.balance.view")]
    public void Procurement_officer_can_buy(string permission) =>
        Assert.True(Allows(ProcurementOfficer, permission), $"PROCUREMENT_OFFICER must hold '{permission}'");

    [Fact]
    public void Procurement_officer_cannot_approve_its_own_purchase_order() =>
        Assert.False(Allows(ProcurementOfficer, "proc.po.approve"));

    [Theory]
    [InlineData("proc.po.approve")]
    [InlineData("inv.adjustment.approve")]
    [InlineData("inv.waste.approve")]
    [InlineData("inv.movement.reverse")]
    [InlineData("inv.balance.view")]
    [InlineData("inv.count.view")]
    [InlineData("master.product.view_cost")]
    public void Procurement_manager_can_approve(string permission) =>
        Assert.True(Allows(ProcurementManager, permission), $"PROCUREMENT_MANAGER must hold '{permission}'");

    [Theory]
    [InlineData("inv.receipt.post")]
    [InlineData("inv.count.freeze")]
    public void Procurement_manager_does_not_do_warehouse_work(string permission) =>
        Assert.False(Allows(ProcurementManager, permission), $"PROCUREMENT_MANAGER must not hold '{permission}'");

    // ================================================================ ADMIN and the fallbacks

    [Theory]
    [InlineData("inv.receipt.post")]
    [InlineData("master.product.view_cost")]
    [InlineData("iam.user.manage")]
    [InlineData("anything.at.all")]
    public void Admin_holds_everything(string permission) =>
        Assert.True(Allows(Admin, permission));

    [Fact]
    public void An_unknown_role_holds_nothing() =>
        Assert.False(Allows("SOMETHING_ELSE", "inv.balance.view"));

    [Fact]
    public void Roles_are_matched_case_insensitively() =>
        Assert.True(RolePermissionMap.Allows(["warehouse_keeper"], "inv.receipt.create"));

    [Fact]
    public void Holding_several_roles_unions_their_permissions()
    {
        Assert.True(RolePermissionMap.Allows([BranchUser, WarehouseKeeper], "inv.receipt.post"));
        Assert.True(RolePermissionMap.Allows([BranchUser, WarehouseKeeper], "inv.request.create"));
    }

    [Fact]
    public void Every_role_can_read_its_own_notifications()
    {
        foreach (var role in new[] { ProcurementOfficer, ProcurementManager, WarehouseKeeper, BranchUser, Auditor })
        {
            Assert.True(Allows(role, "notif.inbox.view"), $"{role} must be able to read its inbox");
        }
    }
}
