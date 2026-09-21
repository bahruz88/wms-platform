using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>Goods receipt document (spec §9.6, TOR §12). DRAFT → POSTED creates exactly one <see cref="MovementGroup"/>.</summary>
public sealed class GoodsReceipt : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int PackagingNoteMaxLength = 500;

    private readonly List<GoodsReceiptLine> _lines = [];

    private GoodsReceipt()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public long? PoId { get; private set; }

    public uint SupplierId { get; private set; }

    public uint LocationId { get; private set; }

    /// <summary>DECIMAL(6,2) — cold-chain temperature at the dock (TOR §12).</summary>
    public decimal? TemperatureC { get; private set; }

    public QualityStatus QualityStatus { get; private set; }

    public string? PackagingNote { get; private set; }

    public ReceiptStatus Status { get; private set; }

    public long? MovementGroupId { get; private set; }

    public IReadOnlyList<GoodsReceiptLine> Lines => _lines.AsReadOnly();

    public static Result<GoodsReceipt> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        long? poId,
        uint supplierId,
        uint locationId,
        decimal? temperatureC,
        QualityStatus qualityStatus,
        string? packagingNote)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return InventoryErrors.InvalidReceiptLine($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (supplierId == 0 || locationId == 0)
        {
            return InventoryErrors.InvalidReceiptLine("supplier_id and location_id are required.");
        }

        return new GoodsReceipt
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            PoId = poId,
            SupplierId = supplierId,
            LocationId = locationId,
            TemperatureC = temperatureC,
            QualityStatus = qualityStatus,
            PackagingNote = packagingNote is { Length: > PackagingNoteMaxLength } note ? note[..PackagingNoteMaxLength] : packagingNote,
            Status = ReceiptStatus.Draft,
        };
    }

    public Result<GoodsReceiptLine> AddLine(
        uint productId,
        decimal receivedQty,
        ushort uomId,
        long? poLineId = null,
        decimal? orderedQty = null,
        decimal rejectedQty = 0m,
        string? batchNo = null,
        DateOnly? productionDate = null,
        DateOnly? expiryDate = null,
        decimal? unitPrice = null,
        string? currency = null,
        string? varianceNote = null)
    {
        if (Status != ReceiptStatus.Draft)
        {
            return InventoryErrors.ReceiptNotDraft(Id, Status);
        }

        var lineNo = (ushort)(_lines.Count + 1);
        var line = GoodsReceiptLine.Create(
            TenantId, lineNo, productId, receivedQty, uomId, poLineId, orderedQty, rejectedQty,
            batchNo, productionDate, expiryDate, unitPrice, currency, varianceNote);
        if (line.IsFailure)
        {
            return line.Error;
        }

        _lines.Add(line.Value);
        return line.Value;
    }

    public Result MarkPosted(long movementGroupId)
    {
        if (Status != ReceiptStatus.Draft)
        {
            return InventoryErrors.ReceiptNotDraft(Id, Status);
        }

        if (_lines.Count == 0)
        {
            return InventoryErrors.ReceiptHasNoLines(Id);
        }

        Status = ReceiptStatus.Posted;
        MovementGroupId = movementGroupId;
        return Result.Success();
    }

    public Result Cancel()
    {
        if (Status != ReceiptStatus.Draft)
        {
            return InventoryErrors.ReceiptNotDraft(Id, Status);
        }

        Status = ReceiptStatus.Cancelled;
        return Result.Success();
    }
}
