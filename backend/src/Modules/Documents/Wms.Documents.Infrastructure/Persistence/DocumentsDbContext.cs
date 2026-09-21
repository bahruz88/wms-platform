using Microsoft.EntityFrameworkCore.Design;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Documents.Domain.Entities;

namespace Wms.Documents.Infrastructure.Persistence;

/// <summary>
/// Schema <c>doc</c> (spec §5): table prefix <c>doc_</c>. The module also owns the shared
/// <c>common_attachment</c> table (spec §11), which keeps its <c>common_</c> name.
/// </summary>
public sealed class DocumentsDbContext(
    DbContextOptions<DocumentsDbContext> options,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ModuleDbContext(options, tenantContext, currentUser, clock)
{
    public const string Prefix = "doc_";
    public const string MigrationsHistoryTable = "__ef_migrations_documents";

    public override string TablePrefix => Prefix;

    public DbSet<Attachment> Attachments => Set<Attachment>();

    protected override void ConfigureModule(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(DocumentsDbContext).Assembly);
}

public sealed class DocumentsDbContextFactory : IDesignTimeDbContextFactory<DocumentsDbContext>
{
    public DocumentsDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<DocumentsDbContext>();
        builder.UseWmsMySql(DesignTimeConnection.Resolve(), DocumentsDbContext.MigrationsHistoryTable);
        return new DocumentsDbContext(builder.Options, DesignTimeContext.Tenant, DesignTimeContext.User, DesignTimeContext.Clock);
    }
}
