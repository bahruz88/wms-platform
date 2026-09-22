using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Wms.Common.Infrastructure.Http;

namespace Wms.Common.Infrastructure.Auth;

public static class RequirePermissionExtensions
{
    /// <summary><c>.RequirePermission("inv.receipt.create")</c> — authenticated + permission check (spec §16).</summary>
    public static TBuilder RequirePermission<TBuilder>(this TBuilder builder, string permission)
        where TBuilder : IEndpointConventionBuilder
    {
        ArgumentNullException.ThrowIfNull(builder);
        ArgumentException.ThrowIfNullOrWhiteSpace(permission);

        builder.RequireAuthorization();
        builder.WithMetadata(new PermissionMetadata(permission));
        builder.AddEndpointFilter(new PermissionEndpointFilter(permission));
        return builder;
    }

    /// <summary>Requires the <c>Idempotency-Key</c> header and replays cached responses (spec §13.2).</summary>
    public static TBuilder RequireIdempotencyKey<TBuilder>(this TBuilder builder)
        where TBuilder : IEndpointConventionBuilder
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.AddEndpointFilter(new IdempotencyEndpointFilter());
        return builder;
    }

    /// <summary>
    /// Requires the <c>Idempotency-Key</c> header but does NOT replay a cached response — for a POST that
    /// reads rather than creates (see <see cref="IdempotencyKeyRequiredFilter"/>).
    /// </summary>
    public static TBuilder RequireIdempotencyKeyHeader<TBuilder>(this TBuilder builder)
        where TBuilder : IEndpointConventionBuilder
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.AddEndpointFilter(new IdempotencyKeyRequiredFilter());
        return builder;
    }
}
