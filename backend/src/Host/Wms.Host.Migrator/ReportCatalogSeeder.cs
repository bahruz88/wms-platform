using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Infrastructure.Persistence;

namespace Wms.Host.Migrator;

/// <summary>
/// Fills <c>rpt_report_definition</c> from <see cref="ReportCatalog"/>.
/// </summary>
/// <remarks>
/// Like the <c>iam</c> catalogue this is <b>system reference data</b>, not demo data: with an empty table the
/// reports screen is blank and <c>runReport</c> answers 404 for every code, so it runs on every migrator
/// invocation. Every step is an upsert keyed on <c>(tenant_id, code)</c>, so re-running only re-applies the
/// current labels and schemas, and a report that leaves the catalogue is deactivated rather than deleted —
/// an export job may still reference it.
/// </remarks>
public sealed class ReportCatalogSeeder(ReportingDbContext reporting, SeedContext context, ILogger<ReportCatalogSeeder> logger)
{
    public async Task<int> SeedAsync(CancellationToken cancellationToken)
    {
        var tenantId = context.TenantId;
        var existing = await reporting.ReportDefinitions
            .ToDictionaryAsync(r => r.Code, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);

        ushort order = 0;
        var inserted = 0;
        foreach (var entry in ReportCatalog.All)
        {
            order++;
            var formats = string.Join(',', entry.SupportedFormats.Select(f => f.ToString().ToUpperInvariant()));
            var parameters = ReportingJson.Serialize(entry.Parameters);
            var columns = ReportingJson.Serialize(entry.Columns);

            if (existing.TryGetValue(entry.Code, out var row))
            {
                row.Update(
                    entry.Name, entry.Description, entry.Category, entry.TorRef, formats,
                    entry.RequiresCostPermission, 200, order, parameters, columns);
                continue;
            }

            reporting.ReportDefinitions.Add(ReportDefinition.Create(
                tenantId, entry.Code, entry.Name, entry.Description, entry.Category, entry.TorRef, formats,
                entry.RequiresCostPermission, 200, order, parameters, columns));
            inserted++;
        }

        var retired = existing.Values.Where(r => !ReportCatalog.ByCode.ContainsKey(r.Code) && r.IsActive).ToList();
        foreach (var row in retired)
        {
            row.Deactivate();
        }

        await reporting.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        logger.LogInformation(
            "Report catalogue ready: {Total} report(s) for tenant {TenantId} ({Inserted} new, {Retired} retired)",
            ReportCatalog.All.Count, tenantId, inserted, retired.Count);
        return 0;
    }
}
