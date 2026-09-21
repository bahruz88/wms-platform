using System.Text;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Infrastructure.Csv;

namespace Wms.Consumption.UnitTests;

/// <summary>
/// Contract <c>uploadSalesCsv</c>: encoding and delimiter are detected, UTF-8 and Windows-1254 are supported,
/// and a row that cannot be read is reported in <c>parseErrors</c> instead of aborting the file.
/// </summary>
public sealed class SalesCsvParserTests
{
    private static readonly SalesCsvParser Parser = new();

    static SalesCsvParserTests() => Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

    [Fact]
    public void A_semicolon_separated_utf8_file_is_parsed()
    {
        var csv = "posCode;qtySold;grossAmount\nPLU-001;120;1440.00\nPLU-002;35;402.50\n";

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), mapping: null);

        Assert.Empty(result.Errors);
        Assert.Equal(SalesCsvParser.Utf8, result.DetectedEncoding);
        Assert.Equal(';', result.DetectedDelimiter);
        Assert.Equal(2, result.Rows.Count);
        Assert.Equal("PLU-001", result.Rows[0].PosCode);
        Assert.Equal(120m, result.Rows[0].QtySold);
        Assert.Equal(1440.00m, result.Rows[0].GrossAmount);
    }

    [Fact]
    public void A_comma_separated_file_is_detected_too()
    {
        var csv = "posCode,qtySold\nPLU-001,10\n";

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), null);

        Assert.Equal(',', result.DetectedDelimiter);
        Assert.Single(result.Rows);
    }

    [Fact]
    public void A_tab_separated_file_is_detected_too()
    {
        var csv = "posCode\tqtySold\nPLU-001\t10\n";

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), null);

        Assert.Equal('\t', result.DetectedDelimiter);
        Assert.Single(result.Rows);
    }

    [Fact]
    public void A_utf8_byte_order_mark_is_stripped()
    {
        var csv = "posCode;qtySold\nPLU-001;10\n";
        var bytes = Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(csv)).ToArray();

        var result = Parser.Parse(bytes, null);

        Assert.Empty(result.Errors);
        Assert.Single(result.Rows);
        Assert.Equal("PLU-001", result.Rows[0].PosCode);
    }

    [Fact]
    public void A_windows_1254_file_is_decoded_with_its_turkish_letters_intact()
    {
        // A POS terminal in the region exports the legacy Turkish code page, not UTF-8.
        var text = "posCode;qtySold\nTAVUK-DÜRÜM;12\nKÖFTE-ŞİŞ;7\nAYRAN-İÇECEK;30\n";
        var bytes = Encoding.GetEncoding(SalesCsvParser.Windows1254).GetBytes(text);

        // The same bytes are NOT valid UTF-8, which is exactly how the parser detects the code page.
        Assert.Throws<DecoderFallbackException>(() =>
            new UTF8Encoding(false, throwOnInvalidBytes: true).GetString(bytes));

        var result = Parser.Parse(bytes, null);

        Assert.Equal(SalesCsvParser.Windows1254, result.DetectedEncoding);
        Assert.Empty(result.Errors);
        Assert.Equal(3, result.Rows.Count);
        Assert.Equal("TAVUK-DÜRÜM", result.Rows[0].PosCode);
        Assert.Equal("KÖFTE-ŞİŞ", result.Rows[1].PosCode);
        Assert.Equal("AYRAN-İÇECEK", result.Rows[2].PosCode);
        Assert.Equal(30m, result.Rows[2].QtySold);
    }

    [Fact]
    public void Malformed_rows_are_collected_and_the_rest_of_the_file_is_still_read()
    {
        var csv = string.Join('\n',
            "posCode;qtySold;grossAmount",
            "PLU-001;120;1440.00",   // good
            "PLU-002;abc;10.00",     // quantity is not a number
            ";5;10.00",              // POS code missing
            "PLU-004",               // too few columns
            "PLU-005;-3;10.00",      // negative quantity
            "PLU-006;8;not-a-number", // amount unreadable, quantity still accepted
            "PLU-007;9;99.90");

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), null);

        Assert.Equal(3, result.Rows.Count);
        Assert.Equal(["PLU-001", "PLU-006", "PLU-007"], result.Rows.Select(r => r.PosCode));
        Assert.Null(result.Rows[1].GrossAmount);

        Assert.Equal(5, result.Errors.Count);
        Assert.Equal([3, 4, 5, 6, 7], result.Errors.Select(e => e.RowNumber));
        Assert.Contains("not a number", result.Errors[0].Message, StringComparison.Ordinal);
        Assert.Contains("empty", result.Errors[1].Message, StringComparison.Ordinal);
        Assert.Contains("column", result.Errors[2].Message, StringComparison.Ordinal);
        Assert.Contains("positive", result.Errors[3].Message, StringComparison.Ordinal);
        Assert.Equal("PLU-004", result.Errors[2].RawLine);
    }

    [Fact]
    public void An_explicit_column_mapping_overrides_the_default_header_names()
    {
        var csv = "PLU;Adet;Tutar\n9001;15;225,50\n";

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), new SalesCsvColumnMapping("PLU", "Adet", "Tutar"));

        Assert.Empty(result.Errors);
        Assert.Equal("9001", result.Rows[0].PosCode);
        Assert.Equal(15m, result.Rows[0].QtySold);
        Assert.Equal(225.50m, result.Rows[0].GrossAmount);
    }

    [Fact]
    public void A_header_without_the_required_columns_produces_one_error_and_no_rows()
    {
        var csv = "foo;bar\n1;2\n";

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), null);

        Assert.Empty(result.Rows);
        var error = Assert.Single(result.Errors);
        Assert.Equal(1, error.RowNumber);
    }

    [Theory]
    [InlineData("1234.56", "1234.56")]
    [InlineData("1234,56", "1234.56")]
    [InlineData("1 234,56", "1234.56")]
    [InlineData("1.234,56", "1234.56")]
    [InlineData("1,234.56", "1234.56")]
    [InlineData("12", "12")]
    public void Both_decimal_separators_are_accepted(string input, string expected)
    {
        Assert.True(SalesCsvParser.TryParseDecimal(input, out var parsed));
        Assert.Equal(decimal.Parse(expected, System.Globalization.CultureInfo.InvariantCulture), parsed);
    }

    [Fact]
    public void Quoted_fields_may_contain_the_delimiter_and_escaped_quotes()
    {
        var csv = "posCode;qtySold\n\"PLU;01\";5\n\"say \"\"hi\"\"\";3\n";

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), null);

        Assert.Empty(result.Errors);
        Assert.Equal("PLU;01", result.Rows[0].PosCode);
        Assert.Equal("say \"hi\"", result.Rows[1].PosCode);
    }

    [Fact]
    public void Windows_line_endings_and_blank_lines_are_tolerated()
    {
        var csv = "posCode;qtySold\r\nPLU-001;5\r\n\r\nPLU-002;6\r\n";

        var result = Parser.Parse(Encoding.UTF8.GetBytes(csv), null);

        Assert.Empty(result.Errors);
        Assert.Equal(2, result.Rows.Count);
    }

    [Fact]
    public void An_empty_file_yields_nothing_rather_than_throwing()
    {
        var result = Parser.Parse([], null);

        Assert.Empty(result.Rows);
        Assert.Empty(result.Errors);
    }

    [Fact]
    public void The_size_limit_of_the_contract_is_five_megabytes()
    {
        Assert.Equal(5L * 1024 * 1024, SalesCsvLimits.MaxBytes);
    }
}
