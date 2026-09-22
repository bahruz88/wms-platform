using System.Text.Json;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Paging;
using Wms.Common.Application.Security;
using Wms.Common.Domain;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Application.Abstractions;

/// <summary>
/// Filter of <c>getDashboardSummary</c>. <see cref="VisibleLocations"/> carries the spec §16 restriction: a
/// branch principal's dashboard describes their branch, not the company.
/// </summary>
public sealed record DashboardFilter(
    uint? LocationId,
    DashboardPeriod Period,
    LocationScope VisibleLocations,
    bool IncludeCost,
    bool IncludeSystemHealth);

/// <summary>Filter of <c>runReport</c> and of an export render — the same shape drives both.</summary>
public sealed record ReportRunFilter(
    string Code,
    IReadOnlyDictionary<string, JsonElement> Parameters,
    LocationScope VisibleLocations,
    bool IncludeCost,
    int Page,
    int Size,
    string? SortKey,
    bool SortDescending);

/// <summary>
/// Filter of <c>listExports</c>. Export jobs are the requester's own rows (contract: "Mənim export işlərim"),
/// so they are scoped by <see cref="RequestedBy"/> and not by location; the location scope that applies to the
/// report data itself is frozen on the job row when it is created.
/// </summary>
public sealed record ExportJobFilter(ExportStatus? Status, uint RequestedBy, DateTimeOffset Since);

/// <summary>Reads <c>rpt_report_definition</c>. The catalogue is data; nothing else describes a report.</summary>
public interface IReportCatalogQueries
{
    Task<IReadOnlyList<ReportDefinitionDto>> ListAsync(ReportCategory? category, bool includeCostReports, CancellationToken cancellationToken);

    Task<ReportDefinitionDto?> GetAsync(string code, CancellationToken cancellationToken);
}

/// <summary>Assembles <c>DashboardSummary</c> from the module contracts (Inventory, MasterData) and <c>common_outbox</c>.</summary>
public interface IDashboardQueries
{
    Task<DashboardSummaryDto> GetAsync(DashboardFilter filter, CancellationToken cancellationToken);
}

/// <summary>Executes one catalogue report and shapes it into the contract's column/row form.</summary>
public interface IReportRunner
{
    Task<Result<ReportResultPageDto>> RunAsync(ReportRunFilter filter, CancellationToken cancellationToken);

    /// <summary>Whole result set for an export, bounded by <see cref="ExportRowCap"/>.</summary>
    Task<Result<ReportDataSet>> RenderAsync(ReportRunFilter filter, CancellationToken cancellationToken);

    /// <summary>Safety net for an export: the same 20 000 row ceiling the balance list uses.</summary>
    const int ExportRowCap = 20_000;
}

public interface IExportJobRepository
{
    Task<ExportJob?> GetAsync(long id, CancellationToken cancellationToken);

    Task<ExportJob?> FindByIdempotencyKeyAsync(uint requestedBy, Guid idempotencyKey, CancellationToken cancellationToken);

    Task<int> CountActiveAsync(uint requestedBy, CancellationToken cancellationToken);

    /// <summary>Queued jobs the worker still has to render, oldest first (used by the recurring runner).</summary>
    Task<IReadOnlyList<long>> DueJobIdsAsync(int max, CancellationToken cancellationToken);

    void Add(ExportJob job);
}

public interface IExportJobQueries
{
    Task<PagedResult<ExportJobDto>> ListAsync(ExportJobFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<ExportJobDto?> GetAsync(long id, uint requestedBy, bool anyUser, CancellationToken cancellationToken);
}

/// <summary>Where a rendered export file lives (MinIO, the same bucket and client Documents uses).</summary>
public interface IExportFileStore
{
    Task<string> UploadAsync(string objectKey, byte[] content, string contentType, CancellationToken cancellationToken);

    Task<Uri> PresignDownloadAsync(string objectKey, string fileName, string contentType, TimeSpan lifetime, CancellationToken cancellationToken);

    Task RemoveAsync(string objectKey, CancellationToken cancellationToken);

    TimeSpan DownloadUrlLifetime { get; }
}

/// <summary>Turns a finished result set into the bytes of one export format.</summary>
public interface IExportRenderer
{
    ExportFormat Format { get; }

    string ContentType { get; }

    string FileExtension { get; }

    byte[] Render(ReportDataSet dataSet);
}

public interface IReportingUnitOfWork
{
    /// <summary><c>common_audit_log</c>; the contract requires an <c>EXPORT</c> row for every export job.</summary>
    IAuditTrail Audit { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}

/// <summary>
/// Unpublished <c>common_outbox</c> rows — the one <c>systemHealth</c> figure the platform actually stores
/// (spec §14.1). Kept as a port so the dashboard can be assembled without a database.
/// </summary>
public interface IOutboxBacklogReader
{
    Task<int> CountPendingAsync(CancellationToken cancellationToken);
}

/// <summary>Tenants with at least one report definition — the recurring export runner iterates them.</summary>
public interface IReportingTenantScanner
{
    Task<IReadOnlyList<uint>> GetActiveTenantsAsync(CancellationToken cancellationToken);
}
