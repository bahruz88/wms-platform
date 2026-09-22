using System.Text.Json;
using System.Text.Json.Serialization;

namespace Wms.Reporting.Domain;

/// <summary>
/// Serialiser of the JSON columns of <c>rpt_report_definition</c> and <c>rpt_export_job</c>. It mirrors the
/// platform's wire format (camelCase properties, UPPER_SNAKE enums — README §8.10) so a stored parameter or
/// column schema round-trips unchanged into the API response.
/// </summary>
public static class ReportingJson
{
    public static JsonSerializerOptions Options { get; } = Build();

    public static string Serialize<T>(T value) => JsonSerializer.Serialize(value, Options);

    public static T? Deserialize<T>(string? json) =>
        string.IsNullOrWhiteSpace(json) ? default : JsonSerializer.Deserialize<T>(json, Options);

    private static JsonSerializerOptions Build()
    {
        var options = new JsonSerializerOptions(JsonSerializerDefaults.Web)
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        };
        options.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.SnakeCaseUpper));
        return options;
    }
}
