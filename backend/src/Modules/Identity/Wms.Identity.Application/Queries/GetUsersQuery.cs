using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Application.Dtos;

namespace Wms.Identity.Application.Queries;

/// <summary><c>GET /api/v1/identity/users</c>.</summary>
public sealed record GetUsersQuery(PageRequest Page) : IQuery<PagedResult<UserDto>>;

public sealed class GetUsersQueryHandler(IIdentityQueries queries) : IQueryHandler<GetUsersQuery, PagedResult<UserDto>>
{
    public async Task<Result<PagedResult<UserDto>>> HandleAsync(GetUsersQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetUsersAsync(query.Page, cancellationToken).ConfigureAwait(false);
    }
}
