using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Integration.Application;

public static class IntegrationApplicationExtensions
{
    public static IServiceCollection AddIntegrationApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(IntegrationApplicationExtensions).Assembly);
}
