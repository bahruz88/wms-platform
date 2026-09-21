using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Integration.Application.Abstractions;

namespace Wms.Integration.Application.Queries;

/// <summary><c>GET /api/v1/integration/outbound</c> — what has been forwarded to 1C and what failed.</summary>
public sealed record GetOutboundMessagesQuery(string? Status, PageRequest Page) : IQuery<PagedResult<OutboundMessageDto>>;

public sealed class GetOutboundMessagesQueryHandler(IIntegrationQueries queries) : IQueryHandler<GetOutboundMessagesQuery, PagedResult<OutboundMessageDto>>
{
    public async Task<Result<PagedResult<OutboundMessageDto>>> HandleAsync(GetOutboundMessagesQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetOutboundAsync(query.Status, query.Page, cancellationToken).ConfigureAwait(false);
    }
}
