using Microsoft.Extensions.Diagnostics.HealthChecks;
using StackExchange.Redis;

namespace Wms.Common.Infrastructure.Health;

public sealed class RedisHealthCheck(IServiceProvider serviceProvider) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        var multiplexer = serviceProvider.GetService<IConnectionMultiplexer>();
        if (multiplexer is null)
        {
            return HealthCheckResult.Unhealthy("Redis:ConnectionString is not configured.");
        }

        try
        {
            var latency = await multiplexer.GetDatabase().PingAsync().ConfigureAwait(false);
            return HealthCheckResult.Healthy($"ping {latency.TotalMilliseconds:0} ms");
        }
        catch (RedisException ex)
        {
            return HealthCheckResult.Unhealthy("Redis is unreachable.", ex);
        }
    }
}
