namespace Wms.MasterData.Contracts;

/// <summary>Spec §4.2. In-process implementation lives in MasterData.Infrastructure; HTTP stub is used when the module is remote.</summary>
public interface IProductCatalog
{
    Task<ProductDto?> GetAsync(long productId, CancellationToken cancellationToken);

    /// <summary>
    /// <c>master_product_uom.factor_to_base</c> valid on <paramref name="date"/> (DECIMAL(18,8)). The caller freezes the
    /// value in <c>inv_movement.conversion_rate</c> (spec §12.1). Null when no factor is defined.
    /// </summary>
    Task<decimal?> GetUomFactorAsync(long productId, long uomId, DateOnly date, CancellationToken cancellationToken);
}
