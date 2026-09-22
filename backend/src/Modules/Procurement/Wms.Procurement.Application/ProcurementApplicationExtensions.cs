using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;
using Wms.Procurement.Application.Commands.Approvals;

namespace Wms.Procurement.Application;

public static class ProcurementApplicationExtensions
{
    public static IServiceCollection AddProcurementApplication(this IServiceCollection services)
    {
        ArgumentNullException.ThrowIfNull(services);
        services.AddWmsHandlersFromAssembly(typeof(ProcurementApplicationExtensions).Assembly);
        services.AddScoped<ApprovalEngine>();
        return services;
    }
}
