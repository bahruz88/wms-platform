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

    public void Deactivate() => IsActive = false;
}
