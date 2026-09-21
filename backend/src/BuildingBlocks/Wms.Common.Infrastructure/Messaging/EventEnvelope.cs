namespace Wms.Common.Infrastructure.Messaging;

/// <summary>What the outbox publisher hands to the bus: routing key = <see cref="EventType"/>, body = JSON payload.</summary>
public sealed record EventEnvelope(string EventType, uint TenantId, string MessageId, string PayloadJson, DateTimeOffset OccurredAt);
