using System.Globalization;
using System.Text;
using Microsoft.Extensions.Options;
using Wms.Common.Application.Storage;
using Wms.Common.Infrastructure.Storage;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Infrastructure.Export;

/// <summary>Excel output (reporting.v1.yaml <c>XLSX</c>), written through <see cref="XlsxWriter"/>.</summary>
public sealed class XlsxExportRenderer : IExportRenderer
{
    public ExportFormat Format => ExportFormat.Xlsx;

    public string ContentType => XlsxWriter.ContentType;

    public string FileExtension => "xlsx";

    public byte[] Render(ReportDataSet dataSet)
    {
        ArgumentNullException.ThrowIfNull(dataSet);
        var headers = dataSet.Columns.Select(c => c.Label).ToList();
        var rows = new List<IReadOnlyList<SheetCell>>(dataSet.Rows.Count);
        foreach (var row in dataSet.Rows)
        {
            var cells = new SheetCell[dataSet.Columns.Count];
            for (var i = 0; i < dataSet.Columns.Count; i++)
            {
                cells[i] = ToCell(dataSet.Columns[i], i < row.Count ? row[i] : null);
            }

            rows.Add(cells);
        }

        return XlsxWriter.Write(dataSet.Name, headers, rows);
    }

    /// <summary>Numeric columns land in the sheet as numbers, so the spreadsheet can sum them.</summary>
    private static SheetCell ToCell(ReportColumnDefinition column, object? value) => value switch
    {
        null => default,
        bool flag => SheetCell.Of(flag ? "1" : "0"),
        long number => SheetCell.Of(number),
        string text when IsNumeric(column.Type)
            && decimal.TryParse(text, NumberStyles.Number, CultureInfo.InvariantCulture, out var parsed) => SheetCell.Of(parsed),
        string text => SheetCell.Of(text),
        _ => SheetCell.Of(value.ToString()),
    };

    private static bool IsNumeric(ReportColumnType type) =>
        type is ReportColumnType.Decimal or ReportColumnType.Money or ReportColumnType.Percent or ReportColumnType.Int;
}

/// <summary>CSV output (reporting.v1.yaml <c>CSV</c>): RFC 4180 quoting, UTF-8 with a BOM so Excel opens it as UTF-8.</summary>
public sealed class CsvExportRenderer : IExportRenderer
{
    public ExportFormat Format => ExportFormat.Csv;

    public string ContentType => "text/csv";

    public string FileExtension => "csv";

    public byte[] Render(ReportDataSet dataSet)
    {
        ArgumentNullException.ThrowIfNull(dataSet);
        var builder = new StringBuilder(4096);
        builder.AppendJoin(',', dataSet.Columns.Select(c => Quote(c.Label))).Append("\r\n");
        foreach (var row in dataSet.Rows)
        {
            builder.AppendJoin(',', row.Select(Field)).Append("\r\n");
        }

        return Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(builder.ToString())).ToArray();
    }

    private static string Field(object? value) => value switch
    {
        null => string.Empty,
        bool flag => flag ? "true" : "false",
        long number => number.ToString(CultureInfo.InvariantCulture),
        _ => Quote(value.ToString() ?? string.Empty),
    };

    private static string Quote(string value) =>
        value.AsSpan().IndexOfAny(",\"\r\n") >= 0 ? '"' + value.Replace("\"", "\"\"", StringComparison.Ordinal) + '"' : value;
}

/// <summary>
/// Export files in MinIO — the same client and bucket the attachment flow uses
/// (<see cref="IObjectStorage"/>, <c>Minio__*</c>).
/// </summary>
public sealed class MinioExportFileStore(IObjectStorage storage, IOptions<MinioOptions> options) : IExportFileStore
{
    public TimeSpan DownloadUrlLifetime => options.Value.DownloadUrlLifetime;

    public async Task<string> UploadAsync(string objectKey, byte[] content, string contentType, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(content);
        await storage.PutAsync(objectKey, content, contentType, cancellationToken).ConfigureAwait(false);
        return objectKey;
    }

    public Task<Uri> PresignDownloadAsync(string objectKey, string fileName, string contentType, TimeSpan lifetime, CancellationToken cancellationToken) =>
        storage.PresignDownloadAsync(objectKey, fileName, contentType, inline: false, lifetime, cancellationToken);

    public Task RemoveAsync(string objectKey, CancellationToken cancellationToken) =>
        storage.RemoveAsync(objectKey, cancellationToken);
}
