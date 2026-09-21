using Wms.Common.Domain;

namespace Wms.Identity.Domain.Entities;

/// <summary><c>iam_user</c> (spec §7). <c>external_id</c> is the Keycloak <c>sub</c> claim.</summary>
public sealed class User : AuditableAggregateRoot<uint>, ITenantEntity
{
    private readonly List<UserRole> _roles = [];
    private readonly List<UserLocation> _locations = [];

    private User()
    {
    }

    public uint TenantId { get; private set; }

    public string ExternalId { get; private set; } = string.Empty;

    public string Username { get; private set; } = string.Empty;

    public string FullName { get; private set; } = string.Empty;

    public string? Email { get; private set; }

    public string? Phone { get; private set; }

    public bool IsActive { get; private set; } = true;

    public IReadOnlyList<UserRole> Roles => _roles.AsReadOnly();

    public IReadOnlyList<UserLocation> Locations => _locations.AsReadOnly();

    public static Result<User> Create(uint tenantId, string externalId, string username, string fullName, string? email = null, string? phone = null)
    {
        var normalizedExternalId = (externalId ?? string.Empty).Trim();
        var normalizedUsername = (username ?? string.Empty).Trim();
        var normalizedFullName = (fullName ?? string.Empty).Trim();

        if (normalizedExternalId.Length is 0 or > 64)
        {
            return IdentityErrors.InvalidUser("external_id must be 1..64 characters.");
        }

        if (normalizedUsername.Length is 0 or > 100)
        {
            return IdentityErrors.InvalidUser("username must be 1..100 characters.");
        }

        if (normalizedFullName.Length is 0 or > 200)
        {
            return IdentityErrors.InvalidUser("full_name must be 1..200 characters.");
        }

        return new User
        {
            TenantId = tenantId,
            ExternalId = normalizedExternalId,
            Username = normalizedUsername,
            FullName = normalizedFullName,
            Email = email?.Trim(),
            Phone = phone?.Trim(),
        };
    }

    public void AssignRole(uint roleId)
    {
        if (_roles.Exists(r => r.RoleId == roleId))
        {
            return;
        }

        _roles.Add(UserRole.Create(Id, roleId));
    }

    public void GrantLocation(uint locationId)
    {
        if (_locations.Exists(l => l.LocationId == locationId))
        {
            return;
        }

        _locations.Add(UserLocation.Create(Id, locationId));
    }

    /// <summary><c>PUT /identity/users/{id}/roles</c> — replaces the whole <c>iam_user_role</c> set.</summary>
    public void ReplaceRoles(IEnumerable<uint> roleIds)
    {
        ArgumentNullException.ThrowIfNull(roleIds);
        _roles.Clear();
        foreach (var roleId in roleIds.Distinct())
        {
            _roles.Add(UserRole.Create(Id, roleId));
        }
    }

    /// <summary><c>PUT /identity/users/{id}/locations</c> — replaces the whole <c>iam_user_location</c> set.</summary>
    public void ReplaceLocations(IEnumerable<uint> locationIds)
    {
        ArgumentNullException.ThrowIfNull(locationIds);
        _locations.Clear();
        foreach (var locationId in locationIds.Distinct())
        {
            _locations.Add(UserLocation.Create(Id, locationId));
        }
    }

    public Result Update(string fullName, string? email, string? phone, bool isActive)
    {
        var normalizedFullName = (fullName ?? string.Empty).Trim();
        if (normalizedFullName.Length is 0 or > 200)
        {
            return IdentityErrors.InvalidUser("full_name must be 1..200 characters.");
        }

        if (email is { Length: > 200 })
        {
            return IdentityErrors.InvalidUser("email must be at most 200 characters.");
        }

        if (phone is { Length: > 32 })
        {
            return IdentityErrors.InvalidUser("phone must be at most 32 characters.");
        }

        FullName = normalizedFullName;
        Email = string.IsNullOrWhiteSpace(email) ? null : email.Trim();
        Phone = string.IsNullOrWhiteSpace(phone) ? null : phone.Trim();
        IsActive = isActive;
        return Result.Success();
    }

    /// <summary>Keeps the row in step with Keycloak when the token shows a renamed or re-mailed account.</summary>
    public bool SyncFromToken(string username, string fullName, string? email)
    {
        var changed = false;
        var normalizedUsername = (username ?? string.Empty).Trim();
        if (normalizedUsername.Length is > 0 and <= 100 && !string.Equals(Username, normalizedUsername, StringComparison.Ordinal))
        {
            Username = normalizedUsername;
            changed = true;
        }

        var normalizedFullName = (fullName ?? string.Empty).Trim();
        if (normalizedFullName.Length is > 0 and <= 200 && !string.Equals(FullName, normalizedFullName, StringComparison.Ordinal))
        {
            FullName = normalizedFullName;
            changed = true;
        }

        var normalizedEmail = string.IsNullOrWhiteSpace(email) ? null : email.Trim();
        if (normalizedEmail is { Length: <= 200 } && !string.Equals(Email, normalizedEmail, StringComparison.Ordinal))
        {
            Email = normalizedEmail;
            changed = true;
        }

        return changed;
    }

    /// <summary>
    /// Links a pre-provisioned row (seeded with the <see cref="UnclaimedExternalIdPrefix"/> placeholder) to the
    /// Keycloak subject that logs in with the matching username. This is what lets the operator prepare users,
    /// roles and location grants before anyone has ever signed in; Keycloak stays the authority for the
    /// username, so matching on it is exactly the intended link.
    /// </summary>
    public bool ClaimExternalId(string externalId)
    {
        if (!IsUnclaimed)
        {
            return false;
        }

        var normalized = (externalId ?? string.Empty).Trim();
        if (normalized.Length is 0 or > 64)
        {
            return false;
        }

        ExternalId = normalized;
        return true;
    }

    public const string UnclaimedExternalIdPrefix = "pending:";

    public bool IsUnclaimed => ExternalId.StartsWith(UnclaimedExternalIdPrefix, StringComparison.Ordinal);

    public void Deactivate() => IsActive = false;

    public void Activate() => IsActive = true;
}
