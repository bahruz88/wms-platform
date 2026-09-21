using System.Linq.Expressions;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Contracts;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Audit;
using Wms.Common.Infrastructure.Outbox;

namespace Wms.Common.Infrastructure.Persistence;

/// <summary>
/// Base DbContext of every module (spec §5, §6, §12.9, §14.1):
/// snake_case names with the module table prefix, DECIMAL(18,4)/DATETIME(3) conventions, automatic
/// tenant + soft-delete query filters, audit/row_version stamping and outbox writing inside SaveChanges.
/// </summary>
public abstract class ModuleDbContext : DbContext, IIntegrationEventOutbox, IAuditTrail
{
    private readonly ITenantContext _tenantContext;
    private readonly ICurrentUser _currentUser;
    private readonly IClock _clock;
    private readonly List<OutboxMessage> _pendingIntegrationEvents = [];

    protected ModuleDbContext(DbContextOptions options, ITenantContext tenantContext, ICurrentUser currentUser, IClock clock)
        : base(options)
    {
        _tenantContext = tenantContext ?? throw new ArgumentNullException(nameof(tenantContext));
        _currentUser = currentUser ?? throw new ArgumentNullException(nameof(currentUser));
        _clock = clock ?? throw new ArgumentNullException(nameof(clock));
    }

    /// <summary>Table prefix of the module schema, e.g. <c>inv_</c> (CONVENTIONS.md).</summary>
    public abstract string TablePrefix { get; }

    /// <summary>Referenced by the generated tenant query filters; evaluated per query, per context instance.</summary>
    public uint CurrentTenantId => _tenantContext.TenantId;

    public DbSet<OutboxMessage> Outbox => Set<OutboxMessage>();

    public DbSet<AuditLogEntry> AuditLog => Set<AuditLogEntry>();

    public static void ApplyTypeConventions(ModelConfigurationBuilder configurationBuilder)
    {
        ArgumentNullException.ThrowIfNull(configurationBuilder);
        configurationBuilder.Properties<decimal>().HavePrecision(18, 4);
        configurationBuilder.Properties<DateTimeOffset>().HavePrecision(3);
        configurationBuilder.Properties<DateTime>().HavePrecision(3);
    }

    public void Enqueue(IntegrationEvent integrationEvent)
    {
        ArgumentNullException.ThrowIfNull(integrationEvent);
        _pendingIntegrationEvents.Add(OutboxMessage.Create(
            integrationEvent.TenantId,
            integrationEvent.EventType,
            OutboxJson.Serialize(integrationEvent),
            integrationEvent.OccurredAt));
    }

    public void Record(string entityType, long entityId, AuditAction action, object? changes = null)
    {
        AuditLog.Add(AuditLogEntry.Create(
            CurrentTenantId,
            entityType,
            entityId,
            action,
            changes is null ? null : OutboxJson.Serialize(changes),
            _currentUser.UserId,
            ipAddress: null,
            _clock.UtcNow));
    }

    public override int SaveChanges(bool acceptAllChangesOnSuccess) =>
        throw new NotSupportedException("Synchronous SaveChanges is disabled; use SaveChangesAsync with a CancellationToken.");

    public override async Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
    {
        StampEntries();

        var ownsTransaction = Database.CurrentTransaction is null;
        var transaction = ownsTransaction ? await Database.BeginTransactionAsync(cancellationToken).ConfigureAwait(false) : null;
        try
        {
            var written = await base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken).ConfigureAwait(false);

            // Domain events are drained after the first save so database-generated ids are available in payloads.
            var outboxRows = DrainDomainEvents();
            outboxRows.AddRange(_pendingIntegrationEvents);
            _pendingIntegrationEvents.Clear();
            if (outboxRows.Count > 0)
            {
                Outbox.AddRange(outboxRows);
                written += await base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken).ConfigureAwait(false);
            }

            if (transaction is not null)
            {
                await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
            }

            return written;
        }
        finally
        {
            if (transaction is not null)
            {
                await transaction.DisposeAsync().ConfigureAwait(false);
            }
        }
    }

    protected abstract void ConfigureModule(ModelBuilder modelBuilder);

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        ArgumentNullException.ThrowIfNull(optionsBuilder);
        optionsBuilder.UseSnakeCaseNamingConvention();
    }

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        ApplyTypeConventions(configurationBuilder);
    }

    protected sealed override void OnModelCreating(ModelBuilder modelBuilder)
    {
        ArgumentNullException.ThrowIfNull(modelBuilder);
        base.OnModelCreating(modelBuilder);

        ConfigureModule(modelBuilder);
        CommonTables.Configure(modelBuilder, excludeFromMigrations: true);
        ApplyTablePrefix(modelBuilder);
        ApplyMandatoryColumnDefaults(modelBuilder);
        ApplyQueryFilters(modelBuilder);
    }

    private void ApplyTablePrefix(ModelBuilder modelBuilder)
    {
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            if (entityType.IsOwned() || entityType.BaseType is not null)
            {
                continue;
            }

            var tableName = entityType.GetTableName();
            if (tableName is null
                || tableName.StartsWith(CommonTables.Prefix, StringComparison.Ordinal)
                || tableName.StartsWith(TablePrefix, StringComparison.Ordinal))
            {
                continue;
            }

            entityType.SetTableName(TablePrefix + tableName);
        }
    }

    /// <summary>
    /// Spec §6.2 mandatory columns: <c>row_version INT UNSIGNED NOT NULL DEFAULT 1</c> and
    /// <c>is_deleted TINYINT(1) NOT NULL DEFAULT 0</c>, plus the optimistic-concurrency token on row_version.
    /// <c>ValueGeneratedNever()</c> after <c>HasDefaultValue()</c> keeps EF writing the in-memory value on INSERT
    /// (no extra round-trip to read a store-generated value); the DDL default only backstops rows written by
    /// data-migration scripts and other tooling that does not go through the domain factories.
    /// </summary>
    private static void ApplyMandatoryColumnDefaults(ModelBuilder modelBuilder)
    {
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            if (entityType.BaseType is not null)
            {
                continue;
            }

            if (typeof(IVersioned).IsAssignableFrom(entityType.ClrType))
            {
                modelBuilder.Entity(entityType.ClrType)
                    .Property(nameof(IVersioned.RowVersion))
                    .IsConcurrencyToken()
                    .HasDefaultValue(1u)
                    .ValueGeneratedNever();
            }

            if (typeof(ISoftDeletable).IsAssignableFrom(entityType.ClrType))
            {
                modelBuilder.Entity(entityType.ClrType)
                    .Property(nameof(ISoftDeletable.IsDeleted))
                    .HasDefaultValue(false)
                    .ValueGeneratedNever();
            }
        }
    }

    /// <summary>Spec §12.9: <c>tenant_id = current tenant</c> for every <see cref="ITenantEntity"/>, plus <c>is_deleted = 0</c> for <see cref="ISoftDeletable"/>.</summary>
    private void ApplyQueryFilters(ModelBuilder modelBuilder)
    {
        var contextConstant = Expression.Constant(this, GetType());
        var tenantIdProperty = typeof(ModuleDbContext).GetProperty(nameof(CurrentTenantId))!;

        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            if (entityType.BaseType is not null || entityType.IsOwned())
            {
                continue;
            }

            var clrType = entityType.ClrType;
            var isTenant = typeof(ITenantEntity).IsAssignableFrom(clrType);
            var isSoftDeletable = typeof(ISoftDeletable).IsAssignableFrom(clrType);
            if (!isTenant && !isSoftDeletable)
            {
                continue;
            }

            var parameter = Expression.Parameter(clrType, "e");
            Expression? body = null;
            if (isTenant)
            {
                body = Expression.Equal(
                    Expression.Property(parameter, nameof(ITenantEntity.TenantId)),
                    Expression.Property(contextConstant, tenantIdProperty));
            }

            if (isSoftDeletable)
            {
                var notDeleted = Expression.Not(Expression.Property(parameter, nameof(ISoftDeletable.IsDeleted)));
                body = body is null ? notDeleted : Expression.AndAlso(body, notDeleted);
            }

            modelBuilder.Entity(clrType).HasQueryFilter(Expression.Lambda(body!, parameter));
        }
    }

    private void StampEntries()
    {
        var now = _clock.UtcNow;
        var userId = _currentUser.UserId;

        foreach (var entry in ChangeTracker.Entries().ToList())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    GuardTenant(entry.Entity);
                    if (entry.Entity is IAuditable created)
                    {
                        created.MarkCreated(now, userId);
                    }

                    break;

                case EntityState.Modified:
                    GuardTenant(entry.Entity);
                    if (entry.Entity is IAuditable updated)
                    {
                        updated.MarkUpdated(now, userId);
                    }

                    if (entry.Entity is IVersioned versioned)
                    {
                        versioned.BumpVersion();
                    }

                    break;

                case EntityState.Deleted when entry.Entity is ISoftDeletable deletable:
                    entry.State = EntityState.Modified;
                    deletable.SoftDelete();
                    if (entry.Entity is IAuditable softUpdated)
                    {
                        softUpdated.MarkUpdated(now, userId);
                    }

                    if (entry.Entity is IVersioned softVersioned)
                    {
                        softVersioned.BumpVersion();
                    }

                    break;

                default:
                    break;
            }
        }
    }

    private void GuardTenant(object entity)
    {
        if (!_tenantContext.HasTenant || entity is not ITenantEntity tenantEntity)
        {
            return;
        }

        if (tenantEntity.TenantId != _tenantContext.TenantId)
        {
            throw new InvalidOperationException(
                $"Cross-tenant write rejected: {entity.GetType().Name} belongs to tenant {tenantEntity.TenantId}, current tenant is {_tenantContext.TenantId}.");
        }
    }

    private List<OutboxMessage> DrainDomainEvents()
    {
        var rows = new List<OutboxMessage>();
        var aggregates = ChangeTracker.Entries()
            .Select(e => e.Entity)
            .OfType<IAggregateRoot>()
            .Where(a => a.DomainEvents.Count > 0)
            .ToList();

        foreach (var aggregate in aggregates)
        {
            var tenantId = aggregate is ITenantEntity tenantEntity ? tenantEntity.TenantId : CurrentTenantId;
            foreach (var domainEvent in aggregate.DomainEvents)
            {
                rows.Add(OutboxMessage.Create(
                    tenantId,
                    domainEvent.GetType().Name,
                    OutboxJson.Serialize(domainEvent),
                    domainEvent.OccurredAt));
            }

            aggregate.ClearDomainEvents();
        }

        return rows;
    }
}
