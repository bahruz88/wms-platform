using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Infrastructure.Persistence;
using Wms.Documents.Infrastructure.Persistence;
using Wms.Identity.Infrastructure.Persistence;
using Wms.Integration.Infrastructure.Persistence;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Infrastructure.Persistence;
using Wms.Notification.Infrastructure.Persistence;
using Wms.Procurement.Infrastructure.Persistence;
using Wms.Reporting.Infrastructure.Persistence;

namespace Wms.ArchitectureTests;

/// <summary>
/// Spec §17.4 rules 2-5, checked against the real EF Core <see cref="IModel"/> built with the MySQL provider
/// (no connection is opened).
/// </summary>
public sealed class ModelConventionTests
{
    /// <summary>Entity types that are intentionally not tenant-scoped, with the reason.</summary>
    private static readonly Dictionary<string, string> TenantFilterExemptions = new(StringComparer.Ordinal)
    {
        ["Wms.Identity.Domain.Entities.Tenant"] = "iam_tenant IS the tenant row (spec §7).",
        ["Wms.Identity.Domain.Entities.Permission"] = "iam_permission is a global catalogue shared by all tenants (spec §7).",
        ["Wms.Identity.Domain.Entities.RolePermission"] = "iam_role_permission is keyed by role/permission only (spec §7).",
        ["Wms.Identity.Domain.Entities.UserRole"] = "iam_user_role is keyed by user/role only (spec §7).",
        ["Wms.Identity.Domain.Entities.UserLocation"] = "iam_user_location is keyed by user/location only (spec §7).",
        ["Wms.Procurement.Domain.Entities.ApprovalStep"] = "proc_approval_step hangs off proc_approval_instance, which is tenant-scoped (spec §10).",
        ["Wms.Common.Infrastructure.Outbox.OutboxMessage"] = "common_outbox is published across tenants by a background job (spec §14.1).",
        ["Wms.Common.Infrastructure.Audit.AuditLogEntry"] = "common_audit_log is append-only and read by auditors across tenants (spec §16).",
    };

    /// <summary>Unique indexes that legitimately do not start with tenant_id, with the reason.</summary>
    private static readonly Dictionary<string, string> UniqueIndexExemptions = new(StringComparer.Ordinal)
    {
        ["iam_tenant:uq_tenant_code"] = "The tenant table cannot be scoped by tenant_id (spec §7).",
        ["iam_permission:uq_perm_code"] = "Global permission catalogue (spec §7).",
        ["proc_approval_step:PK"] = "Surrogate primary key of a child table.",
        ["iam_role_permission:PK"] = "Junction table keyed by (role_id, permission_id); iam_role is tenant-scoped (spec §7 DDL).",
        ["iam_user_role:PK"] = "Junction table keyed by (user_id, role_id); iam_user is tenant-scoped (spec §7 DDL).",
        ["iam_user_location:PK"] = "Junction table keyed by (user_id, location_id); iam_user is tenant-scoped (spec §7 DDL).",
    };

    public static TheoryData<string> ContextNames()
    {
        var data = new TheoryData<string>();
        foreach (var name in Models.Keys)
        {
            data.Add(name);
        }

        return data;
    }

    private static Dictionary<string, IModel> Models { get; } = BuildModels();

    [Theory]
    [MemberData(nameof(ContextNames))]
    public void Every_tenant_entity_has_a_query_filter(string contextName)
    {
        var model = Models[contextName];

        var missing = model.GetEntityTypes()
            .Where(e => e.BaseType is null && !e.IsOwned())
            .Where(e => typeof(ITenantEntity).IsAssignableFrom(e.ClrType))
            .Where(e => e.GetQueryFilter() is null)
            .Select(e => e.ClrType.FullName!)
            .ToList();

        Assert.True(missing.Count == 0, $"{contextName}: these ITenantEntity types have no global query filter (spec §12.9): {string.Join(", ", missing)}");
    }

    [Theory]
    [MemberData(nameof(ContextNames))]
    public void Every_persisted_entity_is_tenant_scoped_unless_explicitly_exempted(string contextName)
    {
        var model = Models[contextName];

        var unscoped = model.GetEntityTypes()
            .Where(e => e.BaseType is null && !e.IsOwned())
            .Where(e => !typeof(ITenantEntity).IsAssignableFrom(e.ClrType))
            .Select(e => e.ClrType.FullName!)
            .Where(name => !TenantFilterExemptions.ContainsKey(name))
            .ToList();

        Assert.True(unscoped.Count == 0, $"{contextName}: these entities are neither ITenantEntity nor exempted (spec §6.2): {string.Join(", ", unscoped)}");
    }

    [Theory]
    [MemberData(nameof(ContextNames))]
    public void Every_unique_index_starts_with_tenant_id(string contextName)
    {
        var model = Models[contextName];
        var violations = new List<string>();

        foreach (var entityType in model.GetEntityTypes())
        {
            var table = entityType.GetTableName();
            if (table is null)
            {
                continue;
            }

            foreach (var index in entityType.GetIndexes().Where(i => i.IsUnique))
            {
                var indexName = index.GetDatabaseName() ?? "(unnamed)";
                if (UniqueIndexExemptions.ContainsKey($"{table}:{indexName}"))
                {
                    continue;
                }

                var firstColumn = index.Properties[0].GetColumnName();
                if (!string.Equals(firstColumn, "tenant_id", StringComparison.Ordinal))
                {
                    violations.Add($"{table}.{indexName} starts with '{firstColumn}'");
                }
            }

            // Composite primary keys must be tenant-first too; single surrogate keys are exempt.
            var primaryKey = entityType.FindPrimaryKey();
            if (primaryKey is { Properties.Count: > 1 }
                && !UniqueIndexExemptions.ContainsKey($"{table}:PK")
                && !string.Equals(primaryKey.Properties[0].GetColumnName(), "tenant_id", StringComparison.Ordinal))
            {
                violations.Add($"{table} composite PK starts with '{primaryKey.Properties[0].GetColumnName()}'");
            }
        }

        Assert.True(violations.Count == 0, $"{contextName}: unique keys must start with tenant_id (spec §6.5): {string.Join("; ", violations)}");
    }

    [Theory]
    [MemberData(nameof(ContextNames))]
    public void No_entity_property_uses_double_or_float(string contextName)
    {
        var model = Models[contextName];

        var violations = model.GetEntityTypes()
            .SelectMany(e => e.GetProperties().Select(p => (Entity: e, Property: p)))
            .Where(x => Nullable.GetUnderlyingType(x.Property.ClrType) is { } underlying
                ? underlying == typeof(double) || underlying == typeof(float)
                : x.Property.ClrType == typeof(double) || x.Property.ClrType == typeof(float))
            .Select(x => $"{x.Entity.GetTableName()}.{x.Property.GetColumnName()}")
            .ToList();

        Assert.True(violations.Count == 0, $"{contextName}: FLOAT/DOUBLE is forbidden (spec §6.3, Əlavə A): {string.Join(", ", violations)}");
    }

    [Theory]
    [MemberData(nameof(ContextNames))]
    public void Every_decimal_column_has_an_explicit_precision(string contextName)
    {
        var model = Models[contextName];

        var violations = model.GetEntityTypes()
            .SelectMany(e => e.GetProperties().Select(p => (Entity: e, Property: p)))
            .Where(x => (Nullable.GetUnderlyingType(x.Property.ClrType) ?? x.Property.ClrType) == typeof(decimal))
            .Where(x => x.Property.GetPrecision() is null)
            .Select(x => $"{x.Entity.GetTableName()}.{x.Property.GetColumnName()}")
            .ToList();

        Assert.True(violations.Count == 0, $"{contextName}: every decimal needs an explicit precision (spec §6.3): {string.Join(", ", violations)}");
    }

    [Fact]
    public void The_balance_entity_has_no_public_setters()
    {
        // Spec §17.4 rule 5 / ADR-004: nothing may assign inv_balance directly.
        var writable = typeof(StockBalance)
            .GetProperties()
            .Where(p => p.SetMethod is { IsPublic: true })
            .Select(p => p.Name)
            .ToList();

        Assert.True(writable.Count == 0, $"inv_balance must only change through Apply/Reserve/Release, but has public setters: {string.Join(", ", writable)}");
    }

    [Fact]
    public void The_ledger_entity_has_no_public_mutators()
    {
        // Spec §9.4: inv_movement is append-only.
        var mutators = typeof(Movement)
            .GetProperties()
            .Where(p => p.SetMethod is { IsPublic: true })
            .Select(p => p.Name)
            .ToList();

        Assert.True(mutators.Count == 0, $"inv_movement is append-only but exposes setters: {string.Join(", ", mutators)}");
    }

    [Theory]
    [MemberData(nameof(ContextNames))]
    public void Every_table_uses_the_modules_prefix(string contextName)
    {
        var (model, prefix) = (Models[contextName], Prefixes[contextName]);

        var violations = model.GetEntityTypes()
            .Where(e => e.BaseType is null && !e.IsOwned())
            .Select(e => e.GetTableName())
            .OfType<string>()
            .Where(table => !table.StartsWith(prefix, StringComparison.Ordinal) && !table.StartsWith("common_", StringComparison.Ordinal))
            .Distinct(StringComparer.Ordinal)
            .ToList();

        Assert.True(violations.Count == 0, $"{contextName}: tables must start with '{prefix}' or 'common_' (CONVENTIONS.md): {string.Join(", ", violations)}");
    }

    private static Dictionary<string, string> Prefixes { get; } = new(StringComparer.Ordinal)
    {
        [nameof(IdentityDbContext)] = IdentityDbContext.Prefix,
        [nameof(MasterDataDbContext)] = MasterDataDbContext.Prefix,
        [nameof(InventoryDbContext)] = InventoryDbContext.Prefix,
        [nameof(ConsumptionDbContext)] = ConsumptionDbContext.Prefix,
        [nameof(ProcurementDbContext)] = ProcurementDbContext.Prefix,
        [nameof(DocumentsDbContext)] = DocumentsDbContext.Prefix,
        [nameof(NotificationDbContext)] = NotificationDbContext.Prefix,
        [nameof(ReportingDbContext)] = ReportingDbContext.Prefix,
        [nameof(IntegrationDbContext)] = IntegrationDbContext.Prefix,
    };

    private static Dictionary<string, IModel> BuildModels()
    {
        var models = new Dictionary<string, IModel>(StringComparer.Ordinal);
        foreach (var context in TestDbContexts.CreateAll())
        {
            using (context)
            {
                models[context.GetType().Name] = context.Model;
            }
        }

        return models;
    }
}
