using Microsoft.AspNetCore.Http;
using Wms.Common.Application.Abstractions;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Http;

namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>
/// Turns the bearer token into an <c>iam_user</c> row once per request (spec §7, §16).
/// </summary>
/// <remarks>
/// The Keycloak token carries no internal identifier, which is why every <c>created_by</c> / <c>posted_by</c> /
/// <c>approved_by</c> / <c>uploaded_by</c> column and every <c>common_audit_log.user_id</c> used to be 0 — and
/// why the §12.6 segregation-of-duties check silently disabled itself (<c>userId != 0</c> guard). This
/// middleware resolves (and, on first sight, provisions) the row so that <see cref="ICurrentUser.UserId"/> is
/// the real identity, and loads the effective permissions and location grants with it.
/// </remarks>
public sealed class PrincipalResolutionMiddleware(RequestDelegate next, ILogger<PrincipalResolutionMiddleware> logger)
{
    private static readonly string[] SkippedPrefixes = ["/health", "/hangfire", "/openapi"];

    public async Task InvokeAsync(HttpContext context, PrincipalContext principalContext, IPrincipalCache cache)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(principalContext);
        ArgumentNullException.ThrowIfNull(cache);

        if (ShouldSkip(context))
        {
            await next(context).ConfigureAwait(false);
            return;
        }

        var tenantId = CurrentUser.ReadTenantId(context.User);
        var externalId = context.User.FindFirst(ClaimNames.Subject)?.Value;
        if (tenantId == 0 || string.IsNullOrWhiteSpace(externalId))
        {
            // No tenant claim: endpoints answer TENANT_REQUIRED. Leave the principal unresolved (fail-closed).
            principalContext.Set(null);
            await next(context).ConfigureAwait(false);
            return;
        }

        var snapshot = await cache.GetAsync(tenantId, externalId, context.RequestAborted).ConfigureAwait(false);
        if (snapshot is null)
        {
            var directory = context.RequestServices.GetService<IPrincipalDirectory>();
            if (directory is null)
            {
                logger.LogWarning(
                    "No IPrincipalDirectory is registered; {Path} runs without an iam_user identity.", context.Request.Path);
                principalContext.Set(null);
                await next(context).ConfigureAwait(false);
                return;
            }

            var claims = new PrincipalClaims(
                tenantId,
                externalId,
                context.User.FindFirst(ClaimNames.PreferredUsername)?.Value ?? externalId,
                context.User.FindFirst(ClaimNames.Name)?.Value
                    ?? context.User.FindFirst(ClaimNames.PreferredUsername)?.Value
                    ?? externalId,
                context.User.FindFirst(ClaimNames.Email)?.Value,
                CurrentUser.ReadRealmRoles(context.User));

            snapshot = await directory.ResolveAsync(claims, context.RequestAborted).ConfigureAwait(false);
            if (snapshot is not null)
            {
                await cache.SetAsync(snapshot, context.RequestAborted).ConfigureAwait(false);
            }
        }

        if (snapshot is { IsActive: false })
        {
            var error = new Error("USER_DISABLED", "This user account is disabled.", StatusCodes.Status403Forbidden);
            context.Response.StatusCode = error.Status;
            await context.Response
                .WriteAsJsonAsync(error.ToProblemDetails(), options: null, contentType: "application/problem+json", context.RequestAborted)
                .ConfigureAwait(false);
            return;
        }

        principalContext.Set(snapshot);
        await next(context).ConfigureAwait(false);
    }

    private static bool ShouldSkip(HttpContext context)
    {
        if (context.User?.Identity?.IsAuthenticated != true)
        {
            return true;
        }

        var path = context.Request.Path;
        foreach (var prefix in SkippedPrefixes)
        {
            if (path.StartsWithSegments(prefix, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }
}
