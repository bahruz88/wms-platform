using Hangfire;
using Hangfire.MySql;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Hosting;
using Wms.Common.Infrastructure.Outbox;
using Wms.Common.Infrastructure.Persistence;

namespace Wms.Common.Infrastructure.Jobs;

/// <summary>
/// Hangfire wiring (spec §15). Server runs only where <c>Jobs:Enabled=true</c> (the <c>wms-worker</c> container or the
/// on-prem single container). Storage: <c>Jobs:Storage=MySql</c> (default, Hangfire.MySqlStorage — LGPL-3.0, see README)
/// or <c>InMemory</c> for local development and tests.
/// </summary>
public static class WmsJobsExtensions
{
    public const string EnabledKey = "Jobs:Enabled";
    public const string StorageKey = "Jobs:Storage";
    public const string TablePrefix = "hangfire_";

    public static bool AreJobsEnabled(this IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        return configuration.GetValue<bool>(EnabledKey);
    }

    public static IServiceCollection AddWmsJobs(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services.AddScoped<OutboxPublisherJob>();
        services.AddSingleton<IJobSchedule, OutboxJobSchedule>();

        if (!configuration.AreJobsEnabled())
        {
            return services;
        }

        var storage = configuration[StorageKey] ?? "MySql";
        services.AddHangfire((_, hangfire) =>
        {
            hangfire
                .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
                .UseSimpleAssemblyNameTypeSerializer()
                .UseRecommendedSerializerSettings();

            if (storage.Equals("InMemory", StringComparison.OrdinalIgnoreCase))
            {
                hangfire.UseInMemoryStorage();
            }
            else
            {
                var connectionString = configuration.GetConnectionString(WmsMySql.ConnectionStringName)
                    ?? throw new InvalidOperationException("Jobs:Enabled=true requires ConnectionStrings:Wms.");
                // PrepareSchemaIfNecessary=false: the runtime user (wms_app) holds no CREATE privilege and
                // spec §18.3 forbids DDL at host startup. The hangfire_* tables are created by the
                // wms-migrator job instead (see EnsureJobStorageSchema).
                hangfire.UseStorage(new MySqlStorage(
                    EnsureAllowUserVariables(connectionString),
                    new MySqlStorageOptions
                    {
                        TablesPrefix = TablePrefix,
                        QueuePollInterval = TimeSpan.FromSeconds(5),
                        PrepareSchemaIfNecessary = false,
                    }));
            }
        });

        services.AddHangfireServer(options =>
        {
            options.ServerName = $"{Environment.MachineName}:wms-worker";
            options.SchedulePollingInterval = TimeSpan.FromSeconds(5);
            options.WorkerCount = Math.Max(2, Environment.ProcessorCount);
        });

        return services;
    }

    /// <summary>Maps <c>/hangfire</c> and registers every <see cref="IJobSchedule"/>. No-op unless jobs are enabled.</summary>
    public static WebApplication MapWmsJobs(this WebApplication app)
    {
        ArgumentNullException.ThrowIfNull(app);
        if (!app.Configuration.AreJobsEnabled())
        {
            return app;
        }

        app.MapHangfireDashboard("/hangfire", new DashboardOptions
        {
            DashboardTitle = "WMS jobs",
            Authorization = [new WmsDashboardAuthorizationFilter(allowAnonymous: app.Environment.IsDevelopment())],
        });

        var manager = app.Services.GetRequiredService<IRecurringJobManager>();
        foreach (var schedule in app.Services.GetServices<IJobSchedule>())
        {
            schedule.Register(manager);
        }

        return app;
    }

    /// <summary>
    /// Creates the <c>hangfire_*</c> tables with the privileged migrator connection. Called by
    /// <c>Wms.Host.Migrator</c> only (spec §18.3): the API/worker hosts run as <c>wms_app</c>, which has
    /// SELECT/INSERT on <c>wms.*</c> and no CREATE, so they cannot install the schema themselves.
    /// Idempotent — Hangfire's installer skips objects that already exist.
    /// </summary>
    public static void EnsureJobStorageSchema(IConfiguration configuration, string migratorConnectionString)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentException.ThrowIfNullOrWhiteSpace(migratorConnectionString);

        var storage = configuration[StorageKey] ?? "MySql";
        if (storage.Equals("InMemory", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        // The MySqlStorage constructor runs MySqlObjectsInstaller when PrepareSchemaIfNecessary is set.
        using var installer = new MySqlStorage(
            EnsureAllowUserVariables(migratorConnectionString),
            new MySqlStorageOptions
            {
                TablesPrefix = TablePrefix,
                PrepareSchemaIfNecessary = true,
            });
    }

    /// <summary>Hangfire.MySqlStorage needs <c>Allow User Variables=True</c>.</summary>
    public static string EnsureAllowUserVariables(string connectionString)
    {
        ArgumentNullException.ThrowIfNull(connectionString);
        if (connectionString.Contains("Allow User Variables", StringComparison.OrdinalIgnoreCase)
            || connectionString.Contains("AllowUserVariables", StringComparison.OrdinalIgnoreCase))
        {
            return connectionString;
        }

        return connectionString.TrimEnd(';') + ";Allow User Variables=True;";
    }
}
