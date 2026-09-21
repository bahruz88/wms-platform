using System.Net.Http.Headers;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection.Extensions;

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
        var baseAddress = ModuleTransportConfiguration.RequireEndpoint(configuration, moduleName);
        services.TryAddTransient<ForwardAuthorizationHandler>();
        return services
            .AddHttpClient<TContract, TImplementation>(client =>
            {
                client.BaseAddress = baseAddress;
                client.Timeout = TimeSpan.FromSeconds(10);
            })
            .AddHttpMessageHandler<ForwardAuthorizationHandler>();
    }
}
