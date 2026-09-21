namespace Wms.Identity.Application.Dtos;

/// <summary><c>AuditFields</c> of common.v1.yaml (spec §6.2).</summary>
public sealed record AuditFieldsDto(
    DateTimeOffset CreatedAt,
    uint CreatedBy,
    DateTimeOffset? UpdatedAt,
    uint? UpdatedBy,
    uint RowVersion);

/// <summary><c>Tenant</c> of identity.v1.yaml.</summary>
public sealed record TenantDetailDto(
    uint Id,
    string Code,
    string Name,
    string DefaultCurrency,
    string Timezone,
    string Locale,
    bool IsActive);

/// <summary><c>UserSummary</c> of identity.v1.yaml.</summary>
public sealed record UserSummaryDto(uint Id, string Username, string FullName, string? Email, bool IsActive);

/// <summary><c>RoleSummary</c> of identity.v1.yaml.</summary>
public sealed record RoleSummaryDto(uint Id, string Code, string Name, bool IsSystem);

/// <summary><c>Role</c> of identity.v1.yaml — summary plus the effective permission codes.</summary>
public sealed record RoleDto(uint Id, string Code, string Name, bool IsSystem, IReadOnlyList<string> Permissions);

/// <summary><c>Permission</c> of identity.v1.yaml.</summary>
public sealed record PermissionDto(ushort Id, string Code, string Module, string? Description, bool IsCritical);

/// <summary><c>User</c> of identity.v1.yaml.</summary>
public sealed record UserDetailDto(
    uint Id,
    string ExternalId,
    string Username,
    string FullName,
    string? Email,
    string? Phone,
    bool IsActive,
    IReadOnlyList<RoleSummaryDto> Roles,
    IReadOnlyList<uint> LocationIds,
    AuditFieldsDto Audit);

/// <summary><c>Delegation</c> of identity.v1.yaml.</summary>
public sealed record DelegationDto(
    uint Id,
    UserSummaryDto FromUser,
    UserSummaryDto ToUser,
    DateOnly ValidFrom,
    DateOnly ValidTo,
    string? Reason,
    bool IsActiveToday,
    DateTimeOffset CreatedAt,
    uint CreatedBy);

/// <summary><c>Me</c> of identity.v1.yaml — what both clients bootstrap from.</summary>
public sealed record MeDto(
    UserSummaryDto User,
    TenantDetailDto Tenant,
    IReadOnlyList<string> Roles,
    IReadOnlyList<string> Permissions,
    IReadOnlyList<uint> LocationIds,
    bool CanViewCost,
    IReadOnlyList<DelegationDto> ActiveDelegations);
