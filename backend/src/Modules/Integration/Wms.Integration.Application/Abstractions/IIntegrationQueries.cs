using Wms.Common.Application.Paging;

namespace Wms.Integration.Application.Abstractions;

public sealed record OutboundMessageDto(
    long Id,
    string SystemCode,
    Guid EventId,
    string EventType,
    string Status,
    ushort AttemptCount,
    string? LastError,
    DateTimeOffset CreatedAt,
    DateTimeOffset? SentAt);

public interface IIntegrationQueries
{
    Task<PagedResult<OutboundMessageDto>> GetOutboundAsync(string? status, PageRequest page, CancellationToken cancellationToken);
}
