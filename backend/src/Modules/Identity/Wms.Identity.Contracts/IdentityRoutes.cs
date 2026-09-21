namespace Wms.Identity.Contracts;

/// <summary>
/// Internal (module-to-module) HTTP routes used when <c>ModuleTransport=Http</c>. They are refused at the
/// gateway and require the shared module secret on every host (<c>Wms.Common.Infrastructure.Auth.InternalApi</c>).
/// </summary>
public static class IdentityRoutes
{
    public const string ModuleName = "Identity";
    public const string Prefix = "/api/v1/identity";
    public const string InternalPermissions = Prefix + "/internal/users/{userId}/permissions";
    public const string InternalTenant = Prefix + "/internal/tenants/{tenantId}";

    /// <summary>Resolves (and provisions) the <c>iam_user</c> row behind a bearer token.</summary>
    public const string InternalPrincipal = Prefix + "/internal/principals/resolve";
}
