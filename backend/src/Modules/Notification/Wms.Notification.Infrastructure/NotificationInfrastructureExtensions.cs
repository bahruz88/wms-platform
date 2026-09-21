using Wms.Common.Infrastructure.Persistence;
using Wms.Notification.Application.Abstractions;
using Wms.Notification.Infrastructure.Persistence;
using Wms.Notification.Infrastructure.Queries;

namespace Wms.Notification.Infrastructure;

public static class NotificationInfrastructureExtensions
{
    public static IServiceCollection AddNotificationInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        services.AddNotificationPersistence(configuration.GetConnectionString(WmsMySql.ConnectionStringName));
        services.AddNotificationServices();
        return services;
    }

    public static IServiceCollection AddNotificationPersistence(this IServiceCollection services, string? connectionString) =>
        services.AddModuleDbContext<NotificationDbContext>(connectionString, NotificationDbContext.MigrationsHistoryTable);

    public static IServiceCollection AddNotificationServices(this IServiceCollection services)
    {
        services.AddScoped<INotificationQueries, NotificationQueries>();
        return services;
    }
}
