using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Security;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain.Entities;

namespace Wms.Inventory.UnitTests;

/// <summary>Minimal in-memory doubles for the handler-level tests (no EF, no database).</summary>
internal sealed class FakeTenantContext(uint tenantId = 1) : ITenantContext
{
    public uint TenantId { get; } = tenantId;

    public bool HasTenant => TenantId != 0;
}

internal sealed class FakeCurrentUser(uint userId, params string[] permissions) : ICurrentUser
{
    public bool IsAuthenticated => true;

    public uint UserId { get; } = userId;

    public string ExternalId => $"sub-{UserId}";

    public string Username => $"user{UserId}";

    public string FullName => $"User {UserId}";

    public IReadOnlyCollection<string> Roles => ["WAREHOUSE_KEEPER"];

    public IReadOnlyCollection<string> Permissions { get; } = permissions;

    public LocationScope LocationScope { get; set; } = LocationScope.Unrestricted;

    public IReadOnlyCollection<uint> LocationIds => LocationScope.LocationIds;

    public bool HasPermission(string permission) => Permissions.Contains(permission, StringComparer.OrdinalIgnoreCase);
}

internal sealed class FakeClock(DateTimeOffset? now = null) : IClock
{
    public DateTimeOffset UtcNow { get; } = now ?? new DateTimeOffset(2026, 9, 22, 8, 0, 0, TimeSpan.Zero);
}

internal sealed class FakeAuditTrail : IAuditTrail
{
    public List<(string EntityType, long EntityId, AuditAction Action)> Entries { get; } = [];

    public void Record(string entityType, long entityId, AuditAction action, object? changes = null) =>
        Entries.Add((entityType, entityId, action));
}

internal sealed class FakeOutbox : IIntegrationEventOutbox
{
    public List<object> Events { get; } = [];

    public void Enqueue(Wms.Common.Contracts.IntegrationEvent integrationEvent) => Events.Add(integrationEvent);
}

internal sealed class FakeInventoryUnitOfWork : IInventoryUnitOfWork
{
    public FakeAuditTrail AuditTrail { get; } = new();

    public IIntegrationEventOutbox Outbox { get; } = new FakeOutbox();

    public IAuditTrail Audit => AuditTrail;

    public int SaveCount { get; private set; }

    public bool Committed { get; private set; }

    public Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken) =>
        Task.FromResult<IUnitOfWorkTransaction>(new FakeTransaction(this));

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken)
    {
        SaveCount++;
        return Task.FromResult(0);
    }

    private sealed class FakeTransaction(FakeInventoryUnitOfWork owner) : IUnitOfWorkTransaction
    {
        public Task CommitAsync(CancellationToken cancellationToken)
        {
            owner.Committed = true;
            return Task.CompletedTask;
        }

        public Task RollbackAsync(CancellationToken cancellationToken) => Task.CompletedTask;

        public ValueTask DisposeAsync() => ValueTask.CompletedTask;
    }
}

internal sealed class FakeStockCountRepository(StockCount? count) : IStockCountRepository
{
    public Task<StockCount?> GetAsync(long countId, CancellationToken cancellationToken) => Task.FromResult(count);

    public Task<StockCount?> FindOpenForLocationAsync(uint tenantId, uint locationId, CancellationToken cancellationToken) =>
        Task.FromResult<StockCount?>(null);

    public void Add(StockCount stockCount)
    {
    }
}

internal sealed class FakeWasteRepository(Waste? waste) : IWasteRepository
{
    public Task<Waste?> GetAsync(long wasteId, CancellationToken cancellationToken) => Task.FromResult(waste);

    public void Add(Waste document)
    {
    }
}
