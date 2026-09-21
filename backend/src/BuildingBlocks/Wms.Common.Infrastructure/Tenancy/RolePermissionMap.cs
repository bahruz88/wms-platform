namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>
/// Bootstrap role → permission map derived from spec §7.1 and TOR roles. It is the fallback used until the
/// Identity module's <c>iam_role_permission</c> data is consulted through <c>IPermissionChecker</c>.
/// TODO(identity): replace with a cached lookup of iam_role_permission per tenant.
/// </summary>
public static class RolePermissionMap
{
    public const string Admin = "ADMIN";

    private static readonly Dictionary<string, string[]> Map = new(StringComparer.OrdinalIgnoreCase)
    {
        [Admin] = ["*"],
        ["PROCUREMENT_OFFICER"] =
        [
            "proc.pr.*", "proc.rfq.*", "proc.quotation.*", "proc.po.create", "proc.po.view", "proc.po.send",
            "master.product.view", "master.product.view_cost", "master.supplier.*", "master.location.view",
            "inv.balance.view", "inv.batch.view", "inv.receipt.view", "rpt.*", "doc.*", "notif.*",
        ],
        ["PROCUREMENT_MANAGER"] =
        [
            "proc.*", "master.*", "inv.*.view", "inv.balance.view", "inv.adjustment.approve", "inv.waste.approve",
            "inv.movement.reverse", "rpt.*", "doc.*", "notif.*",
        ],
        ["WAREHOUSE_KEEPER"] =
        [
            // Deliberately WITHOUT master.product.view_cost (spec §7.1, TOR §3.1, §40).
            "inv.receipt.create", "inv.receipt.post", "inv.receipt.view", "inv.issue.create", "inv.issue.dispatch",
            "inv.transfer.create", "inv.count.create", "inv.count.count", "inv.waste.create", "inv.sample.create",
            "inv.return.create", "inv.balance.view", "inv.batch.view", "inv.request.view",
            "master.product.view", "master.location.view", "master.supplier.view", "doc.attachment.*", "notif.*",
        ],
        ["BRANCH_USER"] =
        [
            "inv.request.create", "inv.request.view", "inv.transfer.confirm", "inv.waste.create", "inv.count.count",
            "inv.balance.view", "inv.batch.view", "master.product.view", "master.location.view", "doc.attachment.*", "notif.*",
        ],
        ["AUDITOR"] = ["*.view", "*.view_cost", "rpt.*", "audit.view", "notif.*"],
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

    /// <summary>Matches dot-separated permission codes where <c>*</c> stands for one segment or the whole remainder.</summary>
    public static bool Matches(string pattern, string permission)
    {
        ArgumentNullException.ThrowIfNull(pattern);
        ArgumentNullException.ThrowIfNull(permission);

        if (pattern == "*")
        {
            return true;
        }

        var patternParts = pattern.Split('.');
        var permissionParts = permission.Split('.');
        for (var i = 0; i < patternParts.Length; i++)
        {
            if (i >= permissionParts.Length)
            {
                return false;
            }

            if (patternParts[i] == "*")
            {
                if (i == patternParts.Length - 1)
                {
                    return true;
                }

                continue;
            }

            if (!string.Equals(patternParts[i], permissionParts[i], StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }
        }

        return patternParts.Length == permissionParts.Length;
    }
}
