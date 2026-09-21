using Wms.Common.Domain;

namespace Wms.Identity.Domain.Entities;

/// <summary><c>iam_role</c> (spec §7).</summary>
public sealed class Role : Entity<uint>, ITenantEntity
{
    private Role()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public bool IsSystem { get; private set; }

    public static Role Create(uint tenantId, string code, string name, bool isSystem = false)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(code);
        ArgumentException.ThrowIfNullOrWhiteSpace(name);
        return new Role { TenantId = tenantId, Code = code.Trim().ToUpperInvariant(), Name = name.Trim(), IsSystem = isSystem };
    }

    /// <summary>A system role keeps its code and name; only its permission set may be curated.</summary>
    public Result Rename(string name)
    {
        if (IsSystem)
        {
            return IdentityErrors.SystemRoleImmutable(Code);
        }

        var normalized = (name ?? string.Empty).Trim();
        if (normalized.Length is 0 or > 120)
        {
            return IdentityErrors.InvalidRole("name must be 1..120 characters.");
        }

        Name = normalized;
        return Result.Success();
    }
}

/// <summary><c>iam_permission</c> — a global catalogue shared by all tenants (spec §7).</summary>
public sealed class Permission : Entity<ushort>
{
    private Permission()
    {
    }

    public string Code { get; private set; } = string.Empty;

    public string Module { get; private set; } = string.Empty;

    public static Permission Create(string code, string module)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(code);
        ArgumentException.ThrowIfNullOrWhiteSpace(module);
        return new Permission { Code = code.Trim(), Module = module.Trim() };
    }
}

/// <summary><c>iam_role_permission</c>.</summary>
public sealed class RolePermission
{
    private RolePermission()
    {
    }

    public uint RoleId { get; private set; }

    public ushort PermissionId { get; private set; }

    public static RolePermission Create(uint roleId, ushort permissionId) =>
        new() { RoleId = roleId, PermissionId = permissionId };
}

/// <summary><c>iam_user_role</c>.</summary>
public sealed class UserRole
{
    private UserRole()
    {
    }

    public uint UserId { get; private set; }

    public uint RoleId { get; private set; }

    public static UserRole Create(uint userId, uint roleId) => new() { UserId = userId, RoleId = roleId };
}

/// <summary><c>iam_user_location</c> — which locations a branch user may see (spec §16).</summary>
public sealed class UserLocation
{
    private UserLocation()
    {
    }

    public uint UserId { get; private set; }

    public uint LocationId { get; private set; }

    public static UserLocation Create(uint userId, uint locationId) => new() { UserId = userId, LocationId = locationId };
}
