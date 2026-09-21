using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// Regulator sample (<c>inv_sample</c>, spec §9.6, TOR §23). AQTA takes goods away; the ledger says so with
/// location <c>−qty</c> / <c>V_SAMPLE</c> <c>+qty</c>. There is no approval step — the inspector does not wait.
/// </summary>
public sealed class Sample : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int AuthorityMaxLength = 150;
    public const int PurposeMaxLength = 500;
    public const string DefaultAuthority = "AQTA";

    private readonly List<SampleLine> _lines = [];

    private Sample()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public uint LocationId { get; private set; }

    public string Authority { get; private set; } = DefaultAuthority;

    public string? Purpose { get; private set; }

    public ushort? ReasonCodeId { get; private set; }

    public long? MovementGroupId { get; private set; }

    public IReadOnlyList<SampleLine> Lines => _lines.AsReadOnly();

    /// <summary>The contract's <c>SimpleDocStatus</c> is derived, not stored (spec §9.6 has no status column).</summary>
    public SimpleDocStatus Status => MovementGroupId is null ? SimpleDocStatus.Draft : SimpleDocStatus.Posted;

    public static Result<Sample> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        uint locationId,
        string? authority,
        string? purpose,
        ushort? reasonCodeId)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return InventoryErrors.InvalidDocument($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (locationId == 0)
        {
            return InventoryErrors.InvalidDocument("location_id is required.");
        }

        return new Sample
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            LocationId = locationId,
            Authority = Text.Truncate(string.IsNullOrWhiteSpace(authority) ? DefaultAuthority : authority.Trim(), AuthorityMaxLength)!,
            Purpose = Text.Truncate(purpose, PurposeMaxLength),
            ReasonCodeId = reasonCodeId is 0 ? null : reasonCodeId,
        };
    }

    public Result ReplaceLines(IReadOnlyList<StockOutLineInput> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (MovementGroupId is not null)
        {
            return InventoryErrors.DocumentNotDraft("sample", Id, nameof(SimpleDocStatus.Posted));
        }

        if (lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A sample document needs at least one line.");
        }

        _lines.Clear();
        var lineNo = (ushort)0;
        foreach (var input in lines)
        {
            lineNo++;
            var line = SampleLine.Create(TenantId, lineNo, input);
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

    public Result MarkPosted(long movementGroupId)
    {
        if (MovementGroupId is not null)
        {
            return InventoryErrors.InvalidDocumentTransition("sample", nameof(SimpleDocStatus.Posted), nameof(SimpleDocStatus.Posted));
        }

        if (_lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A sample document needs at least one line.");
        }

        MovementGroupId = movementGroupId;
        return Result.Success();
    }
}

public sealed class SampleLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private SampleLine()
    {
    }

    public uint TenantId { get; private set; }

    public long SampleId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public long? BatchId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    public decimal QtyBase { get; private set; }

    public decimal? UnitCost { get; private set; }

    public string? Note { get; private set; }

    internal static Result<SampleLine> Create(uint tenantId, ushort lineNo, StockOutLineInput input)
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

        return new SampleLine
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
