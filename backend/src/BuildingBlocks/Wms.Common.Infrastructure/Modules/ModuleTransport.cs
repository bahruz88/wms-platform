using Wms.Common.Infrastructure.Auth;

namespace Wms.Common.Infrastructure.Modules;

/// <summary>How modules call each other (spec §4.2): in-process (default) or over HTTP.</summary>
public enum ModuleTransport
{
    InProcess,
    Http,
}

public static class ModuleTransportConfiguration
{
    public const string Key = "ModuleTransport";
    public const string EndpointsSection = "ModuleEndpoints";

    public static ModuleTransport Resolve(IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        var raw = configuration[Key];
        if (string.IsNullOrWhiteSpace(raw))
        {
            return ModuleTransport.InProcess;
        }

        return Enum.TryParse<ModuleTransport>(raw, ignoreCase: true, out var parsed)
            ? parsed
            : throw new InvalidOperationException($"Unknown {Key} value '{raw}'. Allowed: InProcess, Http.");
    }

    /// <summary>Base address of a remote module, e.g. <c>ModuleEndpoints:MasterData = http://wms-masterdata:8080</c>.</summary>
    public static Uri RequireEndpoint(IConfiguration configuration, string moduleName)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        var raw = configuration[$"{EndpointsSection}:{moduleName}"];
        if (string.IsNullOrWhiteSpace(raw))
        {
            throw new InvalidOperationException(
                $"{Key}=Http requires {EndpointsSection}:{moduleName} to point at the container hosting module '{moduleName}'.");
        }

        return new Uri(raw, UriKind.Absolute);
    }

    /// <summary>
    /// <c>ModuleTransport=Http</c> means the module-to-module calls leave the process, so the shared secret of
    /// <see cref="Wms.Common.Infrastructure.Auth.InternalApi"/> must be configured on both ends. Missing it is a
    /// deployment error, not a runtime one: fail at startup rather than answer 403 on the first internal call.
    /// </summary>
    public static void RequireInternalApiKey(IConfiguration configuration, string moduleName)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        var key = configuration[$"{InternalApiOptions.SectionName}:{nameof(InternalApiOptions.Key)}"];
        if (string.IsNullOrWhiteSpace(key))
        {
            throw new InvalidOperationException(
                $"{Key}=Http needs {InternalApiOptions.SectionName}:{nameof(InternalApiOptions.Key)} "
                + $"(env var {InternalApiOptions.SectionName}__{nameof(InternalApiOptions.Key)}) to be the same secret on every "
                + $"container; without it module '{moduleName}' answers 403 INTERNAL_ROUTE_FORBIDDEN on every internal call.");
        }
    }
}
