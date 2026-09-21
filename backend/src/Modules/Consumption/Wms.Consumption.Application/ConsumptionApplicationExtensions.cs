using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Consumption.Application;

public static class ConsumptionApplicationExtensions
{
    public static IServiceCollection AddConsumptionApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(ConsumptionApplicationExtensions).Assembly);
}
