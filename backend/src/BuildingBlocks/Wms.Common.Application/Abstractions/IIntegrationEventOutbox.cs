using Wms.Common.Contracts;

namespace Wms.Common.Application.Abstractions;

/// <summary>
/// Enqueues an integration event into <c>common_outbox</c>. The row is written by the next
/// <c>SaveChangesAsync</c> of the module DbContext, i.e. inside the business transaction (spec §14.1).
/// </summary>
public interface IIntegrationEventOutbox
{
    void Enqueue(IntegrationEvent integrationEvent);
}
