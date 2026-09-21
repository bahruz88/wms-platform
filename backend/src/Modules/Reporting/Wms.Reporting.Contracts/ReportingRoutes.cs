namespace Wms.Reporting.Contracts;

/// <summary>Reporting is a read replica fed by integration events (spec §5); it exposes no synchronous contract yet.</summary>
public static class ReportingRoutes
{
    public const string ModuleName = "Reporting";
    public const string Prefix = "/api/v1/reporting";
}
