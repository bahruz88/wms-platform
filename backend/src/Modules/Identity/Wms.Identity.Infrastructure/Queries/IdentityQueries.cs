using Wms.Common.Application.Paging;
using Wms.Identity.Application.Abstractions;
using Wms.Identity.Application.Dtos;
using Wms.Identity.Infrastructure.Persistence;

namespace Wms.Identity.Infrastructure.Queries;

public sealed class IdentityQueries(IdentityDbContext db) : IIdentityQueries
{
    public async Task<PagedResult<UserDto>> GetUsersAsync(PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(page);
        var query = db.Users.AsNoTracking();
        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var users = await query
            .OrderBy(u => u.Username)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(u => new
            {
                u.Id,
                u.Username,
                u.FullName,
                u.Email,
                u.Phone,
                u.IsActive,
                RoleIds = u.Roles.Select(r => r.RoleId).ToList(),
                LocationIds = u.Locations.Select(l => l.LocationId).ToList(),
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var roleCodes = await db.Roles.AsNoTracking()
            .ToDictionaryAsync(r => r.Id, r => r.Code, cancellationToken)
            .ConfigureAwait(false);

        var items = users.Select(u => new UserDto(
            u.Id,
            u.Username,
            u.FullName,
            u.Email,
            u.Phone,
            u.IsActive,
            u.RoleIds.Select(id => roleCodes.GetValueOrDefault(id, id.ToString(System.Globalization.CultureInfo.InvariantCulture))).ToList(),
            u.LocationIds)).ToList();

        return new PagedResult<UserDto>(items, page.Page, page.Size, total);
    }

    public async Task<UserDto?> GetUserAsync(uint userId, CancellationToken cancellationToken)
    {
        var user = await db.Users.AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => new
            {
                u.Id,
                u.Username,
                u.FullName,
                u.Email,
                u.Phone,
                u.IsActive,
                RoleIds = u.Roles.Select(r => r.RoleId).ToList(),
                LocationIds = u.Locations.Select(l => l.LocationId).ToList(),
            })
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
        if (user is null)
        {
            return null;
        }

        var roleCodes = await db.Roles.AsNoTracking()
            .Where(r => user.RoleIds.Contains(r.Id))
            .Select(r => r.Code)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new UserDto(user.Id, user.Username, user.FullName, user.Email, user.Phone, user.IsActive, roleCodes, user.LocationIds);
    }
}
