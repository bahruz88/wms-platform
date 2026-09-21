using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Notification.Application;

public static class NotificationApplicationExtensions
{
    public static IServiceCollection AddNotificationApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(NotificationApplicationExtensions).Assembly);
}
