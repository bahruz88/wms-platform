using Wms.Common.Application.Paging;
using Wms.Identity.Application.Dtos;

namespace Wms.Identity.Application.Abstractions;

public interface IIdentityQueries
{
    Task<PagedResult<UserDto>> GetUsersAsync(PageRequest page, CancellationToken cancellationToken);

    Task<UserDto?> GetUserAsync(uint userId, CancellationToken cancellationToken);
}
