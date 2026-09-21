namespace Wms.Identity.Application;

public static class IdentityPermissions
{
    /// <summary>Everyone who can log in holds this; it guards <c>/me</c> and <c>/tenant</c>.</summary>
    public const string MeView = "iam.me.view";

    public const string UserView = "iam.user.view";
    public const string UserManage = "iam.user.manage";
    public const string RoleView = "iam.role.view";
    public const string RoleManage = "iam.role.manage";
    public const string DelegationView = "iam.delegation.view";
    public const string DelegationCreate = "iam.delegation.create";

    /// <summary>Acting on behalf of another user (delegation from someone else).</summary>
    public const string DelegationManage = "iam.delegation.manage";
}
