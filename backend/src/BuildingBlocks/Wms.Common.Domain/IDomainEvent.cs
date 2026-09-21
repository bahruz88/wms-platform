namespace Wms.Common.Domain;

/// <summary>Something that happened inside an aggregate. Persisted to the outbox in the same transaction.</summary>
public interface IDomainEvent
{
    Guid EventId { get; }

    DateTimeOffset OccurredAt { get; }
}

/// <summary>Convenience base record for domain events.</summary>
public abstract record DomainEvent(DateTimeOffset OccurredAt) : IDomainEvent
{
    public Guid EventId { get; init; } = Guid.NewGuid();
}
