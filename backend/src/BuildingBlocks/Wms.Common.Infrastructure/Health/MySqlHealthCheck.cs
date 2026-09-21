using Microsoft.Extensions.Diagnostics.HealthChecks;
using MySqlConnector;
using Wms.Common.Infrastructure.Persistence;

namespace Wms.Common.Infrastructure.Health;

public sealed class MySqlHealthCheck(IConfiguration configuration) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        var connectionString = configuration.GetConnectionString(WmsMySql.ConnectionStringName);
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return HealthCheckResult.Unhealthy("ConnectionStrings:Wms is not configured.");
        }

        try
        {
            await using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync(cancellationToken).ConfigureAwait(false);
            await using var command = connection.CreateCommand();
            command.CommandText = "SELECT 1";
            await command.ExecuteScalarAsync(cancellationToken).ConfigureAwait(false);
            return HealthCheckResult.Healthy();
        }
        catch (Exception ex) when (ex is MySqlException or InvalidOperationException or TimeoutException)
        {
            return HealthCheckResult.Unhealthy("MySQL is unreachable.", ex);
        }
    }
}
