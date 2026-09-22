using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Testcontainers.MySql;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.DependencyInjection;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Security;
using Wms.Common.Infrastructure.Dispatching;
using Wms.Common.Infrastructure.Persistence;
using Wms.Identity.Contracts;
using Wms.Inventory.Infrastructure;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Infrastructure;
using Wms.MasterData.Infrastructure.Persistence;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Domain.Services;
using Wms.Procurement.Infrastructure;
using Wms.Procurement.Infrastructure.Persistence;
using Wms.Procurement.Infrastructure.Services;

namespace Wms.Procurement.IntegrationTests;

/// <summary>
/// Spec §17.2: a real MySQL 8.4 container, the real migrations and the real DI graph of the three modules a
/// purchase touches (MasterData -&gt; Procurement -&gt; Inventory). Only the ambient tenant/user/clock and the
/// approval directory — which normally come from the JWT and from <c>iam_*</c> — are supplied by the test.
/// </summary>
public sealed class ProcurementFixture : IAsyncLifetime
{
    public const string Image = "mysql:8.4";
    public const uint TenantId = 1;

    /// <summary>The four principals the approval tests switch between (<c>iam_user.id</c> stand-ins).</summary>
    public const uint TestBuyerId = 7;

    public const uint TestManagerId = 8;

    public const uint TestAdminId = 9;

    public const uint TestDeputyId = 10;

    private readonly MySqlContainer _container = new MySqlBuilder(Image)
        .WithDatabase("wms")
        .WithUsername("wms_app")
        .WithPassword("wms_app")
        .Build();

    private ServiceProvider? _provider;

    public string ConnectionString => _container.GetConnectionString();

    public TestTenantContext Tenant { get; } = new(TenantId);

    public TestCurrentUser User { get; } = new();

    public TestApprovalDirectory Directory { get; } = new();

    public TestClock Clock { get; } = new(new DateTimeOffset(2026, 9, 21, 9, 0, 0, TimeSpan.Zero));

    public IServiceProvider Services => _provider ?? throw new InvalidOperationException("The fixture is not initialised.");

    public async Task InitializeAsync()
    {
        await _container.StartAsync().ConfigureAwait(false);

        await using (var common = BuildCommon())
        {
            await common.Database.MigrateAsync().ConfigureAwait(false);
        }

        await MigrateAsync<MasterDataDbContext>((o, t, u, c) => new MasterDataDbContext(o, t, u, c), MasterDataDbContext.MigrationsHistoryTable).ConfigureAwait(false);
        await MigrateAsync<InventoryDbContext>((o, t, u, c) => new InventoryDbContext(o, t, u, c), InventoryDbContext.MigrationsHistoryTable).ConfigureAwait(false);
        await MigrateAsync<ProcurementDbContext>((o, t, u, c) => new ProcurementDbContext(o, t, u, c), ProcurementDbContext.MigrationsHistoryTable).ConfigureAwait(false);

        var services = new ServiceCollection();
        services.AddLogging(b => b.SetMinimumLevel(LogLevel.Warning));
        services.AddSingleton<ITenantContext>(Tenant);
        services.AddSingleton<ICurrentUser>(User);
        services.AddSingleton<IClock>(Clock);
        services.AddSingleton<IApprovalDirectory>(Directory);
        services.AddSingleton<IProcurementSettings>(new FixedProcurementSettings(SplitCheckWindow.DefaultWindowDays));

        // MasterData reads iam_tenant for the base currency (its one allowed cross-module dependency);
        // Identity is not part of this fixture, so the tenant row is supplied directly.
        services.AddSingleton<ITenantDirectory>(new TestTenantDirectory(TenantId));
        services.AddScoped<IDispatcher, Dispatcher>();

        services.AddMasterDataPersistence(ConnectionString);
        services.AddMasterDataServices();
        services.AddInventoryPersistence(ConnectionString);
        services.AddInventoryServices();
        services.AddProcurementPersistence(ConnectionString);
        services.AddProcurementServices();
        services.AddProcurementApplication();
        services.AddWmsHandlersFromAssembly(typeof(ProcurementPermissions).Assembly);

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

    public MasterDataDbContext MasterData() =>
        Create<MasterDataDbContext>((o, t, u, c) => new MasterDataDbContext(o, t, u, c), MasterDataDbContext.MigrationsHistoryTable);

    public InventoryDbContext Inventory() =>
        Create<InventoryDbContext>((o, t, u, c) => new InventoryDbContext(o, t, u, c), InventoryDbContext.MigrationsHistoryTable);

    public ProcurementDbContext Procurement() =>
        Create<ProcurementDbContext>((o, t, u, c) => new ProcurementDbContext(o, t, u, c), ProcurementDbContext.MigrationsHistoryTable);

    /// <summary>
    /// Approval rules are tenant-wide, so a test that needs its own bands starts from an empty
    /// <c>proc_approval_rule</c>; the tests of one collection never run in parallel.
    /// </summary>
    public async Task ResetApprovalRulesAsync(CancellationToken cancellationToken)
    {
        await using var procurement = Procurement();
        await procurement.ApprovalRules.ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
    }

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

    private CommonDbContext BuildCommon()
    {
        var builder = new DbContextOptionsBuilder<CommonDbContext>();
        builder.UseWmsMySql(ConnectionString, CommonDbContext.MigrationsHistoryTable);
        return new CommonDbContext(builder.Options);
    }
}

[CollectionDefinition(Name)]
public sealed class ProcurementCollection : ICollectionFixture<ProcurementFixture>
{
    public const string Name = "procurement-mysql";
}

public sealed class TestTenantContext(uint tenantId) : ITenantContext
{
    public uint TenantId => tenantId;

    public bool HasTenant => tenantId != 0;
}

/// <summary>A switchable principal: the tests change who is acting between the buyer and the approver.</summary>
public sealed class TestCurrentUser : ICurrentUser
{
    public bool IsAuthenticated => true;

    public uint UserId { get; private set; } = ProcurementFixture.TestBuyerId;

    public string ExternalId => $"integration-test-{UserId}";

    public string Username => $"user{UserId}";

    public string FullName => $"Integration test user {UserId}";

    public IReadOnlyCollection<string> Roles { get; private set; } = ["PROCUREMENT_OFFICER"];

    /// <summary>The fixture's principal is a head-office buyer: every permission, every location.</summary>
    public IReadOnlyCollection<string> Permissions => ["*"];

    public LocationScope LocationScope => LocationScope.Unrestricted;

    public IReadOnlyCollection<uint> LocationIds => [];

    public bool HasPermission(string permission) => true;

    public void ActAs(uint userId, params string[] roles)
    {
        UserId = userId;
        Roles = roles.Length == 0 ? [] : roles;
    }
}

/// <summary>Stand-in for the Identity-backed directory: role membership and in-force <c>iam_delegation</c> rows.</summary>
public sealed class TestApprovalDirectory : IApprovalDirectory
{
    public Dictionary<uint, IReadOnlyCollection<string>> RolesByUser { get; } = new();

    public List<ActiveDelegation> Delegations { get; } = [];

    public Task<IReadOnlyCollection<string>> GetRoleCodesAsync(uint userId, CancellationToken cancellationToken) =>
        Task.FromResult(RolesByUser.TryGetValue(userId, out var roles) ? roles : []);

    public Task<IReadOnlyList<ActiveDelegation>> GetDelegationsToAsync(uint toUserId, DateOnly onDate, CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<ActiveDelegation>>(Delegations.Where(d => d.ToUserId == toUserId).ToList());

    public void Reset()
    {
        RolesByUser.Clear();
        Delegations.Clear();
    }
}

public sealed class TestClock(DateTimeOffset now) : IClock
{
    public DateTimeOffset UtcNow { get; set; } = now;
}

/// <summary>Stands in for <c>iam_tenant</c>; MasterData resolves the base currency through it (spec §7).</summary>
public sealed class TestTenantDirectory(uint tenantId) : ITenantDirectory
{
    public Task<TenantDto?> GetAsync(uint id, CancellationToken cancellationToken) =>
        Task.FromResult<TenantDto?>(new TenantDto(tenantId, "T1", "Test tenant", "AZN", "Asia/Baku", "az-AZ", true));
}
