using Wms.Common.Application.Security;
using Wms.Common.Domain;

namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>
/// Bootstrap role → permission map derived from spec §7.1 and the TOR roles.
/// </summary>
/// <remarks>
/// Authorization itself no longer runs off this table: <see cref="Wms.Common.Application.Abstractions.ICurrentUser"/>
/// reads the effective permissions from <c>iam_role_permission</c> through the principal directory. The map
/// survives as the <b>bootstrap</b> source — it is what the migrator's seeder expands into
/// <c>iam_role_permission</c>, and what the Identity module falls back to for a system role whose grants have
/// not been seeded yet, so a fresh database is usable before the seeder has run. An architecture test keeps it
/// identical to <c>PermissionCatalog.DefaultRoleGrants</c>.
/// </remarks>
public static class RolePermissionMap
{
    public const string Admin = "ADMIN";

    private const string ViewAllLocations = WmsPermissions.ViewAllLocations;

    /// <summary>
    /// Identical, pattern for pattern, to <c>PermissionCatalog.DefaultRoleGrants</c> in
    /// <c>Wms.Identity.Domain</c>. The duplication is forced by ADR-001 (BuildingBlocks must not reference a
    /// module) and is held in place by <c>RolePermissionMapTests.Bootstrap_map_matches_the_identity_catalogue</c>.
    /// </summary>
    private static readonly Dictionary<string, string[]> Map = new(StringComparer.OrdinalIgnoreCase)
    {
        [Admin] = ["*"],
        ["PROCUREMENT_OFFICER"] =
        [
            "proc.pr.*", "proc.rfq.*", "proc.quotation.*", "proc.po.create", "proc.po.view",
            "proc.po.view_for_receipt", "proc.po.submit", "proc.po.send", "proc.approval.view",
            "master.product.view", "master.product.view_cost", "master.supplier.*", "master.location.view",
            "master.category.view", "master.uom.view", "master.currency.view", "master.reason.view",
            "inv.balance.view", "inv.batch.view", "inv.receipt.view", "rpt.*", "doc.*", "notif.*",
            "iam.me.view", "iam.delegation.view", "iam.delegation.create", ViewAllLocations,
        ],
        ["PROCUREMENT_MANAGER"] =
        [
            "proc.*", "master.*", "inv.*.view", "inv.balance.view", "inv.adjustment.approve",
            "inv.waste.approve", "inv.settings.view", "inv.movement.reverse", "rpt.*", "doc.*", "notif.*",
            "iam.me.view", "iam.user.view", "iam.role.view", "iam.delegation.view", "iam.delegation.create",
            "audit.view", "iam.audit.view", ViewAllLocations,
        ],
        ["WAREHOUSE_KEEPER"] =
        [
            // Deliberately WITHOUT master.product.view_cost (spec §7.1, TOR §3.1, §40).
            "inv.receipt.create", "inv.receipt.post", "inv.receipt.view", "inv.issue.create",
            "inv.issue.dispatch", "inv.issue.view", "inv.issue.confirm", "inv.count.create",
            "inv.count.freeze", "inv.count.enter", "inv.count.post", "inv.count.view",
            "inv.waste.create", "inv.waste.view", "inv.waste.post", "inv.sample.create",
            "inv.sample.view", "inv.sample.post", "inv.rtv.view", "inv.rtv.create", "inv.rtv.post",
            "inv.movement.view",
            "inv.batch.manage", "inv.batch.view", "inv.balance.view", "inv.request.view",
            "inv.settings.view", "master.product.view", "master.location.view", "master.supplier.view",
            "master.category.view", "master.uom.view", "master.reason.view", "master.sequence.view",
            "proc.po.view_for_receipt", "rpt.dashboard.view", "rpt.report.view", "rpt.export.create", "notif.*", "iam.me.view", ViewAllLocations,
            // Not doc.attachment.* : that also grants doc.attachment.manage, i.e. deleting somebody
            // else's upload. A keeper may delete only their own.
            "doc.attachment.view", "doc.attachment.upload", "doc.attachment.delete",
        ],
        ["BRANCH_USER"] =
        [
            // No iam.location.view_all: a branch user is confined to iam_user_location (spec §16).
            "inv.request.create", "inv.request.submit", "inv.request.view", "inv.issue.confirm",
            "inv.waste.create", "inv.waste.view", "inv.count.enter", "inv.count.view",
            "inv.issue.view", "inv.movement.view", "inv.balance.view", "inv.batch.view",
            "master.product.view", "master.location.view", "master.reason.view", "cons.recipe.view",
            "cons.sales.import", "cons.variance.view", "rpt.dashboard.view", "rpt.report.view", "notif.*", "iam.me.view",
            "doc.attachment.view", "doc.attachment.upload", "doc.attachment.delete",
        ],
        ["AUDITOR"] =
        [
            "*.view", "*.view_cost", "rpt.*", "audit.view", "iam.audit.view", "notif.*", "iam.me.view", ViewAllLocations,
        ],
    };

    public static bool Allows(IEnumerable<string> roles, string permission)
    {
        ArgumentNullException.ThrowIfNull(roles);
        ArgumentException.ThrowIfNullOrWhiteSpace(permission);

        foreach (var role in roles)
        {
            if (!Map.TryGetValue(role, out var patterns))
            {
                continue;
            }

            foreach (var pattern in patterns)
            {
                if (Matches(pattern, permission))
                {
                    return true;
                }
            }
        }

        return false;
    }

    /// <inheritdoc cref="PermissionPattern.Matches"/>
    public static bool Matches(string pattern, string permission) => PermissionPattern.Matches(pattern, permission);

    /// <summary>Patterns granted to a role by the bootstrap map; empty for an unknown role.</summary>
    public static IReadOnlyList<string> Patterns(string role)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(role);
        return Map.TryGetValue(role, out var patterns) ? patterns : [];
    }

    /// <summary>Roles the bootstrap map knows.</summary>
    public static IReadOnlyCollection<string> Roles => Map.Keys;
}
