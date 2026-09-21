using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Http;

namespace Wms.Common.Infrastructure.Auth;

/// <summary>
/// The shared secret that separates a module-to-module call from a call made by a browser or a phone.
/// </summary>
/// <remarks>
/// <para>
/// <c>ModuleTransport=Http</c> (spec §4.2) means Inventory, Consumption, Procurement and the worker reach
/// MasterData, Identity and Documents over ordinary HTTP, on the <c>/api/v1/&lt;module&gt;/internal/...</c>
/// routes. Those routes were only ever "internal" by convention: they were marked
/// <c>ExcludeFromDescription()</c> and assumed not to be proxied. They <b>were</b> proxied — the gateway maps
/// <c>/api/v1/&lt;module&gt;/{**catch-all}</c> — and they carry no permission check at all, so any
/// authenticated user could read the whole product, location, supplier and rate catalogue and, worse, call
/// the three writing routes (<c>/internal/consumption-postings</c>, <c>/internal/reversals</c>,
/// <c>/internal/number-sequences/{docType}/next</c>).
/// </para>
/// <para>
/// Defence in depth, two independent layers:
/// 1. the gateway refuses anything containing an <c>internal</c> path segment (404 — the routes do not exist
///    as far as the outside world is concerned);
/// 2. every API host requires this header, so a caller that reaches a module container directly (a pod in the
///    same namespace, a misconfigured ingress, a port-forward) is still refused.
/// Both fail closed: when <c>InternalApi:Key</c> is not configured, every internal route is refused.
/// </para>
/// </remarks>
public sealed class InternalApiOptions
{
    public const string SectionName = "InternalApi";

    /// <summary>Shared secret. Env var form <c>InternalApi__Key</c> (only <c>[A-Za-z0-9_]</c>, see README §8.7).</summary>
    public string? Key { get; set; }
}

public static class InternalApi
{
    public const string HeaderName = "X-Wms-Internal-Key";

    private const string InternalSegment = "internal";

    /// <summary>True for <c>/api/v1/&lt;module&gt;/internal/...</c> — matched on whole segments, never a substring.</summary>
    public static bool IsInternalPath(PathString path)
    {
        if (!path.HasValue)
        {
            return false;
        }

        foreach (var segment in path.Value!.Split('/', StringSplitOptions.RemoveEmptyEntries))
        {
            if (string.Equals(segment, InternalSegment, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    public static bool Matches(string? configured, string? presented)
    {
        if (string.IsNullOrEmpty(configured) || string.IsNullOrEmpty(presented))
        {
            return false;
        }

        var expected = Encoding.UTF8.GetBytes(configured);
        var actual = Encoding.UTF8.GetBytes(presented);
        return CryptographicOperations.FixedTimeEquals(expected, actual);
    }

    public static Error Forbidden() => new(
        "INTERNAL_ROUTE_FORBIDDEN",
        "This route is reserved for module-to-module calls inside the cluster.",
        StatusCodes.Status403Forbidden);
}

/// <summary>Refuses <c>/internal/*</c> unless the caller presents the shared module secret.</summary>
public sealed class InternalRouteGuardMiddleware(RequestDelegate next, IOptions<InternalApiOptions> options)
{
    private readonly string? _key = options.Value.Key;

    public async Task InvokeAsync(HttpContext context)
    {
        ArgumentNullException.ThrowIfNull(context);

        if (InternalApi.IsInternalPath(context.Request.Path)
            && !InternalApi.Matches(_key, context.Request.Headers[InternalApi.HeaderName]))
        {
            var error = InternalApi.Forbidden();
            context.Response.StatusCode = error.Status;
            await context.Response
                .WriteAsJsonAsync(error.ToProblemDetails(), options: null, contentType: "application/problem+json", context.RequestAborted)
                .ConfigureAwait(false);
            return;
        }

        await next(context).ConfigureAwait(false);
    }
}
