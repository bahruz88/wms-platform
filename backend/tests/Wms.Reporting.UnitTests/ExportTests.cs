using System.IO.Compression;
using System.Text;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Security;
using Wms.Reporting.Application;
using Wms.Reporting.Application.Commands;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;
using Wms.Reporting.Infrastructure.Export;

namespace Wms.Reporting.UnitTests;

/// <summary>The asynchronous export pair of reporting.v1.yaml: <c>POST /exports</c> and <c>GET /exports/{id}</c>.</summary>
public sealed class ExportCommandTests
{
    private readonly FakeExportJobRepository _repository = new();
    private readonly FakeReportingUnitOfWork _unitOfWork = new();
    private readonly FakeExportFileStore _files = new();

    private CreateExportCommandHandler Handler(bool includeCost = true, LocationScope? scope = null) =>
        new(
            new StubCatalogQueries(),
            _repository,
            _repository,
            _unitOfWork,
            new StubTenantContext(),
            User(includeCost, scope),
            FixedClock.At());

    private static StubCurrentUser User(bool includeCost = true, LocationScope? scope = null) =>
        includeCost
            ? new StubCurrentUser(scope, ReportingPermissions.ExportCreate, ReportingPermissions.ViewCost)
            : new StubCurrentUser(scope, ReportingPermissions.ExportCreate);

    private static CreateExportCommand Command(
        string code = ReportCatalog.StockBalance,
        ExportFormat format = ExportFormat.Xlsx,
        Guid? key = null) =>
        new(code, format, Json.Empty, null, null, key ?? Guid.NewGuid());

    [Fact]
    public async Task A_queued_job_is_created_and_audited()
    {
        var result = await Handler().HandleAsync(Command(), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(ExportStatus.Queued, result.Value.Status);
        Assert.Equal(ReportCatalog.StockBalance, result.Value.ReportCode);
        Assert.Equal("/api/v1/reporting/exports/1", result.Value.StatusUrl);

        // TOR: exporting a report is audited.
        Assert.Contains(_unitOfWork.AuditTrail.Entries, e => e.Action == AuditAction.Export && e.EntityId == 1);
    }

    [Fact]
    public async Task An_unknown_report_is_not_found()
    {
        var result = await Handler().HandleAsync(Command("NO_SUCH_REPORT"), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(404, result.Error.Status);
    }

    [Fact]
    public async Task A_format_the_report_does_not_support_is_unprocessable()
    {
        // No report renders PDF: there is no PDF writer, so the catalogue never offers the format.
        var result = await Handler().HandleAsync(Command(format: ExportFormat.Pdf), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(422, result.Error.Status);
        Assert.Equal("UNSUPPORTED_FORMAT", result.Error.Code);
    }

    [Fact]
    public async Task A_repeated_idempotency_key_conflicts()
    {
        var key = Guid.NewGuid();
        await Handler().HandleAsync(Command(key: key), TestCancellation.Token);

        var second = await Handler().HandleAsync(Command(key: key), TestCancellation.Token);

        Assert.True(second.IsFailure);
        Assert.Equal(409, second.Error.Status);
        Assert.Equal("IDEMPOTENT_REPLAY", second.Error.Code);
    }

    [Fact]
    public async Task A_fourth_active_job_is_refused()
    {
        for (var i = 0; i < ExportJob.MaxActivePerUser; i++)
        {
            Assert.True((await Handler().HandleAsync(Command(), TestCancellation.Token)).IsSuccess);
        }

        var extra = await Handler().HandleAsync(Command(), TestCancellation.Token);

        Assert.True(extra.IsFailure);
        Assert.Equal(422, extra.Error.Status);
        Assert.Equal("TOO_MANY_ACTIVE_EXPORTS", extra.Error.Code);
    }

    [Fact]
    public async Task The_requesters_scope_and_cost_permission_are_frozen_onto_the_row()
    {
        await Handler(includeCost: false, scope: LocationScope.RestrictedTo([4u, 8u]))
            .HandleAsync(Command(), TestCancellation.Token);

        var job = Assert.Single(_repository.Jobs);
        Assert.False(job.IncludeCost);
        Assert.Equal([4u, 8u], ReportingJson.Deserialize<uint[]>(job.LocationScopeJson)!);
    }

    [Fact]
    public async Task An_unrestricted_requester_stores_no_scope()
    {
        await Handler().HandleAsync(Command(), TestCancellation.Token);

        Assert.Null(Assert.Single(_repository.Jobs).LocationScopeJson);
    }

    [Fact]
    public async Task Cancelling_a_completed_job_removes_the_file()
    {
        await Handler().HandleAsync(Command(), TestCancellation.Token);
        var job = Assert.Single(_repository.Jobs);
        job.Complete("exports/1/1/file.xlsx", "STOCK_BALANCE_2026-09-22.xlsx", 10, 1, FixedClock.Default);
        await _files.UploadAsync("exports/1/1/file.xlsx", [1, 2, 3], "application/octet-stream", TestCancellation.Token);

        var handler = new CancelExportCommandHandler(_repository, _files, _unitOfWork, User(), FixedClock.At());
        var result = await handler.HandleAsync(new CancelExportCommand(job.Id), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(ExportStatus.Cancelled, job.Status);
        Assert.Contains("exports/1/1/file.xlsx", _files.Removed);
        Assert.Empty(_files.Objects);
    }

    [Fact]
    public async Task Cancelling_somebody_elses_job_is_not_found()
    {
        await Handler().HandleAsync(Command(), TestCancellation.Token);

        var stranger = new StubCurrentUser(null, ReportingPermissions.ExportCreate) { UserId = 99 };
        var handler = new CancelExportCommandHandler(_repository, _files, _unitOfWork, stranger, FixedClock.At());
        var result = await handler.HandleAsync(new CancelExportCommand(1), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(404, result.Error.Status);
    }
}

/// <summary>Lifecycle of <c>rpt_export_job</c>.</summary>
public sealed class ExportJobTests
{
    private static ExportJob New() => ExportJob.Create(
        1, "stock_balance", ExportFormat.Csv, "{}", null, true, null, null, 7, Guid.NewGuid(), FixedClock.Default);

    [Fact]
    public void A_new_job_is_queued_and_its_code_is_normalised()
    {
        var job = New();

        Assert.Equal(ExportStatus.Queued, job.Status);
        Assert.Equal("STOCK_BALANCE", job.ReportCode);
        Assert.True(job.IsActive);
        Assert.Equal<byte?>(0, job.ProgressPct);
    }

    [Fact]
    public void A_completed_job_keeps_its_file_for_seven_days()
    {
        var job = New();
        job.Start(FixedClock.Default);
        job.Complete("key", "file.csv", 120, 4, FixedClock.Default);

        Assert.Equal(ExportStatus.Completed, job.Status);
        Assert.Equal<byte?>(100, job.ProgressPct);
        Assert.Equal(FixedClock.Default.AddDays(ExportJob.RetentionDays), job.ExpiresAt);
        Assert.Equal<long?>(4, job.RowCount);
        Assert.False(job.IsActive);
    }

    [Fact]
    public void A_failed_job_records_the_reason_and_stops_being_active()
    {
        var job = New();
        job.Start(FixedClock.Default);
        job.Fail("boom", FixedClock.Default);

        Assert.Equal(ExportStatus.Failed, job.Status);
        Assert.Equal("boom", job.ErrorMessage);
        Assert.False(job.IsActive);
    }

    [Fact]
    public void Cancelling_forgets_the_storage_key_so_nothing_can_be_downloaded_afterwards()
    {
        var job = New();
        job.Complete("key", "file.csv", 120, 4, FixedClock.Default);
        job.Cancel(FixedClock.Default);

        Assert.Equal(ExportStatus.Cancelled, job.Status);
        Assert.Null(job.StorageKey);
        Assert.Null(job.ExpiresAt);
    }
}

/// <summary>The two export writers. Excel output is a real OPC package, not a renamed CSV.</summary>
public sealed class ExportRendererTests
{
    private static ReportDataSet DataSet() => new(
        ReportCatalog.StockBalance,
        "Cari qalıq",
        [
            new ReportColumnDefinition("sku", "SKU", ReportColumnType.String),
            new ReportColumnDefinition("productName", "Məhsul", ReportColumnType.String),
            new ReportColumnDefinition("qtyOnHand", "Qalıq", ReportColumnType.Decimal),
            new ReportColumnDefinition("totalValue", "Dəyər", ReportColumnType.Money, IsCost: true),
        ],
        [
            ["SKU-1", "Toyuq, \"filesi\"", "12.5000", "40.6250"],
            ["SKU-2", "Kartof", "3.0000", null],
        ],
        new Dictionary<string, string>(StringComparer.Ordinal) { ["totalValue"] = "40.6250" },
        FixedClock.Default);

    [Fact]
    public void The_xlsx_package_carries_the_parts_excel_requires()
    {
        var bytes = new XlsxExportRenderer().Render(DataSet());

        using var archive = new ZipArchive(new MemoryStream(bytes), ZipArchiveMode.Read);
        var entries = archive.Entries.Select(e => e.FullName).ToList();
        Assert.Contains("[Content_Types].xml", entries);
        Assert.Contains("_rels/.rels", entries);
        Assert.Contains("xl/workbook.xml", entries);
        Assert.Contains("xl/_rels/workbook.xml.rels", entries);
        Assert.Contains("xl/styles.xml", entries);
        Assert.Contains("xl/worksheets/sheet1.xml", entries);
    }

    [Fact]
    public void The_xlsx_sheet_holds_the_headers_and_writes_quantities_as_numbers()
    {
        var bytes = new XlsxExportRenderer().Render(DataSet());

        using var archive = new ZipArchive(new MemoryStream(bytes), ZipArchiveMode.Read);
        using var reader = new StreamReader(archive.GetEntry("xl/worksheets/sheet1.xml")!.Open());
        var sheet = reader.ReadToEnd();

        Assert.Contains("SKU", sheet, StringComparison.Ordinal);
        Assert.Contains("Məhsul", sheet, StringComparison.Ordinal);
        // A decimal column becomes a real number cell, so the spreadsheet can sum it.
        Assert.Contains("<v>12.5000</v>", sheet, StringComparison.Ordinal);
        // XML special characters in the data are escaped, not dropped.
        Assert.Contains("&quot;filesi&quot;", sheet, StringComparison.Ordinal);
    }

    [Fact]
    public void Xlsx_column_names_follow_the_spreadsheet_alphabet()
    {
        Assert.Equal("A", XlsxWriter.ColumnName(0));
        Assert.Equal("Z", XlsxWriter.ColumnName(25));
        Assert.Equal("AA", XlsxWriter.ColumnName(26));
        Assert.Equal("AB", XlsxWriter.ColumnName(27));
        Assert.Equal("BA", XlsxWriter.ColumnName(52));
    }

    [Fact]
    public void The_csv_starts_with_a_bom_and_quotes_what_rfc_4180_requires()
    {
        var bytes = new CsvExportRenderer().Render(DataSet());

        Assert.Equal(Encoding.UTF8.GetPreamble(), bytes.Take(3));
        var text = Encoding.UTF8.GetString(bytes, 3, bytes.Length - 3);
        Assert.StartsWith("SKU,Məhsul,Qalıq,Dəyər\r\n", text, StringComparison.Ordinal);
        Assert.Contains("\"Toyuq, \"\"filesi\"\"\"", text, StringComparison.Ordinal);
        // A null cell is an empty field, never the word "null".
        Assert.EndsWith("SKU-2,Kartof,3.0000,\r\n", text, StringComparison.Ordinal);
    }

    [Fact]
    public void Both_renderers_declare_the_media_type_the_download_url_will_be_signed_with()
    {
        Assert.Equal(XlsxWriter.ContentType, new XlsxExportRenderer().ContentType);
        Assert.Equal("text/csv", new CsvExportRenderer().ContentType);
        Assert.Equal(ExportFormat.Xlsx, new XlsxExportRenderer().Format);
        Assert.Equal(ExportFormat.Csv, new CsvExportRenderer().Format);
    }
}
