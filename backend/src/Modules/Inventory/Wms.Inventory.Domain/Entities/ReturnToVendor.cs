using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// Return to vendor (<c>inv_return_to_vendor</c>, spec §9.6). Sending the goods back posts location <c>−qty</c> /
/// <c>V_SUPPLIER</c> <c>+qty</c> — the mirror image of a goods receipt. Closing it only records what the supplier
/// agreed to; no further stock moves.
/// </summary>
public sealed class ReturnToVendor : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;

    private readonly List<ReturnToVendorLine> _lines = [];

    private ReturnToVendor()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public uint SupplierId { get; private set; }

    /// <summary>Where the goods leave from. Not in the SPEC DDL — see backend README §8.11.</summary>
    public uint LocationId { get; private set; }

    public long? ReceiptId { get; private set; }

    public ushort ReasonCodeId { get; private set; }

    public decimal? ClaimAmount { get; private set; }

    public RtvStatus Status { get; private set; }

    public long? MovementGroupId { get; private set; }

    public string? Outcome { get; private set; }

    public string? OutcomeNote { get; private set; }

    public string? Note { get; private set; }

    public IReadOnlyList<ReturnToVendorLine> Lines => _lines.AsReadOnly();

    public static Result<ReturnToVendor> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        uint supplierId,
        uint locationId,
        long? receiptId,
        ushort reasonCodeId,
        decimal? claimAmount,
        string? note)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return InventoryErrors.InvalidDocument($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (supplierId == 0 || locationId == 0 || reasonCodeId == 0)
        {
            return InventoryErrors.InvalidDocument("supplier_id, location_id and reason_code_id are required.");
        }

        if (claimAmount is < 0m)
        {
            return InventoryErrors.InvalidDocument("claim_amount cannot be negative.");
        }

        return new ReturnToVendor
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            SupplierId = supplierId,
            LocationId = locationId,
            ReceiptId = receiptId,
            ReasonCodeId = reasonCodeId,
            ClaimAmount = claimAmount,
            Status = RtvStatus.Draft,
            Note = Text.Truncate(note, NoteMaxLength),
        };
    }

    public Result ReplaceLines(IReadOnlyList<StockOutLineInput> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != RtvStatus.Draft)
        {
            return InventoryErrors.DocumentNotDraft("return to vendor", Id, Status.ToString());
        }

        if (lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A return needs at least one line.");
        }

        _lines.Clear();
        var lineNo = (ushort)0;
        foreach (var input in lines)
        {
            lineNo++;
            var line = ReturnToVendorLine.Create(TenantId, lineNo, input);
            if (line.IsFailure)
            {
                return line.Error;
            }

            _lines.Add(line.Value);
        }

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

    /// <summary><c>DRAFT → SENT</c>: the stock leaves and the ledger says where it went.</summary>
    public Result MarkSent(long movementGroupId)
    {
        if (Status != RtvStatus.Draft)
        {
            return InventoryErrors.InvalidDocumentTransition("return to vendor", Status.ToString(), nameof(RtvStatus.Sent));
        }

        if (_lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A return needs at least one line.");
        }

        Status = RtvStatus.Sent;
        MovementGroupId = movementGroupId;
        return Result.Success();
    }

    /// <summary><c>SENT → CLOSED</c> recording the supplier's answer; no stock moves.</summary>
    public Result Close(string outcome, decimal? claimAmount, string? outcomeNote)
    {
        if (Status != RtvStatus.Sent)
        {
            return InventoryErrors.InvalidDocumentTransition("return to vendor", Status.ToString(), nameof(RtvStatus.Closed));
        }

        if (!string.Equals(outcome, "ACCEPTED", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(outcome, "REJECTED", StringComparison.OrdinalIgnoreCase))
        {
            return InventoryErrors.InvalidDocument("outcome must be ACCEPTED or REJECTED.");
        }

        if (claimAmount is < 0m)
        {
            return InventoryErrors.InvalidDocument("claim_amount cannot be negative.");
        }

        Status = RtvStatus.Closed;
        Outcome = outcome.ToUpperInvariant();
        ClaimAmount = claimAmount ?? ClaimAmount;
        OutcomeNote = Text.Truncate(outcomeNote, NoteMaxLength);
        return Result.Success();
    }
}

public sealed class ReturnToVendorLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private ReturnToVendorLine()
    {
    }

    public uint TenantId { get; private set; }

    public long ReturnId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public long? BatchId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    public decimal QtyBase { get; private set; }

    public decimal? UnitCost { get; private set; }

    public string? Note { get; private set; }

    internal static Result<ReturnToVendorLine> Create(uint tenantId, ushort lineNo, StockOutLineInput input)
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

        return new ReturnToVendorLine
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
