using Microsoft.Extensions.DependencyInjection.Extensions;
using Wms.Common.Infrastructure.Persistence;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Infrastructure.Messaging;
using Wms.Notification.Infrastructure.Persistence;
using Wms.Notification.Infrastructure.Persistence.Repositories;
using Wms.Notification.Infrastructure.Queries;

namespace Wms.Notification.Infrastructure;

public static class NotificationInfrastructureExtensions
{
    public static IServiceCollection AddNotificationInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentNullException.ThrowIfNull(services);
        services.AddNotificationPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddNotificationServices();

        // The consumer belongs to whichever process runs background work. Elsewhere the module is
        // read/write API only, and a second consumer would just compete for the same queue.
        if (configuration.GetValue("Jobs:Enabled", false))
        {
            services.AddHostedService<NotificationEventConsumer>();
        }

        return services;
    }

    public static IServiceCollection AddNotificationPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<NotificationDbContext>(connectionString, NotificationDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddNotificationServices(this IServiceCollection services)
    {
        ArgumentNullException.ThrowIfNull(services);
        services.AddScoped<INotificationQueries, NotificationQueries>();
        services.AddScoped<INotificationRepository, NotificationRepository>();
        services.AddScoped<INotificationUnitOfWork, NotificationUnitOfWork>();
        services.TryAddScoped<IPendingApprovalCounter, NoPendingApprovalCounter>();
        return services;
    }
}
