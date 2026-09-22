using System.Text.Json;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Endpoints;

/// <summary><c>ReportRunRequest</c> of reporting.v1.yaml.</summary>
public sealed record ReportRunRequest(
    Dictionary<string, JsonElement>? Parameters,
    int? Page,
    int? Size,
    string? Sort);

/// <summary><c>ExportCreateRequest</c> of reporting.v1.yaml.</summary>
public sealed record ExportCreateRequest(
    string? ReportCode,
    ExportFormat? Format,
    Dictionary<string, JsonElement>? Parameters,
    string? FileName,
    string? Locale);
