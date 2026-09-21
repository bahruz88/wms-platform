using System.Globalization;
using System.Text;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using Wms.Common.Contracts;
using Wms.Common.Infrastructure.Persistence;

namespace Wms.Common.Infrastructure.Messaging;

/// <summary>Publishes to the durable topic exchange <c>wms.events</c> using the RabbitMQ.Client 7 async API.</summary>
public sealed class RabbitMqEventBus(IOptions<RabbitMqOptions> options, ILogger<RabbitMqEventBus> logger) : IEventBus, IAsyncDisposable
{
    private readonly RabbitMqOptions _options = options.Value;
    private readonly SemaphoreSlim _gate = new(1, 1);
    private IConnection? _connection;
    private IChannel? _channel;

    public Task PublishAsync(IntegrationEvent integrationEvent, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(integrationEvent);
        var envelope = new EventEnvelope(
            integrationEvent.EventType,
            integrationEvent.TenantId,
            integrationEvent.EventId.ToString("D"),
            OutboxJson.Serialize(integrationEvent),
            integrationEvent.OccurredAt);
        return PublishAsync(envelope, cancellationToken);
    }

    public async Task PublishAsync(EventEnvelope envelope, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(envelope);
        var channel = await GetChannelAsync(cancellationToken).ConfigureAwait(false);

        var properties = new BasicProperties
        {
            ContentType = "application/json",
            ContentEncoding = "utf-8",
            MessageId = envelope.MessageId,
            Type = envelope.EventType,
            DeliveryMode = DeliveryModes.Persistent,
            Timestamp = new AmqpTimestamp(envelope.OccurredAt.ToUnixTimeSeconds()),
            Headers = new Dictionary<string, object?>
            {
                ["tenant_id"] = envelope.TenantId.ToString(CultureInfo.InvariantCulture),
                ["event_type"] = envelope.EventType,
            },
        };

        var body = Encoding.UTF8.GetBytes(envelope.PayloadJson);
        await channel.BasicPublishAsync(
            exchange: _options.Exchange,
            routingKey: envelope.EventType,
            mandatory: false,
            basicProperties: properties,
            body: body,
            cancellationToken: cancellationToken).ConfigureAwait(false);

        logger.LogDebug("Published {EventType} ({MessageId}) for tenant {TenantId}", envelope.EventType, envelope.MessageId, envelope.TenantId);
    }

    public async ValueTask DisposeAsync()
    {
        if (_channel is not null)
        {
            await _channel.DisposeAsync().ConfigureAwait(false);
        }

        if (_connection is not null)
        {
            await _connection.DisposeAsync().ConfigureAwait(false);
        }

        _gate.Dispose();
    }

    private async Task<IChannel> GetChannelAsync(CancellationToken cancellationToken)
    {
        if (_channel is { IsOpen: true })
        {
            return _channel;
        }

        await _gate.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            if (_channel is { IsOpen: true })
            {
                return _channel;
            }

            if (_connection is not { IsOpen: true })
            {
                if (_connection is not null)
                {
                    await _connection.DisposeAsync().ConfigureAwait(false);
                }

                var factory = new ConnectionFactory
                {
                    HostName = _options.Host,
                    Port = _options.Port,
                    VirtualHost = _options.VirtualHost,
                    UserName = _options.User,
                    Password = _options.Password,
                    ClientProvidedName = "wms-api",
                    AutomaticRecoveryEnabled = true,
                };
                _connection = await factory.CreateConnectionAsync(cancellationToken).ConfigureAwait(false);
            }

            if (_channel is not null)
            {
                await _channel.DisposeAsync().ConfigureAwait(false);
            }

            _channel = await _connection.CreateChannelAsync(cancellationToken: cancellationToken).ConfigureAwait(false);
            await _channel.ExchangeDeclareAsync(
                exchange: _options.Exchange,
                type: ExchangeType.Topic,
                durable: true,
                autoDelete: false,
                cancellationToken: cancellationToken).ConfigureAwait(false);
            return _channel;
        }
        finally
        {
            _gate.Release();
        }
    }
}
