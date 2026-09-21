using Microsoft.AspNetCore.Routing;

namespace Wms.Common.Infrastructure.Modules;

/// <summary>
/// A deployable bounded context (spec §4.1). The host loads the modules listed in <c>Modules</c>
/// (<c>*</c> = all) and calls <see cref="RegisterServices"/> + <see cref="MapEndpoints"/> for each.
/// </summary>
public interface IModule
{
    /// <summary>Name used in <c>--Modules=</c> (CONVENTIONS.md), e.g. <c>inventory</c>.</summary>
    string Name { get; }

    void RegisterServices(IServiceCollection services, IConfiguration configuration);

    void MapEndpoints(IEndpointRouteBuilder app);

    /// <summary>
    /// Registers HTTP client implementations of this module's <c>*.Contracts</c> for processes where the
    /// module itself is NOT loaded (<c>ModuleTransport=Http</c>, spec §4.2).
    /// </summary>
    void RegisterRemoteContracts(IServiceCollection services, IConfiguration configuration)
    {
    }
}
