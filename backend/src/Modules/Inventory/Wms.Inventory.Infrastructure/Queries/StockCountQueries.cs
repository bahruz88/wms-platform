using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Persistence;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Queries;

public sealed class StockCountQueries(
    InventoryDbContext db,
    IReferenceDataLoader referenceData,
    IInventorySettings settings) : IStockCountQueries
{
    public async Task<CountDto?> GetAsync(long countId, bool includeCost, CancellationToken cancellationToken)
    {
        var count = await db.Counts.AsNoTracking()
            .Include(c => c.Lines)
            .FirstOrDefaultAsync(c => c.Id == countId, cancellationToken)
            .ConfigureAwait(false);
        if (count is null)
        {
            return null;
        }

        var threshold = await settings
            .GetDecimalAsync(InventorySettingKeys.CountVarianceApprovalThresholdPct, cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ReferenceDataRequest.For(
                productIds: count.Lines.Select(l => l.ProductId),
                locationIds: [count.LocationId],
                batchIds: count.Lines.Where(l => l.BatchId is not null).Select(l => l.BatchId!.Value)),
            cancellationToken).ConfigureAwait(false);

        var lines = count.Lines
            .OrderBy(l => l.ProductId).ThenBy(l => l.BatchId)
            .Select(l => new CountLineDto(
                l.Id,
                refs.ProductRef(l.ProductId),
                refs.BatchRef(l.BatchId),
                l.BookQty,
                refs.Product(l.ProductId)?.BaseUomCode ?? string.Empty,
                l.CountedQty,
                l.VarianceQty,
                l.VariancePct,
                includeCost && l.VarianceQty is { } variance ? Quantity.Round(variance * l.AvgUnitCost, Money.StorageDecimals) : null,
                StockCount.ExceedsThreshold(l, threshold),
                l.ReasonCodeId,
                l.Note,
                l.CountedBy,
                l.CountedAt))
            .ToList();

        return new CountDto(
            count.Id,
            count.DocNo,
            refs.LocationRef(count.LocationId),
            UpperSnakeCaseEnum.Format(count.CountType),
            UpperSnakeCaseEnum.Format(count.Status),
            count.FrozenAt,
            count.RequiresApproval,
            count.Lines.Count,
            count.Lines.Count(l => l.IsCounted),
            count.Lines.Count(l => l.HasVariance),
            count.RowVersion,
            count.ApprovedBy,
            count.ApprovedAt,
            count.AdjustGroupId,
            includeCost ? lines.Sum(l => l.VarianceValue ?? 0m) : null,
            count.Note,
            lines,
            new AuditFieldsDto(count.CreatedAt, count.CreatedBy, count.UpdatedAt, count.UpdatedBy, count.RowVersion));
    }

    public async Task<PagedResult<CountSummaryDto>> ListAsync(CountFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Counts.AsNoTracking().Include(c => c.Lines).AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            if (!TryParse<CountStatus>(filter.Status, out var status))
            {
                return new PagedResult<CountSummaryDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(c => c.Status == status);
        }

        if (!string.IsNullOrWhiteSpace(filter.CountType))
        {
            if (!TryParse<CountType>(filter.CountType, out var countType))
            {
                return new PagedResult<CountSummaryDto>([], page.Page, page.Size, 0);
            }

            query = query.Where(c => c.CountType == countType);
        }

        if (filter.LocationId is { } locationId)
        {
            query = query.Where(c => c.LocationId == locationId);
        }

        if (filter.DateFrom is { } from)
        {
            var fromAt = new DateTimeOffset(from.ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
            query = query.Where(c => c.CreatedAt >= fromAt);
        }

        if (filter.DateTo is { } to)
        {
            var toAt = new DateTimeOffset(to.AddDays(1).ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
            query = query.Where(c => c.CreatedAt < toAt);
        }

        if (filter.VisibleLocationIds.Count > 0)
        {
            var visible = filter.VisibleLocationIds.ToArray();
            query = query.Where(c => visible.Contains(c.LocationId));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(c => c.Id)
            .Skip(page.Skip)
            .Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var refs = await referenceData
            .LoadAsync(ReferenceDataRequest.For(locationIds: rows.Select(r => r.LocationId)), cancellationToken)
            .ConfigureAwait(false);

        var items = rows.Select(c => new CountSummaryDto(
            c.Id,
            c.DocNo,
            refs.LocationRef(c.LocationId),
            UpperSnakeCaseEnum.Format(c.CountType),
            UpperSnakeCaseEnum.Format(c.Status),
            c.FrozenAt,
            c.RequiresApproval,
            c.Lines.Count,
            c.Lines.Count(l => l.IsCounted),
            c.Lines.Count(l => l.HasVariance),
            c.RowVersion)).ToList();

        return new PagedResult<CountSummaryDto>(items, page.Page, page.Size, total);
    }

    private static bool TryParse<TEnum>(string raw, out TEnum parsed)
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
}
