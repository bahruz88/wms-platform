using Wms.Common.Application.Paging;
using Wms.Documents.Contracts;

namespace Wms.Documents.Application.Abstractions;

public interface IAttachmentQueries
{
    Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken);

    Task<PagedResult<AttachmentDto>> GetByEntityAsync(string entityType, long entityId, PageRequest page, CancellationToken cancellationToken);
}
