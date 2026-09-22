using System.Globalization;

namespace Wms.Reporting.Contracts;

/// <summary>
/// Route table of reporting.v1.yaml. Reporting exposes no cross-module contract of its own: it is a reader,
/// and every other module talks to it through the HTTP API like any client.
/// </summary>
public static class ReportingRoutes
{
    public const string ModuleName = "Reporting";
    public const string Prefix = "/api/v1/reporting";
    public const string DashboardSummary = Prefix + "/dashboard/summary";
    public const string Reports = Prefix + "/reports";
    public const string Exports = Prefix + "/exports";

    /// <summary><c>ExportJob.statusUrl</c> — where the client polls for the job.</summary>
    public static string ExportStatusUrl(long exportId) =>
        string.Create(CultureInfo.InvariantCulture, $"{Exports}/{exportId}");
}
