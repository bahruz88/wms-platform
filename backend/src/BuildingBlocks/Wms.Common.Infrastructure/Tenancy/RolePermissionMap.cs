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
            "inv.transfer.create", "inv.count.create", "inv.count.freeze", "inv.count.enter", "inv.count.post",
            "inv.count.view", "inv.waste.create", "inv.waste.view", "inv.waste.post", "inv.sample.create",
            "inv.sample.view", "inv.return.view", "inv.issue.view", "inv.movement.view", "inv.batch.manage",
            "inv.transfer.confirm",
            "inv.return.create", "inv.balance.view", "inv.batch.view", "inv.request.view",
            "master.product.view", "master.location.view", "master.supplier.view", "doc.attachment.*", "notif.*",
        ],
        ["BRANCH_USER"] =
        [
            "inv.request.create", "inv.request.view", "inv.transfer.confirm", "inv.waste.create",
            "inv.count.enter", "inv.count.view", "inv.waste.view", "inv.issue.view", "inv.movement.view",
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

    /// <summary>
    /// Matches dot-separated permission codes. <c>*</c> is a wildcard for <b>one or more</b> whole segments, so
    /// <c>*.view</c> covers both <c>audit.view</c> and <c>inv.balance.view</c>, and <c>inv.*.view</c> covers
    /// <c>inv.balance.view</c> as well as a deeper <c>inv.receipt.line.view</c>. A segment is matched as a whole:
    /// <c>master.product.view</c> never matches <c>master.product.view_cost</c> (spec §7.1 keeps the two apart).
    /// </summary>
    /// <remarks>
    /// The previous implementation required the pattern and the permission to have the same number of segments,
    /// which silently reduced <c>*.view</c> to two-segment codes only and locked AUDITOR out of every three-segment
    /// read permission (<c>inv.balance.view</c>, <c>inv.movement.view</c>, <c>master.product.view_cost</c>).
    /// </remarks>
    public static bool Matches(string pattern, string permission)
    {
        ArgumentNullException.ThrowIfNull(pattern);
        ArgumentNullException.ThrowIfNull(permission);

        if (pattern.Length == 0 || permission.Length == 0)
        {
            return false;
        }

        return IsMatch(pattern.Split('.'), 0, permission.Split('.'), 0);
    }

    /// <summary>Greedy-with-backtracking segment matcher; patterns are at most a handful of segments long.</summary>
    private static bool IsMatch(string[] pattern, int p, string[] permission, int s)
    {
        while (p < pattern.Length)
        {
            if (pattern[p] == "*")
            {
                // '*' consumes at least one segment; the last '*' swallows the whole remainder.
                if (p == pattern.Length - 1)
                {
                    return s < permission.Length;
                }

                for (var take = s + 1; take <= permission.Length; take++)
                {
                    if (IsMatch(pattern, p + 1, permission, take))
                    {
                        return true;
                    }
                }

                return false;
            }

            if (s >= permission.Length || !string.Equals(pattern[p], permission[s], StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            p++;
            s++;
        }

        return s == permission.Length;
    }
}
