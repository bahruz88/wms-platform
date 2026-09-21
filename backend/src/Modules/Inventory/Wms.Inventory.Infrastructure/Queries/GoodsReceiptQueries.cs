using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Infrastructure.Queries;

public sealed class GoodsReceiptQueries(
    InventoryDbContext db,
    IReferenceDataLoader referenceData,
    IProductCatalog products) : IGoodsReceiptQueries
{
    public async Task<GoodsReceiptDto?> GetAsync(long receiptId, bool includeCost, CancellationToken cancellationToken)
    {
        var receipt = await db.GoodsReceipts.AsNoTracking()
            .Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == receiptId, cancellationToken)
            .ConfigureAwait(false);
        if (receipt is null)
        {
            return null;
        }

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: receipt.Lines.Select(l => l.ProductId),
                locationIds: [receipt.LocationId],
                uomIds: receipt.Lines.Select(l => l.UomId),
                supplierIds: [receipt.SupplierId]),
            cancellationToken).ConfigureAwait(false);

        DateTimeOffset? postedAt = null;
        if (receipt.MovementGroupId is { } groupId)
        {
            postedAt = await db.MovementGroups.AsNoTracking()
                .Where(g => g.Id == groupId)
                .Select(g => (DateTimeOffset?)g.PostedAt)
                .FirstOrDefaultAsync(cancellationToken)
                .ConfigureAwait(false);
        }

        // The batch is only known after posting; match on (product, batchNo, expiry) exactly as PostGoodsReceipt does.
        var batchKeys = receipt.Lines.Where(l => l.BatchNo is not null).ToList();
        var batchIds = new Dictionary<long, long>();
        if (batchKeys.Count > 0)
        {
            var productIds = batchKeys.Select(l => l.ProductId).Distinct().ToArray();
            var candidates = await db.Batches.AsNoTracking()
                .Where(b => productIds.Contains(b.ProductId))
                .Select(b => new { b.Id, b.ProductId, b.BatchNo, b.ExpiryDate })
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);
            foreach (var line in batchKeys)
            {
                var match = candidates.FirstOrDefault(b =>
                    b.ProductId == line.ProductId
                    && string.Equals(b.BatchNo, line.BatchNo, StringComparison.Ordinal)
                    && b.ExpiryDate == line.ExpiryDate);
                if (match is not null)
                {
                    batchIds[line.Id] = match.Id;
                }
            }
        }

        var lines = new List<GoodsReceiptLineDto>(receipt.Lines.Count);
        foreach (var line in receipt.Lines.OrderBy(l => l.LineNo))
        {
            var factor = await products.GetUomFactorAsync(line.ProductId, line.UomId, receipt.DocDate, cancellationToken).ConfigureAwait(false) ?? 1m;
            var baseDecimals = refs.Product(line.ProductId)?.BaseUomDecimals ?? (byte)Quantity.StorageDecimals;
            lines.Add(new GoodsReceiptLineDto(
                line.Id,
                line.LineNo,
                refs.ProductRef(line.ProductId),
                line.PoLineId,
                line.OrderedQty,
                line.ReceivedQty,
                line.RejectedQty,
                line.UomId,
                refs.UomCode(line.UomId),
                Quantity.Convert(line.QtyToStock(), factor, baseDecimals).Value,
                line.BatchNo,
                batchIds.TryGetValue(line.Id, out var batchId) ? batchId : null,
                line.ProductionDate,
                line.ExpiryDate,
                includeCost ? line.UnitPrice : null,
                includeCost ? line.Currency : null,
                line.VarianceNote,
                line.OrderedQty is { } ordered ? line.ReceivedQty - ordered : null));
        }

        return new GoodsReceiptDto(
            receipt.Id,
            receipt.DocNo,
            receipt.DocDate,
            receipt.PoId,
            PoDocNo: null,
            receipt.SupplierId,
            refs.SupplierName(receipt.SupplierId),
            receipt.LocationId,
            refs.LocationName(receipt.LocationId),
            UpperSnakeCaseEnum.Format(receipt.QualityStatus),
            UpperSnakeCaseEnum.Format(receipt.Status),
            HasVariance(receipt),
            receipt.Lines.Count,
            receipt.RowVersion,
            receipt.TemperatureC,
            receipt.PackagingNote,
            receipt.MovementGroupId,
            postedAt,

            // common_attachment belongs to the Documents module; the UI reads it from GET /documents/attachments.
            Lines: lines,
            AttachmentIds: [],
            Audit: new AuditFieldsDto(receipt.CreatedAt, receipt.CreatedBy, receipt.UpdatedAt, receipt.UpdatedBy, receipt.RowVersion));
    }

    public async Task<PagedResult<GoodsReceiptSummaryDto>> ListAsync(GoodsReceiptFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.GoodsReceipts.AsNoTracking().Include(r => r.Lines).AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!TryParseStatus(filter.Status, out var status))
            {
                return new PagedResult<GoodsReceiptSummaryDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(r => r.Status == status);
        }

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(r => r.SupplierId == supplierId);
        }

        if (filter.LocationId is { } locationId)
        {
            query = query.Where(r => r.LocationId == locationId);
        }

        if (filter.PoId is { } poId)
        {
            query = query.Where(r => r.PoId == poId);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(r => r.DocDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(r => r.DocDate <= to);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var term = filter.Search.Trim();
            query = query.Where(r => r.DocNo.Contains(term));
        }

        // Branch users only see receipts for their own locations (spec §16).
        if (filter.VisibleLocationIds.Count > 0)
        {
            var visible = filter.VisibleLocationIds.ToArray();
            query = query.Where(r => visible.Contains(r.LocationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(r => r.DocDate).ThenByDescending(r => r.Id)
            .Skip(page.Skip)
            .Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                locationIds: rows.Select(r => r.LocationId),
                supplierIds: rows.Select(r => r.SupplierId)),
            cancellationToken).ConfigureAwait(false);

        var items = rows.Select(r => new GoodsReceiptSummaryDto(
            r.Id,
            r.DocNo,
            r.DocDate,
            r.PoId,
            PoDocNo: null,
            r.SupplierId,
            refs.SupplierName(r.SupplierId),
            r.LocationId,
            refs.LocationName(r.LocationId),
            UpperSnakeCaseEnum.Format(r.QualityStatus),
            UpperSnakeCaseEnum.Format(r.Status),
            HasVariance(r),
            r.Lines.Count,
            r.RowVersion)).ToList();

        return new PagedResult<GoodsReceiptSummaryDto>(items, page.Page, page.Size, total);
    }

    private static bool HasVariance(GoodsReceipt receipt) =>
        receipt.Lines.Any(l => l.OrderedQty is { } ordered && ordered != l.ReceivedQty);

    private static bool TryParseStatus(string raw, out ReceiptStatus status)
    {
        foreach (var candidate in Enum.GetValues<ReceiptStatus>())
        {
            if (string.Equals(UpperSnakeCaseEnum.Format(candidate), raw, StringComparison.OrdinalIgnoreCase))
            {
                status = candidate;
                return true;
            }
        }

        status = default;
        return false;
    }
}
