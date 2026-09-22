using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Persistence;
using Wms.Common.Infrastructure.Storage;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Infrastructure.Export;
using Wms.Reporting.Infrastructure.Jobs;
using Wms.Reporting.Infrastructure.Persistence;
using Wms.Reporting.Infrastructure.Persistence.Repositories;
using Wms.Reporting.Infrastructure.Queries;
using Wms.Reporting.Infrastructure.Reports;

namespace Wms.Reporting.Infrastructure;

public static class ReportingInfrastructureExtensions
{
    public static IServiceCollection AddReportingInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddReportingPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        // Export files live in the same MinIO bucket the attachment flow uses (CONVENTIONS.md Minio__*).
        services.AddWmsObjectStorage(configuration);
        services.AddReportingServices();
        return services;
    }

    public static IServiceCollection AddReportingPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<ReportingDbContext>(connectionString, ReportingDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddReportingServices(this IServiceCollection services)
    {
        services.AddScoped<IReportCatalogQueries, ReportCatalogQueries>();
        services.AddScoped<IDashboardQueries, DashboardQueries>();
        services.AddScoped<IReportReferenceLoader, ReportReferenceLoader>();
        services.AddScoped<IReportRunner, ReportRunner>();
        services.AddScoped<IReportingUnitOfWork, ReportingUnitOfWork>();
        services.AddScoped<IExportJobRepository, ExportJobRepository>();
        services.AddScoped<IExportJobQueries, ExportJobQueries>();
        services.AddScoped<IReportingTenantScanner, ReportingTenantScanner>();
        services.AddScoped<IOutboxBacklogReader, OutboxBacklogReader>();
        services.AddScoped<IExportFileStore, MinioExportFileStore>();
        services.AddSingleton<IExportRenderer, XlsxExportRenderer>();
        services.AddSingleton<IExportRenderer, CsvExportRenderer>();

        services.AddScoped<ReportExportRunnerJob>();
        services.AddSingleton<IJobSchedule, ReportingJobSchedule>();
        return services;
    }
}
