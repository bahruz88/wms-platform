using Microsoft.AspNetCore.Http;

namespace Wms.Common.Infrastructure.Http;

public static class IdempotencyKey
{
    public const string HeaderName = "Idempotency-Key";

    public static bool TryGet(HttpContext httpContext, out Guid key)
    {
        ArgumentNullException.ThrowIfNull(httpContext);
        key = Guid.Empty;
        var raw = httpContext.Request.Headers[HeaderName].ToString();
        return Guid.TryParse(raw, out key) && key != Guid.Empty;
    }

    /// <summary>Reads the header after <see cref="IdempotencyEndpointFilter"/> validated it.</summary>
    public static Guid Require(HttpContext httpContext) =>
        TryGet(httpContext, out var key)
            ? key
            : throw new InvalidOperationException($"{HeaderName} header is missing; apply RequireIdempotencyKey() to the endpoint.");
}
