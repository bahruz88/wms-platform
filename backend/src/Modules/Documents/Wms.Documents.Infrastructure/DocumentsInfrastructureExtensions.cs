using Microsoft.Extensions.Options;
using Wms.Common.Application.Storage;
using Wms.Common.Infrastructure.Modules;
using Wms.Common.Infrastructure.Persistence;
using Wms.Common.Infrastructure.Storage;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Application;
using Wms.Documents.Contracts;
using Wms.Documents.Infrastructure.Antivirus;
using Wms.Documents.Infrastructure.Contracts;
using Wms.Documents.Infrastructure.Persistence.Repositories;
using Wms.Documents.Infrastructure.Persistence;
using Wms.Documents.Infrastructure.Queries;

namespace Wms.Documents.Infrastructure;

public static class DocumentsInfrastructureExtensions
{
    public static IServiceCollection AddDocumentsInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddDocumentsPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddDocumentsStorage(configuration);
        services.AddDocumentsServices();
        return services;
    }

    public static IServiceCollection AddDocumentsPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<DocumentsDbContext>(connectionString, DocumentsDbContext.MigrationsHistoryTable);

    /// <summary>MinIO client and virus scanner (<c>Minio__*</c> and <c>Antivirus__*</c>).</summary>
    public static IServiceCollection AddDocumentsStorage(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);

        services.AddWmsObjectStorage(configuration);
        services.Configure<AntivirusOptions>(configuration.GetSection(AntivirusOptions.SectionName));

        services.AddSingleton(sp =>
        {
            var minio = sp.GetRequiredService<IOptions<MinioOptions>>().Value;
            return new AttachmentLinkOptions(minio.UploadUrlLifetime, minio.DownloadUrlLifetime);
        });

        // Antivirus__Enabled=false keeps the dev stack running without a clamd container (scan_result=SKIPPED).
        services.AddSingleton<IVirusScanner>(sp =>
        {
            var antivirus = sp.GetRequiredService<IOptions<AntivirusOptions>>();
            return antivirus.Value.Enabled
                ? new ClamAvVirusScanner(antivirus, sp.GetRequiredService<ILogger<ClamAvVirusScanner>>())
                : new DisabledVirusScanner();
        });

        return services;
    }

    public static IServiceCollection AddDocumentsServices(this IServiceCollection services)
    {
        services.AddScoped<IAttachmentQueries, AttachmentQueries>();
        services.AddScoped<IAttachmentRepository, AttachmentRepository>();
        services.AddScoped<IDocumentsUnitOfWork, DocumentsUnitOfWork>();
        services.AddScoped<IAttachmentReader, AttachmentReader>();
        return services;
    }

    public static IServiceCollection AddDocumentsRemoteContracts(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddModuleHttpClient<IAttachmentReader, HttpAttachmentReader>(configuration, DocumentsRoutes.ModuleName);
        return services;
    }
}
