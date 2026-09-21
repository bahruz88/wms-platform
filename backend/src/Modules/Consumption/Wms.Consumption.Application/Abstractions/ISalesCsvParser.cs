namespace Wms.Consumption.Application.Abstractions;

/// <summary>One data row of a POS export: the POS code, the quantity sold and optionally the gross amount.</summary>
public sealed record ParsedSalesRow(int RowNumber, string PosCode, decimal QtySold, decimal? GrossAmount);

public sealed record ParsedSalesError(int RowNumber, string? RawLine, string Message);

/// <summary>
/// Outcome of parsing a POS CSV: the readable rows and, separately, the rows that could not be read — a broken
/// row never silently disappears (contract: <c>parseErrors</c>).
/// </summary>
public sealed record SalesCsvParseResult(
    IReadOnlyList<ParsedSalesRow> Rows,
    IReadOnlyList<ParsedSalesError> Errors,
    string DetectedEncoding,
    char DetectedDelimiter);

/// <summary>Column names to look for. Null falls back to the default header names.</summary>
public sealed record SalesCsvColumnMapping(string? PosCode, string? QtySold, string? GrossAmount);

public static class SalesCsvLimits
{
    /// <summary>Maximum accepted upload size; a bigger file is rejected with <c>422 FILE_TOO_LARGE</c>.</summary>
    public const long MaxBytes = 5L * 1024 * 1024;
}

public interface ISalesCsvParser
{
    SalesCsvParseResult Parse(byte[] content, SalesCsvColumnMapping? mapping);
}
