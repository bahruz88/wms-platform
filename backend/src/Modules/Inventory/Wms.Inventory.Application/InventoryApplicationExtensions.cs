using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Inventory.Application;

public static class InventoryApplicationExtensions
{
    public static IServiceCollection AddInventoryApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(InventoryApplicationExtensions).Assembly);
}
