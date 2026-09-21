namespace Wms.Common.Infrastructure.Persistence;

/// <summary>Connection string used by design-time factories (migrations scaffolding does not open it).</summary>
public static class DesignTimeConnection
{
    public const string Fallback = "Server=localhost;Port=3306;Database=wms;User=wms_migrator;Password=wms_migrator;";

    public static string Resolve()
    {
        var fromEnvironment = Environment.GetEnvironmentVariable("ConnectionStrings__WmsMigrator");
        return string.IsNullOrWhiteSpace(fromEnvironment) ? Fallback : fromEnvironment;
    }
}
