using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Messaging;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Notification.Domain.Entities;
using Wms.Notification.Infrastructure.Persistence;

namespace Wms.Notification.Infrastructure.Messaging;

/// <summary>
/// Turns integration events into inbox rows (spec §14.1).
///
/// The queue, its binding to every routing key on <c>wms.events</c>, and its dead-letter exchange
/// are declared once in <c>deploy/rabbitmq/definitions.json</c>; this consumer only reads from it.
/// Redeclaring here would have to repeat the quorum-queue arguments exactly or the broker rejects
/// the channel, and two places owning one topology is how they drift apart.
///
/// Which events matter is a tenant's decision, held in <c>notif_rule</c>, not something frozen into
/// a binding — so the queue takes everything and an event nobody has a rule for is acknowledged and
/// discarded.
///
/// Delivery is at-least-once, so the same event can arrive twice. <c>uq_notif_event</c> makes the
/// second one a no-op: the insert is attempted, the duplicate key is caught, and the message is
/// acknowledged. That is the whole idempotency story — no extra bookkeeping table.
/// </summary>
public sealed class NotificationEventConsumer(
    IServiceScopeFactory scopeFactory,
    IOptions<RabbitMqOptions> options,
    IClock clock,
    ILogger<NotificationEventConsumer> logger) : BackgroundService
{
    /// <summary>The durable queue of <c>deploy/rabbitmq/definitions.json</c>.</summary>
    public const string QueueName = "wms.notification";

    private readonly RabbitMqOptions _options = options.Value;
    private IConnection? _connection;
    private IChannel? _channel;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ConnectAsync(stoppingToken).ConfigureAwait(false);
                // Connected and consuming; the delegate does the work from here.
                await Task.Delay(Timeout.InfiniteTimeSpan, stoppingToken).ConfigureAwait(false);
            }
            catch (OperationCanceledException)
            {
                return;
            }
            catch (Exception ex)
            {
                // A broker that is not up yet is the normal case on a cold start, not a failure.
                logger.LogWarning(ex, "Notification consumer lost its connection; retrying in 5 s.");
                await SafeCloseAsync().ConfigureAwait(false);
                try
                {
                    await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken).ConfigureAwait(false);
                }
                catch (OperationCanceledException)
                {
                    return;
                }
            }
        }
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        await SafeCloseAsync().ConfigureAwait(false);
        await base.StopAsync(cancellationToken).ConfigureAwait(false);
    }

    private async Task ConnectAsync(CancellationToken cancellationToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _options.Host,
            Port = _options.Port,
            VirtualHost = _options.VirtualHost,
            UserName = _options.User,
            Password = _options.Password,
            ClientProvidedName = "wms-notifications",
            AutomaticRecoveryEnabled = true,
        };

        _connection = await factory.CreateConnectionAsync(cancellationToken).ConfigureAwait(false);
        _channel = await _connection.CreateChannelAsync(cancellationToken: cancellationToken).ConfigureAwait(false);

        // Passive: assert the queue is there without describing it. A mismatch in the quorum-queue
        // arguments would close the channel, and the topology is not this consumer's to define.
        await _channel.QueueDeclarePassiveAsync(QueueName, cancellationToken).ConfigureAwait(false);

        // Composing an inbox row is a database write, not a race to drain the queue.
        await _channel.BasicQosAsync(0, prefetchCount: 16, global: false, cancellationToken).ConfigureAwait(false);

        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.ReceivedAsync += OnReceivedAsync;
        await _channel.BasicConsumeAsync(QueueName, autoAck: false, consumer, cancellationToken).ConfigureAwait(false);

        logger.LogInformation("Notification consumer is reading {Queue}.", QueueName);
    }

    private async Task OnReceivedAsync(object sender, BasicDeliverEventArgs args)
    {
        var channel = _channel;
        if (channel is null)
        {
            return;
        }

        var eventType = args.BasicProperties.Type ?? args.RoutingKey;
        try
        {
            var json = Encoding.UTF8.GetString(args.Body.Span);
            await HandleAsync(eventType, json, CancellationToken.None).ConfigureAwait(false);
            await channel.BasicAckAsync(args.DeliveryTag, multiple: false).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            // Requeueing would loop forever on a malformed payload. `requeue: false` hands the
            // message to wms.dlx instead, so it lands in wms.dead-letter for inspection rather than
            // vanishing, and one bad message cannot stall every notification behind it.
            logger.LogError(ex, "Notification consumer could not handle {EventType}; dead-lettered.", eventType);
            await channel.BasicNackAsync(args.DeliveryTag, multiple: false, requeue: false).ConfigureAwait(false);
        }
    }

    private async Task HandleAsync(string eventType, string payloadJson, CancellationToken cancellationToken)
    {
        using var document = JsonDocument.Parse(payloadJson);
        var payload = document.RootElement;

        if (!payload.TryGetProperty("tenantId", out var tenantElement) || !tenantElement.TryGetUInt32(out var tenantId))
        {
            logger.LogWarning("Event {EventType} carries no tenantId; ignored.", eventType);
            return;
        }

        var eventId = payload.TryGetProperty("eventId", out var idElement) && idElement.ValueKind is JsonValueKind.String
            && Guid.TryParse(idElement.GetString(), out var parsed)
                ? parsed
                : Guid.NewGuid();

        using var scope = scopeFactory.CreateScope();
        scope.ServiceProvider.GetRequiredService<ITenantContextInitializer>().Initialize(tenantId);
        var db = scope.ServiceProvider.GetRequiredService<NotificationDbContext>();

        var rules = await db.Rules.AsNoTracking()
            .Where(r => r.IsActive && r.EventType == eventType)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        if (rules.Count == 0)
        {
            return;
        }

        var composed = NotificationComposer.Compose(eventType, payload);
        var createdAt = clock.UtcNow;
        var written = 0;

        foreach (var rule in rules)
        {
            foreach (var message in Build(rule, composed, tenantId, eventId, eventType, createdAt))
            {
                db.Messages.Add(message);
                written++;
            }
        }

        if (written == 0)
        {
            return;
        }

        try
        {
            await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            logger.LogInformation("Event {EventType} produced {Count} notifications for tenant {TenantId}.", eventType, written, tenantId);
        }
        catch (DbUpdateException ex) when (IsDuplicate(ex))
        {
            // uq_notif_event: this event has already been delivered. Redelivery is expected.
            logger.LogDebug("Event {EventType} ({EventId}) was already delivered; skipped.", eventType, eventId);
        }
    }

    private static IEnumerable<NotificationMessage> Build(
        NotificationRule rule,
        ComposedNotification composed,
        uint tenantId,
        Guid eventId,
        string eventType,
        DateTimeOffset createdAt)
    {
        // The rule's severity wins over the composer's default: a tenant that marks expiry CRITICAL
        // means it, even where the platform would have said WARNING.
        var channel = rule.ChannelList.FirstOrDefault() ?? "IN_APP";

        foreach (var userId in rule.TargetUserIdList)
        {
            var message = NotificationMessage.Create(
                tenantId, eventId, eventType, composed.Title, composed.Body, createdAt, rule.Severity,
                recipientUserId: userId, recipientRole: null, channel: channel,
                link: composed.Link, entityType: composed.EntityType, entityId: composed.EntityId,
                locationId: composed.LocationId);
            if (message.IsSuccess)
            {
                yield return message.Value;
            }
        }

        if (!string.IsNullOrWhiteSpace(rule.TargetRoleCode))
        {
            var message = NotificationMessage.Create(
                tenantId, eventId, eventType, composed.Title, composed.Body, createdAt, rule.Severity,
                recipientUserId: null, recipientRole: rule.TargetRoleCode, channel: channel,
                link: composed.Link, entityType: composed.EntityType, entityId: composed.EntityId,
                locationId: composed.LocationId);
            if (message.IsSuccess)
            {
                yield return message.Value;
            }
        }
    }

    private static bool IsDuplicate(DbUpdateException ex) =>
        ex.InnerException?.Message.Contains("Duplicate entry", StringComparison.OrdinalIgnoreCase) == true;

    private async Task SafeCloseAsync()
    {
        try
        {
            if (_channel is not null)
            {
                await _channel.DisposeAsync().ConfigureAwait(false);
                _channel = null;
            }

            if (_connection is not null)
            {
                await _connection.DisposeAsync().ConfigureAwait(false);
                _connection = null;
            }
        }
        catch (Exception ex)
        {
            logger.LogDebug(ex, "Notification consumer close failed; ignored.");
        }
    }
}
