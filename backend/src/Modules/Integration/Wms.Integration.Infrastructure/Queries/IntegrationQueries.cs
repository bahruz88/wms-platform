using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Persistence;
using Wms.Integration.Application.Abstractions;
using Wms.Integration.Infrastructure.Persistence;

namespace Wms.Integration.Infrastructure.Queries;

public sealed class IntegrationQueries(IntegrationDbContext db) : IIntegrationQueries
{
    public async Task<PagedResult<OutboundMessageDto>> GetOutboundAsync(string? status, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(page);
        var query = db.OutboundMessages.AsNoTracking();
        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(m => m.Id)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(m => new { m.Id, m.SystemCode, m.EventId, m.EventType, m.Status, m.AttemptCount, m.LastError, m.CreatedAt, m.SentAt })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows
            .Select(m => new OutboundMessageDto(
                m.Id, m.SystemCode, m.EventId, m.EventType, UpperSnakeCaseEnum.Format(m.Status),
                m.AttemptCount, m.LastError, m.CreatedAt, m.SentAt))
            .Where(m => status is null || string.Equals(m.Status, status, StringComparison.OrdinalIgnoreCase))
            .ToList();

        return new PagedResult<OutboundMessageDto>(items, page.Page, page.Size, total);
    }
}
