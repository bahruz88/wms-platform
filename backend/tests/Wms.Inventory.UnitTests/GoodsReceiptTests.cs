using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §9.6: goods receipt document lifecycle.</summary>
public sealed class GoodsReceiptTests
{
    private static GoodsReceipt NewDraft() => GoodsReceipt.CreateDraft(
        1, "GR-2026-00311", new DateOnly(2026, 9, 21), poId: 42, supplierId: 3, locationId: 10,
        temperatureC: 4.5m, QualityStatus.Accepted, packagingNote: null).Value;

    [Fact]
    public void CreateDraft_starts_in_draft_without_a_movement_group()
    {
        var receipt = NewDraft();

        Assert.Equal(ReceiptStatus.Draft, receipt.Status);
        Assert.Null(receipt.MovementGroupId);
        Assert.Equal(4.5m, receipt.TemperatureC);
    }

    [Fact]
    public void AddLine_numbers_lines_sequentially()
    {
        var receipt = NewDraft();

        receipt.AddLine(productId: 55, receivedQty: 10m, uomId: 1);
        receipt.AddLine(productId: 56, receivedQty: 20m, uomId: 1);

        Assert.Equal([(ushort)1, (ushort)2], receipt.Lines.Select(l => l.LineNo));
    }

    [Fact]
    public void AddLine_rejects_a_rejected_quantity_above_the_received_quantity()
    {
        var receipt = NewDraft();

        var result = receipt.AddLine(productId: 55, receivedQty: 10m, uomId: 1, rejectedQty: 11m);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_RECEIPT_LINE", result.Error.Code);
    }

    [Fact]
    public void QtyToStock_excludes_the_rejected_quantity()
    {
        var receipt = NewDraft();
        var line = receipt.AddLine(productId: 55, receivedQty: 10m, uomId: 1, rejectedQty: 2m).Value;

        Assert.Equal(8m, line.QtyToStock());
    }

    [Fact]
    public void MarkPosted_requires_at_least_one_line()
    {
        var receipt = NewDraft();

        var result = receipt.MarkPosted(movementGroupId: 900);

        Assert.True(result.IsFailure);
        Assert.Equal("RECEIPT_HAS_NO_LINES", result.Error.Code);
    }

    [Fact]
    public void A_posted_receipt_cannot_be_posted_or_changed_again()
    {
        var receipt = NewDraft();
        receipt.AddLine(productId: 55, receivedQty: 10m, uomId: 1);
        Assert.True(receipt.MarkPosted(900).IsSuccess);

        Assert.Equal(ReceiptStatus.Posted, receipt.Status);
        Assert.Equal(900, receipt.MovementGroupId);
        Assert.Equal("RECEIPT_NOT_DRAFT", receipt.MarkPosted(901).Error.Code);
        Assert.Equal("RECEIPT_NOT_DRAFT", receipt.AddLine(57, 1m, 1).Error.Code);
        Assert.Equal("RECEIPT_NOT_DRAFT", receipt.Cancel().Error.Code);
    }
}
