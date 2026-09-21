using Wms.Common.Infrastructure.Modules;
using Wms.Common.Infrastructure.Persistence;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Contracts;
using Wms.Documents.Infrastructure.Contracts;
using Wms.Documents.Infrastructure.Persistence;
using Wms.Documents.Infrastructure.Queries;

namespace Wms.Documents.Infrastructure;

public static class DocumentsInfrastructureExtensions
{
    public static IServiceCollection AddDocumentsInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddDocumentsPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddDocumentsServices();
        return services;
    }

    public static IServiceCollection AddDocumentsPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<DocumentsDbContext>(connectionString, DocumentsDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddDocumentsServices(this IServiceCollection services)
    {
        services.AddScoped<IAttachmentQueries, AttachmentQueries>();
        services.AddScoped<IAttachmentReader, AttachmentReader>();
        return services;
    }

    public static IServiceCollection AddDocumentsRemoteContracts(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddModuleHttpClient<IAttachmentReader, HttpAttachmentReader>(configuration, DocumentsRoutes.ModuleName);
        return services;
    }
}
