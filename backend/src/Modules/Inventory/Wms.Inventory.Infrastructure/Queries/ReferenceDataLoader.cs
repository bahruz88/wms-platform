using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Infrastructure.Queries;

/// <summary>
/// Batches the master-data lookups a document page needs. Products, locations, UoMs and suppliers come from the
/// MasterData contracts (in-process or HTTP, spec §4.2); batches are Inventory's own table.
/// </summary>
public sealed class ReferenceDataLoader(
    InventoryDbContext db,
    IProductCatalog products,
    ILocationCatalog locations,
    IUomCatalog uoms,
    ISupplierCatalog suppliers) : IReferenceDataLoader
{
    public async Task<ReferenceDataSet> LoadAsync(ReferenceDataRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var productMap = request.ProductIds.Count == 0
            ? new Dictionary<uint, ProductDto>()
            : (await products.GetManyAsync(request.ProductIds, cancellationToken).ConfigureAwait(false))
                .ToDictionary(p => p.Id);

        var locationMap = request.LocationIds.Count == 0
            ? new Dictionary<uint, LocationDto>()
            : (await locations.GetManyAsync(request.LocationIds, cancellationToken).ConfigureAwait(false))
                .ToDictionary(l => l.Id);

        var uomMap = request.UomIds.Count == 0
            ? new Dictionary<ushort, UomRefDto>()
            : (await uoms.GetManyAsync(request.UomIds, cancellationToken).ConfigureAwait(false))
                .ToDictionary(u => u.Id);

        var supplierMap = request.SupplierIds.Count == 0
            ? new Dictionary<uint, SupplierRefDto>()
            : (await suppliers.GetManyAsync(request.SupplierIds, cancellationToken).ConfigureAwait(false))
                .ToDictionary(s => s.Id);

        var batchMap = new Dictionary<long, BatchRefDto>();
        if (request.BatchIds.Count > 0)
        {
            var ids = request.BatchIds.ToArray();
            var rows = await db.Batches.AsNoTracking()
                .Where(b => ids.Contains(b.Id))
                .Select(b => new { b.Id, b.BatchNo, b.ExpiryDate, b.Status })
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);
            foreach (var row in rows)
            {
                batchMap[row.Id] = new BatchRefDto(row.Id, row.BatchNo, row.ExpiryDate, UpperSnakeCaseEnum.Format(row.Status));
            }
        }

        return new ReferenceDataSet(productMap, locationMap, batchMap, uomMap, supplierMap);
    }
}
