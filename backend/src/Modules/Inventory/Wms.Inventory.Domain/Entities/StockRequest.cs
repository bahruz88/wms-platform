using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// Branch request for goods (<c>inv_stock_request</c>, spec §9.6, TOR §16). It moves nothing by itself: the
/// warehouse answers it with one or more <see cref="Issue"/> documents, and <c>issued_qty</c> tracks how much of
/// each line has been served.
/// </summary>
public sealed class StockRequest : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;

    private readonly List<StockRequestLine> _lines = [];

    private StockRequest()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    /// <summary>Usually the central warehouse.</summary>
    public uint FromLocationId { get; private set; }

    /// <summary>The branch asking.</summary>
    public uint ToLocationId { get; private set; }

    public DateOnly? RequiredDate { get; private set; }

    public StockRequestStatus Status { get; private set; }

    public string? Note { get; private set; }

    public IReadOnlyList<StockRequestLine> Lines => _lines.AsReadOnly();

    public static Result<StockRequest> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        uint fromLocationId,
        uint toLocationId,
        DateOnly? requiredDate,
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

        return new StockRequest
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            FromLocationId = fromLocationId,
            ToLocationId = toLocationId,
            RequiredDate = requiredDate,
            Status = StockRequestStatus.Draft,
            Note = Text.Truncate(note, NoteMaxLength),
        };
    }

    public Result ReplaceLines(IReadOnlyList<(uint ProductId, decimal Qty, ushort UomId, string? Note)> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != StockRequestStatus.Draft)
        {
            return InventoryErrors.DocumentNotDraft("stock request", Id, Status.ToString());
        }

        if (lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A stock request needs at least one line.");
        }

        _lines.Clear();
        var lineNo = (ushort)0;
        foreach (var input in lines)
        {
            lineNo++;
            var line = StockRequestLine.Create(TenantId, lineNo, input.ProductId, input.Qty, input.UomId, input.Note);
            if (line.IsFailure)
            {
                return line.Error;
            }

            _lines.Add(line.Value);
        }

        return Result.Success();
    }

    /// <summary><c>DRAFT → SUBMITTED</c>: the warehouse now sees it in its picking queue.</summary>
    public Result Submit()
    {
        if (Status != StockRequestStatus.Draft)
        {
            return InventoryErrors.InvalidDocumentTransition("stock request", Status.ToString(), nameof(StockRequestStatus.Submitted));
        }

        if (_lines.Count == 0)
        {
            return InventoryErrors.InvalidDocument("A stock request needs at least one line.");
        }

        Status = StockRequestStatus.Submitted;
        return Result.Success();
    }

    public Result Cancel()
    {
        if (Status is StockRequestStatus.Issued or StockRequestStatus.Closed or StockRequestStatus.Cancelled)
        {
            return InventoryErrors.InvalidDocumentTransition("stock request", Status.ToString(), nameof(StockRequestStatus.Cancelled));
        }

        Status = StockRequestStatus.Cancelled;
        return Result.Success();
    }

    /// <summary>
    /// Called when an issue is dispatched against this request; moves the header to PARTIALLY_ISSUED or ISSUED.
    /// Keyed by <c>line_no</c> rather than the surrogate id: the id is still 0 on a line that has not been through
    /// SaveChanges, and every such line would collide on the same key.
    /// </summary>
    public void RecordIssued(IReadOnlyDictionary<ushort, decimal> issuedByLineNo)
    {
        ArgumentNullException.ThrowIfNull(issuedByLineNo);
        foreach (var line in _lines)
        {
            if (issuedByLineNo.TryGetValue(line.LineNo, out var qty))
            {
                line.AddIssued(qty);
            }
        }

        if (_lines.Count == 0)
        {
            return;
        }

        Status = _lines.All(l => l.IssuedQty >= l.Qty)
            ? StockRequestStatus.Issued
            : _lines.Any(l => l.IssuedQty > 0m) ? StockRequestStatus.PartiallyIssued : StockRequestStatus.Picking;
    }
}

public sealed class StockRequestLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private StockRequestLine()
    {
    }

    public uint TenantId { get; private set; }

    public long RequestId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    /// <summary>How much has been dispatched so far, in the same UoM.</summary>
    public decimal IssuedQty { get; private set; }

    public string? Note { get; private set; }

    internal static Result<StockRequestLine> Create(uint tenantId, ushort lineNo, uint productId, decimal qty, ushort uomId, string? note)
    {
        if (productId == 0 || uomId == 0)
        {
            return InventoryErrors.InvalidDocument($"Line {lineNo}: product_id and uom_id are required.");
        }

        if (qty <= 0m)
        {
            return InventoryErrors.InvalidQuantity($"Line {lineNo}: qty must be positive.");
        }

        return new StockRequestLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            ProductId = productId,
            Qty = qty,
            UomId = uomId,
            Note = Text.Truncate(note, NoteMaxLength),
        };
    }

    internal void AddIssued(decimal qty) => IssuedQty += qty;
}

/// <summary>Shared string helpers for the document aggregates.</summary>
internal static class Text
{
    public static string? Truncate(string? value, int maxLength) =>
        value is { Length: > 0 } && value.Length > maxLength ? value[..maxLength] : value;
}
