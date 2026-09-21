namespace Wms.Common.Domain;

/// <summary>
/// Matcher for dot-separated permission codes with <c>*</c> wildcards. Shared by the bootstrap role map
/// (<c>RolePermissionMap</c>), the <c>iam_permission</c> catalogue expansion and the runtime permission check,
/// so all three agree on what a pattern means.
/// </summary>
public static class PermissionPattern
{
    /// <summary>
    /// <c>*</c> is a wildcard for <b>one or more</b> whole segments, so <c>*.view</c> covers both
    /// <c>audit.view</c> and <c>inv.balance.view</c>, and <c>inv.*.view</c> covers <c>inv.balance.view</c> as
    /// well as a deeper <c>inv.receipt.line.view</c>. A segment is matched as a whole:
    /// <c>master.product.view</c> never matches <c>master.product.view_cost</c> (spec §7.1 keeps the two apart).
    /// </summary>
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
