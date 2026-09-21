using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;

namespace Wms.Common.Infrastructure.Persistence;

/// <summary>Stub tenant/user/clock used by <c>IDesignTimeDbContextFactory</c> implementations (migrations scaffolding only).</summary>
public static class DesignTimeContext
{
    public static ITenantContext Tenant { get; } = new StubTenantContext();

    public static ICurrentUser User { get; } = new StubCurrentUser();

    public static IClock Clock { get; } = new StubClock();

    private sealed class StubTenantContext : ITenantContext
    {
        public uint TenantId => 0;

        public bool HasTenant => false;
    }

    private sealed class StubCurrentUser : ICurrentUser
    {
        public bool IsAuthenticated => false;

        public uint UserId => 0;

        public string ExternalId => string.Empty;

        public string Username => "design-time";

        public string FullName => "design-time";

        public IReadOnlyCollection<string> Roles => [];

        public IReadOnlyCollection<string> Permissions => [];

        public LocationScope LocationScope => LocationScope.Unrestricted;

        public IReadOnlyCollection<uint> LocationIds => [];

        public bool HasPermission(string permission) => false;
    }

    private sealed class StubClock : IClock
    {
        public DateTimeOffset UtcNow => DateTimeOffset.UtcNow;
    }
}
