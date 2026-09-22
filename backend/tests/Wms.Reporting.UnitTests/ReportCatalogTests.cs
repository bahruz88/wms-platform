using System.Text.RegularExpressions;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.UnitTests;

/// <summary>
/// The catalogue is what <c>listReports</c> serves and what the migrator writes into
/// <c>rpt_report_definition</c>, so it has to satisfy reporting.v1.yaml before it reaches the database.
/// </summary>
public sealed class ReportCatalogTests
{
    public static TheoryData<string> Codes()
    {
        var data = new TheoryData<string>();
        foreach (var entry in ReportCatalog.All)
        {
            data.Add(entry.Code);
        }

        return data;
    }

    [Fact]
    public void The_catalogue_is_not_empty_and_every_code_is_unique()
    {
        Assert.NotEmpty(ReportCatalog.All);
        Assert.Equal(ReportCatalog.All.Count, ReportCatalog.All.Select(e => e.Code).Distinct(StringComparer.Ordinal).Count());
        Assert.Equal(ReportCatalog.All.Count, ReportCatalog.ByCode.Count);
    }

    [Theory]
    [MemberData(nameof(Codes))]
    public void Every_code_matches_the_contract_pattern(string code) =>
        Assert.Matches("^[A-Z][A-Z0-9_]{2,47}$", code);

    [Theory]
    [MemberData(nameof(Codes))]
    public void Every_parameter_name_matches_the_contract_pattern(string code)
    {
        foreach (var parameter in ReportCatalog.ByCode[code].Parameters)
        {
            Assert.Matches("^[a-z][A-Za-z0-9]{0,47}$", parameter.Name);
            Assert.False(string.IsNullOrWhiteSpace(parameter.Label));
        }
    }

    [Theory]
    [MemberData(nameof(Codes))]
    public void Every_report_has_unique_column_keys_and_at_least_one_column(string code)
    {
        var columns = ReportCatalog.ByCode[code].Columns;
        Assert.NotEmpty(columns);
        Assert.Equal(columns.Count, columns.Select(c => c.Key).Distinct(StringComparer.Ordinal).Count());
        Assert.All(columns, c => Assert.False(string.IsNullOrWhiteSpace(c.Label)));
    }

    [Theory]
    [MemberData(nameof(Codes))]
    public void Every_report_supports_at_least_one_export_format(string code) =>
        Assert.NotEmpty(ReportCatalog.ByCode[code].SupportedFormats);

    [Theory]
    [MemberData(nameof(Codes))]
    public void Every_cost_column_is_a_money_column(string code)
    {
        // Spec §16 strips isCost columns; a quantity must never be caught by that filter, and a price must
        // never escape it.
        foreach (var column in ReportCatalog.ByCode[code].Columns.Where(c => c.IsCost))
        {
            Assert.Equal(ReportColumnType.Money, column.Type);
        }
    }

    [Theory]
    [MemberData(nameof(Codes))]
    public void The_parameter_and_column_schemas_round_trip_through_the_stored_json(string code)
    {
        var entry = ReportCatalog.ByCode[code];

        var parameters = ReportingJson.Deserialize<List<ReportParameterDefinition>>(ReportingJson.Serialize(entry.Parameters))!;
        var columns = ReportingJson.Deserialize<List<ReportColumnDefinition>>(ReportingJson.Serialize(entry.Columns))!;

        Assert.Equal(entry.Parameters.Select(p => p.Name), parameters.Select(p => p.Name));
        Assert.Equal(entry.Parameters.Select(p => p.Type), parameters.Select(p => p.Type));
        Assert.Equal(entry.Columns.Select(c => c.Key), columns.Select(c => c.Key));
        Assert.Equal(entry.Columns.Select(c => c.Type), columns.Select(c => c.Type));
        Assert.Equal(entry.Columns.Select(c => c.IsCost), columns.Select(c => c.IsCost));
    }

    [Fact]
    public void Enum_values_are_serialised_exactly_as_the_contract_spells_them()
    {
        // README §8.10: enums travel as UPPER_SNAKE. The contract writes DATETIME, not DATE_TIME.
        Assert.Equal("\"DATETIME\"", ReportingJson.Serialize(ReportColumnType.Datetime));
        Assert.Equal("\"DATE_RANGE\"", ReportingJson.Serialize(ReportParamType.DateRange));
        Assert.Equal("\"XLSX\"", ReportingJson.Serialize(ExportFormat.Xlsx));
        Assert.Equal("\"QUEUED\"", ReportingJson.Serialize(ExportStatus.Queued));
        Assert.Equal("\"PROCUREMENT\"", ReportingJson.Serialize(ReportCategory.Procurement));
    }

    [Fact]
    public void Every_category_used_by_the_catalogue_is_a_contract_category()
    {
        var allowed = Enum.GetValues<ReportCategory>();
        Assert.All(ReportCatalog.All, e => Assert.Contains(e.Category, allowed));
    }

    [Fact]
    public void The_reports_the_contract_names_and_that_the_existing_schemas_can_answer_are_all_present()
    {
        // reporting.v1.yaml names twelve codes as examples of TOR §29. PO_STATUS, PRICE_TREND and
        // SUPPLIER_PERFORMANCE are Procurement (Faza 2: proc_price_history does not exist yet), so the nine
        // that the inv_ schema can answer are the ones that must be here.
        string[] expected =
        [
            "STOCK_BALANCE", "STOCK_BY_BATCH", "EXPIRY", "STOCK_COVERAGE", "MOVEMENT_LEDGER",
            "BRANCH_CONSUMPTION", "WASTE_SUMMARY", "COUNT_VARIANCE", "RECEIPT_VARIANCE",
        ];

        Assert.Equal(expected.Order(StringComparer.Ordinal), ReportCatalog.All.Select(e => e.Code).Order(StringComparer.Ordinal));
    }

    [Fact]
    public void Every_parameter_is_optional_so_an_empty_object_runs_the_report()
    {
        // The catalogue documents a default for every filter; a client that sends {} still gets an answer.
        Assert.All(ReportCatalog.All, entry => Assert.DoesNotContain(entry.Parameters, p => p.Required));
    }

    [Fact]
    public void Report_names_and_labels_are_written_in_the_interface_language()
    {
        // CONVENTIONS.md: the interface language is Azerbaijani, and these strings are shown verbatim.
        Assert.All(ReportCatalog.All, entry =>
        {
            Assert.False(string.IsNullOrWhiteSpace(entry.Name));
            Assert.False(string.IsNullOrWhiteSpace(entry.Description));
            Assert.DoesNotMatch(new Regex("^[A-Z_]+$"), entry.Name);
        });
    }
}
