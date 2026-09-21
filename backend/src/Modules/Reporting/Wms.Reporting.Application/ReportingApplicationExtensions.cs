using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Reporting.Application;

public static class ReportingApplicationExtensions
{
    public static IServiceCollection AddReportingApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(ReportingApplicationExtensions).Assembly);
}
