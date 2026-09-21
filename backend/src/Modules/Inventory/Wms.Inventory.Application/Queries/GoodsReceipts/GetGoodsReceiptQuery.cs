using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Queries.GoodsReceipts;

/// <summary><c>GET /api/v1/inventory/goods-receipts/{id}</c>.</summary>
public sealed record GetGoodsReceiptQuery(long ReceiptId) : IQuery<GoodsReceiptDto>;

public sealed class GetGoodsReceiptQueryHandler(IGoodsReceiptQueries queries, ICurrentUser currentUser) : IQueryHandler<GetGoodsReceiptQuery, GoodsReceiptDto>
{
    public async Task<Result<GoodsReceiptDto>> HandleAsync(GetGoodsReceiptQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var includeCost = currentUser.HasPermission(InventoryPermissions.ViewCost);
        var dto = await queries.GetAsync(query.ReceiptId, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? InventoryErrors.ReceiptNotFound(query.ReceiptId) : dto;
    }
}
