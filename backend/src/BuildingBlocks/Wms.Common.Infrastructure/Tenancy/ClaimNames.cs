namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>Keycloak token claims (CONVENTIONS.md, realm <c>wms</c>).</summary>
public static class ClaimNames
{
    public const string TenantId = "tenant_id";
    public const string Subject = "sub";
    public const string PreferredUsername = "preferred_username";
    public const string Name = "name";
    public const string Email = "email";
    public const string RealmAccess = "realm_access";
    public const string Roles = "roles";
}
