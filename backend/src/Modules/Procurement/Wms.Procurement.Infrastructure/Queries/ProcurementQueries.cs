using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;
using Wms.Procurement.Infrastructure.Persistence;

namespace Wms.Procurement.Infrastructure.Queries;

/// <summary>
/// Read side of Procurement. Every query is <c>AsNoTracking</c>, pages in the database and decorates the page
/// with one batched master-data lookup per kind (spec §13.4, Əlavə A).
/// </summary>
public sealed partial class ProcurementQueries(
    ProcurementDbContext db,
    IProcurementReferenceDataLoader referenceData,
    IPriceHistoryRepository priceHistoryLookup,
    IApprovalDirectory approvalDirectory,
    ICurrencyRateReader currencyRates,
    IStockBalanceReader stockBalances,
    ITenantContext tenantContext,
    IClock clock) : IProcurementQueries
{
    // ------------------------------------------------------------ Requisitions

    public async Task<PagedResult<RequisitionSummaryDto>> ListRequisitionsAsync(
        RequisitionFilter filter,
        PageRequest page,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Requisitions.AsNoTracking();
        if (filter.Status is { } status)
        {
            query = query.Where(r => r.Status == status);
        }

        if (filter.ProductType is { } productType)
        {
            query = query.Where(r => r.ProductType == productType);
        }

        if (filter.Priority is { } priority)
        {
            query = query.Where(r => r.Priority == priority);
        }

        if (filter.RequesterLocationId is { } locationId)
        {
            query = query.Where(r => r.RequesterLocationId == locationId);
        }

        // Spec §16, fail closed: only an explicitly unrestricted scope lifts the filter. A restricted scope
        // with no granted locations matches nothing, which is the point of LocationScope.
        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(r => visible.Contains(r.RequesterLocationId));
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
            var search = filter.Search.Trim();
            query = query.Where(r => r.DocNo.Contains(search) || (r.Note != null && r.Note.Contains(search)));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(r => r.DocDate).ThenByDescending(r => r.Id)
            .Skip(page.Skip).Take(page.Size)
            .Select(r => new
            {
                r.Id, r.DocNo, r.DocDate, r.RequesterLocationId, r.ProductType, r.Priority,
                r.RequiredDate, r.Status, r.CreatedBy, r.RowVersion,
                LineCount = r.Lines.Count,
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                locationIds: rows.Select(r => r.RequesterLocationId),
                userIds: rows.Select(r => r.CreatedBy)),
            cancellationToken).ConfigureAwait(false);

        var items = rows
            .Select(r => new RequisitionSummaryDto(
                r.Id, r.DocNo, r.DocDate, refs.LocationRef(r.RequesterLocationId), r.ProductType, r.Priority,
                r.RequiredDate, r.Status, r.LineCount, refs.UserRef(r.CreatedBy), r.RowVersion))
            .ToList();

        return new PagedResult<RequisitionSummaryDto>(items, page.Page, page.Size, total);
    }

    public async Task<RequisitionDto?> GetRequisitionAsync(long requisitionId, CancellationToken cancellationToken)
    {
        var requisition = await db.Requisitions.AsNoTracking()
            .Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == requisitionId, cancellationToken)
            .ConfigureAwait(false);
        if (requisition is null)
        {
            return null;
        }

        var lines = requisition.Lines.OrderBy(l => l.LineNo).ToList();
        var lineIds = lines.Select(l => l.Id).ToArray();

        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                productIds: lines.Select(l => l.ProductId),
                locationIds: [requisition.RequesterLocationId],
                uomIds: lines.Select(l => l.UomId),
                userIds: [requisition.CreatedBy]),
            cancellationToken).ConfigureAwait(false);

        var rfqIds = await db.RfqLines.AsNoTracking()
            .Where(l => l.RequisitionLineId != null && lineIds.Contains(l.RequisitionLineId!.Value))
            .Select(l => l.RfqId).Distinct().ToListAsync(cancellationToken).ConfigureAwait(false);

        var purchaseOrderIds = await db.PurchaseOrderLines.AsNoTracking()
            .Where(l => l.RequisitionLineId != null && lineIds.Contains(l.RequisitionLineId!.Value))
            .Select(l => l.PoId).Distinct().ToListAsync(cancellationToken).ConfigureAwait(false);

        var lineDtos = new List<RequisitionLineDto>(lines.Count);
        foreach (var line in lines)
        {
            // Current stock at the requesting location gives the buyer context (contract: currentStockQty).
            var level = await stockBalances.GetAsync(line.ProductId, requisition.RequesterLocationId, cancellationToken).ConfigureAwait(false);
            lineDtos.Add(new RequisitionLineDto(
                line.Id, line.LineNo, refs.ProductRef(line.ProductId), line.Qty, line.UomId,
                refs.UomCode(line.UomId), line.ConvertedQty, level?.QtyOnHand, line.Note));
        }

        return new RequisitionDto(
            requisition.Id,
            requisition.DocNo,
            requisition.DocDate,
            refs.LocationRef(requisition.RequesterLocationId),
            requisition.ProductType,
            requisition.Priority,
            requisition.RequiredDate,
            requisition.Status,
            lines.Count,
            refs.UserRef(requisition.CreatedBy),
            requisition.RowVersion,
            requisition.Note,
            requisition.RejectComment,
            lineDtos,
            rfqIds,
            purchaseOrderIds,
            [],
            Audit(requisition));
    }

    // ------------------------------------------------------------ RFQs

    public async Task<PagedResult<RfqSummaryDto>> ListRfqsAsync(RfqFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Rfqs.AsNoTracking();
        if (filter.Status is { } status)
        {
            query = query.Where(r => r.Status == status);
        }

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(r => r.Suppliers.Any(s => s.SupplierId == supplierId));
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
            var search = filter.Search.Trim();
            query = query.Where(r => r.DocNo.Contains(search) || (r.Note != null && r.Note.Contains(search)));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(r => r.DocDate).ThenByDescending(r => r.Id)
            .Skip(page.Skip).Take(page.Size)
            .Select(r => new
            {
                r.Id, r.DocNo, r.DocDate, r.DueDate, r.Status, r.RowVersion,
                SupplierCount = r.Suppliers.Count,
                QuotationCount = db.Quotations.Count(q => q.RfqId == r.Id),
                SelectedQuotationId = db.Quotations.Where(q => q.RfqId == r.Id && q.IsSelected).Select(q => (long?)q.Id).FirstOrDefault(),
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows
            .Select(r => new RfqSummaryDto(
                r.Id, r.DocNo, r.DocDate, r.DueDate, r.Status, r.SupplierCount, r.QuotationCount, r.SelectedQuotationId, r.RowVersion))
            .ToList();

        return new PagedResult<RfqSummaryDto>(items, page.Page, page.Size, total);
    }

    public async Task<RfqDto?> GetRfqAsync(long rfqId, CancellationToken cancellationToken)
    {
        var rfq = await db.Rfqs.AsNoTracking()
            .Include(r => r.Lines)
            .Include(r => r.Suppliers)
            .FirstOrDefaultAsync(r => r.Id == rfqId, cancellationToken)
            .ConfigureAwait(false);
        if (rfq is null)
        {
            return null;
        }

        var lines = rfq.Lines.OrderBy(l => l.LineNo).ToList();
        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                productIds: lines.Select(l => l.ProductId),
                uomIds: lines.Select(l => l.UomId),
                supplierIds: rfq.Suppliers.Select(s => s.SupplierId),
                userIds: [rfq.CreatedBy]),
            cancellationToken).ConfigureAwait(false);

        var quotationCount = await db.Quotations.AsNoTracking().CountAsync(q => q.RfqId == rfq.Id, cancellationToken).ConfigureAwait(false);
        var selectedQuotationId = await db.Quotations.AsNoTracking()
            .Where(q => q.RfqId == rfq.Id && q.IsSelected)
            .Select(q => (long?)q.Id)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        var prLineIds = lines.Where(l => l.RequisitionLineId is not null).Select(l => l.RequisitionLineId!.Value).ToArray();
        var requisitionIds = prLineIds.Length == 0
            ? []
            : await db.RequisitionLines.AsNoTracking()
                .Where(l => prLineIds.Contains(l.Id))
                .Select(l => l.RequisitionId)
                .Distinct()
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);

        return new RfqDto(
            rfq.Id,
            rfq.DocNo,
            rfq.DocDate,
            rfq.DueDate,
            rfq.Status,
            rfq.Suppliers.Count,
            quotationCount,
            selectedQuotationId,
            rfq.RowVersion,
            rfq.Note,
            lines.Select(l => new RfqLineDto(
                l.Id, l.LineNo, refs.ProductRef(l.ProductId), l.RequisitionLineId, l.Qty, l.UomId, refs.UomCode(l.UomId), l.Note)).ToList(),
            rfq.Suppliers.Select(s => refs.SupplierRef(s.SupplierId)).ToList(),
            requisitionIds,
            Audit(rfq));
    }

    // ------------------------------------------------------------ Quotations

    public async Task<PagedResult<QuotationSummaryDto>> ListQuotationsAsync(QuotationFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Quotations.AsNoTracking();
        if (filter.RfqId is { } rfqId)
        {
            query = query.Where(q => q.RfqId == rfqId);
        }

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(q => q.SupplierId == supplierId);
        }

        if (filter.IsSelected is { } isSelected)
        {
            query = query.Where(q => q.IsSelected == isSelected);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(q => q.QuoteDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(q => q.QuoteDate <= to);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(q => q.QuoteDate).ThenByDescending(q => q.Id)
            .Skip(page.Skip).Take(page.Size)
            .Select(q => new QuotationRow(
                q.Id, q.RfqId, q.SupplierId, q.QuoteNo, q.QuoteDate, q.ValidUntil, q.Currency, q.DeliveryDays,
                q.TotalAmount, q.TotalAmountBase, q.IsSelected, q.SelectionNote, q.RowVersion, q.Lines.Count))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = await ToSummariesAsync(rows, cancellationToken).ConfigureAwait(false);
        return new PagedResult<QuotationSummaryDto>(items, page.Page, page.Size, total);
    }

    public async Task<QuotationDto?> GetQuotationAsync(long quotationId, CancellationToken cancellationToken)
    {
        var quotation = await db.Quotations.AsNoTracking()
            .Include(q => q.Lines)
            .FirstOrDefaultAsync(q => q.Id == quotationId, cancellationToken)
            .ConfigureAwait(false);
        if (quotation is null)
        {
            return null;
        }

        var lines = quotation.Lines.OrderBy(l => l.LineNo).ToList();
        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                productIds: lines.Select(l => l.ProductId),
                uomIds: lines.Select(l => l.UomId),
                supplierIds: [quotation.SupplierId],
                userIds: [quotation.CreatedBy]),
            cancellationToken).ConfigureAwait(false);

        var rfqDocNo = quotation.RfqId is null
            ? null
            : await db.Rfqs.AsNoTracking().Where(r => r.Id == quotation.RfqId).Select(r => r.DocNo).FirstOrDefaultAsync(cancellationToken).ConfigureAwait(false);

        var isCheapest = await IsCheapestAsync(quotation.Id, quotation.RfqId, cancellationToken).ConfigureAwait(false);

        return new QuotationDto(
            quotation.Id,
            quotation.RfqId,
            rfqDocNo,
            refs.SupplierRef(quotation.SupplierId),
            quotation.QuoteNo,
            quotation.QuoteDate,
            quotation.ValidUntil,
            quotation.Currency,
            quotation.DeliveryDays,
            lines.Count == 0 ? null : quotation.TotalAmount,
            lines.Count == 0 ? null : quotation.TotalAmountBase,
            quotation.IsSelected,
            isCheapest,
            quotation.SelectionNote,
            quotation.RowVersion,
            quotation.PaymentTerms,
            quotation.FxRate,
            lines.Select(l => new QuotationLineDto(
                l.Id, l.LineNo, l.RfqLineId, refs.ProductRef(l.ProductId), l.Qty, l.UomId, refs.UomCode(l.UomId),
                l.UnitPrice, l.UnitPriceBase, l.LineTotal, l.Note)).ToList(),
            [],
            Audit(quotation));
    }

    // ------------------------------------------------------------ Shared helpers

    private static AuditDto Audit(Requisition entity) =>
        new(entity.CreatedAt, entity.CreatedBy, entity.UpdatedAt, entity.UpdatedBy, entity.RowVersion);

    private static AuditDto Audit(Rfq entity) =>
        new(entity.CreatedAt, entity.CreatedBy, entity.UpdatedAt, entity.UpdatedBy, entity.RowVersion);

    private static AuditDto Audit(Quotation entity) =>
        new(entity.CreatedAt, entity.CreatedBy, entity.UpdatedAt, entity.UpdatedBy, entity.RowVersion);

    private static AuditDto Audit(PurchaseOrder entity) =>
        new(entity.CreatedAt, entity.CreatedBy, entity.UpdatedAt, entity.UpdatedBy, entity.RowVersion);

    private async Task<bool> IsCheapestAsync(long quotationId, long? rfqId, CancellationToken cancellationToken)
    {
        if (rfqId is null)
        {
            return true;
        }

        var siblings = await db.Quotations.AsNoTracking()
            .Where(q => q.RfqId == rfqId)
            .Select(q => new { q.Id, q.TotalAmountBase, LineCount = q.Lines.Count })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var cheapest = QuotationRanking.CheapestQuotationId(
            siblings.Select(q => new RankedQuotation(q.Id, q.LineCount == 0 ? null : q.TotalAmountBase)));
        return cheapest is null || cheapest == quotationId;
    }

    private async Task<IReadOnlyList<QuotationSummaryDto>> ToSummariesAsync(IReadOnlyList<QuotationRow> rows, CancellationToken cancellationToken)
    {
        if (rows.Count == 0)
        {
            return [];
        }

        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(supplierIds: rows.Select(r => r.SupplierId)),
            cancellationToken).ConfigureAwait(false);

        var rfqIds = rows.Where(r => r.RfqId is not null).Select(r => r.RfqId!.Value).Distinct().ToArray();
        var rfqDocNos = rfqIds.Length == 0
            ? new Dictionary<long, string>()
            : await db.Rfqs.AsNoTracking()
                .Where(r => rfqIds.Contains(r.Id))
                .ToDictionaryAsync(r => r.Id, r => r.DocNo, cancellationToken)
                .ConfigureAwait(false);

        // The cheapest of each RFQ is computed once per page, not once per row.
        var cheapestByRfq = new Dictionary<long, long?>();
        foreach (var rfqId in rfqIds)
        {
            var siblings = await db.Quotations.AsNoTracking()
                .Where(q => q.RfqId == rfqId)
                .Select(q => new { q.Id, q.TotalAmountBase, LineCount = q.Lines.Count })
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);
            cheapestByRfq[rfqId] = QuotationRanking.CheapestQuotationId(
                siblings.Select(q => new RankedQuotation(q.Id, q.LineCount == 0 ? null : q.TotalAmountBase)));
        }

        return rows
            .Select(r => new QuotationSummaryDto(
                r.Id,
                r.RfqId,
                r.RfqId is { } id ? rfqDocNos.GetValueOrDefault(id) : null,
                refs.SupplierRef(r.SupplierId),
                r.QuoteNo,
                r.QuoteDate,
                r.ValidUntil,
                r.Currency,
                r.DeliveryDays,
                r.LineCount == 0 ? null : r.TotalAmount,
                r.LineCount == 0 ? null : r.TotalAmountBase,
                r.IsSelected,
                r.RfqId is not { } rfq || cheapestByRfq.GetValueOrDefault(rfq) is not { } cheapest || cheapest == r.Id,
                r.SelectionNote,
                r.RowVersion))
            .ToList();
    }

    private sealed record QuotationRow(
        long Id,
        long? RfqId,
        uint SupplierId,
        string? QuoteNo,
        DateOnly QuoteDate,
        DateOnly? ValidUntil,
        string Currency,
        ushort? DeliveryDays,
        decimal TotalAmount,
        decimal TotalAmountBase,
        bool IsSelected,
        string? SelectionNote,
        uint RowVersion,
        int LineCount);
}
