using System.Text.Json;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using StackExchange.Redis;
using Wms.Common.Application.Abstractions;

namespace Wms.Common.Infrastructure.Tenancy;

public sealed class PrincipalCacheOptions
{
    public const string SectionName = "PrincipalCache";

    /// <summary>How long a resolved principal may be reused. Writes in Identity invalidate the entry explicitly.</summary>
    public int TtlSeconds { get; set; } = 30;
}

internal static class PrincipalCacheKey
{
    public static string For(uint tenantId, string externalId) =>
        $"wms:principal:{tenantId}:{externalId}";
}

/// <summary>
/// Redis-backed cache. Redis is shared by every container, so an <c>iam</c> change made in the Identity
/// container is seen immediately by Inventory, MasterData and the worker.
/// </summary>
public sealed class RedisPrincipalCache(IConnectionMultiplexer redis, IOptions<PrincipalCacheOptions> options, ILogger<RedisPrincipalCache> logger)
    : IPrincipalCache
{
    private readonly TimeSpan _ttl = TimeSpan.FromSeconds(Math.Max(1, options.Value.TtlSeconds));

    public async Task<PrincipalSnapshot?> GetAsync(uint tenantId, string externalId, CancellationToken cancellationToken)
    {
        try
        {
            var value = await redis.GetDatabase().StringGetAsync(PrincipalCacheKey.For(tenantId, externalId)).ConfigureAwait(false);
            return value.IsNullOrEmpty ? null : JsonSerializer.Deserialize<PrincipalSnapshot>((string)value!);
        }
        catch (Exception ex) when (ex is RedisException or JsonException)
        {
            logger.LogWarning(ex, "Principal cache read failed; falling back to a direct lookup.");
            return null;
        }
    }

    public async Task SetAsync(PrincipalSnapshot snapshot, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(snapshot);
        try
        {
            await redis.GetDatabase()
                .StringSetAsync(
                    PrincipalCacheKey.For(snapshot.TenantId, snapshot.ExternalId),
                    JsonSerializer.Serialize(snapshot),
                    _ttl)
                .ConfigureAwait(false);
        }
        catch (RedisException ex)
        {
            logger.LogWarning(ex, "Principal cache write failed; the next request resolves again.");
        }
    }

    public async Task InvalidateAsync(uint tenantId, string externalId, CancellationToken cancellationToken)
    {
        try
        {
            await redis.GetDatabase().KeyDeleteAsync(PrincipalCacheKey.For(tenantId, externalId)).ConfigureAwait(false);
        }
        catch (RedisException ex)
        {
            logger.LogWarning(ex, "Principal cache invalidation failed; the entry expires within the TTL.");
        }
    }
}

/// <summary>In-process fallback used when no Redis connection string is configured (tests, `dotnet run`).</summary>
public sealed class MemoryPrincipalCache(IMemoryCache cache, IOptions<PrincipalCacheOptions> options) : IPrincipalCache
{
    private readonly TimeSpan _ttl = TimeSpan.FromSeconds(Math.Max(1, options.Value.TtlSeconds));

    public Task<PrincipalSnapshot?> GetAsync(uint tenantId, string externalId, CancellationToken cancellationToken) =>
        Task.FromResult(cache.Get<PrincipalSnapshot>(PrincipalCacheKey.For(tenantId, externalId)));

    public Task SetAsync(PrincipalSnapshot snapshot, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(snapshot);
        cache.Set(PrincipalCacheKey.For(snapshot.TenantId, snapshot.ExternalId), snapshot, _ttl);
        return Task.CompletedTask;
    }

    public Task InvalidateAsync(uint tenantId, string externalId, CancellationToken cancellationToken)
    {
        cache.Remove(PrincipalCacheKey.For(tenantId, externalId));
        return Task.CompletedTask;
    }
}
