using System.Globalization;
using System.Text.Json;
using Wms.Common.Domain;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Infrastructure.Reports;

/// <summary>
/// The report parameters of <c>ReportRunRequest.parameters</c> after validation against the definition's
/// schema. Every parameter of the catalogue is optional (<see cref="ReportCatalog"/>), so a request with an
/// empty object runs every report over a documented default window.
/// </summary>
public sealed record ReportArguments(
    uint? LocationId,
    uint? ProductId,
    uint? SupplierId,
    bool IncludeZero,
    bool OnlyVariances,
    int WithinDays,
    int WindowDays,
    string? DocType,
    string? BatchStatus,
    DateOnly From,
    DateOnly To)
{
    /// <summary>An absent <c>dateRange</c> means the trailing 30 days including today.</summary>
    public const int DefaultPeriodDays = 30;

    public static Result<ReportArguments> Parse(ReportDefinitionDto definition, IReadOnlyDictionary<string, JsonElement> values, DateOnly today)
    {
        ArgumentNullException.ThrowIfNull(definition);
        ArgumentNullException.ThrowIfNull(values);

        var errors = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        var declared = definition.Parameters.ToDictionary(p => p.Name, StringComparer.Ordinal);

        foreach (var name in values.Keys)
        {
            if (!declared.ContainsKey(name))
            {
                Add(errors, "parameters", $"'{name}' bu hesabatın parametri deyil.");
            }
        }

        foreach (var parameter in definition.Parameters)
        {
            if (parameter.Required && !values.ContainsKey(parameter.Name))
            {
                Add(errors, parameter.Name, "Məcburi parametr.");
            }
        }

        var from = today.AddDays(-(DefaultPeriodDays - 1));
        var to = today;
        if (values.TryGetValue("dateRange", out var range) && range.ValueKind != JsonValueKind.Null)
        {
            if (range.ValueKind != JsonValueKind.Object)
            {
                Add(errors, "dateRange", "{ from, to } formatında obyekt gözlənilir.");
            }
            else
            {
                from = ReadDate(range, "from", from, errors);
                to = ReadDate(range, "to", to, errors);
                if (from > to)
                {
                    Add(errors, "dateRange", "'from' 'to'-dan sonra ola bilməz.");
                }
            }
        }

        var arguments = new ReportArguments(
            ReadId(values, "locationId", errors),
            ReadId(values, "productId", errors),
            ReadId(values, "supplierId", errors),
            ReadBool(values, "includeZero", Default(declared, "includeZero", false), errors),
            ReadBool(values, "onlyVariances", Default(declared, "onlyVariances", true), errors),
            ReadInt(values, "withinDays", Default(declared, "withinDays", DefaultPeriodDays), 0, 3650, errors),
            ReadInt(values, "windowDays", Default(declared, "windowDays", DefaultPeriodDays), 1, 3650, errors),
            ReadEnum(values, "docType", declared, errors),
            ReadEnum(values, "batchStatus", declared, errors),
            from,
            to);

        return errors.Count == 0
            ? Result.Success(arguments)
            : ReportingErrors.InvalidParameters(errors.ToDictionary(e => e.Key, e => e.Value.ToArray(), StringComparer.Ordinal));
    }

    private static void Add(Dictionary<string, List<string>> errors, string key, string message)
    {
        if (!errors.TryGetValue(key, out var list))
        {
            list = [];
            errors[key] = list;
        }

        list.Add(message);
    }

    private static T Default<T>(IReadOnlyDictionary<string, ReportParameterDefinition> declared, string name, T fallback)
    {
        if (!declared.TryGetValue(name, out var parameter) || parameter.DefaultValue is null)
        {
            return fallback;
        }

        if (parameter.DefaultValue is JsonElement element)
        {
            try
            {
                return element.Deserialize<T>(ReportingJson.Options) ?? fallback;
            }
            catch (JsonException)
            {
                return fallback;
            }
        }

        return parameter.DefaultValue is T typed ? typed : fallback;
    }

    private static uint? ReadId(IReadOnlyDictionary<string, JsonElement> values, string name, Dictionary<string, List<string>> errors)
    {
        if (!values.TryGetValue(name, out var element) || element.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined)
        {
            return null;
        }

        if (element.ValueKind == JsonValueKind.Number && element.TryGetUInt32(out var number))
        {
            return number == 0 ? null : number;
        }

        if (element.ValueKind == JsonValueKind.String
            && uint.TryParse(element.GetString(), NumberStyles.None, CultureInfo.InvariantCulture, out var parsed))
        {
            return parsed == 0 ? null : parsed;
        }

        Add(errors, name, "Müsbət tam ədəd gözlənilir.");
        return null;
    }

    private static bool ReadBool(IReadOnlyDictionary<string, JsonElement> values, string name, bool fallback, Dictionary<string, List<string>> errors)
    {
        if (!values.TryGetValue(name, out var element) || element.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined)
        {
            return fallback;
        }

        return element.ValueKind switch
        {
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.String when bool.TryParse(element.GetString(), out var parsed) => parsed,
            _ => Invalid(errors, name, "true və ya false gözlənilir.", fallback),
        };
    }

    private static int ReadInt(
        IReadOnlyDictionary<string, JsonElement> values,
        string name,
        int fallback,
        int minimum,
        int maximum,
        Dictionary<string, List<string>> errors)
    {
        if (!values.TryGetValue(name, out var element) || element.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined)
        {
            return Math.Clamp(fallback, minimum, maximum);
        }

        int parsed;
        if (element.ValueKind == JsonValueKind.Number && element.TryGetInt32(out parsed))
        {
            // fall through
        }
        else if (element.ValueKind == JsonValueKind.String
            && int.TryParse(element.GetString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out parsed))
        {
            // fall through
        }
        else
        {
            return Invalid(errors, name, "Tam ədəd gözlənilir.", Math.Clamp(fallback, minimum, maximum));
        }

        if (parsed < minimum || parsed > maximum)
        {
            return Invalid(errors, name, $"{minimum} ilə {maximum} arasında olmalıdır.", Math.Clamp(fallback, minimum, maximum));
        }

        return parsed;
    }

    private static string? ReadEnum(
        IReadOnlyDictionary<string, JsonElement> values,
        string name,
        IReadOnlyDictionary<string, ReportParameterDefinition> declared,
        Dictionary<string, List<string>> errors)
    {
        if (!values.TryGetValue(name, out var element) || element.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined)
        {
            return null;
        }

        if (element.ValueKind != JsonValueKind.String)
        {
            return Invalid(errors, name, "Mətn dəyər gözlənilir.", (string?)null);
        }

        var value = element.GetString();
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        var allowed = declared.TryGetValue(name, out var parameter) ? parameter.AllowedValues : null;
        if (allowed is { Count: > 0 } && !allowed.Any(a => string.Equals(a.Value, value, StringComparison.OrdinalIgnoreCase)))
        {
            return Invalid(errors, name, $"İcazə verilən dəyərlər: {string.Join(", ", allowed.Select(a => a.Value))}.", (string?)null);
        }

        return value.ToUpperInvariant();
    }

    private static T Invalid<T>(Dictionary<string, List<string>> errors, string key, string message, T fallback)
    {
        Add(errors, key, message);
        return fallback;
    }

    private static DateOnly ReadDate(JsonElement range, string property, DateOnly fallback, Dictionary<string, List<string>> errors)
    {
        if (!range.TryGetProperty(property, out var element) || element.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined)
        {
            return fallback;
        }

        if (element.ValueKind == JsonValueKind.String
            && DateOnly.TryParseExact(element.GetString(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var parsed))
        {
            return parsed;
        }

        Add(errors, "dateRange", $"'{property}' YYYY-MM-DD formatında olmalıdır.");
        return fallback;
    }
}
