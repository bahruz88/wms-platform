using Microsoft.AspNetCore.Http;
using Wms.Common.Application.Abstractions;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Http;

namespace Wms.Common.Infrastructure.Auth;

/// <summary>Endpoint metadata describing the required permission (visible in OpenAPI / arch tests).</summary>
public sealed record PermissionMetadata(string Permission);

/// <summary>Rejects the call with 403 <c>FORBIDDEN</c> when the current user lacks the permission (spec §16).</summary>
public sealed class PermissionEndpointFilter(string permission) : IEndpointFilter
{
    public string Permission { get; } = permission;

    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(next);

        var user = context.HttpContext.RequestServices.GetRequiredService<ICurrentUser>();
        if (!user.HasPermission(Permission))
        {
            return CommonErrors.Forbidden(Permission).ToProblem();
        }

        return await next(context).ConfigureAwait(false);
    }
}
