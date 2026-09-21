using Wms.Common.Domain;

namespace Wms.Identity.Domain;

public static class IdentityErrors
{
    public static Error TenantNotFound(uint tenantId) => new("TENANT_NOT_FOUND", $"Tenant {tenantId} was not found.", 404);

    public static Error UserNotFound(uint userId) => new("USER_NOT_FOUND", $"User {userId} was not found.", 404);

    public static Error InvalidUser(string reason) => new("INVALID_USER", reason, 422);

    public static Error InvalidTenant(string reason) => new("INVALID_TENANT", reason, 422);

    public static Error InvalidDelegation(string reason) => new("INVALID_DELEGATION", reason, 422);
}
