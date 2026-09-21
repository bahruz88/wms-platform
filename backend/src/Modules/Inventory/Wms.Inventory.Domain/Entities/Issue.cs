using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// Issue / transfer document (<c>inv_issue</c>, spec §9.6). It posts in <b>two</b> steps so goods in a van are
/// never invisible (spec §12.3):
/// <list type="number">
/// <item><c>dispatch</c> — source <c>−qty</c> / <c>IN_TRANSIT</c> <c>+qty</c>, status DISPATCHED;</item>
/// <item><c>confirm-receipt</c> — <c>IN_TRANSIT</c> <c>−received</c> / target <c>+received</c>, status RECEIVED,
/// or DISCREPANCY when the branch counted something different.</item>
/// </list>
/// A discrepancy leaves the difference sitting in IN_TRANSIT on purpose: it is a real, visible loss that someone
/// has to clear with an adjustment, not a number that quietly disappears.
/// </summary>
public sealed class Issue : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;

    private readonly List<IssueLine> _lines = [];

    private Issue()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public IssueType IssueType { get; private set; }

    public uint FromLocationId { get; private set; }

    public uint ToLocationId { get; private set; }

    public long? RequestId { get; private set; }

    public IssueStatus Status { get; private set; }

    /// <summary>Source → IN_TRANSIT.</summary>
    public long? DispatchGroupId { get; private set; }

    /// <summary>IN_TRANSIT → target.</summary>
    public long? ReceiptGroupId { get; private set; }

    public DateTimeOffset? DispatchedAt { get; private set; }

    public DateTimeOffset? ReceivedAt { get; private set; }

    public uint? ReceivedBy { get; private set; }

    public string? Note { get; private set; }

    public IReadOnlyList<IssueLine> Lines => _lines.AsReadOnly();

    public bool HasDiscrepancy => _lines.Any(l => l.DiscrepancyQty is { } d && d != 0m);

    public static Result<Issue> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        IssueType issueType,
        uint fromLocationId,
        uint toLocationId,
        long? requestId,
        string? note)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return InventoryErrors.InvalidDocument($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (fromLocationId == 0 || toLocationId == 0)
        {
            return InventoryErrors.InvalidDocument("from_location_id and to_location_id are required.");
        }

        if (fromLocationId == toLocationId)
        {
            return InventoryErrors.SameLocation();
        }

        return new Issue
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            IssueType = issueType,
            FromLocationId = fromLocationId,
            ToLocationId = toLocationId,
            RequestId = requestId,
            Status = IssueStatus.Draft,
            Note = Text.Truncate(note, NoteMaxLength),
        };
    }

    public Result ReplaceLines(IReadOnlyList<IssueLineInput> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != IssueStatus.Draft)
        {
            return InventoryErrors.DocumentNotDraft("issue", Id, Status.ToString());
        }

        if (lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("An issue needs at least one line.");
        }

        _lines.Clear();
        var lineNo = (ushort)0;
        foreach (var input in lines)
        {
            lineNo++;
            var line = IssueLine.Create(TenantId, lineNo, input);
            if (line.IsFailure)
            {
                return line.Error;
            }

            _lines.Add(line.Value);
        }

        return Result.Success();
    }

    /// <summary>
    /// Records what the ledger took for each line. A line whose operator picked a batch other than the FEFO/FIFO
    /// suggestion must carry a reason code (spec §12.4) — the aggregate is where that rule lives, so no caller can
    /// write an unexplained override.
    /// </summary>
    public Result RecordDispatch(IReadOnlyList<PostedLineResult> results)
    {
        ArgumentNullException.ThrowIfNull(results);

        foreach (var result in results)
        {
            var line = _lines.FirstOrDefault(l => l.Id == result.LineId);
            if (line is null)
            {
                continue;
            }

            if (line.BatchId is { } chosen
                && result.SuggestedBatchId is { } suggestion
                && chosen != suggestion
                && line.BatchOverrideReasonCodeId is null or 0)
            {
                return InventoryErrors.BatchOverrideReasonRequired(line.LineNo);
            }

            line.ApplyDispatch(result.QtyBase, result.BatchId, result.SuggestedBatchId, result.UnitCost);
        }

        return Result.Success();
    }

    /// <summary><c>DRAFT → DISPATCHED</c>. The caller has already written the source → IN_TRANSIT group.</summary>
    public Result MarkDispatched(long dispatchGroupId, DateTimeOffset dispatchedAt)
    {
        if (Status != IssueStatus.Draft)
        {
            return InventoryErrors.InvalidDocumentTransition("issue", Status.ToString(), nameof(IssueStatus.Dispatched));
        }

        if (_lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("An issue needs at least one line.");
        }

        Status = IssueStatus.Dispatched;
        DispatchGroupId = dispatchGroupId;
        DispatchedAt = dispatchedAt;
        return Result.Success();
    }

    /// <summary>
    /// <c>DISPATCHED → RECEIVED</c> (or DISCREPANCY). Every line must be confirmed; a line where the branch counted
    /// something other than what was sent needs a reason code and a note.
    /// </summary>
    public Result ConfirmReceipt(
        IReadOnlyList<IssueReceiptInput> confirmations,
        uint receivedBy,
        DateTimeOffset receivedAt)
    {
        ArgumentNullException.ThrowIfNull(confirmations);
        if (Status != IssueStatus.Dispatched)
        {
            return InventoryErrors.InvalidDocumentTransition("issue", Status.ToString(), nameof(IssueStatus.Received));
        }

        foreach (var confirmation in confirmations)
        {
            var line = _lines.FirstOrDefault(l => l.Id == confirmation.LineId);
            if (line is null)
            {
                return InventoryErrors.IssueLineNotFound(confirmation.LineId);
            }

            var confirmed = line.Confirm(confirmation.ReceivedQty, confirmation.ReasonCodeId, confirmation.Note);
            if (confirmed.IsFailure)
            {
                return confirmed.Error;
            }
        }

        var missing = _lines.Where(l => l.ReceivedQty is null).Select(l => l.LineNo).ToList();
        if (missing.Count > 0)
        {
            return InventoryErrors.IssueLinesUnconfirmed(missing);
        }

        Status = HasDiscrepancy ? IssueStatus.Discrepancy : IssueStatus.Received;
        ReceivedBy = receivedBy;
        ReceivedAt = receivedAt;
        return Result.Success();
    }

    public void AttachReceiptGroup(long receiptGroupId) => ReceiptGroupId = receiptGroupId;

    public Result Cancel()
    {
        if (Status != IssueStatus.Draft)
        {
            return InventoryErrors.InvalidDocumentTransition("issue", Status.ToString(), nameof(IssueStatus.Cancelled));
        }

        Status = IssueStatus.Cancelled;
        return Result.Success();
    }
}

/// <summary>Input of one issue line as the client sends it.</summary>
public sealed record IssueLineInput(
    uint ProductId,
    decimal Qty,
    ushort UomId,
    long? RequestLineId = null,
    long? BatchId = null,
    ushort? BatchOverrideReasonCodeId = null,
    string? BatchOverrideNote = null);

/// <summary>What the receiving location says it actually got.</summary>
public sealed record IssueReceiptInput(long LineId, decimal ReceivedQty, ushort? ReasonCodeId, string? Note);

public sealed class IssueLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private IssueLine()
    {
    }

    public uint TenantId { get; private set; }

    public long IssueId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public long? RequestLineId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    /// <summary>Filled at dispatch time once the conversion factor is known.</summary>
    public decimal QtyBase { get; private set; }

    /// <summary>The batch actually taken (set at dispatch by the FEFO/FIFO allocation or by the operator).</summary>
    public long? BatchId { get; private set; }

    /// <summary>What FEFO/FIFO would have picked — kept so the override is auditable (spec §12.4).</summary>
    public long? SuggestedBatchId { get; private set; }

    public ushort? BatchOverrideReasonCodeId { get; private set; }

    public string? BatchOverrideNote { get; private set; }

    public decimal? ReceivedQty { get; private set; }

    public decimal? DiscrepancyQty { get; private set; }

    public ushort? DiscrepancyReasonCodeId { get; private set; }

    public string? DiscrepancyNote { get; private set; }

    public decimal? UnitCost { get; private set; }

    internal static Result<IssueLine> Create(uint tenantId, ushort lineNo, IssueLineInput input)
    {
        ArgumentNullException.ThrowIfNull(input);
        if (input.ProductId == 0 || input.UomId == 0)
        {
            return InventoryErrors.InvalidDocument($"Line {lineNo}: product_id and uom_id are required.");
        }

        if (input.Qty <= 0m)
        {
            return InventoryErrors.InvalidQuantity($"Line {lineNo}: qty must be positive.");
        }

        return new IssueLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            ProductId = input.ProductId,
            RequestLineId = input.RequestLineId,
            Qty = input.Qty,
            UomId = input.UomId,
            BatchId = input.BatchId,
            BatchOverrideReasonCodeId = input.BatchOverrideReasonCodeId,
            BatchOverrideNote = Text.Truncate(input.BatchOverrideNote, NoteMaxLength),
        };
    }

    internal void ApplyDispatch(decimal qtyBase, long? batchId, long? suggestedBatchId, decimal? unitCost)
    {
        QtyBase = qtyBase;
        BatchId = batchId;
        SuggestedBatchId = suggestedBatchId;
        UnitCost = unitCost;
    }

    internal Result Confirm(decimal receivedQty, ushort? reasonCodeId, string? note)
    {
        if (receivedQty < 0m || receivedQty > Qty)
        {
            return InventoryErrors.InvalidQuantity($"Line {LineNo}: received_qty must be between 0 and the dispatched quantity.");
        }

        var discrepancy = Qty - receivedQty;
        if (discrepancy != 0m && (reasonCodeId is null or 0 || string.IsNullOrWhiteSpace(note)))
        {
            return InventoryErrors.DiscrepancyReasonRequired(LineNo);
        }

        ReceivedQty = receivedQty;
        DiscrepancyQty = discrepancy;
        DiscrepancyReasonCodeId = discrepancy == 0m ? null : reasonCodeId;
        DiscrepancyNote = discrepancy == 0m ? null : Text.Truncate(note, NoteMaxLength);
        return Result.Success();
    }
}
