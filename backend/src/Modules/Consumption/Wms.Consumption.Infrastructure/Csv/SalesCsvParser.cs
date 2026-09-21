using System.Globalization;
using System.Text;
using Wms.Consumption.Application.Abstractions;

namespace Wms.Consumption.Infrastructure.Csv;

/// <summary>
/// POS export reader (contract <c>uploadSalesCsv</c>). Deliberately hand-written rather than a CSV library:
/// the input is a small, flat export and the requirements are specific — encoding and delimiter are detected,
/// a broken row is reported instead of aborting the file, and both decimal separators are accepted.
///
/// <list type="bullet">
/// <item><b>Encoding:</b> BOM first (UTF-8, UTF-16 LE/BE); otherwise a strict UTF-8 decode is attempted and a
/// failure means the file is Windows-1254 (the Turkish code page POS terminals in the region emit).</item>
/// <item><b>Delimiter:</b> whichever of <c>; , TAB |</c> appears most often in the header line.</item>
/// <item><b>Numbers:</b> <c>1 234,56</c> and <c>1,234.56</c> both parse; the separator is decided per value.</item>
/// <item><b>Quotes:</b> RFC 4180 double quotes, including <c>""</c> escaping and embedded delimiters.</item>
/// </list>
/// </summary>
public sealed class SalesCsvParser : ISalesCsvParser
{
    public const string Windows1254 = "windows-1254";
    public const string Utf8 = "utf-8";

    private static readonly char[] Delimiters = [';', ',', '\t', '|'];
    private static readonly string[] DefaultPosCodeHeaders = ["poscode", "pos_code", "plu", "code", "kod", "menuitem", "menu_item", "item"];
    private static readonly string[] DefaultQtyHeaders = ["qtysold", "qty_sold", "qty", "quantity", "say", "miqdar", "adet", "ədəd"];
    private static readonly string[] DefaultAmountHeaders = ["grossamount", "gross_amount", "amount", "total", "məbləğ", "mebleg", "tutar"];

    static SalesCsvParser() => Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

    public SalesCsvParseResult Parse(byte[] content, SalesCsvColumnMapping? mapping)
    {
        ArgumentNullException.ThrowIfNull(content);

        var (text, encodingName) = Decode(content);
        var lines = SplitLines(text);
        if (lines.Count == 0)
        {
            return new SalesCsvParseResult([], [], encodingName, ';');
        }

        var delimiter = DetectDelimiter(lines[0]);
        var header = SplitRow(lines[0], delimiter);
        var columns = ResolveColumns(header, mapping);

        var rows = new List<ParsedSalesRow>();
        var errors = new List<ParsedSalesError>();

        if (columns.PosCode < 0 || columns.Qty < 0)
        {
            errors.Add(new ParsedSalesError(
                1,
                lines[0],
                $"Header does not contain the POS code and quantity columns (looked for '{mapping?.PosCode ?? string.Join("/", DefaultPosCodeHeaders)}' and '{mapping?.QtySold ?? string.Join("/", DefaultQtyHeaders)}')."));
            return new SalesCsvParseResult(rows, errors, encodingName, delimiter);
        }

        for (var i = 1; i < lines.Count; i++)
        {
            var rowNumber = i + 1;
            var raw = lines[i];
            if (string.IsNullOrWhiteSpace(raw))
            {
                continue;
            }

            var fields = SplitRow(raw, delimiter);
            if (fields.Count <= Math.Max(columns.PosCode, columns.Qty))
            {
                errors.Add(new ParsedSalesError(rowNumber, raw, $"Row has {fields.Count} column(s); at least {Math.Max(columns.PosCode, columns.Qty) + 1} are required."));
                continue;
            }

            var posCode = fields[columns.PosCode].Trim();
            if (posCode.Length == 0)
            {
                errors.Add(new ParsedSalesError(rowNumber, raw, "POS code is empty."));
                continue;
            }

            if (!TryParseDecimal(fields[columns.Qty], out var qty))
            {
                errors.Add(new ParsedSalesError(rowNumber, raw, $"Quantity '{fields[columns.Qty].Trim()}' is not a number."));
                continue;
            }

            if (qty <= 0m)
            {
                errors.Add(new ParsedSalesError(rowNumber, raw, $"Quantity must be positive but is '{fields[columns.Qty].Trim()}'."));
                continue;
            }

            decimal? amount = null;
            if (columns.Amount >= 0 && columns.Amount < fields.Count && !string.IsNullOrWhiteSpace(fields[columns.Amount]))
            {
                if (TryParseDecimal(fields[columns.Amount], out var parsedAmount))
                {
                    amount = parsedAmount;
                }
                else
                {
                    errors.Add(new ParsedSalesError(rowNumber, raw, $"Gross amount '{fields[columns.Amount].Trim()}' is not a number; the quantity was still accepted."));
                }
            }

            rows.Add(new ParsedSalesRow(rowNumber, posCode, qty, amount));
        }

        return new SalesCsvParseResult(rows, errors, encodingName, delimiter);
    }

    /// <summary>BOM, then a strict UTF-8 attempt; an invalid byte sequence means the legacy Turkish code page.</summary>
    public static (string Text, string EncodingName) Decode(byte[] content)
    {
        ArgumentNullException.ThrowIfNull(content);
        if (content.Length >= 3 && content[0] == 0xEF && content[1] == 0xBB && content[2] == 0xBF)
        {
            return (Encoding.UTF8.GetString(content, 3, content.Length - 3), Utf8);
        }

        if (content.Length >= 2 && content[0] == 0xFF && content[1] == 0xFE)
        {
            return (Encoding.Unicode.GetString(content, 2, content.Length - 2), "utf-16le");
        }

        if (content.Length >= 2 && content[0] == 0xFE && content[1] == 0xFF)
        {
            return (Encoding.BigEndianUnicode.GetString(content, 2, content.Length - 2), "utf-16be");
        }

        try
        {
            return (new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true).GetString(content), Utf8);
        }
        catch (DecoderFallbackException)
        {
            return (Encoding.GetEncoding(Windows1254).GetString(content), Windows1254);
        }
    }

    public static char DetectDelimiter(string headerLine)
    {
        ArgumentNullException.ThrowIfNull(headerLine);
        var best = ';';
        var bestCount = -1;
        foreach (var candidate in Delimiters)
        {
            var count = headerLine.Count(c => c == candidate);
            if (count > bestCount)
            {
                best = candidate;
                bestCount = count;
            }
        }

        return bestCount <= 0 ? ';' : best;
    }

    /// <summary>Accepts both <c>1 234,56</c> and <c>1,234.56</c>; the last separator in the text decides.</summary>
    public static bool TryParseDecimal(string? value, out decimal result)
    {
        result = 0m;
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        var text = value.Trim().Replace(" ", string.Empty, StringComparison.Ordinal).Replace(" ", string.Empty, StringComparison.Ordinal);
        var lastComma = text.LastIndexOf(',');
        var lastDot = text.LastIndexOf('.');

        if (lastComma >= 0 && lastDot >= 0)
        {
            text = lastComma > lastDot
                ? text.Replace(".", string.Empty, StringComparison.Ordinal).Replace(',', '.')
                : text.Replace(",", string.Empty, StringComparison.Ordinal);
        }
        else if (lastComma >= 0)
        {
            text = text.Replace(',', '.');
        }

        return decimal.TryParse(text, NumberStyles.Number, CultureInfo.InvariantCulture, out result);
    }

    public static List<string> SplitRow(string line, char delimiter)
    {
        ArgumentNullException.ThrowIfNull(line);
        var fields = new List<string>();
        var builder = new StringBuilder();
        var inQuotes = false;

        for (var i = 0; i < line.Length; i++)
        {
            var c = line[i];
            if (inQuotes)
            {
                if (c == '"')
                {
                    if (i + 1 < line.Length && line[i + 1] == '"')
                    {
                        builder.Append('"');
                        i++;
                        continue;
                    }

                    inQuotes = false;
                    continue;
                }

                builder.Append(c);
                continue;
            }

            if (c == '"')
            {
                inQuotes = true;
                continue;
            }

            if (c == delimiter)
            {
                fields.Add(builder.ToString());
                builder.Clear();
                continue;
            }

            builder.Append(c);
        }

        fields.Add(builder.ToString());
        return fields;
    }

    private static List<string> SplitLines(string text) =>
        text.Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n')
            .Split('\n')
            .Where(l => l.Length > 0)
            .ToList();

    private static (int PosCode, int Qty, int Amount) ResolveColumns(IReadOnlyList<string> header, SalesCsvColumnMapping? mapping)
    {
        var normalized = header.Select(Normalize).ToList();
        var posCode = IndexOf(normalized, mapping?.PosCode, DefaultPosCodeHeaders);
        var qty = IndexOf(normalized, mapping?.QtySold, DefaultQtyHeaders);
        var amount = IndexOf(normalized, mapping?.GrossAmount, DefaultAmountHeaders);
        return (posCode, qty, amount);
    }

    private static int IndexOf(List<string> header, string? explicitName, string[] fallbacks)
    {
        if (!string.IsNullOrWhiteSpace(explicitName))
        {
            var wanted = Normalize(explicitName);
            var index = header.IndexOf(wanted);
            if (index >= 0)
            {
                return index;
            }
        }

        foreach (var fallback in fallbacks)
        {
            var index = header.IndexOf(fallback);
            if (index >= 0)
            {
                return index;
            }
        }

        return -1;
    }

    private static string Normalize(string value) =>
        new string((value ?? string.Empty).Trim().ToLowerInvariant().Where(c => !char.IsWhiteSpace(c) && c != '﻿').ToArray());
}
