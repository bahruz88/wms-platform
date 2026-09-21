namespace Wms.MasterData.Contracts;

/// <summary>Supplier card as seen by other modules (spec §4.2). No banking or commercial-terms data.</summary>
public sealed record SupplierRefDto(
    uint Id,
    string Code,
    string Name,
    string Currency,
    bool IsApprovedFoodSupplier,
    bool IsActive);

public interface ISupplierCatalog
{
    Task<SupplierRefDto?> GetAsync(long supplierId, CancellationToken cancellationToken);

    /// <summary>Bulk variant used to decorate document lines without an N+1 round trip.</summary>
    Task<IReadOnlyList<SupplierRefDto>> GetManyAsync(IReadOnlyCollection<uint> supplierIds, CancellationToken cancellationToken);
}
