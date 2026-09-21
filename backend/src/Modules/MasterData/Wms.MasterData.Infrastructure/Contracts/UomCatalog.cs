using Wms.Common.Infrastructure.Persistence;
using Wms.MasterData.Contracts;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.MasterData.Infrastructure.Contracts;

/// <summary>In-process <see cref="IUomCatalog"/> (spec §4.2).</summary>
public sealed class UomCatalog(MasterDataDbContext db) : IUomCatalog
{
    public async Task<UomRefDto?> GetAsync(long uomId, CancellationToken cancellationToken)
    {
        if (uomId is <= 0 or > ushort.MaxValue)
        {
            return null;
        }

        var uoms = await GetManyAsync([(ushort)uomId], cancellationToken).ConfigureAwait(false);
        return uoms.Count == 0 ? null : uoms[0];
    }

    public async Task<IReadOnlyList<UomRefDto>> GetManyAsync(IReadOnlyCollection<ushort> uomIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(uomIds);
        if (uomIds.Count == 0)
        {
            return [];
        }

        var ids = uomIds.Distinct().ToArray();
        var rows = await db.Uoms.AsNoTracking()
            .Where(u => ids.Contains(u.Id))
            .Select(u => new { u.Id, u.Code, u.Name, u.UomClass, u.Decimals })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows
            .Select(u => new UomRefDto(u.Id, u.Code, u.Name, UpperSnakeCaseEnum.Format(u.UomClass), u.Decimals))
            .ToList();
    }
}

/// <summary>In-process <see cref="IReasonCodeCatalog"/> (spec §4.2).</summary>
public sealed class ReasonCodeCatalog(MasterDataDbContext db) : IReasonCodeCatalog
{
    public async Task<ReasonCodeRefDto?> GetAsync(long reasonCodeId, CancellationToken cancellationToken)
    {
        if (reasonCodeId is <= 0 or > ushort.MaxValue)
        {
            return null;
        }

        var codes = await GetManyAsync([(ushort)reasonCodeId], cancellationToken).ConfigureAwait(false);
        return codes.Count == 0 ? null : codes[0];
    }

    public async Task<IReadOnlyList<ReasonCodeRefDto>> GetManyAsync(IReadOnlyCollection<ushort> reasonCodeIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(reasonCodeIds);
        if (reasonCodeIds.Count == 0)
        {
            return [];
        }

        var ids = reasonCodeIds.Distinct().ToArray();
        var rows = await db.ReasonCodes.AsNoTracking()
            .Where(r => ids.Contains(r.Id))
            .Select(r => new { r.Id, r.Code, r.Name, r.ReasonGroup, r.RequiresApproval, r.RequiresPhoto, r.IsActive })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows
            .Select(r => new ReasonCodeRefDto(
                r.Id, r.Code, r.Name, UpperSnakeCaseEnum.Format(r.ReasonGroup), r.RequiresApproval, r.RequiresPhoto, r.IsActive))
            .ToList();
    }
}
