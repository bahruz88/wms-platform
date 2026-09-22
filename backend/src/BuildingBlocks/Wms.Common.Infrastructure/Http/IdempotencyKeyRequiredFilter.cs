using Microsoft.AspNetCore.Http;
using Wms.Common.Domain;

namespace Wms.Common.Infrastructure.Http;

/// <summary>
/// Requires <c>Idempotency-Key</c> (spec §13.2) without caching the response.
/// </summary>
/// <remarks>
/// <see cref="IdempotencyEndpointFilter"/> also replays the first response for 24 h, which is right for a POST
/// that creates something. <c>runReport</c> is a POST only because its parameter object does not fit a query
/// string: reporting.v1.yaml states that a repeated key simply runs the report again, and replaying a cached
/// page would hand back yesterday's stock.
/// </remarks>
public sealed class IdempotencyKeyRequiredFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(next);

        if (HttpMethods.IsPost(context.HttpContext.Request.Method) && !IdempotencyKey.TryGet(context.HttpContext, out _))
        {
            return new Error(
                "IDEMPOTENCY_KEY_REQUIRED",
                $"POST requests require an '{IdempotencyKey.HeaderName}' header containing a GUID.",
                400).ToProblem();
        }

        return await next(context).ConfigureAwait(false);
    }
}
