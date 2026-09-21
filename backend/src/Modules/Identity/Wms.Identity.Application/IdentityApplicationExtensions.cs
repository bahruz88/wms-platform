using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Identity.Application;

public static class IdentityApplicationExtensions
{
    public static IServiceCollection AddIdentityApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(IdentityApplicationExtensions).Assembly);
}
