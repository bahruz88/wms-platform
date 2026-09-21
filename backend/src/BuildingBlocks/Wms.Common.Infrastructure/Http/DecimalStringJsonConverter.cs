using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Wms.Common.Infrastructure.Http;

/// <summary>Quantities and amounts travel as JSON strings (<c>"qty": "12.5000"</c>) so clients never touch floats (CONVENTIONS.md).</summary>
public sealed class DecimalStringJsonConverter : JsonConverter<decimal>
{
    public override decimal Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Number)
        {
            return reader.GetDecimal();
        }

        if (reader.TokenType == JsonTokenType.String
            && decimal.TryParse(reader.GetString(), NumberStyles.Number, CultureInfo.InvariantCulture, out var value))
        {
            return value;
        }

        throw new JsonException("Expected a decimal number encoded as a string.");
    }

    public override void Write(Utf8JsonWriter writer, decimal value, JsonSerializerOptions options)
    {
        ArgumentNullException.ThrowIfNull(writer);
        writer.WriteStringValue(value.ToString(CultureInfo.InvariantCulture));
    }
}
