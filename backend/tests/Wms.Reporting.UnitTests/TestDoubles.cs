using System.Text.Json;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Paging;
using Wms.Common.Application.Security;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;
using Wms.Reporting.Infrastructure.Queries;
using Wms.Reporting.Infrastructure.Reports;

namespace Wms.Reporting.UnitTests;

internal sealed class FixedClock(DateTimeOffset now) : IClock
{
    public static readonly DateTimeOffset Default = new(2026, 9, 22, 8, 0, 0, TimeSpan.Zero);

    public DateTimeOffset UtcNow { get; } = now;

    public static FixedClock At(DateTimeOffset? now = null) => new(now ?? Default);
}

internal sealed class StubTenantContext(uint tenantId = 1) : ITenantContext
{
    public uint TenantId { get; } = tenantId;

    public bool HasTenant => TenantId != 0;
}

/// <summary>A principal with an explicit permission set and location scope — the two gates every report obeys.</summary>
internal sealed class StubCurrentUser : ICurrentUser
{
    public StubCurrentUser(LocationScope? scope = null, params string[] permissions)
    {
        LocationScope = scope ?? LocationScope.Unrestricted;
        Permissions = permissions;
    }

    public bool IsAuthenticated => true;

    public uint UserId { get; init; } = 7;

    public string ExternalId => "stub";

    public string Username => "stub";

    public string FullName => "Stub";

    public IReadOnlyCollection<string> Roles => ["ADMIN"];

    public IReadOnlyCollection<string> Permissions { get; }

    public LocationScope LocationScope { get; }

    public IReadOnlyCollection<uint> LocationIds => LocationScope.VisibleIds;

    public bool HasPermission(string permission) =>
        Permissions.Contains(permission, StringComparer.OrdinalIgnoreCase);
}

/// <summary>Serves the real <see cref="ReportCatalog"/> without a database, exactly as the seeded table would.</summary>
internal sealed class StubCatalogQueries : IReportCatalogQueries
{
    public Task<IReadOnlyList<ReportDefinitionDto>> ListAsync(ReportCategory? category, bool includeCostReports, CancellationToken cancellationToken)
    {
        var rows = ReportCatalog.All
            .Where(e => category is null || e.Category == category)
            .Where(e => includeCostReports || !e.RequiresCostPermission)
            .Select(Map)
            .ToList();
        return Task.FromResult<IReadOnlyList<ReportDefinitionDto>>(rows);
    }

    public Task<ReportDefinitionDto?> GetAsync(string code, CancellationToken cancellationToken) =>
        Task.FromResult(ReportCatalog.ByCode.TryGetValue(code, out var entry) ? Map(entry) : null);

    private static ReportDefinitionDto Map(ReportCatalogEntry entry) =>
        new(entry.Code, entry.Name, entry.Description, entry.Category, entry.TorRef,
            entry.Parameters, entry.Columns, entry.RequiresCostPermission, entry.SupportedFormats, 200);
}

/// <summary>Records what the runner asked Inventory for and answers with one fabricated row.</summary>
internal sealed class RecordingInventorySource : IInventoryReportingSource
{
    public ReportingScope? LastScope { get; private set; }

    public ReportSlice? LastSlice { get; private set; }

    public string? LastDocType { get; private set; }

    public uint? LastLocationId { get; private set; }

    public DateOnly? LastFrom { get; private set; }

    public DateOnly? LastTo { get; private set; }

    public InventoryDashboardDto Dashboard { get; set; } = new(
        1234.5678m, 42, 100m, 30, 7, 3, 2, 1, 4, 1, 5, 9, 6, 250m, 100m,
        [new DashboardDayPoint(new DateOnly(2026, 9, 21), 2m)],
        [new DashboardDayPoint(new DateOnly(2026, 9, 21), 1m)],
        [new DashboardDayPoint(new DateOnly(2026, 9, 21), 25m)]);

    public Task<InventoryDashboardDto> GetDashboardAsync(InventoryDashboardRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastLocationId = request.LocationId;
        LastFrom = request.PeriodFrom;
        LastTo = request.PeriodTo;
        return Task.FromResult(Dashboard);
    }

    public Task<ReportRowSet<StockBalanceReportRow>> GetStockBalancesAsync(StockBalanceReportRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastSlice = request.Slice;
        LastLocationId = request.LocationId;
        return Task.FromResult(new ReportRowSet<StockBalanceReportRow>(
            [new StockBalanceReportRow(1, 2, 12.5m, 1m, 11.5m, 3.2500m, 40.6250m, 1)], 1));
    }

    public Task<ReportRowSet<BatchStockReportRow>> GetBatchStockAsync(BatchStockReportRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastSlice = request.Slice;
        return Task.FromResult(new ReportRowSet<BatchStockReportRow>(
            [new BatchStockReportRow(5, "B-1", 1, 2, new DateOnly(2026, 10, 1), null, "ACTIVE", 9, 3, 4m, 2m, 8m)], 1));
    }

    public Task<ReportRowSet<MovementLedgerReportRow>> GetMovementsAsync(MovementReportRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastSlice = request.Slice;
        LastDocType = request.DocType;
        LastFrom = request.DateFrom;
        LastTo = request.DateTo;
        return Task.FromResult(new ReportRowSet<MovementLedgerReportRow>(
            [new MovementLedgerReportRow(11, 3, FixedClock.Default, new DateOnly(2026, 9, 20), "RECEIPT", "GR-2026-00001", 1, 2, null, null, 5m, 2m, 10m, null)], 1));
    }

    public Task<ReportRowSet<MovementAggregateReportRow>> GetMovementAggregateAsync(MovementAggregateReportRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastSlice = request.Slice;
        LastDocType = request.DocType;
        LastFrom = request.DateFrom;
        LastTo = request.DateTo;
        return Task.FromResult(new ReportRowSet<MovementAggregateReportRow>(
            [new MovementAggregateReportRow(1, 2, 7m, 14m, 3, new DateOnly(2026, 9, 1), new DateOnly(2026, 9, 20))], 1));
    }

    public Task<ReportRowSet<CountVarianceReportRow>> GetCountVariancesAsync(CountVarianceReportRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastSlice = request.Slice;
        return Task.FromResult(new ReportRowSet<CountVarianceReportRow>(
            [new CountVarianceReportRow(3, "CNT-1", new DateOnly(2026, 9, 10), "POSTED", 2, 1, null, null, 10m, 9m, -1m, -10m, 2m, -2m)], 1));
    }

    public Task<ReportRowSet<ReceiptVarianceReportRow>> GetReceiptVariancesAsync(ReceiptVarianceReportRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastSlice = request.Slice;
        return Task.FromResult(new ReportRowSet<ReceiptVarianceReportRow>(
            [new ReceiptVarianceReportRow(4, "GR-1", new DateOnly(2026, 9, 5), "POSTED", 2, 3, 1, 10m, 9m, 9m, 0m, -1m, -10m, 2m)], 1));
    }

    public Task<ReportRowSet<StockCoverageReportRow>> GetStockCoverageAsync(StockCoverageReportRequest request, CancellationToken cancellationToken)
    {
        LastScope = request.Scope;
        LastSlice = request.Slice;
        return Task.FromResult(new ReportRowSet<StockCoverageReportRow>(
            [new StockCoverageReportRow(1, 2, 20m, 30m, 1m, 20m, 2m, 40m)], 1));
    }
}

/// <summary>Labels without MasterData: one product, one location, one supplier.</summary>
internal sealed class StubReferenceLoader : IReportReferenceLoader
{
    public Task<ReportReferenceData> LoadAsync(
        IEnumerable<uint> productIds,
        IEnumerable<uint> locationIds,
        IEnumerable<uint> supplierIds,
        CancellationToken cancellationToken)
    {
        var products = new Dictionary<uint, ProductDto>
        {
            [1] = new(1, "SKU-1", "Toyuq filesi", 1, "FOOD_PRODUCT", 1, "KQ", 3, true, true, "FEFO", 10, 5m, 100m, 20m, 18m, true),
        };
        var locations = new Dictionary<uint, LocationDto>
        {
            [2] = new(2, "WH-01", "Mərkəzi anbar", "CENTRAL_WAREHOUSE", null, false, true, true, true),
        };
        var suppliers = new Dictionary<uint, SupplierRefDto>
        {
            [3] = new(3, "SUP-1", "Təchizatçı A", "AZN", true, true),
        };
        return Task.FromResult(new ReportReferenceData(products, locations, suppliers));
    }
}

internal sealed class FakeAuditTrail : IAuditTrail
{
    public List<(string EntityType, long EntityId, AuditAction Action)> Entries { get; } = [];

    public void Record(string entityType, long entityId, AuditAction action, object? changes = null) =>
        Entries.Add((entityType, entityId, action));
}

internal sealed class FakeReportingUnitOfWork : IReportingUnitOfWork
{
    public FakeAuditTrail AuditTrail { get; } = new();

    public int SaveCount { get; private set; }

    public IAuditTrail Audit => AuditTrail;

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken)
    {
        SaveCount++;
        return Task.FromResult(1);
    }
}

/// <summary>In-memory <c>rpt_export_job</c>.</summary>
internal sealed class FakeExportJobRepository : IExportJobRepository, IExportJobQueries
{
    private long _nextId = 1;

    public List<ExportJob> Jobs { get; } = [];

    public Task<ExportJob?> GetAsync(long id, CancellationToken cancellationToken) =>
        Task.FromResult(Jobs.Find(j => j.Id == id));

    public Task<ExportJob?> FindByIdempotencyKeyAsync(uint requestedBy, Guid idempotencyKey, CancellationToken cancellationToken) =>
        Task.FromResult(Jobs.Find(j => j.RequestedBy == requestedBy && j.IdempotencyKey == idempotencyKey));

    public Task<int> CountActiveAsync(uint requestedBy, CancellationToken cancellationToken) =>
        Task.FromResult(Jobs.Count(j => j.RequestedBy == requestedBy && j.IsActive));

    public Task<IReadOnlyList<long>> DueJobIdsAsync(int max, CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<long>>([.. Jobs.Where(j => j.Status == ExportStatus.Queued).Take(max).Select(j => j.Id)]);

    public void Add(ExportJob job)
    {
        // Entity<TId>.Id has a protected setter; the database assigns it in production.
        typeof(Wms.Common.Domain.Entity<long>)
            .GetProperty("Id")!
            .GetSetMethod(nonPublic: true)!
            .Invoke(job, [_nextId++]);
        Jobs.Add(job);
    }

    public Task<PagedResult<ExportJobDto>> ListAsync(ExportJobFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        var rows = Jobs
            .Where(j => j.RequestedBy == filter.RequestedBy && j.RequestedAt >= filter.Since)
            .Where(j => filter.Status is null || j.Status == filter.Status)
            .Select(Map)
            .ToList();
        return Task.FromResult(new PagedResult<ExportJobDto>(rows, page.Page, page.Size, rows.Count));
    }

    public Task<ExportJobDto?> GetAsync(long id, uint requestedBy, bool anyUser, CancellationToken cancellationToken)
    {
        var job = Jobs.Find(j => j.Id == id && (anyUser || j.RequestedBy == requestedBy));
        return Task.FromResult(job is null ? null : Map(job));
    }

    private static ExportJobDto Map(ExportJob job) =>
        new(job.Id, job.ReportCode, job.Format, job.Status, job.ProgressPct, job.RowCount, job.FileName,
            job.SizeBytes, null, null, job.ErrorMessage, job.RequestedAt, job.CompletedAt, job.ExpiresAt,
            Wms.Reporting.Contracts.ReportingRoutes.ExportStatusUrl(job.Id));
}

internal sealed class FakeExportFileStore : IExportFileStore
{
    public Dictionary<string, byte[]> Objects { get; } = new(StringComparer.Ordinal);

    public List<string> Removed { get; } = [];

    public TimeSpan DownloadUrlLifetime => TimeSpan.FromMinutes(5);

    public Task<string> UploadAsync(string objectKey, byte[] content, string contentType, CancellationToken cancellationToken)
    {
        Objects[objectKey] = content;
        return Task.FromResult(objectKey);
    }

    public Task<Uri> PresignDownloadAsync(string objectKey, string fileName, string contentType, TimeSpan lifetime, CancellationToken cancellationToken) =>
        Task.FromResult(new Uri($"http://minio/{objectKey}?sig=fake"));

    public Task RemoveAsync(string objectKey, CancellationToken cancellationToken)
    {
        Removed.Add(objectKey);
        Objects.Remove(objectKey);
        return Task.CompletedTask;
    }
}

internal static class Json
{
    public static Dictionary<string, JsonElement> Parameters(string json) =>
        JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(json, ReportingJson.Options) ?? [];

    public static Dictionary<string, JsonElement> Empty => [];
}
