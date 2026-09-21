using Microsoft.EntityFrameworkCore;
using Testcontainers.MySql;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.IntegrationTests;

/// <summary>
/// Spec §17.2 / §3: a real MySQL 8.4 LTS container — an in-memory provider cannot reproduce
/// <c>SELECT ... FOR UPDATE</c>, DECIMAL semantics or the ledger behaviour.
/// </summary>
public sealed class MySqlFixture : IAsyncLifetime
{
    public const string Image = "mysql:8.4";

    private readonly MySqlContainer _container = new MySqlBuilder(Image)
        .WithDatabase("wms")
        .WithUsername("wms_app")
        .WithPassword("wms_app")
        .Build();

    public string ConnectionString => _container.GetConnectionString();

    public TestTenantContext Tenant { get; } = new(tenantId: 1);

    public TestCurrentUser User { get; } = new(userId: 7);

    public TestClock Clock { get; } = new(new DateTimeOffset(2026, 9, 21, 10, 0, 0, TimeSpan.Zero));

    public async Task InitializeAsync()
    {
        await _container.StartAsync().ConfigureAwait(false);

        // The real migrations, not EnsureCreated: this is the only place where the hand-written DDL of the
        // Inventory initial migration (inv_movement PARTITION BY RANGE, spec §9.4) is executed against a real
        // MySQL, so a broken migration fails the test suite instead of only the deployment.
        // CommonDbContext first - it owns common_outbox / common_audit_log, which the module contexts map but
        // deliberately exclude from their own migrations.
        await using (var common = CreateCommonContext())
        {
            await common.Database.MigrateAsync().ConfigureAwait(false);
        }

        await using var db = CreateContext();
        await db.Database.MigrateAsync().ConfigureAwait(false);
    }

    public async Task DisposeAsync()
    {
        await _container.DisposeAsync().ConfigureAwait(false);
    }

    public CommonDbContext CreateCommonContext()
    {
        var builder = new DbContextOptionsBuilder<CommonDbContext>();
        builder.UseWmsMySql(ConnectionString, CommonDbContext.MigrationsHistoryTable);
        return new CommonDbContext(builder.Options);
    }

    public InventoryDbContext CreateContext()
    {
        var builder = new DbContextOptionsBuilder<InventoryDbContext>();
        builder.UseWmsMySql(ConnectionString, InventoryDbContext.MigrationsHistoryTable);
        return new InventoryDbContext(builder.Options, Tenant, User, Clock);
    }
}

[CollectionDefinition(Name)]
public sealed class MySqlCollection : ICollectionFixture<MySqlFixture>
{
    public const string Name = "mysql";
}

public sealed class TestTenantContext(uint tenantId) : ITenantContext
{
    public uint TenantId => tenantId;

    public bool HasTenant => tenantId != 0;
}

public sealed class TestCurrentUser(uint userId) : ICurrentUser
{
    public bool IsAuthenticated => true;

    public uint UserId => userId;

    public string ExternalId => "integration-test";

    public string Username => "integration-test";

    public IReadOnlyCollection<string> Roles => ["ADMIN"];

    public IReadOnlyCollection<uint> LocationIds => [];

    public bool HasPermission(string permission) => true;
}

public sealed class TestClock(DateTimeOffset now) : IClock
{
    public DateTimeOffset UtcNow { get; set; } = now;
}
