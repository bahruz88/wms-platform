using System.Globalization;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Wms.Common.Application.Abstractions;

namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>Principal read from Keycloak claims: <c>sub</c>, <c>preferred_username</c>, <c>realm_access.roles</c>, <c>tenant_id</c>.</summary>
public sealed class CurrentUser : ICurrentUser
{
    public const string SystemUsername = "system";

    private readonly ClaimsPrincipal? _principal;
    private readonly Lazy<IReadOnlyCollection<string>> _roles;
    private readonly Lazy<IReadOnlyCollection<uint>> _locationIds;
    private readonly Lazy<HashSet<string>> _explicitPermissions;

    public CurrentUser(IHttpContextAccessor httpContextAccessor)
    {
        ArgumentNullException.ThrowIfNull(httpContextAccessor);
        _principal = httpContextAccessor.HttpContext?.User;
        _roles = new Lazy<IReadOnlyCollection<string>>(ReadRoles);
        _locationIds = new Lazy<IReadOnlyCollection<uint>>(ReadLocationIds);
        _explicitPermissions = new Lazy<HashSet<string>>(ReadPermissions);
    }

    public bool IsAuthenticated => _principal?.Identity?.IsAuthenticated == true;

    public uint UserId =>
        uint.TryParse(Claim(ClaimNames.UserId), NumberStyles.None, CultureInfo.InvariantCulture, out var id) ? id : 0;

    public string ExternalId => Claim(ClaimNames.Subject) ?? string.Empty;

    public string Username => Claim(ClaimNames.PreferredUsername) ?? (IsAuthenticated ? ExternalId : SystemUsername);

    public IReadOnlyCollection<string> Roles => _roles.Value;

    public IReadOnlyCollection<uint> LocationIds => _locationIds.Value;

    public bool HasPermission(string permission)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(permission);
        if (!IsAuthenticated)
        {
            return false;
        }

        return _explicitPermissions.Value.Contains(permission) || RolePermissionMap.Allows(Roles, permission);
    }

    private string? Claim(string type) => _principal?.FindFirst(type)?.Value;

    private IEnumerable<string> ClaimValues(string type) =>
        _principal?.FindAll(type).Select(c => c.Value) ?? [];

    private IReadOnlyCollection<string> ReadRoles()
    {
        var roles = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var value in ClaimValues(ClaimNames.Roles).Concat(ClaimValues(ClaimTypes.Role)))
        {
            roles.Add(value);
        }

        foreach (var realmAccess in ClaimValues(ClaimNames.RealmAccess))
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

        return roles;
    }

    private IReadOnlyCollection<uint> ReadLocationIds()
    {
        var ids = new HashSet<uint>();
        foreach (var value in ClaimValues(ClaimNames.LocationIds))
        {
            foreach (var part in value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            {
                if (uint.TryParse(part, NumberStyles.None, CultureInfo.InvariantCulture, out var id))
                {
                    ids.Add(id);
                }
            }
        }

        return ids;
    }

    private HashSet<string> ReadPermissions()
    {
        var permissions = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var value in ClaimValues(ClaimNames.Permissions))
        {
            foreach (var part in value.Split([' ', ','], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            {
                permissions.Add(part);
            }
        }

        return permissions;
    }
}
