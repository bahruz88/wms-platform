using Wms.Common.Infrastructure.Modules;

namespace Wms.Host.Api;

/// <summary>Wires the resolved modules into the container and the endpoint table (spec §4.1, §4.2).</summary>
public static class ModuleLoader
{
    public static IReadOnlyList<IModule> LoadModules(this WebApplicationBuilder builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        var modules = ModuleRegistry.Resolve(builder.Configuration[ModuleRegistry.ConfigurationKey]);
        foreach (var module in modules)
        {
            module.RegisterServices(builder.Services, builder.Configuration);
        }

        // Contracts of modules that are not hosted here: in-process is impossible, so HTTP clients are required.
        var transport = ModuleTransportConfiguration.Resolve(builder.Configuration);
        if (transport == ModuleTransport.Http)
        {
            foreach (var remote in ModuleRegistry.Remaining(modules))
            {
                remote.RegisterRemoteContracts(builder.Services, builder.Configuration);
            }
        }
        else
        {
            // Fail fast with an actionable message instead of an opaque DI resolution error at first request.
            var missing = ModuleRegistry.MissingDependencies(modules);
            if (missing.Count > 0)
            {
                throw new InvalidOperationException(
                    $"{ModuleRegistry.ConfigurationKey}='{builder.Configuration[ModuleRegistry.ConfigurationKey]}' with {ModuleTransportConfiguration.Key}=InProcess "
                    + $"but these required modules are not loaded: {string.Join(", ", missing)}. "
                    + $"Either add them to {ModuleRegistry.ConfigurationKey}, or set {ModuleTransportConfiguration.Key}=Http and configure "
                    + $"{ModuleTransportConfiguration.EndpointsSection}:<Module> for each (spec §4.2).");
            }
        }

        builder.Services.AddSingleton<IReadOnlyList<IModule>>(modules);
        return modules;
    }

    public static WebApplication MapModuleEndpoints(this WebApplication app)
    {
        ArgumentNullException.ThrowIfNull(app);
        foreach (var module in app.Services.GetRequiredService<IReadOnlyList<IModule>>())
        {
            module.MapEndpoints(app);
        }

        return app;
    }
}
