namespace Wms.Common.Domain;

/// <summary>Non-generic view of an aggregate root used by infrastructure to drain domain events.</summary>
public interface IAggregateRoot
{
    IReadOnlyCollection<IDomainEvent> DomainEvents { get; }

    void ClearDomainEvents();
}
