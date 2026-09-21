using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.MasterData.Application;

public static class MasterDataApplicationExtensions
{
    public static IServiceCollection AddMasterDataApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(MasterDataApplicationExtensions).Assembly);
}
