using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;
using Wms.Reporting.Infrastructure.Persistence;

namespace Wms.Reporting.Infrastructure.Queries;

/// <summary>
/// Reads <c>rpt_report_definition</c>. The catalogue is data: the parameter and column schemas are stored as
/// JSON and handed to the client unchanged, so adding a report is a seed change, not an API change.
/// </summary>
public sealed class ReportCatalogQueries(ReportingDbContext db) : IReportCatalogQueries
{
    public async Task<IReadOnlyList<ReportDefinitionDto>> ListAsync(ReportCategory? category, bool includeCostReports, CancellationToken cancellationToken)
    {
        var query = db.ReportDefinitions.AsNoTracking().Where(r => r.IsActive);
        if (category is { } value)
        {
            var name = value.ToString().ToUpperInvariant();
            query = query.Where(r => r.Category == name);
        }

        if (!includeCostReports)
        {
            // Spec §16: a report whose whole point is cost is not even listed without the permission.
            query = query.Where(r => !r.RequiresCostPermission);
        }

        var rows = await query
            .OrderBy(r => r.Category)
            .ThenBy(r => r.SortOrder)
            .ThenBy(r => r.Code)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return [.. rows.Select(Map)];
    }

    public async Task<ReportDefinitionDto?> GetAsync(string code, CancellationToken cancellationToken)
    {
        var normalised = (code ?? string.Empty).Trim().ToUpperInvariant();
        var row = await db.ReportDefinitions.AsNoTracking()
            .FirstOrDefaultAsync(r => r.IsActive && r.Code == normalised, cancellationToken)
            .ConfigureAwait(false);
        return row is null ? null : Map(row);
    }

    internal static ReportDefinitionDto Map(ReportDefinition row) =>
        new(
            row.Code,
            row.Name,
            row.Description,
            Enum.TryParse<ReportCategory>(row.Category, ignoreCase: true, out var category) ? category : ReportCategory.Stock,
            row.TorRef,
            ReportingJson.Deserialize<List<ReportParameterDefinition>>(row.ParametersJson) ?? [],
            ReportingJson.Deserialize<List<ReportColumnDefinition>>(row.ColumnsJson) ?? [],
            row.RequiresCostPermission,
            Formats(row.SupportedFormats),
            row.MaxSyncRows);

    private static IReadOnlyList<ExportFormat> Formats(string value)
    {
        var formats = new List<ExportFormat>();
        foreach (var part in value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            if (Enum.TryParse<ExportFormat>(part, ignoreCase: true, out var format))
            {
                formats.Add(format);
            }
        }

        return formats;
    }
}
