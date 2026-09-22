using System.Globalization;
using System.IO.Compression;
using System.Text;

namespace Wms.Reporting.Infrastructure.Export;

/// <summary>One cell of a generated sheet: either a number or inline text.</summary>
public readonly record struct SheetCell(string? Text, decimal? Number)
{
    public static SheetCell Of(string? text) => new(text, null);

    public static SheetCell Of(decimal value) => new(null, value);

    public bool IsEmpty => Text is null && Number is null;
}

/// <summary>
/// Minimal SpreadsheetML (.xlsx) writer: a ZIP with the five parts Excel needs, inline strings and a bold
/// header row.
/// </summary>
/// <remarks>
/// Written by hand on purpose. The alternatives are a commercial licence (EPPlus) or another third-party
/// dependency, and the project already has one licence question open (Hangfire.MySqlStorage, README §8.2);
/// an export sheet needs no styling engine, so <see cref="System.IO.Compression"/> and a few hundred bytes of
/// XML are the whole requirement.
/// </remarks>
public static class XlsxWriter
{
    public const string ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

    public static byte[] Write(string sheetName, IReadOnlyList<string> headers, IReadOnlyList<IReadOnlyList<SheetCell>> rows)
    {
        ArgumentNullException.ThrowIfNull(headers);
        ArgumentNullException.ThrowIfNull(rows);

        using var buffer = new MemoryStream();
        using (var archive = new ZipArchive(buffer, ZipArchiveMode.Create, leaveOpen: true))
        {
            Add(archive, "[Content_Types].xml", ContentTypesXml);
            Add(archive, "_rels/.rels", RootRelsXml);
            Add(archive, "xl/workbook.xml", WorkbookXml(sheetName));
            Add(archive, "xl/_rels/workbook.xml.rels", WorkbookRelsXml);
            Add(archive, "xl/styles.xml", StylesXml);
            Add(archive, "xl/worksheets/sheet1.xml", SheetXml(headers, rows));
        }

        return buffer.ToArray();
    }

    /// <summary>Spreadsheet column name of a zero-based index: 0 → A, 26 → AA.</summary>
    public static string ColumnName(int index)
    {
        var name = string.Empty;
        var remaining = index + 1;
        while (remaining > 0)
        {
            var modulo = (remaining - 1) % 26;
            name = (char)('A' + modulo) + name;
            remaining = (remaining - modulo) / 26;
        }

        return name;
    }

    private static void Add(ZipArchive archive, string path, string content)
    {
        var entry = archive.CreateEntry(path, CompressionLevel.Optimal);
        using var stream = entry.Open();
        var bytes = Encoding.UTF8.GetBytes(content);
        stream.Write(bytes, 0, bytes.Length);
    }

    private static string SheetXml(IReadOnlyList<string> headers, IReadOnlyList<IReadOnlyList<SheetCell>> rows)
    {
        var builder = new StringBuilder(4096);
        builder.Append("""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>""");
        builder.Append("""<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>""");

        builder.Append("""<row r="1">""");
        for (var i = 0; i < headers.Count; i++)
        {
            AppendInline(builder, ColumnName(i), 1, headers[i], styleIndex: 1);
        }

        builder.Append("</row>");

        for (var r = 0; r < rows.Count; r++)
        {
            var rowNumber = r + 2;
            builder.Append(CultureInfo.InvariantCulture, $"""<row r="{rowNumber}">""");
            var row = rows[r];
            for (var c = 0; c < row.Count; c++)
            {
                var cell = row[c];
                if (cell.IsEmpty)
                {
                    continue;
                }

                if (cell.Number is { } number)
                {
                    builder.Append(CultureInfo.InvariantCulture, $"""<c r="{ColumnName(c)}{rowNumber}"><v>{number.ToString(CultureInfo.InvariantCulture)}</v></c>""");
                }
                else
                {
                    AppendInline(builder, ColumnName(c), rowNumber, cell.Text!, styleIndex: 0);
                }
            }

            builder.Append("</row>");
        }

        builder.Append("</sheetData></worksheet>");
        return builder.ToString();
    }

    private static void AppendInline(StringBuilder builder, string column, int rowNumber, string text, int styleIndex)
    {
        var style = styleIndex == 0 ? string.Empty : $""" s="{styleIndex.ToString(CultureInfo.InvariantCulture)}" """.TrimEnd();
        builder.Append(CultureInfo.InvariantCulture, $"""<c r="{column}{rowNumber}"{style} t="inlineStr"><is><t xml:space="preserve">{Escape(text)}</t></is></c>""");
    }

    private static string Escape(string value)
    {
        var builder = new StringBuilder(value.Length + 8);
        foreach (var c in value)
        {
            switch (c)
            {
                case '&': builder.Append("&amp;"); break;
                case '<': builder.Append("&lt;"); break;
                case '>': builder.Append("&gt;"); break;
                case '"': builder.Append("&quot;"); break;
                case '\'': builder.Append("&apos;"); break;
                default:
                    // Control characters are illegal in XML 1.0 even when escaped.
                    builder.Append(c < ' ' && c is not ('\t' or '\n' or '\r') ? ' ' : c);
                    break;
            }
        }

        return builder.ToString();
    }

    private static string WorkbookXml(string sheetName) =>
        $"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="{Escape(SafeSheetName(sheetName))}" sheetId="1" r:id="rId1"/></sheets></workbook>""";

    /// <summary>Excel rejects <c>[]*/\?:</c> in a sheet name and caps it at 31 characters.</summary>
    private static string SafeSheetName(string name)
    {
        var builder = new StringBuilder(31);
        foreach (var c in name)
        {
            if (builder.Length == 31)
            {
                break;
            }

            builder.Append(c is '[' or ']' or '*' or '/' or '\\' or '?' or ':' ? '_' : c);
        }

        return builder.Length == 0 ? "Sheet1" : builder.ToString();
    }

    private const string ContentTypesXml =
        """<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/></Types>""";

    private const string RootRelsXml =
        """<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>""";

    private const string WorkbookRelsXml =
        """<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>""";

    private const string StylesXml =
        """<?xml version="1.0" encoding="UTF-8" standalone="yes"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><b/><sz val="11"/><name val="Calibri"/></font></fonts><fills count="1"><fill><patternFill patternType="none"/></fill></fills><borders count="1"><border/></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs></styleSheet>""";
}
