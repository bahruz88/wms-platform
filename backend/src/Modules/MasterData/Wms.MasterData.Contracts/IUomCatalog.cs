namespace Wms.MasterData.Contracts;

/// <summary>Unit of measure as seen by other modules (spec §4.2).</summary>
public sealed record UomRefDto(ushort Id, string Code, string Name, string UomClass, byte Decimals);

public interface IUomCatalog
{
    Task<UomRefDto?> GetAsync(long uomId, CancellationToken cancellationToken);

    /// <summary>Bulk variant used to decorate document lines without an N+1 round trip. Unknown ids are omitted.</summary>
    Task<IReadOnlyList<UomRefDto>> GetManyAsync(IReadOnlyCollection<ushort> uomIds, CancellationToken cancellationToken);
}
