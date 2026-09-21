using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Paging;
using Wms.Common.Application.Security;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Queries;

public sealed class BatchQueries(InventoryDbContext db, IReferenceDataLoader referenceData, IClock clock) : IBatchQueries
{
    public async Task<BatchDto?> GetAsync(long batchId, LocationScope visibleLocations, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(visibleLocations);
        var batch = await db.Batches.AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == batchId, cancellationToken)
            .ConfigureAwait(false);
        if (batch is null)
        {
            return null;
        }

        // A restricted principal may only see a batch that is actually held in one of its locations.
        if (visibleLocations.IsRestricted)
        {
            var visible = visibleLocations.VisibleIds;
            var here = await db.Balances.AsNoTracking()
                .AnyAsync(b => b.BatchId == batchId && b.QtyOnHand != 0m && visible.Contains(b.LocationId), cancellationToken)
                .ConfigureAwait(false);
            if (!here)
            {
                return null;
            }
        }

        var page = await MapAsync([batch], visibleLocations, cancellationToken).ConfigureAwait(false);
        return page[0];
    }

    public async Task<PagedResult<BatchDto>> ListAsync(BatchFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Batches.AsNoTracking().AsQueryable();

        if (filter.ProductId is { } productId)
        {
            query = query.Where(b => b.ProductId == productId);
        }

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(b => b.SupplierId == supplierId);
        }

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!QueryHelpers.TryParseEnum<BatchStatus>(filter.Status, out var status))
            {
                return new PagedResult<BatchDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(b => b.Status == status);
        }

        if (filter.ExpiryBefore is { } expiryBefore)
        {
            query = query.Where(b => b.ExpiryDate != null && b.ExpiryDate < expiryBefore);
        }

        if (!string.IsNullOrWhiteSpace(filter.BatchNo))
        {
            var term = filter.BatchNo.Trim();
            query = query.Where(b => b.BatchNo.Contains(term));
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(b => db.Balances
                .Any(bal => bal.BatchId == b.Id && bal.QtyOnHand != 0m && visible.Contains(bal.LocationId)));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);

        // Default order is FEFO (spec §12.4): earliest expiry first, batches without one last.
        var rows = await query
            .OrderBy(b => b.ExpiryDate == null).ThenBy(b => b.ExpiryDate).ThenBy(b => b.ReceivedAt)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new PagedResult<BatchDto>(
            await MapAsync(rows, filter.VisibleLocations, cancellationToken).ConfigureAwait(false),
            page.Page,
            page.Size,
            total);
    }

    private async Task<List<BatchDto>> MapAsync(
        IReadOnlyList<Batch> batches,
        LocationScope visibleLocations,
        CancellationToken cancellationToken)
    {
        if (batches.Count == 0)
        {
            return [];
        }

        var ids = batches.Select(b => b.Id).ToArray();
        var balanceQuery = db.Balances.AsNoTracking().Where(b => ids.Contains(b.BatchId) && b.QtyOnHand != 0m);

        // The per-location breakdown is location-scoped data: a branch must not learn how much of a batch
        // the central warehouse holds. qtyTotal below is the sum of what is left, i.e. what this principal sees.
        if (visibleLocations.IsRestricted)
        {
            var visible = visibleLocations.VisibleIds;
            balanceQuery = balanceQuery.Where(b => visible.Contains(b.LocationId));
        }

        var balances = await balanceQuery
            .Select(b => new { b.BatchId, b.LocationId, b.QtyOnHand })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: batches.Select(b => b.ProductId),
                locationIds: balances.Select(b => b.LocationId),
                supplierIds: batches.Where(b => b.SupplierId is not null).Select(b => b.SupplierId!.Value)),
            cancellationToken).ConfigureAwait(false);

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        return batches.Select(batch =>
        {
            var rows = balances.Where(b => b.BatchId == batch.Id).ToList();
            return new BatchDto(
                batch.Id,
                refs.ProductRef(batch.ProductId),
                batch.BatchNo,
                batch.ProductionDate,
                batch.ExpiryDate,
                batch.SupplierId,
                batch.SupplierId is { } supplierId ? refs.SupplierName(supplierId) : null,
                batch.ReceivedAt,
                UpperSnakeCaseEnum.Format(batch.Status),
                batch.ExpiryDate is { } expiry ? expiry.DayNumber - today.DayNumber : null,
                rows.Sum(r => r.QtyOnHand),
                rows.Select(r => new BatchLocationQtyDto(refs.LocationRef(r.LocationId), r.QtyOnHand)).ToList(),
                batch.RowVersion);
        }).ToList();
    }
}

public sealed class MovementQueries(InventoryDbContext db, IReferenceDataLoader referenceData) : IMovementQueries
{
    public async Task<PagedResult<MovementDto>> ListAsync(MovementFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = from movement in db.Movements.AsNoTracking()
                    join grp in db.MovementGroups.AsNoTracking() on movement.GroupId equals grp.Id
                    select new { Movement = movement, Group = grp };

        if (filter.ProductId is { } productId)
        {
            query = query.Where(x => x.Movement.ProductId == productId);
        }

        if (filter.LocationId is { } locationId)
        {
            query = query.Where(x => x.Movement.LocationId == locationId);
        }

        if (filter.BatchId is { } batchId)
        {
            query = query.Where(x => x.Movement.BatchId == batchId);
        }

        if (filter.GroupId is { } groupId)
        {
            query = query.Where(x => x.Movement.GroupId == groupId);
        }

        if (!string.IsNullOrWhiteSpace(filter.DocType))
        {
            if (!QueryHelpers.TryParseEnum<DocType>(filter.DocType, out var docType))
            {
                return new PagedResult<MovementDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(x => x.Group.DocType == docType);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(x => x.Group.DocDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(x => x.Group.DocDate <= to);
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(x => visible.Contains(x.Movement.LocationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(x => x.Movement.PostedAt).ThenByDescending(x => x.Movement.Id)
            .Skip(page.Skip).Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await LoadRefsAsync(rows.Select(r => r.Movement).ToList(), cancellationToken).ConfigureAwait(false);
        var items = rows
            .Select(x => Map(x.Movement, x.Group.DocType, x.Group.DocNo, x.Group.DocDate, refs, includeCost))
            .ToList();

        return new PagedResult<MovementDto>(items, page.Page, page.Size, total);
    }

    public async Task<MovementGroupDto?> GetGroupAsync(long groupId, bool includeCost, CancellationToken cancellationToken)
    {
        var group = await db.MovementGroups.AsNoTracking()
            .Include(g => g.Lines)
            .FirstOrDefaultAsync(g => g.Id == groupId, cancellationToken)
            .ConfigureAwait(false);
        if (group is null)
        {
            return null;
        }

        // The back-reference the contract declares. It was only ever computed as a bool and then dropped,
        // so a client could not tell a reversed group from a reversible one without trying the reversal.
        var reversedByGroupId = await db.MovementGroups.AsNoTracking()
            .Where(g => g.ReversesGroupId == groupId)
            .OrderBy(g => g.Id)
            .Select(g => (long?)g.Id)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await LoadRefsAsync(group.Lines, cancellationToken).ConfigureAwait(false);
        var lines = group.Lines
            .OrderBy(l => l.LineNo)
            .Select(l => Map(l, group.DocType, group.DocNo, group.DocDate, refs, includeCost))
            .ToList();

        return new MovementGroupDto(
            group.Id,
            UpperSnakeCaseEnum.Format(group.DocType),
            group.DocNo,
            group.DocDate,
            group.SourceDocType,
            group.SourceDocId,
            group.ReasonCodeId,
            group.Note,
            group.ReversesGroupId,
            reversedByGroupId,
            group.PostedAt,
            group.PostedBy,
            group.SumQtyBase(),
            lines);
    }

    private Task<ReferenceDataSet> LoadRefsAsync(IReadOnlyList<Movement> movements, CancellationToken cancellationToken) =>
        referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: movements.Select(m => m.ProductId),
                locationIds: movements.Select(m => m.LocationId),
                batchIds: movements.Where(m => m.BatchId is not null).Select(m => m.BatchId!.Value),
                uomIds: movements.Select(m => m.BaseUomId)),
            cancellationToken);

    private static MovementDto Map(Movement movement, DocType docType, string docNo, DateOnly docDate, ReferenceDataSet refs, bool includeCost) =>
        new(
            movement.Id,
            movement.GroupId,
            movement.LineNo,
            UpperSnakeCaseEnum.Format(docType),
            docNo,
            docDate,
            refs.ProductRef(movement.ProductId),
            refs.BatchRef(movement.BatchId),
            refs.LocationRef(movement.LocationId),
            movement.QtyBase,
            movement.BaseUomId,
            refs.UomCode(movement.BaseUomId),
            movement.EnteredQty,
            movement.EnteredUomId,
            movement.ConversionRate,
            includeCost ? movement.UnitCost : null,
            includeCost ? movement.Currency : null,
            includeCost ? movement.FxRate : null,
            movement.PostedAt,
            movement.PostedBy);
}
