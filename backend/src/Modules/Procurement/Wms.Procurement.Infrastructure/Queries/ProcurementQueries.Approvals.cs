using Wms.Common.Application.Paging;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Infrastructure.Queries;

public sealed partial class ProcurementQueries
{
    // ------------------------------------------------------------ Approvals

    public async Task<ApprovalInstanceDto?> GetApprovalAsync(long approvalId, CancellationToken cancellationToken)
    {
        var instance = await db.ApprovalInstances.AsNoTracking()
            .Include(a => a.Steps)
            .FirstOrDefaultAsync(a => a.Id == approvalId, cancellationToken)
            .ConfigureAwait(false);
        if (instance is null)
        {
            return null;
        }

        return new ApprovalInstanceDto(
            instance.Id,
            instance.DocType,
            instance.DocId,
            instance.DocNo,
            instance.AmountBase,
            instance.CurrentStep,
            instance.Status,
            instance.Steps
                .OrderBy(s => s.StepNo)
                .Select(s => new ApprovalStepDto(
                    s.Id,
                    s.StepNo,
                    s.ApproverRoleCode,
                    s.ApproverUserId is { } approver ? UserRefDto.Named(approver, s.ApproverUsername) : null,
                    s.DelegatedFromUserId is { } delegator ? UserRefDto.Named(delegator, s.DelegatedFromUsername) : null,
                    s.Decision,
                    s.DecidedAt,
                    s.Comment))
                .ToList(),
            instance.CreatedAt);
    }

    public async Task<PagedResult<PendingApprovalDto>> ListPendingApprovalsAsync(
        ApprovalDocType? docType,
        IReadOnlyCollection<string> roleCodes,
        uint actingUserId,
        PageRequest page,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(roleCodes);
        ArgumentNullException.ThrowIfNull(page);

        if (roleCodes.Count == 0)
        {
            return PagedResult<PendingApprovalDto>.Empty(page);
        }

        var codes = roleCodes.Select(c => c.ToUpperInvariant()).Distinct().ToArray();

        var query =
            from instance in db.ApprovalInstances.AsNoTracking()
            join step in db.ApprovalSteps.AsNoTracking() on instance.Id equals step.InstanceId
            where instance.Status == ApprovalStatus.Pending
                && step.StepNo == instance.CurrentStep
                && step.Decision == ApprovalDecision.Pending
                && codes.Contains(step.ApproverRoleCode)
                // Separation of duties: the requester never sees their own document in this list.
                && instance.RequestedBy != actingUserId
            select new { instance, step };

        if (docType is { } type)
        {
            query = query.Where(x => x.instance.DocType == type);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderBy(x => x.instance.CreatedAt).ThenBy(x => x.instance.Id)
            .Skip(page.Skip).Take(page.Size)
            .Select(x => new
            {
                ApprovalId = x.instance.Id,
                StepId = x.step.Id,
                x.instance.DocType,
                x.instance.DocId,
                x.instance.DocNo,
                x.step.StepNo,
                x.step.ApproverRoleCode,
                x.instance.AmountBase,
                x.instance.RequestedBy,
                x.instance.RequestedByUsername,
                x.instance.CreatedAt,
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var poIds = rows.Where(r => r.DocType == ApprovalDocType.Po).Select(r => r.DocId).Distinct().ToArray();
        var summaries = poIds.Length == 0
            ? new Dictionary<long, (uint SupplierId, uint LocationId, int LineCount)>()
            : (await db.PurchaseOrders.AsNoTracking()
                .Where(p => poIds.Contains(p.Id))
                .Select(p => new { p.Id, p.SupplierId, p.DeliveryLocationId, LineCount = p.Lines.Count })
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false))
                .ToDictionary(p => p.Id, p => (SupplierId: p.SupplierId, LocationId: p.DeliveryLocationId, LineCount: p.LineCount));

        // Users are not fetched: the requester's name travels on the instance itself (see UserRefDto.Named).
        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                locationIds: summaries.Values.Select(v => v.LocationId),
                supplierIds: summaries.Values.Select(v => v.SupplierId)),
            cancellationToken).ConfigureAwait(false);

        // Which of these came through a delegation is resolved once, from the caller's in-force delegations.
        var delegations = await approvalDirectory
            .GetDelegationsToAsync(actingUserId, DateOnly.FromDateTime(clock.UtcNow.UtcDateTime), cancellationToken)
            .ConfigureAwait(false);

        var items = rows
            .Select(r =>
            {
                var summary = summaries.TryGetValue(r.DocId, out var po)
                    ? $"{refs.SupplierRef(po.SupplierId).Name} · {refs.LocationRef(po.LocationId).Name} · {po.LineCount} sətir"
                    : r.DocNo;

                var via = delegations.FirstOrDefault(d => d.FromUserRoleCodes.Contains(r.ApproverRoleCode, StringComparer.OrdinalIgnoreCase));
                return new PendingApprovalDto(
                    r.ApprovalId, r.StepId, r.DocType, r.DocId, r.DocNo, r.StepNo, r.AmountBase, summary,
                    UserRefDto.Named(r.RequestedBy, r.RequestedByUsername),
                    via is null ? null : UserRefDto.Unknown(via.FromUserId),
                    r.CreatedAt);
            })
            .ToList();

        return new PagedResult<PendingApprovalDto>(items, page.Page, page.Size, total);
    }

    // ------------------------------------------------------------ Approval rules

    public async Task<IReadOnlyList<ApprovalRuleDto>> ListApprovalRulesAsync(ApprovalDocType? docType, bool? isActive, CancellationToken cancellationToken)
    {
        var query = db.ApprovalRules.AsNoTracking();
        if (docType is { } type)
        {
            query = query.Where(r => r.DocType == type);
        }

        if (isActive is { } active)
        {
            query = query.Where(r => r.IsActive == active);
        }

        return await query
            .OrderBy(r => r.DocType).ThenBy(r => r.StepNo).ThenBy(r => r.MinAmountBase)
            .Select(r => new ApprovalRuleDto(
                r.Id, r.DocType, r.ProductType, r.MinAmountBase, r.MaxAmountBase, r.StepNo,
                r.ApproverRoleId, r.ApproverRoleCode, r.IsActive, r.RowVersion))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task<ApprovalRuleDto?> GetApprovalRuleAsync(uint ruleId, CancellationToken cancellationToken) =>
        await db.ApprovalRules.AsNoTracking()
            .Where(r => r.Id == ruleId)
            .Select(r => new ApprovalRuleDto(
                r.Id, r.DocType, r.ProductType, r.MinAmountBase, r.MaxAmountBase, r.StepNo,
                r.ApproverRoleId, r.ApproverRoleCode, r.IsActive, r.RowVersion))
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

    // ------------------------------------------------------------ Price history

    public async Task<PagedResult<PriceHistoryEntryDto>> ListPriceHistoryAsync(
        PriceHistoryFilter filter,
        PageRequest page,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.PriceHistory.AsNoTracking();
        if (filter.ProductId is { } productId)
        {
            query = query.Where(p => p.ProductId == productId);
        }

        if (filter.SupplierId is { } supplierId)
        {
            query = query.Where(p => p.SupplierId == supplierId);
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(p => p.PriceDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(p => p.PriceDate <= to);
        }

        if (filter.MinDiffPct is { } minDiff)
        {
            query = query.Where(p => p.DiffPct != null && (p.DiffPct >= minDiff || p.DiffPct <= -minDiff));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(p => p.PriceDate).ThenByDescending(p => p.Id)
            .Skip(page.Skip).Take(page.Size)
            .Select(p => new
            {
                p.Id, p.ProductId, p.SupplierId, p.PoId, p.PriceDate, p.UnitPrice, p.Currency,
                p.UnitPriceBase, p.PrevPriceBase, p.DiffAmount, p.DiffPct,
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var poIds = rows.Where(r => r.PoId is not null).Select(r => r.PoId!.Value).Distinct().ToArray();
        var poDocNos = poIds.Length == 0
            ? new Dictionary<long, string>()
            : await db.PurchaseOrders.AsNoTracking()
                .Where(p => poIds.Contains(p.Id))
                .ToDictionaryAsync(p => p.Id, p => p.DocNo, cancellationToken)
                .ConfigureAwait(false);

        var refs = await referenceData.LoadAsync(
            ProcurementReferenceRequest.For(
                productIds: rows.Select(r => r.ProductId),
                supplierIds: rows.Select(r => r.SupplierId)),
            cancellationToken).ConfigureAwait(false);

        var items = rows
            .Select(p => new PriceHistoryEntryDto(
                p.Id, refs.ProductRef(p.ProductId), refs.SupplierRef(p.SupplierId), p.PoId,
                p.PoId is { } id ? poDocNos.GetValueOrDefault(id) : null,
                p.PriceDate, p.UnitPrice, p.Currency, p.UnitPriceBase, p.PrevPriceBase, p.DiffAmount, p.DiffPct))
            .ToList();

        return new PagedResult<PriceHistoryEntryDto>(items, page.Page, page.Size, total);
    }
}
