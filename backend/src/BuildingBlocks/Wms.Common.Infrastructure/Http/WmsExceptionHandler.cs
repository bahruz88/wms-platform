using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using Wms.Common.Domain;

namespace Wms.Common.Infrastructure.Http;

/// <summary>Last-resort mapping of exceptions to RFC 7807 (spec §13.3, §13.5).</summary>
public sealed class WmsExceptionHandler(IProblemDetailsService problemDetailsService, ILogger<WmsExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(httpContext);
        ArgumentNullException.ThrowIfNull(exception);

        var error = exception switch
        {
            DbUpdateConcurrencyException => CommonErrors.StaleVersion(),
            OperationCanceledException => new Error("REQUEST_CANCELLED", "The request was cancelled by the client.", 499),

            // Minimal API parameter binding (missing/unparseable required query, route or body values) throws this.
            // Without an explicit mapping it fell through to 500 — e.g. GET /consumption/variance without periodFrom.
            BadHttpRequestException bad => new Error(
                "BAD_REQUEST",
                bad.Message,
                bad.StatusCode is >= 400 and < 500 ? bad.StatusCode : StatusCodes.Status400BadRequest),

            // ModuleTransport=Http: a sibling module refused or was unreachable. Reporting it as this module's
            // own INTERNAL_ERROR hides where the fault actually is.
            HttpRequestException http => new Error(
                "UPSTREAM_MODULE_UNAVAILABLE",
                $"A dependent module call failed: {http.Message}",
                StatusCodes.Status502BadGateway),

            _ => new Error("INTERNAL_ERROR", "An unexpected error occurred.", 500),
        };

        if (error.Status >= 500)
        {
            logger.LogError(exception, "Unhandled exception for {Method} {Path}", httpContext.Request.Method, httpContext.Request.Path);
        }

        httpContext.Response.StatusCode = error.Status;
        return await problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            ProblemDetails = error.ToProblemDetails(),
            Exception = exception,
        }).ConfigureAwait(false);
    }
}
