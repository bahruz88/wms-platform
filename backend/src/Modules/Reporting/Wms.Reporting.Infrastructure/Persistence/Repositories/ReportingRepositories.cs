using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Paging;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Contracts;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Infrastructure.Persistence.Repositories;

public sealed class ReportingUnitOfWork(ReportingDbContext db) : IReportingUnitOfWork
{
    public IAuditTrail Audit => db;

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);
}

public sealed class ExportJobRepository(ReportingDbContext db) : IExportJobRepository
{
    public Task<ExportJob?> GetAsync(long id, CancellationToken cancellationToken) =>
        db.ExportJobs.FirstOrDefaultAsync(j => j.Id == id, cancellationToken);

    public Task<ExportJob?> FindByIdempotencyKeyAsync(uint requestedBy, Guid idempotencyKey, CancellationToken cancellationToken) =>
        db.ExportJobs.AsNoTracking()
            .FirstOrDefaultAsync(j => j.RequestedBy == requestedBy && j.IdempotencyKey == idempotencyKey, cancellationToken);

    public Task<int> CountActiveAsync(uint requestedBy, CancellationToken cancellationToken) =>
        db.ExportJobs.AsNoTracking()
            .CountAsync(j => j.RequestedBy == requestedBy && (j.Status == ExportStatus.Queued || j.Status == ExportStatus.Running), cancellationToken);

    public async Task<IReadOnlyList<long>> DueJobIdsAsync(int max, CancellationToken cancellationToken) =>
        await db.ExportJobs.AsNoTracking()
            .Where(j => j.Status == ExportStatus.Queued)
            .OrderBy(j => j.RequestedAt)
            .Take(max)
            .Select(j => j.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

    public void Add(ExportJob job) => db.ExportJobs.Add(job);
}

/// <summary>Tenants that have a report catalogue — the recurring export runner iterates exactly these.</summary>
public sealed class ReportingTenantScanner(ReportingDbContext db) : IReportingTenantScanner
{
    public async Task<IReadOnlyList<uint>> GetActiveTenantsAsync(CancellationToken cancellationToken) =>
        await db.ReportDefinitions.IgnoreQueryFilters().AsNoTracking()
            .Select(r => r.TenantId)
            .Distinct()
            .OrderBy(id => id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
}

/// <summary>
/// <c>common_outbox</c> is shared platform infrastructure that every module context maps (spec §11), not
/// another module's table, so reading its backlog crosses no boundary.
/// </summary>
public sealed class OutboxBacklogReader(ReportingDbContext db) : IOutboxBacklogReader
{
    public Task<int> CountPendingAsync(CancellationToken cancellationToken) =>
        db.Outbox.AsNoTracking().CountAsync(m => m.ProcessedAt == null, cancellationToken);
}

/// <summary>Read side of <c>rpt_export_job</c>; fills <c>downloadUrl</c> with a fresh presigned link.</summary>
public sealed class ExportJobQueries(ReportingDbContext db, IExportFileStore files, IClock clock) : IExportJobQueries
{
    public async Task<PagedResult<ExportJobDto>> ListAsync(ExportJobFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.ExportJobs.AsNoTracking()
            .Where(j => j.RequestedBy == filter.RequestedBy && j.RequestedAt >= filter.Since);
        if (filter.Status is { } status)
        {
            query = query.Where(j => j.Status == status);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(j => j.RequestedAt)
            .ThenByDescending(j => j.Id)
            .Skip(page.Skip)
            .Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = new List<ExportJobDto>(rows.Count);
        foreach (var row in rows)
        {
            items.Add(await MapAsync(row, cancellationToken).ConfigureAwait(false));
        }

        return new PagedResult<ExportJobDto>(items, page.Page, page.Size, total);
    }

    public async Task<ExportJobDto?> GetAsync(long id, uint requestedBy, bool anyUser, CancellationToken cancellationToken)
    {
        var row = await db.ExportJobs.AsNoTracking()
            .FirstOrDefaultAsync(j => j.Id == id && (anyUser || j.RequestedBy == requestedBy), cancellationToken)
            .ConfigureAwait(false);
        return row is null ? null : await MapAsync(row, cancellationToken).ConfigureAwait(false);
    }

    private async Task<ExportJobDto> MapAsync(ExportJob row, CancellationToken cancellationToken)
    {
        Uri? downloadUrl = null;
        DateTimeOffset? expiresAt = null;
        if (row.Status == ExportStatus.Completed && !string.IsNullOrEmpty(row.StorageKey))
        {
            // Contract: presigned for five minutes and refreshed on every read.
            downloadUrl = await files
                .PresignDownloadAsync(row.StorageKey, row.FileName ?? "export", ContentTypeOf(row.Format), files.DownloadUrlLifetime, cancellationToken)
                .ConfigureAwait(false);
            expiresAt = clock.UtcNow.Add(files.DownloadUrlLifetime);
        }

        return new ExportJobDto(
            row.Id,
            row.ReportCode,
            row.Format,
            row.Status,
            row.ProgressPct,
            row.RowCount,
            row.FileName,
            row.SizeBytes,
            downloadUrl?.ToString(),
            expiresAt,
            row.ErrorMessage,
            row.RequestedAt,
            row.CompletedAt,
            row.ExpiresAt,
            ReportingRoutes.ExportStatusUrl(row.Id));
    }

    internal static string ContentTypeOf(ExportFormat format) => format switch
    {
        ExportFormat.Xlsx => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        ExportFormat.Csv => "text/csv",
        _ => "application/pdf",
    };
}
