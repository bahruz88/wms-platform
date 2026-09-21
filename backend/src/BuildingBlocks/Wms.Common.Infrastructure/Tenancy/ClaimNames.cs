namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>Keycloak token claims (CONVENTIONS.md, realm <c>wms</c>).</summary>
public static class ClaimNames
{
    public const string TenantId = "tenant_id";
    public const string Subject = "sub";
    public const string PreferredUsername = "preferred_username";
    public const string RealmAccess = "realm_access";
    public const string Roles = "roles";
    public const string UserId = "user_id";
    public const string LocationIds = "location_ids";
    public const string Permissions = "permissions";
}
