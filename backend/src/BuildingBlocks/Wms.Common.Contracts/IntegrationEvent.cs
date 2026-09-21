namespace Wms.Common.Contracts;

/// <summary>
/// Base of every integration event (spec §14). Consumers must be idempotent and de-duplicate on <see cref="EventId"/>.
/// </summary>
public abstract record IntegrationEvent(uint TenantId, DateTimeOffset OccurredAt)
{
    public Guid EventId { get; init; } = Guid.NewGuid();

    /// <summary>Routing key on the <c>wms.events</c> topic exchange.</summary>
    public string EventType => GetType().Name;
}
