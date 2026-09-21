namespace Wms.Common.Infrastructure.Messaging;

/// <summary>Bound from the <c>RabbitMq</c> section (CONVENTIONS.md).</summary>
public sealed class RabbitMqOptions
{
    public const string SectionName = "RabbitMq";

    public string Host { get; set; } = "localhost";

    public int Port { get; set; } = 5672;

    public string VirtualHost { get; set; } = "/";

    public string User { get; set; } = "guest";

    public string Password { get; set; } = "guest";

    /// <summary>Topic exchange; routing key = integration event type name.</summary>
    public string Exchange { get; set; } = "wms.events";
}
