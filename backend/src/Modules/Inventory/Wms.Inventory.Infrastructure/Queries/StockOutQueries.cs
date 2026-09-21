using Wms.Common.Application.Dtos;
using Wms.Common.Application.Paging;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Infrastructure.Queries;

using WasteDocument = Wms.Inventory.Domain.Entities.Waste;

public sealed class WasteQueries(
    InventoryDbContext db,
    IReferenceDataLoader referenceData,
    IReasonCodeCatalog reasonCodes) : IWasteQueries
{
    public async Task<WasteDto?> GetAsync(long wasteId, bool includeCost, CancellationToken cancellationToken)
    {
        var waste = await db.Wastes.AsNoTracking()
            .Include(w => w.Lines)
            .FirstOrDefaultAsync(w => w.Id == wasteId, cancellationToken)
            .ConfigureAwait(false);
        if (waste is null)
        {
            return null;
        }

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: waste.Lines.Select(l => l.ProductId),
                locationIds: [waste.LocationId],
                batchIds: waste.Lines.Where(l => l.BatchId is not null).Select(l => l.BatchId!.Value),
                uomIds: waste.Lines.Select(l => l.UomId)),
            cancellationToken).ConfigureAwait(false);

        var reason = await reasonCodes.GetAsync(waste.ReasonCodeId, cancellationToken).ConfigureAwait(false);

        var lines = waste.Lines.OrderBy(l => l.LineNo).Select(l => new StockOutLineDto(
            l.Id, l.LineNo, refs.ProductRef(l.ProductId), refs.BatchRef(l.BatchId), l.Qty, l.UomId,
            refs.UomCode(l.UomId), l.QtyBase, includeCost ? l.UnitCost : null,
            QueryHelpers.Value(l.QtyBase, l.UnitCost, includeCost), l.Note)).ToList();

        return new WasteDto(
            waste.Id, waste.DocNo, waste.DocDate, refs.LocationRef(waste.LocationId),
            waste.ReasonCodeId, reason?.Name ?? string.Empty, UpperSnakeCaseEnum.Format(waste.Status),
            includeCost ? lines.Sum(l => l.TotalValue ?? 0m) : null,
            waste.Lines.Count, waste.RowVersion,
            waste.ApprovedBy, waste.ApprovedAt, waste.ApprovalComment, waste.MovementGroupId, waste.Note,
            lines, [], QueryHelpers.Audit(waste, waste.RowVersion));
    }

    public async Task<PagedResult<WasteSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Wastes.AsNoTracking().Include(w => w.Lines).AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!QueryHelpers.TryParseEnum<WasteStatus>(filter.Status, out var status))
            {
                return new PagedResult<WasteSummaryDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(w => w.Status == status);
        }

        query = Apply(query, filter);

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(w => w.DocDate).ThenByDescending(w => w.Id)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData
            .LoadAsync(ReferenceDataRequest.For(locationIds: rows.Select(r => r.LocationId)), cancellationToken)
            .ConfigureAwait(false);
        var reasons = await reasonCodes
            .GetManyAsync(rows.Select(r => r.ReasonCodeId).Distinct().ToArray(), cancellationToken)
            .ConfigureAwait(false);

        var items = rows.Select(w => new WasteSummaryDto(
            w.Id, w.DocNo, w.DocDate, refs.LocationRef(w.LocationId), w.ReasonCodeId,
            reasons.FirstOrDefault(r => r.Id == w.ReasonCodeId)?.Name ?? string.Empty,
            UpperSnakeCaseEnum.Format(w.Status),
            includeCost ? w.Lines.Sum(l => QueryHelpers.Value(l.QtyBase, l.UnitCost, true) ?? 0m) : null,
            w.Lines.Count, w.RowVersion)).ToList();

        return new PagedResult<WasteSummaryDto>(items, page.Page, page.Size, total);
    }

    private static IQueryable<WasteDocument> Apply(IQueryable<WasteDocument> query, DocumentFilter filter)
    {
        if (filter.LocationId is { } locationId)
        {
            query = query.Where(w => w.LocationId == locationId);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(w => w.DocDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(w => w.DocDate <= to);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var term = filter.Search.Trim();
            query = query.Where(w => w.DocNo.Contains(term));
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(w => visible.Contains(w.LocationId));
        }

        return query;
    }
}

public sealed class SampleQueries(InventoryDbContext db, IReferenceDataLoader referenceData) : ISampleQueries
{
    public async Task<SampleDto?> GetAsync(long sampleId, bool includeCost, CancellationToken cancellationToken)
    {
        var sample = await db.Samples.AsNoTracking()
            .Include(s => s.Lines)
            .FirstOrDefaultAsync(s => s.Id == sampleId, cancellationToken)
            .ConfigureAwait(false);
        if (sample is null)
        {
            return null;
        }

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: sample.Lines.Select(l => l.ProductId),
                locationIds: [sample.LocationId],
                batchIds: sample.Lines.Where(l => l.BatchId is not null).Select(l => l.BatchId!.Value),
                uomIds: sample.Lines.Select(l => l.UomId)),
            cancellationToken).ConfigureAwait(false);

        var lines = sample.Lines.OrderBy(l => l.LineNo).Select(l => new StockOutLineDto(
            l.Id, l.LineNo, refs.ProductRef(l.ProductId), refs.BatchRef(l.BatchId), l.Qty, l.UomId,
            refs.UomCode(l.UomId), l.QtyBase, includeCost ? l.UnitCost : null,
            QueryHelpers.Value(l.QtyBase, l.UnitCost, includeCost), l.Note)).ToList();

        return new SampleDto(
            sample.Id, sample.DocNo, sample.DocDate, refs.LocationRef(sample.LocationId),
            sample.Authority, sample.Purpose, UpperSnakeCaseEnum.Format(sample.Status),
            sample.Lines.Count, sample.RowVersion, sample.ReasonCodeId, sample.MovementGroupId,
            lines, [], QueryHelpers.Audit(sample, sample.RowVersion));
    }

    public async Task<PagedResult<SampleSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Samples.AsNoTracking().Include(s => s.Lines).AsQueryable();

        if (filter.LocationId is { } locationId)
        {
            query = query.Where(s => s.LocationId == locationId);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(s => s.DocDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(s => s.DocDate <= to);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var term = filter.Search.Trim();
            query = query.Where(s => s.DocNo.Contains(term) || s.Authority.Contains(term));
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(s => visible.Contains(s.LocationId));
        }

        // SimpleDocStatus is derived from movement_group_id, so the status filter runs on that column.
        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!QueryHelpers.TryParseEnum<SimpleDocStatus>(filter.Status, out var status))
            {
                return new PagedResult<SampleSummaryDto>([], page.Page, page.Size, 0);
            }

            query = status == SimpleDocStatus.Posted
                ? query.Where(s => s.MovementGroupId != null)
                : query.Where(s => s.MovementGroupId == null);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(s => s.DocDate).ThenByDescending(s => s.Id)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData
            .LoadAsync(ReferenceDataRequest.For(locationIds: rows.Select(r => r.LocationId)), cancellationToken)
            .ConfigureAwait(false);

        var items = rows.Select(s => new SampleSummaryDto(
            s.Id, s.DocNo, s.DocDate, refs.LocationRef(s.LocationId), s.Authority, s.Purpose,
            UpperSnakeCaseEnum.Format(s.Status), s.Lines.Count, s.RowVersion)).ToList();

        return new PagedResult<SampleSummaryDto>(items, page.Page, page.Size, total);
    }
}

public sealed class ReturnToVendorQueries(
    InventoryDbContext db,
    IReferenceDataLoader referenceData,
    ICurrencyRateReader currencyRates) : IReturnToVendorQueries
{
    public async Task<ReturnToVendorDto?> GetAsync(long returnId, bool includeCost, CancellationToken cancellationToken)
    {
        var document = await db.ReturnsToVendor.AsNoTracking()
            .Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == returnId, cancellationToken)
            .ConfigureAwait(false);
        if (document is null)
        {
            return null;
        }

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: document.Lines.Select(l => l.ProductId),
                locationIds: [document.LocationId],
                batchIds: document.Lines.Where(l => l.BatchId is not null).Select(l => l.BatchId!.Value),
                uomIds: document.Lines.Select(l => l.UomId),
                supplierIds: [document.SupplierId]),
            cancellationToken).ConfigureAwait(false);

        var receiptDocNo = document.ReceiptId is { } receiptId
            ? await db.GoodsReceipts.AsNoTracking().Where(g => g.Id == receiptId).Select(g => g.DocNo).FirstOrDefaultAsync(cancellationToken).ConfigureAwait(false)
            : null;

        var lines = document.Lines.OrderBy(l => l.LineNo).Select(l => new StockOutLineDto(
            l.Id, l.LineNo, refs.ProductRef(l.ProductId), refs.BatchRef(l.BatchId), l.Qty, l.UomId,
            refs.UomCode(l.UomId), l.QtyBase, includeCost ? l.UnitCost : null,
            QueryHelpers.Value(l.QtyBase, l.UnitCost, includeCost), l.Note)).ToList();

        // claimAmount is declared as Money in inventory.v1.yaml; inv_return_to_vendor stores only the amount,
        // so the currency is the tenant's base currency (spec §12.5).
        var currency = await currencyRates.GetBaseCurrencyAsync(cancellationToken).ConfigureAwait(false);

        return new ReturnToVendorDto(
            document.Id, document.DocNo, document.DocDate, document.SupplierId, refs.SupplierName(document.SupplierId),
            refs.LocationRef(document.LocationId), document.ReceiptId, receiptDocNo, document.ReasonCodeId,
            MoneyDto.From(includeCost ? document.ClaimAmount : null, currency), UpperSnakeCaseEnum.Format(document.Status), document.RowVersion,
            document.MovementGroupId, document.Outcome, document.OutcomeNote, document.Note,
            lines, [], QueryHelpers.Audit(document, document.RowVersion));
    }

    public async Task<PagedResult<ReturnToVendorSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.ReturnsToVendor.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!QueryHelpers.TryParseEnum<RtvStatus>(filter.Status, out var status))
            {
                return new PagedResult<ReturnToVendorSummaryDto>([], page.Page, page.Size, 0);
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

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(r => visible.Contains(r.LocationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(r => r.DocDate).ThenByDescending(r => r.Id)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                locationIds: rows.Select(r => r.LocationId),
                supplierIds: rows.Select(r => r.SupplierId)),
            cancellationToken).ConfigureAwait(false);

        var currency = await currencyRates.GetBaseCurrencyAsync(cancellationToken).ConfigureAwait(false);
        var items = rows.Select(r => new ReturnToVendorSummaryDto(
            r.Id, r.DocNo, r.DocDate, r.SupplierId, refs.SupplierName(r.SupplierId),
            refs.LocationRef(r.LocationId), r.ReceiptId, null, r.ReasonCodeId,
            MoneyDto.From(includeCost ? r.ClaimAmount : null, currency), UpperSnakeCaseEnum.Format(r.Status), r.RowVersion)).ToList();

        return new PagedResult<ReturnToVendorSummaryDto>(items, page.Page, page.Size, total);
    }
}
