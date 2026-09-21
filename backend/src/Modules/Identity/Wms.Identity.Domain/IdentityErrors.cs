using Wms.Common.Domain;

namespace Wms.Identity.Domain;

public static class IdentityErrors
{
    public static Error TenantNotFound(uint tenantId) => new("TENANT_NOT_FOUND", $"Tenant {tenantId} was not found.", 404);

    public static Error UserNotFound(uint userId) => new("USER_NOT_FOUND", $"User {userId} was not found.", 404);

    public static Error RoleNotFound(uint roleId) => new("ROLE_NOT_FOUND", $"Role {roleId} was not found.", 404);

    public static Error DelegationNotFound(uint delegationId) =>
        new("DELEGATION_NOT_FOUND", $"Delegation {delegationId} was not found.", 404);

    public static Error InvalidUser(string reason) => new("INVALID_USER", reason, 422);

    public static Error InvalidTenant(string reason) => new("INVALID_TENANT", reason, 422);

    public static Error InvalidDelegation(string reason) => new("INVALID_DELEGATION", reason, 422);

    public static Error InvalidRole(string reason) => new("INVALID_ROLE", reason, 422);

    public static Error UserAlreadyExists(string field, string value) =>
        new("USER_ALREADY_EXISTS", $"A user with {field} '{value}' already exists in this tenant.", 409);

    public static Error RoleAlreadyExists(string code) =>
        new("ROLE_ALREADY_EXISTS", $"A role with code '{code}' already exists in this tenant.", 409);

    public static Error UnknownPermission(IEnumerable<string> codes) =>
        new("UNKNOWN_PERMISSION", $"Unknown permission code(s): {string.Join(", ", codes)}.", 422);

    /// <summary>Spec §7.1 / TOR §3.1, §40 — the warehouse keeper must never see cost.</summary>
    public static Error SegregationOfDuties(string reason) => new("SEGREGATION_OF_DUTIES", reason, 422);

    public static Error SystemRoleImmutable(string code) =>
        new("SYSTEM_ROLE_IMMUTABLE", $"'{code}' is a system role; its code and name cannot be changed.", 422);

    public static Error VirtualLocationNotGrantable(uint locationId) =>
        new("VIRTUAL_LOCATION_NOT_GRANTABLE", $"Location {locationId} is virtual and cannot be granted to a user.", 422);

    public static Error DelegationOverlap() =>
        new("DELEGATION_OVERLAP", "An active delegation for the same user already covers this period.", 422);
}
