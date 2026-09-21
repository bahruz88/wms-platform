using Wms.Common.Application.Paging;

namespace Wms.Common.Infrastructure.Http;

/// <summary>Shared <c>?page=&amp;size=</c> query binding for Minimal API endpoints (spec §13.4, max size 200).</summary>
public sealed record PagingRequest(int? Page, int? Size)
{
    public PageRequest ToPageRequest() => new(Page ?? 1, Size ?? PageRequest.DefaultSize);
}
