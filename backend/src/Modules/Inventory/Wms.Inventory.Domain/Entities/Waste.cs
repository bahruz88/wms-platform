using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>Input of one stock-out line for waste, sample and return-to-vendor documents.</summary>
public sealed record StockOutLineInput(uint ProductId, decimal Qty, ushort UomId, long? BatchId = null, string? Note = null);

/// <summary>
/// Waste document (<c>inv_waste</c>, spec §9.6, TOR §22). Posting writes location <c>−qty</c> / <c>V_WASTE</c>
/// <c>+qty</c>, so waste is part of the ledger rather than a column nobody adds up — which is precisely the Excel
/// failure this model exists to remove.
/// </summary>
public sealed class Waste : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;

    private readonly List<WasteLine> _lines = [];

    private Waste()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public uint LocationId { get; private set; }

    public ushort ReasonCodeId { get; private set; }

    public WasteStatus Status { get; private set; }

    public uint? ApprovedBy { get; private set; }

    public DateTimeOffset? ApprovedAt { get; private set; }

    public string? ApprovalComment { get; private set; }

    public long? MovementGroupId { get; private set; }

    public string? Note { get; private set; }

    public IReadOnlyList<WasteLine> Lines => _lines.AsReadOnly();

    public static Result<Waste> CreateDraft(uint tenantId, string docNo, DateOnly docDate, uint locationId, ushort reasonCodeId, string? note)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return InventoryErrors.InvalidDocument($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (locationId == 0 || reasonCodeId == 0)
        {
            return InventoryErrors.InvalidDocument("location_id and reason_code_id are required.");
        }

        return new Waste
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            LocationId = locationId,
            ReasonCodeId = reasonCodeId,
            Status = WasteStatus.Draft,
            Note = Text.Truncate(note, NoteMaxLength),
        };
    }

    public Result ReplaceLines(IReadOnlyList<StockOutLineInput> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != WasteStatus.Draft)
        {
            return InventoryErrors.DocumentNotDraft("waste", Id, Status.ToString());
        }

        if (lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A waste document needs at least one line.");
        }

        _lines.Clear();
        var lineNo = (ushort)0;
        foreach (var input in lines)
        {
            lineNo++;
            var line = WasteLine.Create(TenantId, lineNo, input);
            if (line.IsFailure)
            {
                return line.Error;
            }

            _lines.Add(line.Value);
        }

        return Result.Success();
    }

    /// <summary><c>DRAFT → PENDING_APPROVAL</c>.</summary>
    public Result Submit()
    {
        if (Status is not (WasteStatus.Draft or WasteStatus.Rejected))
        {
            return InventoryErrors.InvalidDocumentTransition("waste", Status.ToString(), nameof(WasteStatus.PendingApproval));
        }

        if (_lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A waste document needs at least one line.");
        }

        Status = WasteStatus.PendingApproval;
        return Result.Success();
    }

    public Result Approve(uint approvedBy, DateTimeOffset approvedAt, string? comment)
    {
        if (Status != WasteStatus.PendingApproval)
        {
            return InventoryErrors.InvalidDocumentTransition("waste", Status.ToString(), nameof(WasteStatus.Approved));
        }

        Status = WasteStatus.Approved;
        ApprovedBy = approvedBy;
        ApprovedAt = approvedAt;
        ApprovalComment = Text.Truncate(comment, NoteMaxLength);
        return Result.Success();
    }

    public Result Reject(uint rejectedBy, DateTimeOffset rejectedAt, string? comment)
    {
        if (Status != WasteStatus.PendingApproval)
        {
            return InventoryErrors.InvalidDocumentTransition("waste", Status.ToString(), nameof(WasteStatus.Rejected));
        }

        Status = WasteStatus.Rejected;
        ApprovedBy = rejectedBy;
        ApprovedAt = rejectedAt;
        ApprovalComment = Text.Truncate(comment, NoteMaxLength);
        return Result.Success();
    }

    /// <summary>Records what the ledger actually took for each line (base quantity, batch, unit cost).</summary>
    public void RecordPostedLines(IReadOnlyList<PostedLineResult> results)
    {
        ArgumentNullException.ThrowIfNull(results);
        foreach (var result in results)
        {
            _lines.FirstOrDefault(l => l.Id == result.LineId)?.ApplyPosting(result.QtyBase, result.BatchId, result.UnitCost);
        }
    }

    public Result MarkPosted(long movementGroupId)
    {
        if (Status != WasteStatus.Approved)
        {
            return InventoryErrors.InvalidDocumentTransition("waste", Status.ToString(), nameof(WasteStatus.Posted));
        }

        Status = WasteStatus.Posted;
        MovementGroupId = movementGroupId;
        return Result.Success();
    }
}

public sealed class WasteLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private WasteLine()
    {
    }

    public uint TenantId { get; private set; }

    public long WasteId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public long? BatchId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    public decimal QtyBase { get; private set; }

    public decimal? UnitCost { get; private set; }

    public string? Note { get; private set; }

    internal static Result<WasteLine> Create(uint tenantId, ushort lineNo, StockOutLineInput input)
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

        return new WasteLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            ProductId = input.ProductId,
            BatchId = input.BatchId,
            Qty = input.Qty,
            UomId = input.UomId,
            Note = Text.Truncate(input.Note, NoteMaxLength),
        };
    }

    internal void ApplyPosting(decimal qtyBase, long? batchId, decimal? unitCost)
    {
        QtyBase = qtyBase;
        BatchId = batchId;
        UnitCost = unitCost;
    }
}
