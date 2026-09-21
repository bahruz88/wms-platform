using Wms.Common.Contracts;

namespace Wms.Common.Infrastructure.Messaging;

/// <summary>Thin abstraction over RabbitMQ (spec §3: no MassTransit). Business code never calls this directly — it goes through the outbox.</summary>
public interface IEventBus
{
    Task PublishAsync(EventEnvelope envelope, CancellationToken cancellationToken);

    Task PublishAsync(IntegrationEvent integrationEvent, CancellationToken cancellationToken);
}
