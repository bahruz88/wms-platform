using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Procurement.Application;

public static class ProcurementApplicationExtensions
{
    public static IServiceCollection AddProcurementApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(ProcurementApplicationExtensions).Assembly);
}
