using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using StackExchange.Redis;
using Wms.Common.Application.Abstractions;
using Wms.Common.Domain;

namespace Wms.Common.Infrastructure.Http;

/// <summary>
/// Spec §13.2: every POST requires <c>Idempotency-Key: &lt;GUID&gt;</c>. The first response is cached in Redis for
/// 24 h per tenant/user/path/key and replayed on repeats. Business-level de-duplication (e.g. <c>uq_mg_idem</c>)
/// still lives in the handlers; this filter only shields against network retries.
/// </summary>
public sealed class IdempotencyEndpointFilter : IEndpointFilter
{
    public const string ReplayHeader = "Idempotent-Replay";
    private static readonly TimeSpan Ttl = TimeSpan.FromHours(24);

    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(next);

        var http = context.HttpContext;
        if (!HttpMethods.IsPost(http.Request.Method))
        {
            return await next(context).ConfigureAwait(false);
        }

        if (!IdempotencyKey.TryGet(http, out var key))
        {
            return new Error(
                "IDEMPOTENCY_KEY_REQUIRED",
                $"POST requests require an '{IdempotencyKey.HeaderName}' header containing a GUID.",
                400).ToProblem();
        }

        var services = http.RequestServices;
        var tenant = services.GetRequiredService<ITenantContext>();
        var user = services.GetRequiredService<ICurrentUser>();
        var logger = services.GetRequiredService<ILogger<IdempotencyEndpointFilter>>();
        var cacheKey = $"wms:idem:{tenant.TenantId}:{user.ExternalId}:{http.Request.Path}:{key:D}";

        var database = TryGetRedis(services, logger);
        if (database is not null)
        {
            var replay = await TryReadAsync(database, cacheKey, logger).ConfigureAwait(false);
            if (replay is not null)
            {
                http.Response.Headers[ReplayHeader] = "true";
                return Results.Content(replay.Body, replay.ContentType, statusCode: replay.StatusCode);
            }
        }

        var result = await next(context).ConfigureAwait(false);

        if (database is not null
            && result is IValueHttpResult { Value: not null } valueResult
            && result is IStatusCodeHttpResult { StatusCode: int statusCode }
            && statusCode < 500)
        {
            var jsonOptions = services.GetRequiredService<IOptions<Microsoft.AspNetCore.Http.Json.JsonOptions>>().Value.SerializerOptions;
            var body = JsonSerializer.Serialize(valueResult.Value, valueResult.Value.GetType(), jsonOptions);
            await TryWriteAsync(database, cacheKey, new CachedResponse(statusCode, "application/json", body), logger).ConfigureAwait(false);
        }

        return result;
    }

    private static IDatabase? TryGetRedis(IServiceProvider services, ILogger logger)
    {
        var multiplexer = services.GetService<IConnectionMultiplexer>();
        if (multiplexer is null)
        {
            return null;
        }

        if (!multiplexer.IsConnected)
        {
            logger.LogWarning("Redis is not connected; idempotency replay cache is bypassed for this request");
            return null;
        }

        return multiplexer.GetDatabase();
    }

    private static async Task<CachedResponse?> TryReadAsync(IDatabase database, string cacheKey, ILogger logger)
    {
        try
        {
            var cached = await database.StringGetAsync(cacheKey).ConfigureAwait(false);
            return cached.HasValue ? JsonSerializer.Deserialize<CachedResponse>((string)cached!) : null;
        }
        catch (RedisException ex)
        {
            logger.LogWarning(ex, "Idempotency cache read failed for {CacheKey}", cacheKey);
            return null;
        }
    }

    private static async Task TryWriteAsync(IDatabase database, string cacheKey, CachedResponse response, ILogger logger)
    {
        try
        {
            await database.StringSetAsync(cacheKey, JsonSerializer.Serialize(response), Ttl).ConfigureAwait(false);
        }
        catch (RedisException ex)
        {
            logger.LogWarning(ex, "Idempotency cache write failed for {CacheKey}", cacheKey);
        }
    }

    private sealed record CachedResponse(int StatusCode, string ContentType, string Body);
}
