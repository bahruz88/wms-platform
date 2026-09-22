using Microsoft.Extensions.DependencyInjection.Extensions;
using Wms.Common.Application.Storage;

namespace Wms.Common.Infrastructure.Storage;

public static class ObjectStorageExtensions
{
    /// <summary>
    /// Binds <c>Minio__*</c> (CONVENTIONS.md) and registers the single MinIO client the platform uses — the
    /// attachment flow (spec §11) and the report exports (reporting.v1.yaml) share it. Idempotent, so a host
    /// that loads both Documents and Reporting registers it once.
    /// </summary>
    public static IServiceCollection AddWmsObjectStorage(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services.Configure<MinioOptions>(configuration.GetSection(MinioOptions.SectionName));
        services.TryAddSingleton<IObjectStorage, MinioObjectStorage>();
        return services;
    }
}
