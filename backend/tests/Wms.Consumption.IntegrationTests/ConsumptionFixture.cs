using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Testcontainers.MySql;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.DependencyInjection;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Dispatching;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Application;
using Wms.Consumption.Infrastructure;
using Wms.Consumption.Infrastructure.Persistence;
using Wms.Inventory.Infrastructure;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Infrastructure;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.Consumption.IntegrationTests;

/// <summary>
/// Spec §17.2: a real MySQL 8.4 container, the real migrations and the real DI graph of the three modules
/// involved in a consumption cycle (MasterData -&gt; Consumption -&gt; Inventory). Nothing is faked except the
/// tenant/user/clock ambient context, which normally comes from the JWT.
/// </summary>
public sealed class ConsumptionFixture : IAsyncLifetime
{
    public const string Image = "mysql:8.4";
    public const uint TenantId = 1;

    private readonly MySqlContainer _container = new MySqlBuilder(Image)
        .WithDatabase("wms")
        .WithUsername("wms_app")
        .WithPassword("wms_app")
        .Build();

    private ServiceProvider? _provider;

    public string ConnectionString => _container.GetConnectionString();

    public TestTenantContext Tenant { get; } = new(TenantId);

    public TestCurrentUser User { get; } = new(userId: 7);

    public TestClock Clock { get; } = new(new DateTimeOffset(2026, 9, 21, 3, 0, 0, TimeSpan.Zero));

    public IServiceProvider Services => _provider ?? throw new InvalidOperationException("The fixture is not initialised.");

    public async Task InitializeAsync()
    {
        await _container.StartAsync().ConfigureAwait(false);

        // common_outbox / common_audit_log first: the module contexts map them but exclude them from their migrations.
        await using (var common = Build<CommonDbContext>(o => new CommonDbContext(o), CommonDbContext.MigrationsHistoryTable))
        {
            await common.Database.MigrateAsync().ConfigureAwait(false);
        }

        await MigrateAsync<MasterDataDbContext>((o, t, u, c) => new MasterDataDbContext(o, t, u, c), MasterDataDbContext.MigrationsHistoryTable).ConfigureAwait(false);
        await MigrateAsync<InventoryDbContext>((o, t, u, c) => new InventoryDbContext(o, t, u, c), InventoryDbContext.MigrationsHistoryTable).ConfigureAwait(false);
        await MigrateAsync<ConsumptionDbContext>((o, t, u, c) => new ConsumptionDbContext(o, t, u, c), ConsumptionDbContext.MigrationsHistoryTable).ConfigureAwait(false);

        var services = new ServiceCollection();
        services.AddLogging(b => b.SetMinimumLevel(LogLevel.Warning));
        services.AddSingleton<ITenantContext>(Tenant);
        services.AddSingleton<ICurrentUser>(User);
        services.AddSingleton<IClock>(Clock);
        services.AddScoped<IDispatcher, Dispatcher>();

        services.AddMasterDataPersistence(ConnectionString);
        services.AddMasterDataServices();
        services.AddInventoryPersistence(ConnectionString);
        services.AddInventoryServices();
        services.AddConsumptionPersistence(ConnectionString);
        services.AddConsumptionServices();
        services.AddWmsHandlersFromAssembly(typeof(ConsumptionPermissions).Assembly);

        _provider = services.BuildServiceProvider();
    }

    public async Task DisposeAsync()
    {
        if (_provider is not null)
        {
            await _provider.DisposeAsync().ConfigureAwait(false);
        }

        await _container.DisposeAsync().ConfigureAwait(false);
    }

    public MasterDataDbContext MasterData() => Create<MasterDataDbContext>((o, t, u, c) => new MasterDataDbContext(o, t, u, c), MasterDataDbContext.MigrationsHistoryTable);

    public InventoryDbContext Inventory() => Create<InventoryDbContext>((o, t, u, c) => new InventoryDbContext(o, t, u, c), InventoryDbContext.MigrationsHistoryTable);

    public ConsumptionDbContext Consumption() => Create<ConsumptionDbContext>((o, t, u, c) => new ConsumptionDbContext(o, t, u, c), ConsumptionDbContext.MigrationsHistoryTable);

    private async Task MigrateAsync<TContext>(
        Func<DbContextOptions<TContext>, ITenantContext, ICurrentUser, IClock, TContext> factory,
        string historyTable)
        where TContext : DbContext
    {
        await using var context = Create(factory, historyTable);
        await context.Database.MigrateAsync().ConfigureAwait(false);
    }

    private TContext Create<TContext>(
        Func<DbContextOptions<TContext>, ITenantContext, ICurrentUser, IClock, TContext> factory,
        string historyTable)
        where TContext : DbContext
    {
        var builder = new DbContextOptionsBuilder<TContext>();
        builder.UseWmsMySql(ConnectionString, historyTable);
        return factory(builder.Options, Tenant, User, Clock);
    }

    private TContext Build<TContext>(Func<DbContextOptions<TContext>, TContext> factory, string historyTable)
        where TContext : DbContext
    {
        var builder = new DbContextOptionsBuilder<TContext>();
        builder.UseWmsMySql(ConnectionString, historyTable);
        return factory(builder.Options);
    }
}

[CollectionDefinition(Name)]
public sealed class ConsumptionCollection : ICollectionFixture<ConsumptionFixture>
{
    public const string Name = "consumption-mysql";
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
