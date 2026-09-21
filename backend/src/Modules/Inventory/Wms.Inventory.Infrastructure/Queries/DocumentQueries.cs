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

/// <summary>Shared helpers for the document read side: enum parsing and the common line decoration.</summary>
internal static class QueryHelpers
{
    public static bool TryParseEnum<TEnum>(string raw, out TEnum parsed)
        where TEnum : struct, Enum
    {
        foreach (var candidate in Enum.GetValues<TEnum>())
        {
            if (string.Equals(UpperSnakeCaseEnum.Format(candidate), raw, StringComparison.OrdinalIgnoreCase))
            {
                parsed = candidate;
                return true;
            }
        }

        parsed = default;
        return false;
    }

    public static AuditFieldsDto Audit(IAuditable auditable, uint rowVersion) =>
        new(auditable.CreatedAt, auditable.CreatedBy, auditable.UpdatedAt, auditable.UpdatedBy, rowVersion);

    public static decimal? Value(decimal qtyBase, decimal? unitCost, bool includeCost) =>
        includeCost && unitCost is { } cost ? Quantity.Round(qtyBase * cost, Money.StorageDecimals) : null;
}

public sealed class StockRequestQueries(InventoryDbContext db, IReferenceDataLoader referenceData) : IStockRequestQueries
{
    public async Task<StockRequestDto?> GetAsync(long requestId, CancellationToken cancellationToken)
    {
        var request = await db.StockRequests.AsNoTracking()
            .Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == requestId, cancellationToken)
            .ConfigureAwait(false);
        if (request is null)
        {
            return null;
        }

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: request.Lines.Select(l => l.ProductId),
                locationIds: [request.FromLocationId, request.ToLocationId],
                uomIds: request.Lines.Select(l => l.UomId)),
            cancellationToken).ConfigureAwait(false);

        var issueIds = await db.Issues.AsNoTracking()
            .Where(i => i.RequestId == requestId)
            .Select(i => i.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new StockRequestDto(
            request.Id,
            request.DocNo,
            request.DocDate,
            refs.LocationRef(request.FromLocationId),
            refs.LocationRef(request.ToLocationId),
            request.RequiredDate,
            UpperSnakeCaseEnum.Format(request.Status),
            request.Lines.Count,
            request.RowVersion,
            request.Note,
            request.Lines.OrderBy(l => l.LineNo).Select(l => new StockRequestLineDto(
                l.Id, l.LineNo, refs.ProductRef(l.ProductId), l.Qty, l.UomId, refs.UomCode(l.UomId), l.IssuedQty, l.Note)).ToList(),
            issueIds,
            QueryHelpers.Audit(request, request.RowVersion));
    }

    public async Task<PagedResult<StockRequestSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.StockRequests.AsNoTracking().Include(r => r.Lines).AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!QueryHelpers.TryParseEnum<StockRequestStatus>(filter.Status, out var status))
            {
                return new PagedResult<StockRequestSummaryDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(r => r.Status == status);
        }

        if (filter.LocationId is { } toLocation)
        {
            query = query.Where(r => r.ToLocationId == toLocation);
        }

        if (filter.SecondaryLocationId is { } fromLocation)
        {
            query = query.Where(r => r.FromLocationId == fromLocation);
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

        // A branch sees the requests it raised as well as the ones it is the source of (spec §16).
        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(r => visible.Contains(r.ToLocationId) || visible.Contains(r.FromLocationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(r => r.DocDate).ThenByDescending(r => r.Id)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(locationIds: rows.SelectMany(r => new[] { r.FromLocationId, r.ToLocationId })),
            cancellationToken).ConfigureAwait(false);

        var items = rows.Select(r => new StockRequestSummaryDto(
            r.Id, r.DocNo, r.DocDate,
            refs.LocationRef(r.FromLocationId), refs.LocationRef(r.ToLocationId),
            r.RequiredDate, UpperSnakeCaseEnum.Format(r.Status), r.Lines.Count, r.RowVersion)).ToList();

        return new PagedResult<StockRequestSummaryDto>(items, page.Page, page.Size, total);
    }
}

public sealed class IssueQueries(InventoryDbContext db, IReferenceDataLoader referenceData) : IIssueQueries
{
    public async Task<IssueDto?> GetAsync(long issueId, bool includeCost, CancellationToken cancellationToken)
    {
        var issue = await db.Issues.AsNoTracking()
            .Include(i => i.Lines)
            .FirstOrDefaultAsync(i => i.Id == issueId, cancellationToken)
            .ConfigureAwait(false);
        if (issue is null)
        {
            return null;
        }

        var batchIds = issue.Lines
            .SelectMany(l => new[] { l.BatchId, l.SuggestedBatchId })
            .Where(id => id is not null)
            .Select(id => id!.Value);

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: issue.Lines.Select(l => l.ProductId),
                locationIds: [issue.FromLocationId, issue.ToLocationId],
                batchIds: batchIds,
                uomIds: issue.Lines.Select(l => l.UomId)),
            cancellationToken).ConfigureAwait(false);

        var requestDocNo = issue.RequestId is { } requestId
            ? await db.StockRequests.AsNoTracking().Where(r => r.Id == requestId).Select(r => r.DocNo).FirstOrDefaultAsync(cancellationToken).ConfigureAwait(false)
            : null;

        return new IssueDto(
            issue.Id,
            issue.DocNo,
            issue.DocDate,
            UpperSnakeCaseEnum.Format(issue.IssueType),
            refs.LocationRef(issue.FromLocationId),
            refs.LocationRef(issue.ToLocationId),
            issue.RequestId,
            requestDocNo,
            UpperSnakeCaseEnum.Format(issue.Status),
            issue.DispatchedAt,
            issue.ReceivedAt,
            issue.Lines.Count,
            issue.RowVersion,
            issue.DispatchGroupId,
            issue.ReceiptGroupId,
            issue.ReceivedBy,
            issue.Note,
            issue.Lines.OrderBy(l => l.LineNo).Select(l => new IssueLineDto(
                l.Id, l.LineNo, refs.ProductRef(l.ProductId), l.RequestLineId, l.Qty, l.UomId, refs.UomCode(l.UomId),
                l.QtyBase, refs.BatchRef(l.BatchId), refs.BatchRef(l.SuggestedBatchId), l.BatchOverrideReasonCodeId,
                l.ReceivedQty, l.DiscrepancyQty, l.DiscrepancyReasonCodeId, l.DiscrepancyNote,
                includeCost ? l.UnitCost : null)).ToList(),
            QueryHelpers.Audit(issue, issue.RowVersion));
    }

    public async Task<PagedResult<IssueSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Issues.AsNoTracking().Include(i => i.Lines).AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!QueryHelpers.TryParseEnum<IssueStatus>(filter.Status, out var status))
            {
                return new PagedResult<IssueSummaryDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(i => i.Status == status);
        }

        if (!string.IsNullOrWhiteSpace(filter.Kind))
        {
            if (!QueryHelpers.TryParseEnum<IssueType>(filter.Kind, out var issueType))
            {
                return new PagedResult<IssueSummaryDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(i => i.IssueType == issueType);
        }

        if (filter.SecondaryLocationId is { } fromLocation)
        {
            query = query.Where(i => i.FromLocationId == fromLocation);
        }

        if (filter.LocationId is { } toLocation)
        {
            query = query.Where(i => i.ToLocationId == toLocation);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(i => i.DocDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(i => i.DocDate <= to);
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var term = filter.Search.Trim();
            query = query.Where(i => i.DocNo.Contains(term));
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(i => visible.Contains(i.ToLocationId) || visible.Contains(i.FromLocationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(i => i.DocDate).ThenByDescending(i => i.Id)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(locationIds: rows.SelectMany(r => new[] { r.FromLocationId, r.ToLocationId })),
            cancellationToken).ConfigureAwait(false);

        var items = rows.Select(i => new IssueSummaryDto(
            i.Id, i.DocNo, i.DocDate, UpperSnakeCaseEnum.Format(i.IssueType),
            refs.LocationRef(i.FromLocationId), refs.LocationRef(i.ToLocationId),
            i.RequestId, null, UpperSnakeCaseEnum.Format(i.Status),
            i.DispatchedAt, i.ReceivedAt, i.Lines.Count, i.RowVersion)).ToList();

        return new PagedResult<IssueSummaryDto>(items, page.Page, page.Size, total);
    }
}
