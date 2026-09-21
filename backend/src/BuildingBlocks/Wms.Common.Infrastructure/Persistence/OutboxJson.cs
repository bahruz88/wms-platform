using System.Text.Json;
using System.Text.Json.Serialization;

namespace Wms.Common.Infrastructure.Persistence;

/// <summary>JSON settings for outbox payloads and audit change sets.</summary>
public static class OutboxJson
{
    public static JsonSerializerOptions Options { get; } = CreateOptions();

    public static string Serialize(object value)
    {
        ArgumentNullException.ThrowIfNull(value);
        return JsonSerializer.Serialize(value, value.GetType(), Options);
    }

    private static JsonSerializerOptions CreateOptions()
    {
        var options = new JsonSerializerOptions(JsonSerializerDefaults.Web);
        options.Converters.Add(new JsonStringEnumConverter());
        return options;
    }
}
