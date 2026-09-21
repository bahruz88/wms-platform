namespace Wms.Common.Application.Security;

/// <summary>Permission codes that the platform itself (not a single module) reasons about.</summary>
public static class WmsPermissions
{
    /// <summary>
    /// Lifts the <c>iam_user_location</c> restriction of spec §16. Without it a principal sees exactly the
    /// locations listed in <c>iam_user_location</c> — and none at all when that list is empty. Granted to the
    /// company-wide roles (ADMIN, AUDITOR, PROCUREMENT_MANAGER, PROCUREMENT_OFFICER, WAREHOUSE_KEEPER) and
    /// deliberately withheld from BRANCH_USER.
    /// </summary>
    public const string ViewAllLocations = "iam.location.view_all";
}
