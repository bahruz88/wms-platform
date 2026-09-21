using System.Globalization;
using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>One product/batch row of the freeze snapshot (spec §12.7).</summary>
public sealed record CountSnapshotRow(uint ProductId, long BatchId, decimal QtyOnHand, decimal AvgUnitCost);

/// <summary>
/// Inventory count document (<c>inv_count</c>, spec §9.6, §12.7, TOR §21).
///
/// <para>Lifecycle: <c>DRAFT → FROZEN → COUNTING → REVIEW → APPROVED → POSTED</c>, with <c>CANCELLED</c> reachable
/// from anything before POSTED. From FROZEN until POSTED/CANCELLED the location is blocked for
/// RECEIPT/ISSUE/TRANSFER/WASTE/SAMPLE/CONSUMPTION (<c>409 LOCATION_FROZEN</c>).</para>
///
/// <para>The freeze writes <c>book_qty</c> at that instant; every later comparison is against that frozen number,
/// which is exactly what makes the variance report meaningful.</para>
/// </summary>
public sealed class StockCount : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;
    public const int ScopeMaxLength = 2000;

    /// <summary>Statuses during which the location is blocked (spec §12.7).</summary>
    public static readonly CountStatus[] FreezingStatuses =
        [CountStatus.Frozen, CountStatus.Counting, CountStatus.Review, CountStatus.Approved];

    /// <summary>Statuses that count as an already-open document for the same location.</summary>
    public static readonly CountStatus[] OpenStatuses =
        [CountStatus.Draft, CountStatus.Frozen, CountStatus.Counting, CountStatus.Review, CountStatus.Approved];

    private readonly List<StockCountLine> _lines = [];

    private StockCount()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public uint LocationId { get; private set; }

    public CountType CountType { get; private set; }

    public CountStatus Status { get; private set; }

    /// <summary>The instant the location was blocked and <c>book_qty</c> was written.</summary>
    public DateTimeOffset? FrozenAt { get; private set; }

    public uint? ApprovedBy { get; private set; }

    public DateTimeOffset? ApprovedAt { get; private set; }

    /// <summary>The <c>COUNT_ADJUST</c> group created by posting (spec §12.3).</summary>
    public long? AdjustGroupId { get; private set; }

    /// <summary>Set at submit time: at least one line is beyond <c>count_variance_approval_threshold_pct</c>.</summary>
    public bool RequiresApproval { get; private set; }

    public string? Note { get; private set; }

    /// <summary>CYCLE scope, comma-separated category ids (see backend README §8.11 for the deviation note).</summary>
    public string? ScopeCategoryIds { get; private set; }

    /// <summary>CYCLE/SPOT scope, comma-separated product ids.</summary>
    public string? ScopeProductIds { get; private set; }

    public IReadOnlyList<StockCountLine> Lines => _lines.AsReadOnly();

    public bool IsFreezing => FreezingStatuses.Contains(Status);

    public static Result<StockCount> CreateDraft(
        uint tenantId,
        string docNo,
        uint locationId,
        CountType countType,
        IReadOnlyCollection<uint> categoryIds,
        IReadOnlyCollection<uint> productIds,
        string? note)
    {
        ArgumentNullException.ThrowIfNull(categoryIds);
        ArgumentNullException.ThrowIfNull(productIds);

        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return InventoryErrors.InvalidCount($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (locationId == 0)
        {
            return InventoryErrors.InvalidCount("location_id is required.");
        }

        // FULL takes whatever is on the location; the narrower types must say what they cover.
        if (countType == CountType.Spot && productIds.Count == 0)
        {
            return InventoryErrors.CountScopeRequired("SPOT", "productIds");
        }

        if (countType == CountType.Cycle && categoryIds.Count == 0 && productIds.Count == 0)
        {
            return InventoryErrors.CountScopeRequired("CYCLE", "categoryIds or productIds");
        }

        var categoryScope = Join(categoryIds);
        var productScope = Join(productIds);
        if (categoryScope is { Length: > ScopeMaxLength } || productScope is { Length: > ScopeMaxLength })
        {
            return InventoryErrors.InvalidCount($"The count scope exceeds {ScopeMaxLength} characters; split it into several documents.");
        }

        return new StockCount
        {
            TenantId = tenantId,
            DocNo = docNo,
            LocationId = locationId,
            CountType = countType,
            Status = CountStatus.Draft,
            Note = Truncate(note, NoteMaxLength),
            ScopeCategoryIds = categoryScope,
            ScopeProductIds = productScope,
        };
    }

    public IReadOnlyCollection<uint> ScopeCategories() => Split(ScopeCategoryIds);

    public IReadOnlyCollection<uint> ScopeProducts() => Split(ScopeProductIds);

    /// <summary>
    /// <c>DRAFT → FROZEN</c>: blocks the location and writes <c>book_qty</c> for every row of the snapshot
    /// (spec §12.7). The caller has already taken the <c>FOR UPDATE</c> locks on those balance rows.
    /// </summary>
    public Result Freeze(IReadOnlyList<CountSnapshotRow> snapshot, DateTimeOffset frozenAt)
    {
        ArgumentNullException.ThrowIfNull(snapshot);
        if (Status != CountStatus.Draft)
        {
            return InventoryErrors.InvalidCountTransition(Status, CountStatus.Frozen);
        }

        _lines.Clear();
        foreach (var row in snapshot.OrderBy(r => r.ProductId).ThenBy(r => r.BatchId))
        {
            _lines.Add(StockCountLine.Snapshot(TenantId, row.ProductId, row.BatchId, row.QtyOnHand, row.AvgUnitCost));
        }

        Status = CountStatus.Frozen;
        FrozenAt = frozenAt;
        return Result.Success();
    }

    /// <summary>
    /// Upserts one counted line by <c>(productId, batchId)</c> so a mobile client can send shelf by shelf.
    /// A product that was not on the location at freeze time is added with <c>bookQty = 0</c>.
    /// </summary>
    public Result CountLine(uint productId, long? batchId, decimal countedQtyBase, ushort? reasonCodeId, string? note, uint countedBy, DateTimeOffset now)
    {
        if (Status is not (CountStatus.Frozen or CountStatus.Counting))
        {
            return InventoryErrors.InvalidCountTransition(Status, CountStatus.Counting);
        }

        var normalizedBatch = batchId is null or StockCountLine.NoBatch ? null : batchId;
        var line = _lines.FirstOrDefault(l => l.ProductId == productId && l.BatchId == normalizedBatch);
        if (line is null)
        {
            line = StockCountLine.Snapshot(TenantId, productId, normalizedBatch, 0m, 0m);
            _lines.Add(line);
        }

        var counted = line.Count(countedQtyBase, reasonCodeId, note, countedBy, now);
        if (counted.IsFailure)
        {
            return counted.Error;
        }

        Status = CountStatus.Counting;
        return Result.Success();
    }

    /// <summary>
    /// <c>COUNTING → REVIEW</c>. Every line must carry a counted quantity; a line beyond
    /// <paramref name="approvalThresholdPct"/> flags the document for approval (spec §12.6).
    /// </summary>
    public Result Submit(decimal approvalThresholdPct)
    {
        if (Status != CountStatus.Counting)
        {
            return InventoryErrors.InvalidCountTransition(Status, CountStatus.Review);
        }

        var uncounted = _lines.Where(l => !l.IsCounted).Select(l => l.ProductId).Distinct().ToList();
        if (uncounted.Count > 0)
        {
            return InventoryErrors.CountLinesIncomplete(uncounted);
        }

        RequiresApproval = _lines.Any(l => ExceedsThreshold(l, approvalThresholdPct));
        Status = CountStatus.Review;
        return Result.Success();
    }

    public static bool ExceedsThreshold(StockCountLine line, decimal approvalThresholdPct)
    {
        ArgumentNullException.ThrowIfNull(line);
        return line.VariancePct is { } pct && Math.Abs(pct) > approvalThresholdPct;
    }

    /// <summary><c>REVIEW → APPROVED</c>. The caller enforces the segregation-of-duties rule (spec §7.1).</summary>
    public Result Approve(uint approvedBy, DateTimeOffset approvedAt)
    {
        if (Status != CountStatus.Review)
        {
            return InventoryErrors.InvalidCountTransition(Status, CountStatus.Approved);
        }

        Status = CountStatus.Approved;
        ApprovedBy = approvedBy;
        ApprovedAt = approvedAt;
        return Result.Success();
    }

    /// <summary><c>REVIEW → COUNTING</c>: the reviewer sends the sheet back for a recount.</summary>
    public Result Reject()
    {
        if (Status != CountStatus.Review)
        {
            return InventoryErrors.InvalidCountTransition(Status, CountStatus.Counting);
        }

        Status = CountStatus.Counting;
        return Result.Success();
    }

    /// <summary><c>APPROVED → POSTED</c>; the location is released. <paramref name="adjustGroupId"/> is null when no line varied.</summary>
    public Result MarkPosted(long? adjustGroupId)
    {
        if (Status != CountStatus.Approved)
        {
            return InventoryErrors.InvalidCountTransition(Status, CountStatus.Posted);
        }

        Status = CountStatus.Posted;
        AdjustGroupId = adjustGroupId;
        return Result.Success();
    }

    /// <summary>Anything before POSTED can be cancelled; the freeze is lifted and nothing is written to the ledger.</summary>
    public Result Cancel(string? note)
    {
        if (Status is CountStatus.Posted or CountStatus.Cancelled)
        {
            return InventoryErrors.InvalidCountTransition(Status, CountStatus.Cancelled);
        }

        Status = CountStatus.Cancelled;
        Note = Truncate(note ?? Note, NoteMaxLength);
        return Result.Success();
    }

    private static string? Truncate(string? value, int maxLength) =>
        value is { Length: > 0 } && value.Length > maxLength ? value[..maxLength] : value;

    private static string? Join(IReadOnlyCollection<uint> ids) => ids.Count == 0
        ? null
        : string.Join(',', ids.Distinct().OrderBy(id => id).Select(id => id.ToString(CultureInfo.InvariantCulture)));

    private static IReadOnlyCollection<uint> Split(string? csv)
    {
        if (string.IsNullOrWhiteSpace(csv))
        {
            return [];
        }

        var ids = new List<uint>();
        foreach (var part in csv.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            if (uint.TryParse(part, NumberStyles.None, CultureInfo.InvariantCulture, out var id))
            {
                ids.Add(id);
            }
        }

        return ids;
    }
}
