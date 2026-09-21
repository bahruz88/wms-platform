namespace Wms.Identity.Contracts;

/// <summary>Internal (module-to-module) HTTP routes used when <c>ModuleTransport=Http</c>.</summary>
public static class IdentityRoutes
{
    public const string ModuleName = "Identity";
    public const string Prefix = "/api/v1/identity";
    public const string InternalPermissions = Prefix + "/internal/users/{userId}/permissions";
    public const string InternalTenant = Prefix + "/internal/tenants/{tenantId}";
}
