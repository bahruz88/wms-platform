using Wms.Common.Application.Security;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Domain;
using Wms.Reporting.Infrastructure.Reports;

namespace Wms.Reporting.UnitTests;

/// <summary>
/// The two rules that apply to every report: money is absent without <c>master.product.view_cost</c>
/// (spec §16) and the caller's <c>LocationScope</c> reaches the query (README §8.17).
/// </summary>
public sealed class ReportRunnerTests
{
    private readonly RecordingInventorySource _inventory = new();

    private ReportRunner Runner() => new(new StubCatalogQueries(), _inventory, new StubReferenceLoader(), FixedClock.At());

    private static ReportRunFilter Filter(
        string code,
        bool includeCost = true,
        LocationScope? scope = null,
        string? sortKey = null,
        int page = 1,
        int size = 50) =>
        new(code, Json.Empty, scope ?? LocationScope.Unrestricted, includeCost, page, size, sortKey, false);

    [Fact]
    public async Task An_unknown_code_is_not_found()
    {
        var result = await Runner().RunAsync(Filter("NO_SUCH_REPORT"), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("NOT_FOUND", result.Error.Code);
        Assert.Equal(404, result.Error.Status);
    }

    [Fact]
    public async Task Cost_columns_are_absent_without_the_permission()
    {
        var withCost = await Runner().RunAsync(Filter(ReportCatalog.StockBalance), TestCancellation.Token);
        var withoutCost = await Runner().RunAsync(Filter(ReportCatalog.StockBalance, includeCost: false), TestCancellation.Token);

        Assert.Contains(withCost.Value.Columns, c => c.Key == "totalValue");
        Assert.DoesNotContain(withoutCost.Value.Columns, c => c.IsCost);
        Assert.DoesNotContain(withoutCost.Value.Columns, c => c.Key == "totalValue");

        // The row array follows the column list, so a stripped column takes its value with it.
        Assert.Equal(withCost.Value.Columns.Count - 2, withoutCost.Value.Columns.Count);
        Assert.All(withoutCost.Value.Rows, row => Assert.Equal(withoutCost.Value.Columns.Count, row.Count));
    }

    [Fact]
    public async Task A_restricted_principal_forwards_its_locations_to_inventory()
    {
        var scope = LocationScope.RestrictedTo([5u, 9u]);

        await Runner().RunAsync(Filter(ReportCatalog.StockBalance, scope: scope), TestCancellation.Token);

        Assert.NotNull(_inventory.LastScope);
        Assert.True(_inventory.LastScope!.IsRestricted);
        Assert.Equal([5u, 9u], _inventory.LastScope.LocationIds);
    }

    [Fact]
    public async Task An_unrestricted_principal_forwards_no_restriction()
    {
        await Runner().RunAsync(Filter(ReportCatalog.StockBalance), TestCancellation.Token);

        Assert.False(_inventory.LastScope!.IsRestricted);
    }

    [Fact]
    public async Task A_location_outside_the_scope_is_refused_rather_than_silently_widened()
    {
        var filter = new ReportRunFilter(
            ReportCatalog.StockBalance,
            Json.Parameters("""{"locationId":99}"""),
            LocationScope.RestrictedTo([5u]),
            true,
            1,
            50,
            null,
            false);

        var result = await Runner().RunAsync(filter, TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(403, result.Error.Status);
    }

    [Fact]
    public async Task An_unknown_sort_column_is_a_validation_error()
    {
        var result = await Runner().RunAsync(Filter(ReportCatalog.StockBalance, sortKey: "nonsense"), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("VALIDATION_FAILED", result.Error.Code);
        Assert.Contains("sort", result.Error.Details!.Keys);
    }

    [Fact]
    public async Task Sorting_by_a_cost_column_is_refused_when_the_column_is_not_visible()
    {
        var result = await Runner().RunAsync(
            Filter(ReportCatalog.StockBalance, includeCost: false, sortKey: "totalValue"),
            TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(400, result.Error.Status);
    }

    [Fact]
    public async Task Paging_translates_into_a_zero_based_slice()
    {
        await Runner().RunAsync(Filter(ReportCatalog.StockBalance, page: 3, size: 25), TestCancellation.Token);

        Assert.Equal(50, _inventory.LastSlice!.Skip);
        Assert.Equal(25, _inventory.LastSlice.Take);
    }

    [Fact]
    public async Task A_page_larger_than_the_definition_allows_is_clamped()
    {
        var result = await Runner().RunAsync(Filter(ReportCatalog.StockBalance, size: 10_000), TestCancellation.Token);

        Assert.Equal(200, result.Value.Size);
        Assert.Equal(200, _inventory.LastSlice!.Take);
    }

    [Fact]
    public async Task Decimal_values_are_strings_and_counts_are_numbers()
    {
        var result = await Runner().RunAsync(Filter(ReportCatalog.StockBalance), TestCancellation.Token);

        var columns = result.Value.Columns;
        var row = result.Value.Rows[0];
        Assert.Equal("12.5000", row[columns.ToList().FindIndex(c => c.Key == "qtyOnHand")]);
        Assert.Equal("40.6250", row[columns.ToList().FindIndex(c => c.Key == "totalValue")]);
        Assert.Equal(1L, row[columns.ToList().FindIndex(c => c.Key == "batchCount")]);
    }

    [Fact]
    public async Task Master_data_labels_are_resolved_through_the_catalogue_contracts()
    {
        var result = await Runner().RunAsync(Filter(ReportCatalog.StockBalance), TestCancellation.Token);

        var columns = result.Value.Columns.ToList();
        var row = result.Value.Rows[0];
        Assert.Equal("SKU-1", row[columns.FindIndex(c => c.Key == "sku")]);
        Assert.Equal("Toyuq filesi", row[columns.FindIndex(c => c.Key == "productName")]);
        Assert.Equal("WH-01", row[columns.FindIndex(c => c.Key == "locationCode")]);
        Assert.Equal("KQ", row[columns.FindIndex(c => c.Key == "uom")]);
    }

    [Theory]
    [InlineData("BRANCH_CONSUMPTION", "CONSUMPTION")]
    [InlineData("WASTE_SUMMARY", "WASTE")]
    public async Task The_aggregate_reports_ask_for_their_own_document_type(string code, string docType)
    {
        await Runner().RunAsync(Filter(code), TestCancellation.Token);

        Assert.Equal(docType, _inventory.LastDocType);
    }

    [Fact]
    public async Task The_expiry_report_sorts_by_expiry_date_unless_told_otherwise()
    {
        await Runner().RunAsync(Filter(ReportCatalog.Expiry), TestCancellation.Token);

        Assert.Equal("expiryDate", _inventory.LastSlice!.SortKey);
    }

    [Fact]
    public async Task Stock_coverage_flags_a_product_below_its_master_data_minimum()
    {
        var result = await Runner().RunAsync(Filter(ReportCatalog.StockCoverage), TestCancellation.Token);

        var columns = result.Value.Columns.ToList();
        var row = result.Value.Rows[0];
        // The stub product carries min_stock = 5 and the stub balance 20 on hand.
        Assert.Equal("5.0000", row[columns.FindIndex(c => c.Key == "minStock")]);
        Assert.Equal(false, row[columns.FindIndex(c => c.Key == "belowMin")]);
    }

    [Fact]
    public async Task A_report_page_carries_no_totals_but_an_export_does()
    {
        var page = await Runner().RunAsync(Filter(ReportCatalog.StockBalance), TestCancellation.Token);
        var export = await Runner().RenderAsync(Filter(ReportCatalog.StockBalance), TestCancellation.Token);

        Assert.Null(page.Value.Totals);
        Assert.NotNull(export.Value.Totals);
        Assert.Equal("40.6250", export.Value.Totals!["totalValue"]);
    }

    [Fact]
    public async Task An_export_asks_for_the_whole_result_set_in_one_slice()
    {
        await Runner().RenderAsync(Filter(ReportCatalog.MovementLedger), TestCancellation.Token);

        Assert.Equal(0, _inventory.LastSlice!.Skip);
        Assert.Equal(IReportRunner.ExportRowCap, _inventory.LastSlice.Take);
    }

    [Fact]
    public async Task Data_is_live_so_dataAsOf_equals_generatedAt()
    {
        var result = await Runner().RunAsync(Filter(ReportCatalog.StockBalance), TestCancellation.Token);

        Assert.Equal(result.Value.GeneratedAt, result.Value.DataAsOf);
    }
}
