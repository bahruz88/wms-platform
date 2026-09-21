using Wms.Common.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Domain.Entities;

/// <summary>
/// <c>cons_run</c> — the theoretical consumption document of one branch-day. One per
/// (location, business_date) (invariant 2); a posted run is never edited, only reversed (ADR-003).
/// </summary>
public sealed class ConsumptionRun : AggregateRoot<long>, ITenantEntity, IVersioned
{
    public const int DocNoMaxLength = 32;
    public const int FailureReasonMaxLength = 500;

    private readonly List<ConsumptionRunLine> _lines = [];

    private ConsumptionRun()
    {
    }

    public uint TenantId { get; private set; }

    /// <summary><c>CN-{YYYY}-{00000}</c> from <c>master_number_sequence</c>.</summary>
    public string DocNo { get; private set; } = string.Empty;

    public uint LocationId { get; private set; }

    public DateOnly BusinessDate { get; private set; }

    public long ImportId { get; private set; }

    public ConsumptionRunStatus Status { get; private set; } = ConsumptionRunStatus.Draft;

    public long? MovementGroupId { get; private set; }

    public ushort ShortfallCount { get; private set; }

    /// <summary>Sales lines whose menu item is unknown or has no recipe on the business date (invariant 5).</summary>
    public ushort UnmappedCount { get; private set; }

    public string? FailureReason { get; private set; }

    public DateTimeOffset? CalculatedAt { get; private set; }

    public DateTimeOffset? PostedAt { get; private set; }

    public uint? PostedBy { get; private set; }

    public uint RowVersion { get; private set; } = 1;

    public IReadOnlyList<ConsumptionRunLine> Lines => _lines.AsReadOnly();

    public void BumpVersion() => RowVersion++;

    public static Result<ConsumptionRun> CreateDraft(uint tenantId, string docNo, uint locationId, DateOnly businessDate, long importId)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return ConsumptionErrors.InvalidRecipeLine($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (locationId == 0 || importId == 0)
        {
            return ConsumptionErrors.InvalidRecipeLine("location_id and import_id are required.");
        }

        return new ConsumptionRun
        {
            TenantId = tenantId,
            DocNo = docNo,
            LocationId = locationId,
            BusinessDate = businessDate,
            ImportId = importId,
            Status = ConsumptionRunStatus.Draft,
        };
    }

    /// <summary>DRAFT/CALCULATED -&gt; CALCULATED. A POSTED run is never recalculated.</summary>
    public Result ApplyCalculation(IEnumerable<ConsumptionRunLine> lines, ushort unmappedCount, DateTimeOffset calculatedAt)
    {
        ArgumentNullException.ThrowIfNull(lines);
        // REVERSED is allowed back in: uq_run_day keeps one row per branch-day, so a reversed day is redone on
        // the same document (its storno stays in the ledger through inv_movement_group.reverses_group_id).
        if (Status is not (ConsumptionRunStatus.Draft or ConsumptionRunStatus.Calculated or ConsumptionRunStatus.Failed or ConsumptionRunStatus.Reversed))
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(ConsumptionRun), Id, Status, ConsumptionRunStatus.Calculated);
        }

        _lines.Clear();
        _lines.AddRange(lines);
        UnmappedCount = unmappedCount;
        ShortfallCount = (ushort)_lines.Count(l => l.ShortfallQtyBase > 0m);
        Status = ConsumptionRunStatus.Calculated;
        MovementGroupId = null;
        PostedAt = null;
        PostedBy = null;
        FailureReason = null;
        CalculatedAt = calculatedAt;
        return Result.Success();
    }

    public Result MarkFailed(string reason)
    {
        if (Status == ConsumptionRunStatus.Posted)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(ConsumptionRun), Id, Status, ConsumptionRunStatus.Failed);
        }

        Status = ConsumptionRunStatus.Failed;
        FailureReason = reason is { Length: > FailureReasonMaxLength } ? reason[..FailureReasonMaxLength] : reason;
        return Result.Success();
    }

    /// <summary>CALCULATED -&gt; POSTED with the ledger group Inventory created (null when the whole day was a shortfall).</summary>
    public Result MarkPosted(long? movementGroupId, DateTimeOffset postedAt, uint postedBy)
    {
        if (Status != ConsumptionRunStatus.Calculated)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(ConsumptionRun), Id, Status, ConsumptionRunStatus.Posted);
        }

        Status = ConsumptionRunStatus.Posted;
        MovementGroupId = movementGroupId;
        PostedAt = postedAt;
        PostedBy = postedBy;
        ShortfallCount = (ushort)_lines.Count(l => l.ShortfallQtyBase > 0m);
        return Result.Success();
    }

    public Result MarkReversed()
    {
        if (Status != ConsumptionRunStatus.Posted)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(ConsumptionRun), Id, Status, ConsumptionRunStatus.Reversed);
        }

        Status = ConsumptionRunStatus.Reversed;
        return Result.Success();
    }

    public decimal TotalPostedQtyBase() => _lines.Sum(l => l.PostedQtyBase);

    public decimal TotalShortfallQtyBase() => _lines.Sum(l => l.ShortfallQtyBase);
}
