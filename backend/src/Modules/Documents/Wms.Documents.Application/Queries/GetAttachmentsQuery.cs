using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Contracts;

namespace Wms.Documents.Application.Queries;

/// <summary><c>GET /api/v1/documents/attachments?entityType=&amp;entityId=</c>.</summary>
public sealed record GetAttachmentsQuery(string EntityType, long EntityId, PageRequest Page) : IQuery<PagedResult<AttachmentDto>>;

public sealed class GetAttachmentsQueryHandler(IAttachmentQueries queries) : IQueryHandler<GetAttachmentsQuery, PagedResult<AttachmentDto>>
{
    public async Task<Result<PagedResult<AttachmentDto>>> HandleAsync(GetAttachmentsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetByEntityAsync(query.EntityType, query.EntityId, query.Page, cancellationToken).ConfigureAwait(false);
    }
}
