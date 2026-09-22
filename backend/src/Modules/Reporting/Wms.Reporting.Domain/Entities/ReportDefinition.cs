using Wms.Common.Domain;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Domain.Entities;

/// <summary>One allowed value of an <c>ENUM</c> report parameter (reporting.v1.yaml).</summary>
public sealed record ReportAllowedValue(string Value, string Label);

/// <summary><c>ReportParameter</c> of reporting.v1.yaml: what the client renders the run form from.</summary>
public sealed record ReportParameterDefinition(
    string Name,
    string Label,
    ReportParamType Type,
    bool Required,
    object? DefaultValue = null,
    IReadOnlyList<ReportAllowedValue>? AllowedValues = null);

/// <summary>
/// <c>ReportColumn</c> of reporting.v1.yaml. <see cref="IsCost"/> columns are removed from both the column list
/// and every row for a principal without <c>master.product.view_cost</c> (spec §16) — never masked, never null.
/// </summary>
public sealed record ReportColumnDefinition(
    string Key,
    string Label,
    ReportColumnType Type,
    bool IsCost = false,
    int? Width = null,
    ColumnAlign Align = ColumnAlign.Left);

/// <summary>
/// <c>rpt_report_definition</c>: the catalogue row of one report (TOR §29). The parameter and column schemas
/// are stored as JSON so the catalogue is data — <c>listReports</c> and <c>getReportDefinition</c> read this
/// table and nothing else. <see cref="ReportCatalog"/> is the source the migrator upserts from.
/// </summary>
public sealed class ReportDefinition : Entity<ushort>, ITenantEntity
{
    private ReportDefinition()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public string? Description { get; private set; }

    public string Category { get; private set; } = string.Empty;

    /// <summary>Reference into TOR §29, e.g. <c>29.1</c>; null when the tender number is not known.</summary>
    public string? TorRef { get; private set; }

    /// <summary>Comma separated <see cref="ExportFormat"/> values, e.g. <c>XLSX,CSV</c>.</summary>
    public string SupportedFormats { get; private set; } = string.Empty;

    /// <summary>True when the whole point of the report is cost — such a report is hidden from a principal without the permission.</summary>
    public bool RequiresCostPermission { get; private set; }

    public int MaxSyncRows { get; private set; } = 200;

    public ushort SortOrder { get; private set; }

    public string ParametersJson { get; private set; } = "[]";

    public string ColumnsJson { get; private set; } = "[]";

    public bool SupportsExcelExport { get; private set; } = true;

    public bool IsActive { get; private set; } = true;

    public static ReportDefinition Create(
        uint tenantId,
        string code,
        string name,
        string? description,
        ReportCategory category,
        string? torRef,
        string supportedFormats,
        bool requiresCostPermission,
        int maxSyncRows,
        ushort sortOrder,
        string parametersJson,
        string columnsJson)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(code);
        var definition = new ReportDefinition { TenantId = tenantId, Code = code.Trim().ToUpperInvariant() };
        definition.Update(name, description, category, torRef, supportedFormats, requiresCostPermission, maxSyncRows, sortOrder, parametersJson, columnsJson);
        return definition;
    }

    /// <summary>Re-applies the code catalogue onto an existing row (the migrator upsert is idempotent).</summary>
    public void Update(
        string name,
        string? description,
        ReportCategory category,
        string? torRef,
        string supportedFormats,
        bool requiresCostPermission,
        int maxSyncRows,
        ushort sortOrder,
        string parametersJson,
        string columnsJson)
    {
        Name = (name ?? string.Empty).Trim();
        Description = string.IsNullOrWhiteSpace(description) ? null : description.Trim();
        Category = category.ToString().ToUpperInvariant();
        TorRef = string.IsNullOrWhiteSpace(torRef) ? null : torRef.Trim();
        SupportedFormats = (supportedFormats ?? string.Empty).Trim();
        RequiresCostPermission = requiresCostPermission;
        MaxSyncRows = Math.Clamp(maxSyncRows, 1, 200);
        SortOrder = sortOrder;
        ParametersJson = parametersJson ?? "[]";
        ColumnsJson = columnsJson ?? "[]";
        SupportsExcelExport = SupportedFormats.Contains(nameof(ExportFormat.Xlsx), StringComparison.OrdinalIgnoreCase);
        IsActive = true;
    }

    public void Deactivate() => IsActive = false;
}
