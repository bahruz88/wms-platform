using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;

namespace Wms.Host.Migrator;

/// <summary>
/// Tenant / user / clock the seeder runs as. The design-time stubs report <c>HasTenant = false</c>, which would make
/// every global query filter evaluate <c>tenant_id = 0</c> and hide the rows the seeder needs to read back for its
/// idempotency checks — so seeding gets a real tenant instead.
/// </summary>
public sealed class SeedContext(uint tenantId, uint userId) : ITenantContext, ICurrentUser, IClock
{
    public const uint DefaultTenantId = 1;

    /// <summary>Written into <c>created_by</c> / <c>posted_by</c>; matches the dev <c>admin</c> user.</summary>
    public const uint DefaultUserId = 1;

    public uint TenantId { get; } = tenantId;

    public bool HasTenant => true;

    public bool IsAuthenticated => true;

    public uint UserId { get; } = userId;

    public string ExternalId => "seeder";

    public string Username => "seeder";

    public string FullName => "Seeder";

    public IReadOnlyCollection<string> Roles => ["ADMIN"];

    public IReadOnlyCollection<string> Permissions => ["*"];

    /// <summary>The seeder writes for every location, so it is not location-scoped.</summary>
    public LocationScope LocationScope => LocationScope.Unrestricted;

    public IReadOnlyCollection<uint> LocationIds => [];

    public DateTimeOffset UtcNow => DateTimeOffset.UtcNow;

    public bool HasPermission(string permission) => true;
}
