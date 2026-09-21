namespace Wms.Common.Infrastructure.Persistence;

/// <summary>MySQL 8.4 LTS wiring shared by every module DbContext (spec §3).</summary>
public static class WmsMySql
{
    public const string ConnectionStringName = "Wms";
    public const string MigratorConnectionStringName = "WmsMigrator";

    public static ServerVersion ServerVersion { get; } = ServerVersion.Parse("8.4.0-mysql");

    public static DbContextOptionsBuilder UseWmsMySql(
        this DbContextOptionsBuilder builder,
        string? connectionString,
        string migrationsHistoryTable)
    {
        ArgumentNullException.ThrowIfNull(builder);
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                $"MySQL connection string is not configured (ConnectionStrings:{ConnectionStringName} or ConnectionStrings:{MigratorConnectionStringName}).");
        }

        // No EnableRetryOnFailure: handlers open explicit transactions (spec §12.2), which retrying strategies reject.
        builder.UseMySql(connectionString, ServerVersion, mysql => mysql.MigrationsHistoryTable(migrationsHistoryTable));
        return builder;
    }

    /// <summary>Registers a module DbContext against the shared <c>wms</c> database with its own migrations history table.</summary>
    public static IServiceCollection AddModuleDbContext<TContext>(
        this IServiceCollection services,
        string? connectionString,
        string migrationsHistoryTable)
        where TContext : ModuleDbContext
    {
        ArgumentNullException.ThrowIfNull(services);
        services.AddDbContext<TContext>(options => options.UseWmsMySql(connectionString, migrationsHistoryTable));
        return services;
    }
}
