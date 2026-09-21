using Microsoft.EntityFrameworkCore;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Infrastructure.Persistence;
using Wms.Documents.Infrastructure.Persistence;
using Wms.Identity.Infrastructure.Persistence;
using Wms.Integration.Infrastructure.Persistence;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Infrastructure.Persistence;
using Wms.Notification.Infrastructure.Persistence;
using Wms.Procurement.Infrastructure.Persistence;
using Wms.Reporting.Infrastructure.Persistence;

namespace Wms.ArchitectureTests;

/// <summary>
/// Builds every module DbContext against the MySQL provider without opening a connection, so the architecture
/// tests inspect exactly the model that runs in production.
/// </summary>
public static class TestDbContexts
{
    public const string FakeConnectionString = "Server=localhost;Port=3306;Database=wms_archtests;User=arch;Password=arch;";

    public static IEnumerable<DbContext> CreateAll()
    {
        yield return Create<IdentityDbContext>((o, t, u, c) => new IdentityDbContext(o, t, u, c));
        yield return Create<MasterDataDbContext>((o, t, u, c) => new MasterDataDbContext(o, t, u, c));
        yield return Create<InventoryDbContext>((o, t, u, c) => new InventoryDbContext(o, t, u, c));
        yield return Create<ConsumptionDbContext>((o, t, u, c) => new ConsumptionDbContext(o, t, u, c));
        yield return Create<ProcurementDbContext>((o, t, u, c) => new ProcurementDbContext(o, t, u, c));
        yield return Create<DocumentsDbContext>((o, t, u, c) => new DocumentsDbContext(o, t, u, c));
        yield return Create<NotificationDbContext>((o, t, u, c) => new NotificationDbContext(o, t, u, c));
        yield return Create<ReportingDbContext>((o, t, u, c) => new ReportingDbContext(o, t, u, c));
        yield return Create<IntegrationDbContext>((o, t, u, c) => new IntegrationDbContext(o, t, u, c));
    }

    private static TContext Create<TContext>(
        Func<DbContextOptions<TContext>,
            Wms.Common.Application.Abstractions.ITenantContext,
            Wms.Common.Application.Abstractions.ICurrentUser,
            Wms.Common.Application.Abstractions.IClock,
            TContext> factory)
        where TContext : DbContext
    {
        var builder = new DbContextOptionsBuilder<TContext>();
        builder.UseWmsMySql(FakeConnectionString, $"__ef_migrations_{typeof(TContext).Name.ToLowerInvariant()}");
        return factory(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
