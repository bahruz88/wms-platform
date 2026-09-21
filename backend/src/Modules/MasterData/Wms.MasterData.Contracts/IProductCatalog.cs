namespace Wms.MasterData.Contracts;

/// <summary>Spec §4.2. In-process implementation lives in MasterData.Infrastructure; HTTP stub is used when the module is remote.</summary>
public interface IProductCatalog
{
    Task<ProductDto?> GetAsync(long productId, CancellationToken cancellationToken);

    /// <summary>Bulk variant used to decorate document lines without an N+1 round trip. Unknown ids are omitted.</summary>
    Task<IReadOnlyList<ProductDto>> GetManyAsync(IReadOnlyCollection<uint> productIds, CancellationToken cancellationToken);

    /// <summary>Active product ids in the given categories — the scope resolver of a CYCLE inventory count (TOR §21).</summary>
    Task<IReadOnlyList<uint>> GetIdsByCategoryAsync(IReadOnlyCollection<uint> categoryIds, CancellationToken cancellationToken);

    /// <summary>
    /// <c>master_product_uom.factor_to_base</c> valid on <paramref name="date"/> (DECIMAL(18,8)). The caller freezes the
    /// value in <c>inv_movement.conversion_rate</c> (spec §12.1). Null when no factor is defined.
    /// </summary>
    Task<decimal?> GetUomFactorAsync(long productId, long uomId, DateOnly date, CancellationToken cancellationToken);
}
