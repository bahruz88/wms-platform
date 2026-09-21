namespace Wms.Common.Application.Paging;

/// <summary>Paged response envelope <c>{ items, page, size, total }</c> (spec §13.4).</summary>
public sealed record PagedResult<T>(IReadOnlyList<T> Items, int Page, int Size, long Total)
{
    public static PagedResult<T> Empty(PageRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);
        return new PagedResult<T>([], request.Page, request.Size, 0);
    }
}
