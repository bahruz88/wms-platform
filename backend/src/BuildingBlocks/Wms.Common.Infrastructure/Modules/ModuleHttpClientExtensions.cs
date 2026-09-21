using System.Net.Http.Headers;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Options;
using Wms.Common.Infrastructure.Auth;

namespace Wms.Common.Infrastructure.Modules;

/// <summary>Forwards the caller's bearer token to the remote module so tenant/permissions are evaluated identically there.</summary>
public sealed class ForwardAuthorizationHandler(IHttpContextAccessor httpContextAccessor) : DelegatingHandler
{
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var authorization = httpContextAccessor.HttpContext?.Request.Headers.Authorization.ToString();
        if (!string.IsNullOrWhiteSpace(authorization) && AuthenticationHeaderValue.TryParse(authorization, out var header))
        {
            request.Headers.Authorization = header;
        }

        return base.SendAsync(request, cancellationToken);
    }
}

/// <summary>
/// Presents the shared module secret on every <c>/internal/*</c> call so the remote host accepts it
/// (see <see cref="InternalApi"/>). Without this header the target answers 403 INTERNAL_ROUTE_FORBIDDEN.
/// </summary>
public sealed class InternalApiKeyHandler(IOptions<InternalApiOptions> options) : DelegatingHandler
{
    private readonly string? _key = options.Value.Key;

    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (!string.IsNullOrEmpty(_key))
        {
            request.Headers.Remove(InternalApi.HeaderName);
            request.Headers.Add(InternalApi.HeaderName, _key);
        }

        return base.SendAsync(request, cancellationToken);
    }
}

public static class ModuleHttpClientExtensions
{
    /// <summary>Typed HTTP client for a remote module contract (<c>ModuleTransport=Http</c>), base address from <c>ModuleEndpoints:&lt;Module&gt;</c>.</summary>
    public static IHttpClientBuilder AddModuleHttpClient<TContract, TImplementation>(
        this IServiceCollection services,
        IConfiguration configuration,
        string moduleName)
        where TContract : class
        where TImplementation : class, TContract
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);
        var baseAddress = ModuleTransportConfiguration.RequireEndpoint(configuration, moduleName);
        ModuleTransportConfiguration.RequireInternalApiKey(configuration, moduleName);
        services.TryAddTransient<ForwardAuthorizationHandler>();
        services.TryAddTransient<InternalApiKeyHandler>();
        return services
            .AddHttpClient<TContract, TImplementation>(client =>
            {
                client.BaseAddress = baseAddress;
                client.Timeout = TimeSpan.FromSeconds(10);
            })
            .AddHttpMessageHandler<ForwardAuthorizationHandler>()
            .AddHttpMessageHandler<InternalApiKeyHandler>();
    }
}
