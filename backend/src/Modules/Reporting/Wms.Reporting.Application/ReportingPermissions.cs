namespace Wms.Reporting.Application;

/// <summary><c>x-permission</c> values of reporting.v1.yaml. Every code exists in <c>PermissionCatalog</c>.</summary>
public static class ReportingPermissions
{
    public const string DashboardView = "rpt.dashboard.view";
    public const string ReportView = "rpt.report.view";
    public const string ReportExport = "rpt.report.export";
    public const string ExportCreate = "rpt.export.create";

    /// <summary>Cost columns and money KPIs are absent without it (spec §16, TOR §3.1).</summary>
    public const string ViewCost = "master.product.view_cost";

    /// <summary><c>systemHealth</c> is for ADMIN/AUDITOR only (reporting.v1.yaml).</summary>
    public const string AuditView = "iam.audit.view";
}
