using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>Header of a ledger document (spec §9.3, ADR-003).</summary>
public sealed record MovementGroupHeader(
    uint TenantId,
    DocType DocType,
    string DocNo,
    DateOnly DocDate,
    DateTimeOffset PostedAt,
    uint PostedBy,
    Guid IdempotencyKey,
    string? SourceDocType = null,
    long? SourceDocId = null,
    ushort? ReasonCodeId = null,
    string? Note = null,
    long? ReversesGroupId = null);

/// <summary>Input of one ledger line. <c>EnteredQty</c> is signed: + into <c>LocationId</c>, − out of it.</summary>
public sealed record MovementLineInput(
    uint ProductId,
    uint LocationId,
    long? BatchId,
    decimal EnteredQty,
    ushort EnteredUomId,
    decimal ConversionRate,
    ushort BaseUomId,
    int BaseDecimals,
    decimal? UnitCost = null,
    string? Currency = null,
    decimal? FxRate = null);

/// <summary>
/// Double-entry ledger document (ADR-003). The factory rejects any set of lines whose base quantities do not sum
/// to zero, so an unbalanced group can never exist in memory, let alone in <c>inv_movement</c>.
/// </summary>
public sealed class MovementGroup : AggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;

    private readonly List<Movement> _lines = [];

    private MovementGroup()
    {
    }

    public uint TenantId { get; private set; }

    public DocType DocType { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public string? SourceDocType { get; private set; }

    public long? SourceDocId { get; private set; }

    public ushort? ReasonCodeId { get; private set; }

    public string? Note { get; private set; }

    /// <summary>Storno: the group this one reverses (spec §9.4).</summary>
    public long? ReversesGroupId { get; private set; }

    public DateTimeOffset PostedAt { get; private set; }

    public uint PostedBy { get; private set; }

    public Guid IdempotencyKey { get; private set; }

    public IReadOnlyList<Movement> Lines => _lines.AsReadOnly();

    public static Result<MovementGroup> Create(MovementGroupHeader header, IReadOnlyList<MovementLineInput> lines)
    {
        ArgumentNullException.ThrowIfNull(header);
        ArgumentNullException.ThrowIfNull(lines);

        if (string.IsNullOrWhiteSpace(header.DocNo) || header.DocNo.Length > DocNoMaxLength)
        {
            return InventoryErrors.InvalidQuantity($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (header.IdempotencyKey == Guid.Empty)
        {
            return InventoryErrors.InvalidQuantity("idempotency_key is required.");
        }

        if (lines.Count < 2)
        {
            return InventoryErrors.EmptyMovementGroup();
        }

        var group = new MovementGroup
        {
            TenantId = header.TenantId,
            DocType = header.DocType,
            DocNo = header.DocNo,
            DocDate = header.DocDate,
            SourceDocType = header.SourceDocType,
            SourceDocId = header.SourceDocId,
            ReasonCodeId = header.ReasonCodeId,
            Note = header.Note is { Length: > NoteMaxLength } note ? note[..NoteMaxLength] : header.Note,
            ReversesGroupId = header.ReversesGroupId,
            PostedAt = header.PostedAt,
            PostedBy = header.PostedBy,
            IdempotencyKey = header.IdempotencyKey,
        };

        var sum = 0m;
        for (var i = 0; i < lines.Count; i++)
        {
            var input = lines[i];
            var lineNo = (ushort)(i + 1);
            if (input.ConversionRate <= 0m)
            {
                return InventoryErrors.InvalidQuantity($"Line {lineNo}: conversion_rate must be positive.");
            }

            var qtyBase = Quantity.Convert(input.EnteredQty, input.ConversionRate, input.BaseDecimals);
            if (qtyBase.IsZero)
            {
                return InventoryErrors.ZeroQuantityLine(lineNo);
            }

            group._lines.Add(Movement.Create(group, lineNo, input, qtyBase.Value));
            sum += qtyBase.Value;
        }

        if (sum != 0m)
        {
            return InventoryErrors.UnbalancedMovementGroup(sum);
        }

        return group;
    }

    /// <summary>Always 0 for a constructed group — exposed for tests and the DoubleEntryCheck job.</summary>
    public decimal SumQtyBase() => _lines.Sum(l => l.QtyBase);

    /// <summary>Builds the storno group: same lines with inverted signs (spec §9.4, §12.6).</summary>
    public Result<MovementGroup> BuildReversal(string docNo, DateOnly docDate, DateTimeOffset postedAt, uint postedBy, Guid idempotencyKey, ushort reasonCodeId, string? note)
    {
        var header = new MovementGroupHeader(
            TenantId,
            DocType.Reversal,
            docNo,
            docDate,
            postedAt,
            postedBy,
            idempotencyKey,
            SourceDocType: DocType.ToString(),
            SourceDocId: Id,
            ReasonCodeId: reasonCodeId,
            Note: note,
            ReversesGroupId: Id);

        var inputs = _lines.Select(l => new MovementLineInput(
            l.ProductId,
            l.LocationId,
            l.BatchId,
            -l.QtyBase,
            l.BaseUomId,
            1m,
            l.BaseUomId,
            Quantity.StorageDecimals,
            l.UnitCost,
            l.Currency,
            l.FxRate)).ToList();

        return Create(header, inputs);
    }
}
