using System.Globalization;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;

namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>
/// Principal read from Keycloak claims (<c>sub</c>, <c>preferred_username</c>, <c>realm_access.roles</c>,
/// <c>tenant_id</c>) joined with the <c>iam</c> row that <see cref="PrincipalResolutionMiddleware"/> resolved.
/// </summary>
/// <remarks>
/// The token deliberately carries no internal identifiers. <see cref="UserId"/>, <see cref="Permissions"/> and
/// <see cref="LocationScope"/> all come from the database (<c>iam_user</c>, <c>iam_role_permission</c>,
/// <c>iam_user_location</c>), so revoking a role or a location takes effect without re-issuing tokens.
/// </remarks>
public sealed class CurrentUser : ICurrentUser
{
    public const string SystemUsername = "system";

    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly PrincipalContext _principalContext;
    private readonly ClaimsPrincipal? _principal;
    private readonly Lazy<IReadOnlyCollection<string>> _claimRoles;

    public CurrentUser(IHttpContextAccessor httpContextAccessor, PrincipalContext principalContext)
    {
        ArgumentNullException.ThrowIfNull(httpContextAccessor);
        ArgumentNullException.ThrowIfNull(principalContext);
        _httpContextAccessor = httpContextAccessor;
        _principalContext = principalContext;
        _principal = httpContextAccessor.HttpContext?.User;
        _claimRoles = new Lazy<IReadOnlyCollection<string>>(ReadClaimRoles);
    }

    public bool IsAuthenticated => _principal?.Identity?.IsAuthenticated == true;

    public uint UserId => _principalContext.Snapshot?.UserId ?? 0;

    public string ExternalId => Claim(ClaimNames.Subject) ?? _principalContext.Snapshot?.ExternalId ?? string.Empty;

    public string Username =>
        Claim(ClaimNames.PreferredUsername)
        ?? _principalContext.Snapshot?.Username
        ?? (IsAuthenticated ? ExternalId : SystemUsername);

    public string FullName => _principalContext.Snapshot?.FullName ?? Claim(ClaimNames.Name) ?? Username;

    /// <summary>Realm roles from the token, plus whatever <c>iam_user_role</c> adds on top of them.</summary>
    public IReadOnlyCollection<string> Roles
    {
        get
        {
            var snapshot = _principalContext.Snapshot;
            if (snapshot is null || snapshot.Roles.Count == 0)
            {
                return _claimRoles.Value;
            }

            var roles = new HashSet<string>(_claimRoles.Value, StringComparer.OrdinalIgnoreCase);
            foreach (var role in snapshot.Roles)
            {
                roles.Add(role);
            }

            return roles;
        }
    }

    public IReadOnlyCollection<string> Permissions =>
        _principalContext.Snapshot?.Permissions ?? (IReadOnlyCollection<string>)[];

    /// <summary>
    /// Fail-closed: a principal without <see cref="WmsPermissions.ViewAllLocations"/> sees exactly the
    /// locations of <c>iam_user_location</c>, and nothing when that list is empty. Only a context with no
    /// HTTP request at all (background jobs, the migrator's seeder) is treated as unrestricted.
    /// </summary>
    public LocationScope LocationScope
    {
        get
        {
            var snapshot = _principalContext.Snapshot;
            if (snapshot is null)
            {
                return _httpContextAccessor.HttpContext is null ? LocationScope.Unrestricted : LocationScope.Nothing;
            }

            return snapshot.Permissions.Contains(WmsPermissions.ViewAllLocations, StringComparer.OrdinalIgnoreCase)
                ? LocationScope.Unrestricted
                : LocationScope.RestrictedTo(snapshot.LocationIds);
        }
    }

    public IReadOnlyCollection<uint> LocationIds => _principalContext.Snapshot?.LocationIds ?? [];

    public bool HasPermission(string permission)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(permission);
        if (!IsAuthenticated)
        {
            return false;
        }

        var snapshot = _principalContext.Snapshot;
        if (snapshot is null)
        {
            return false;
        }

        foreach (var granted in snapshot.Permissions)
        {
            if (string.Equals(granted, permission, StringComparison.OrdinalIgnoreCase)
                || (granted.Contains('*', StringComparison.Ordinal) && RolePermissionMap.Matches(granted, permission)))
            {
                return true;
            }
        }

        return false;
    }

    private string? Claim(string type) => _principal?.FindFirst(type)?.Value;

    private IEnumerable<string> ClaimValues(string type) =>
        _principal?.FindAll(type).Select(c => c.Value) ?? [];

    private IReadOnlyCollection<string> ReadClaimRoles() => ReadRealmRoles(_principal);

    /// <summary>Realm roles as Keycloak spells them: flat <c>roles</c> claims plus the <c>realm_access</c> object.</summary>
    public static IReadOnlyList<string> ReadRealmRoles(ClaimsPrincipal? principal)
    {
        var roles = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (principal is null)
        {
            return [];
        }

        foreach (var value in principal.FindAll(ClaimNames.Roles).Select(c => c.Value)
                     .Concat(principal.FindAll(ClaimTypes.Role).Select(c => c.Value)))
        {
            roles.Add(value);
        }

        foreach (var realmAccess in principal.FindAll(ClaimNames.RealmAccess).Select(c => c.Value))
        {
            try
            {
                using var document = JsonDocument.Parse(realmAccess);
                if (document.RootElement.TryGetProperty(ClaimNames.Roles, out var array) && array.ValueKind == JsonValueKind.Array)
                {
                    foreach (var role in array.EnumerateArray())
                    {
                        if (role.ValueKind == JsonValueKind.String)
                        {
                            roles.Add(role.GetString()!);
                        }
                    }
                }
            }
            catch (JsonException)
            {
                // A malformed realm_access claim simply yields no roles.
            }
        }

        return [.. roles];
    }

    /// <summary>Reads the tenant id straight off the principal (same claim <see cref="TenantContext"/> uses).</summary>
    public static uint ReadTenantId(ClaimsPrincipal? principal)
    {
        var raw = principal?.FindFirst(ClaimNames.TenantId)?.Value;
        return uint.TryParse(raw, NumberStyles.None, CultureInfo.InvariantCulture, out var tenantId) ? tenantId : 0;
    }
}
