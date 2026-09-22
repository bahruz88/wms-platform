using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Application.Dtos;

/// <summary><c>Kpi</c> of reporting.v1.yaml.</summary>
public enum KpiSeverity
{
    Normal,
    Warning,
    Critical,
}

/// <summary><c>DashboardAlert.severity</c> of reporting.v1.yaml.</summary>
public enum AlertSeverity
{
    Info,
    Warning,
    Critical,
}

/// <summary>Trend comparison window of <c>getDashboardSummary</c>.</summary>
public enum DashboardPeriod
{
    Today,
    Week,
    Month,
}

public sealed record KpiDto(
    string Key,
    string Label,
    decimal Value,
    string? Unit,
    decimal? TrendPct,
    KpiSeverity Severity,
    string? Link,
    bool IsCost);

public sealed record DashboardAlertDto(string Type, AlertSeverity Severity, int Count, string Title, string? Link);

public sealed record DashboardSeriesPointDto(DateOnly Date, decimal Value);

public sealed record DashboardSeriesDto(
    string Key,
    string Label,
    string? Unit,
    bool IsCost,
    IReadOnlyList<DashboardSeriesPointDto> Points);

/// <summary>
/// <c>DashboardSummary.systemHealth</c> — ADMIN/AUDITOR only. The two reconciliation pairs are <c>null</c>
/// today on purpose: <c>BalanceReconciliationJob</c> and <c>DoubleEntryCheckJob</c> only write to the log
/// (README §8.8), so there is no stored outcome to report and the dashboard does not invent one.
/// </summary>
public sealed record SystemHealthDto(
    DateTimeOffset? LastBalanceReconciliationAt,
    bool? BalanceReconciliationOk,
    DateTimeOffset? LastDoubleEntryCheckAt,
    bool? DoubleEntryCheckOk,
    int? OutboxPending);

public sealed record DashboardSummaryDto(
    DateTimeOffset GeneratedAt,
    uint? LocationId,
    IReadOnlyList<KpiDto> Kpis,
    IReadOnlyList<DashboardAlertDto> Alerts,
    IReadOnlyList<DashboardSeriesDto> Series,
    SystemHealthDto? SystemHealth);

/// <summary><c>ReportDefinition</c> of reporting.v1.yaml, read from <c>rpt_report_definition</c>.</summary>
public sealed record ReportDefinitionDto(
    string Code,
    string Name,
    string? Description,
    ReportCategory Category,
    string? TorRef,
    IReadOnlyList<ReportParameterDefinition> Parameters,
    IReadOnlyList<ReportColumnDefinition> Columns,
    bool RequiresCostPermission,
    IReadOnlyList<ExportFormat> SupportedFormats,
    int MaxSyncRows);

/// <summary><c>ReportResultPage</c> of reporting.v1.yaml: rows are value arrays in <c>columns</c> order.</summary>
public sealed record ReportResultPageDto(
    int Page,
    int Size,
    long Total,
    string Code,
    IReadOnlyList<ReportColumnDefinition> Columns,
    IReadOnlyList<IReadOnlyList<object?>> Rows,
    IReadOnlyDictionary<string, string>? Totals,
    DateTimeOffset GeneratedAt,
    DateTimeOffset DataAsOf);

/// <summary>The whole result of a report, used to render an export file.</summary>
public sealed record ReportDataSet(
    string Code,
    string Name,
    IReadOnlyList<ReportColumnDefinition> Columns,
    IReadOnlyList<IReadOnlyList<object?>> Rows,
    IReadOnlyDictionary<string, string>? Totals,
    DateTimeOffset GeneratedAt);

/// <summary><c>ExportJob</c> of reporting.v1.yaml.</summary>
public sealed record ExportJobDto(
    long Id,
    string ReportCode,
    ExportFormat Format,
    ExportStatus Status,
    int? ProgressPct,
    long? RowCount,
    string? FileName,
    long? SizeBytes,
    string? DownloadUrl,
    DateTimeOffset? DownloadUrlExpiresAt,
    string? ErrorMessage,
    DateTimeOffset RequestedAt,
    DateTimeOffset? CompletedAt,
    DateTimeOffset? ExpiresAt,
    string StatusUrl);
