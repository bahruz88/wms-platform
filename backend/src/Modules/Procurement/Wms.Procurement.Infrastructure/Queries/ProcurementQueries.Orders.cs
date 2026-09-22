using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.Infrastructure.Queries;

public sealed partial class ProcurementQueries
{
    // ------------------------------------------------------------ Comparison matrix

    public async Task<RfqComparisonDto?> GetRfqComparisonAsync(long rfqId, CancellationToken cancellationToken)
    {
        var rfq = await db.Rfqs.AsNoTracking()
            .Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == rfqId, cancellationToken)
            .ConfigureAwait(false);
        if (rfq is null)
        {
            return null;
        }

        var quotations = await db.Quotations.AsNoTracking()
            .Include(q => q.Lines)
            .Where(q => q.RfqId == rfqId)
            .OrderBy(q => q.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var lines = rfq.Lines.OrderBy(l => l.LineNo).ToList();
        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                productIds: lines.Select(l => l.ProductId),
                uomIds: lines.Select(l => l.UomId),
                supplierIds: quotations.Select(q => q.SupplierId)),
            cancellationToken).ConfigureAwait(false);

        var baseCurrency = await currencyRates.GetBaseCurrencyAsync(cancellationToken).ConfigureAwait(false);
        var previousPrices = await priceHistoryLookup
            .GetLastPricesBaseAsync(tenantContext.TenantId, lines.Select(l => l.ProductId).Distinct().ToArray(), cancellationToken)
            .ConfigureAwait(false);

        var cheapestId = QuotationRanking.CheapestQuotationId(
            quotations.Select(q => new RankedQuotation(q.Id, q.Lines.Count == 0 ? null : q.TotalAmountBase)));
        var selectedId = quotations.Find(q => q.IsSelected)?.Id;

        var columns = quotations
            .Select(q => new QuotationSummaryDto(
                q.Id, q.RfqId, rfq.DocNo, refs.SupplierRef(q.SupplierId), q.QuoteNo, q.QuoteDate, q.ValidUntil,
                q.Currency, q.DeliveryDays,
                q.Lines.Count == 0 ? null : q.TotalAmount,
                q.Lines.Count == 0 ? null : q.TotalAmountBase,
                q.IsSelected,
                cheapestId is null || cheapestId == q.Id,
                q.SelectionNote,
                q.RowVersion))
            .ToList();

        var rows = new List<RfqComparisonRowDto>(lines.Count);
        foreach (var line in lines)
        {
            previousPrices.TryGetValue(line.ProductId, out var previous);
            decimal? prevPriceBase = previousPrices.ContainsKey(line.ProductId) ? previous : null;

            var cells = new List<RfqComparisonCellDto>(quotations.Count);
            foreach (var quotation in quotations)
            {
                // A supplier may answer a line either by its RFQ line or simply by quoting the same product.
                var quotationLine = quotation.Lines.FirstOrDefault(l => l.RfqLineId == line.Id)
                    ?? quotation.Lines.FirstOrDefault(l => l.ProductId == line.ProductId);

                cells.Add(new RfqComparisonCellDto(
                    quotation.Id,
                    quotationLine?.Id,
                    quotationLine?.UnitPrice,
                    quotationLine is null ? null : quotation.Currency,
                    quotationLine?.UnitPriceBase,
                    quotationLine is null ? null : Quantity.Round(quotationLine.UnitPriceBase * line.Qty, Money.StorageDecimals),
                    DiffPct(prevPriceBase, quotationLine?.UnitPriceBase),
                    false));
            }

            var lowest = QuotationRanking.LowestUnitPriceQuotationId(cells.Select(c => (c.QuotationId, c.UnitPriceBase)));
            var marked = cells
                .Select(c => c with { IsLowest = lowest is not null && c.QuotationId == lowest && c.UnitPriceBase is not null })
                .ToList();

            rows.Add(new RfqComparisonRowDto(
                line.Id, refs.ProductRef(line.ProductId), line.Qty, refs.UomCode(line.UomId), prevPriceBase, marked));
        }

        return new RfqComparisonDto(rfq.Id, rfq.DocNo, baseCurrency, cheapestId, selectedId, columns, rows);
    }

    private static decimal? DiffPct(decimal? previous, decimal? current)
    {
        if (previous is not { } prev || current is not { } now || prev == 0m)
        {
            return null;
        }

        return Quantity.Round((now - prev) / prev * 100m, 4);
    }

    // ------------------------------------------------------------ Purchase orders

    public async Task<PagedResult<PurchaseOrderSummaryDto>> ListPurchaseOrdersAsync(
        PurchaseOrderFilter filter,
        PageRequest page,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.PurchaseOrders.AsNoTracking();
        if (filter.Status is { } status)
        {
            query = query.Where(p => p.Status == status);
        }

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(p => p.SupplierId == supplierId);
        }

        if (filter.DeliveryLocationId is { } locationId)
        {
            query = query.Where(p => p.DeliveryLocationId == locationId);
        }

        // Spec §16: a restricted principal sees only the orders delivered to their own locations.
        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(p => visible.Contains(p.DeliveryLocationId));
        }

        if (filter.ProductType is { } productType)
        {
            query = query.Where(p => p.ProductType == productType);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(p => p.DocDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(p => p.DocDate <= to);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(p => p.DocNo.Contains(search) || (p.Note != null && p.Note.Contains(search)));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(p => p.DocDate).ThenByDescending(p => p.Id)
            .Skip(page.Skip).Take(page.Size)
            .Select(p => new
            {
                p.Id, p.DocNo, p.DocDate, p.SupplierId, p.Currency, p.TotalAmount, p.TotalAmountBase,
                p.DeliveryLocationId, p.ProductType, p.ExpectedDate, p.Status, p.CreatedBy, p.RowVersion,
                OrderedQty = p.Lines.Sum(l => (decimal?)l.Qty) ?? 0m,
                ReceivedQty = p.Lines.Sum(l => (decimal?)l.ReceivedQty) ?? 0m,
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                locationIds: rows.Select(r => r.DeliveryLocationId),
                supplierIds: rows.Select(r => r.SupplierId),
                userIds: rows.Select(r => r.CreatedBy)),
            cancellationToken).ConfigureAwait(false);

        var items = rows
            .Select(p => new PurchaseOrderSummaryDto(
                p.Id, p.DocNo, p.DocDate, refs.SupplierRef(p.SupplierId), p.Currency, p.TotalAmount, p.TotalAmountBase,
                refs.LocationRef(p.DeliveryLocationId), p.ProductType, p.ExpectedDate, p.Status,
                ReceivedPct(p.OrderedQty, p.ReceivedQty), refs.UserRef(p.CreatedBy), p.RowVersion))
            .ToList();

        return new PagedResult<PurchaseOrderSummaryDto>(items, page.Page, page.Size, total);
    }

    public async Task<PagedResult<OpenPurchaseOrderDto>> ListOpenPurchaseOrdersAsync(
        OpenPurchaseOrderFilter filter,
        PageRequest page,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var open = PurchaseOrder.OpenForReceiptStatuses.ToArray();
        var query = db.PurchaseOrders.AsNoTracking().Where(p => open.Contains(p.Status));

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(p => p.SupplierId == supplierId);
        }

        if (filter.DeliveryLocationId is { } locationId)
        {
            query = query.Where(p => p.DeliveryLocationId == locationId);
        }

        // The keeper's receipt queue is the sharpest case of spec §16: it must show the warehouses they hold
        // and nothing else.
        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(p => visible.Contains(p.DeliveryLocationId));
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(p => p.DocNo.Contains(search));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var orders = await query
            .Include(p => p.Lines)
            .OrderBy(p => p.ExpectedDate ?? p.DocDate).ThenBy(p => p.Id)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                productIds: orders.SelectMany(p => p.Lines).Select(l => l.ProductId),
                locationIds: orders.Select(p => p.DeliveryLocationId),
                uomIds: orders.SelectMany(p => p.Lines).Select(l => l.UomId),
                supplierIds: orders.Select(p => p.SupplierId)),
            cancellationToken).ConfigureAwait(false);

        var items = orders
            .Select(p => new OpenPurchaseOrderDto(
                p.Id,
                p.DocNo,
                p.DocDate,
                refs.SupplierRef(p.SupplierId),
                refs.LocationRef(p.DeliveryLocationId),
                p.ExpectedDate,
                p.Status,
                p.Lines
                    .Where(l => l.RemainingQty() > 0m)
                    .OrderBy(l => l.LineNo)
                    .Select(l => new OpenPurchaseOrderLineDto(
                        l.Id, l.LineNo, refs.ProductRef(l.ProductId), l.Qty, l.UomId, refs.UomCode(l.UomId), l.ReceivedQty, l.RemainingQty()))
                    .ToList()))
            .ToList();

        return new PagedResult<OpenPurchaseOrderDto>(items, page.Page, page.Size, total);
    }

    public async Task<PurchaseOrderDetailDto?> GetPurchaseOrderAsync(long purchaseOrderId, CancellationToken cancellationToken)
    {
        var purchaseOrder = await db.PurchaseOrders.AsNoTracking()
            .Include(p => p.Lines)
            .FirstOrDefaultAsync(p => p.Id == purchaseOrderId, cancellationToken)
            .ConfigureAwait(false);
        if (purchaseOrder is null)
        {
            return null;
        }

        var lines = purchaseOrder.Lines.OrderBy(l => l.LineNo).ToList();
        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                productIds: lines.Select(l => l.ProductId),
                locationIds: [purchaseOrder.DeliveryLocationId],
                uomIds: lines.Select(l => l.UomId),
                supplierIds: [purchaseOrder.SupplierId],
                userIds: [purchaseOrder.CreatedBy]),
            cancellationToken).ConfigureAwait(false);

        var approvalId = await db.ApprovalInstances.AsNoTracking()
            .Where(a => a.DocType == ApprovalDocType.Po && a.DocId == purchaseOrder.Id)
            .OrderByDescending(a => a.Id)
            .Select(a => (long?)a.Id)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
        var approval = approvalId is null ? null : await GetApprovalAsync(approvalId.Value, cancellationToken).ConfigureAwait(false);

        return new PurchaseOrderDetailDto(
            purchaseOrder.Id,
            purchaseOrder.DocNo,
            purchaseOrder.DocDate,
            refs.SupplierRef(purchaseOrder.SupplierId),
            purchaseOrder.Currency,
            purchaseOrder.TotalAmount,
            purchaseOrder.TotalAmountBase,
            refs.LocationRef(purchaseOrder.DeliveryLocationId),
            purchaseOrder.ProductType,
            purchaseOrder.ExpectedDate,
            purchaseOrder.Status,
            purchaseOrder.ReceivedPct(),
            refs.UserRef(purchaseOrder.CreatedBy),
            purchaseOrder.RowVersion,
            purchaseOrder.FxRate,
            purchaseOrder.Subtotal,
            purchaseOrder.VatAmount,
            purchaseOrder.Incoterms,
            purchaseOrder.PaymentTerms,
            purchaseOrder.Note,
            purchaseOrder.QuotationId,
            purchaseOrder.SentAt,
            approval,
            purchaseOrder.SplitCheckWarning,
            lines.Select(l => new Application.Dtos.PurchaseOrderLineDto(
                l.Id, l.LineNo, l.RequisitionLineId, refs.ProductRef(l.ProductId), l.Qty, l.UomId, refs.UomCode(l.UomId),
                l.UnitPrice, l.VatRate, l.LineTotal, l.ReceivedQty, l.RemainingQty())).ToList(),
            [],
            [],
            Audit(purchaseOrder));
    }

    public async Task<Wms.Procurement.Contracts.PurchaseOrderDto?> GetPurchaseOrderContractAsync(long purchaseOrderId, CancellationToken cancellationToken)
    {
        var purchaseOrder = await db.PurchaseOrders.AsNoTracking()
            .Include(p => p.Lines)
            .FirstOrDefaultAsync(p => p.Id == purchaseOrderId, cancellationToken)
            .ConfigureAwait(false);
        if (purchaseOrder is null)
        {
            return null;
        }

        return new Wms.Procurement.Contracts.PurchaseOrderDto(
            purchaseOrder.Id,
            purchaseOrder.DocNo,
            purchaseOrder.DocDate,
            purchaseOrder.SupplierId,
            purchaseOrder.Currency,
            purchaseOrder.FxRate,
            Common.Infrastructure.Persistence.UpperSnakeCaseEnum.Format(purchaseOrder.Status),
            purchaseOrder.DeliveryLocationId,
            purchaseOrder.Lines
                .OrderBy(l => l.LineNo)
                .Select(l => new Wms.Procurement.Contracts.PurchaseOrderLineDto(l.Id, l.LineNo, l.ProductId, l.Qty, l.UomId, l.UnitPrice, l.ReceivedQty))
                .ToList());
    }

    private static decimal ReceivedPct(decimal orderedQty, decimal receivedQty) =>
        orderedQty <= 0m ? 0m : Quantity.Round(Math.Min(receivedQty, orderedQty) / orderedQty * 100m, 4);
}
