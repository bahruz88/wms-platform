using Wms.Reporting.Application;
using Wms.Reporting.Application.Commands;
using Wms.Reporting.Application.Queries;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.UnitTests;

/// <summary><c>listReports</c> and <c>getReportDefinition</c>.</summary>
public sealed class CatalogueQueryTests
{
    private static ListReportsQueryHandler List(bool includeCost) =>
        new(new StubCatalogQueries(), Principal(includeCost));

    private static GetReportDefinitionQueryHandler Get(bool includeCost) =>
        new(new StubCatalogQueries(), Principal(includeCost));

    private static StubCurrentUser Principal(bool includeCost) =>
        includeCost
            ? new StubCurrentUser(null, ReportingPermissions.ReportView, ReportingPermissions.ViewCost)
            : new StubCurrentUser(null, ReportingPermissions.ReportView);

    [Fact]
    public async Task The_catalogue_is_an_array_not_a_page()
    {
        var result = await List(includeCost: true).HandleAsync(new ListReportsQuery(null), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(ReportCatalog.All.Count, result.Value.Count);
    }

    [Fact]
    public async Task A_category_filter_narrows_the_catalogue()
    {
        var result = await List(includeCost: true).HandleAsync(new ListReportsQuery(ReportCategory.Stock), TestCancellation.Token);

        Assert.NotEmpty(result.Value);
        Assert.All(result.Value, r => Assert.Equal(ReportCategory.Stock, r.Category));
    }

    [Fact]
    public async Task Cost_columns_are_stripped_from_the_catalogue_itself()
    {
        var withCost = await List(includeCost: true).HandleAsync(new ListReportsQuery(null), TestCancellation.Token);
        var withoutCost = await List(includeCost: false).HandleAsync(new ListReportsQuery(null), TestCancellation.Token);

        Assert.Contains(withCost.Value.SelectMany(r => r.Columns), c => c.IsCost);
        Assert.DoesNotContain(withoutCost.Value.SelectMany(r => r.Columns), c => c.IsCost);
    }

    [Fact]
    public async Task A_definition_is_served_with_its_parameter_schema()
    {
        var result = await Get(includeCost: true)
            .HandleAsync(new GetReportDefinitionQuery(ReportCatalog.MovementLedger), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(ReportCatalog.MovementLedger, result.Value.Code);
        Assert.Contains(result.Value.Parameters, p => p.Name == "dateRange" && p.Type == ReportParamType.DateRange);
        Assert.Contains(result.Value.Parameters, p => p.Name == "docType" && p.AllowedValues is { Count: > 0 });
        Assert.Equal(200, result.Value.MaxSyncRows);
    }

    [Fact]
    public async Task An_unknown_code_is_not_found()
    {
        var result = await Get(includeCost: true)
            .HandleAsync(new GetReportDefinitionQuery("NOPE_REPORT"), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(404, result.Error.Status);
    }
}

/// <summary><c>ReportRunRequest.sort</c> is <c>columnKey,asc|desc</c>.</summary>
public sealed class SortParserTests
{
    [Theory]
    [InlineData(null, null, false)]
    [InlineData("", null, false)]
    [InlineData("qtyOnHand", "qtyOnHand", false)]
    [InlineData("qtyOnHand,asc", "qtyOnHand", false)]
    [InlineData("qtyOnHand,desc", "qtyOnHand", true)]
    [InlineData(" qtyOnHand , DESC ", "qtyOnHand", true)]
    public void A_sort_expression_is_split_into_a_key_and_a_direction(string? sort, string? key, bool descending)
    {
        var (parsedKey, parsedDescending) = SortParser.Parse(sort);

        Assert.Equal(key, parsedKey);
        Assert.Equal(descending, parsedDescending);
    }
}
