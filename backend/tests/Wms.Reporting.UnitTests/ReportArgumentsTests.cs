using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Infrastructure.Reports;

namespace Wms.Reporting.UnitTests;

/// <summary>
/// <c>runReport</c> answers 400 <c>VALIDATION_FAILED</c> for a parameter object the definition does not
/// describe (reporting.v1.yaml), and fills in the documented defaults for everything left out.
/// </summary>
public sealed class ReportArgumentsTests
{
    private static readonly DateOnly Today = new(2026, 9, 22);

    private static ReportDefinitionDto Definition(string code)
    {
        var entry = ReportCatalog.ByCode[code];
        return new ReportDefinitionDto(
            entry.Code, entry.Name, entry.Description, entry.Category, entry.TorRef,
            entry.Parameters, entry.Columns, entry.RequiresCostPermission, entry.SupportedFormats, 200);
    }

    [Fact]
    public void An_empty_parameter_object_yields_the_trailing_thirty_days()
    {
        var result = ReportArguments.Parse(Definition(ReportCatalog.MovementLedger), Json.Empty, Today);

        Assert.True(result.IsSuccess);
        Assert.Equal(new DateOnly(2026, 8, 24), result.Value.From);
        Assert.Equal(Today, result.Value.To);
        Assert.Null(result.Value.LocationId);
        Assert.Null(result.Value.DocType);
    }

    [Fact]
    public void Declared_defaults_are_applied()
    {
        var result = ReportArguments.Parse(Definition(ReportCatalog.CountVariance), Json.Empty, Today);

        Assert.True(result.IsSuccess);
        Assert.True(result.Value.OnlyVariances);

        var balance = ReportArguments.Parse(Definition(ReportCatalog.StockBalance), Json.Empty, Today);
        Assert.True(balance.IsSuccess);
        Assert.False(balance.Value.IncludeZero);
    }

    [Fact]
    public void An_explicit_date_range_is_honoured()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.WasteSummary),
            Json.Parameters("""{"dateRange":{"from":"2026-09-01","to":"2026-09-10"}}"""),
            Today);

        Assert.True(result.IsSuccess);
        Assert.Equal(new DateOnly(2026, 9, 1), result.Value.From);
        Assert.Equal(new DateOnly(2026, 9, 10), result.Value.To);
    }

    [Fact]
    public void A_reversed_date_range_is_rejected()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.WasteSummary),
            Json.Parameters("""{"dateRange":{"from":"2026-09-20","to":"2026-09-01"}}"""),
            Today);

        Assert.True(result.IsFailure);
        Assert.Equal("VALIDATION_FAILED", result.Error.Code);
        Assert.Contains("dateRange", result.Error.Details!.Keys);
    }

    [Fact]
    public void A_malformed_date_is_rejected()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.WasteSummary),
            Json.Parameters("""{"dateRange":{"from":"01.09.2026"}}"""),
            Today);

        Assert.True(result.IsFailure);
        Assert.Contains("dateRange", result.Error.Details!.Keys);
    }

    [Fact]
    public void A_parameter_the_report_does_not_declare_is_rejected()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.StockBalance),
            Json.Parameters("""{"supplierId":3}"""),
            Today);

        Assert.True(result.IsFailure);
        Assert.Contains("parameters", result.Error.Details!.Keys);
    }

    [Fact]
    public void An_enum_value_outside_the_allowed_list_is_rejected()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.MovementLedger),
            Json.Parameters("""{"docType":"DELIVERY"}"""),
            Today);

        Assert.True(result.IsFailure);
        Assert.Contains("docType", result.Error.Details!.Keys);
    }

    [Fact]
    public void An_allowed_enum_value_is_upper_cased()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.MovementLedger),
            Json.Parameters("""{"docType":"receipt"}"""),
            Today);

        Assert.True(result.IsSuccess);
        Assert.Equal("RECEIPT", result.Value.DocType);
    }

    [Fact]
    public void Identifiers_accept_both_the_number_and_the_string_form()
    {
        var number = ReportArguments.Parse(Definition(ReportCatalog.StockBalance), Json.Parameters("""{"locationId":4}"""), Today);
        var text = ReportArguments.Parse(Definition(ReportCatalog.StockBalance), Json.Parameters("""{"locationId":"4"}"""), Today);

        Assert.Equal(4u, number.Value.LocationId);
        Assert.Equal(4u, text.Value.LocationId);
    }

    [Fact]
    public void An_out_of_range_integer_is_rejected()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.Expiry),
            Json.Parameters("""{"withinDays":100000}"""),
            Today);

        Assert.True(result.IsFailure);
        Assert.Contains("withinDays", result.Error.Details!.Keys);
    }

    [Fact]
    public void A_non_boolean_flag_is_rejected()
    {
        var result = ReportArguments.Parse(
            Definition(ReportCatalog.StockBalance),
            Json.Parameters("""{"includeZero":"maybe"}"""),
            Today);

        Assert.True(result.IsFailure);
        Assert.Contains("includeZero", result.Error.Details!.Keys);
    }
}
