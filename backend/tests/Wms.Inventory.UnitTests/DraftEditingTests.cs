using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>
/// Spec §9.6 and §12: a DRAFT document may be rewritten or abandoned; a POSTED one may not.
/// Both rules live in the aggregate, so no command handler can write around them.
/// </summary>
public sealed class DraftEditingTests
{
    private static GoodsReceipt NewReceipt() => GoodsReceipt.CreateDraft(
        1, "GR-2026-00412", new DateOnly(2026, 9, 22), poId: null, supplierId: 3, locationId: 10,
        temperatureC: 4m, QualityStatus.Accepted, packagingNote: "ilk yazı").Value;

    private static Issue NewIssue() => Issue.CreateDraft(
        1, "IS-2026-00099", new DateOnly(2026, 9, 22), IssueType.BranchTransfer,
        fromLocationId: 905, toLocationId: 909, requestId: null, note: "ilk qeyd").Value;

    [Fact]
    public void UpdateDraft_replaces_the_header_but_keeps_the_document_number()
    {
        var receipt = NewReceipt();

        var result = receipt.UpdateDraft(
            new DateOnly(2026, 9, 23), poId: 7, supplierId: 4, locationId: 11,
            temperatureC: 2m, QualityStatus.PartiallyAccepted, packagingNote: "yeni yazı");

        Assert.True(result.IsSuccess);
        Assert.Equal("GR-2026-00412", receipt.DocNo);
        Assert.Equal(4u, receipt.SupplierId);
        Assert.Equal("yeni yazı", receipt.PackagingNote);
    }

    [Fact]
    public void ClearLines_then_AddLine_renumbers_from_one()
    {
        var receipt = NewReceipt();
        receipt.AddLine(productId: 55, receivedQty: 10m, uomId: 1);
        receipt.AddLine(productId: 56, receivedQty: 20m, uomId: 1);

        receipt.ClearLines();
        receipt.AddLine(productId: 57, receivedQty: 30m, uomId: 1);

        Assert.Equal([(ushort)1], receipt.Lines.Select(l => l.LineNo));
        Assert.Equal(57u, receipt.Lines[0].ProductId);
    }

    [Fact]
    public void A_posted_receipt_refuses_both_editing_and_cancellation()
    {
        var receipt = NewReceipt();
        receipt.AddLine(productId: 55, receivedQty: 10m, uomId: 1);
        receipt.MarkPosted(movementGroupId: 900);

        var edited = receipt.UpdateDraft(
            new DateOnly(2026, 9, 23), null, 4, 11, null, QualityStatus.Accepted, null);
        var cleared = receipt.ClearLines();
        var cancelled = receipt.Cancel();

        Assert.True(edited.IsFailure);
        Assert.True(cleared.IsFailure);
        Assert.True(cancelled.IsFailure);
        Assert.Equal(ReceiptStatus.Posted, receipt.Status);
    }

    [Fact]
    public void A_cancelled_receipt_cannot_be_cancelled_twice()
    {
        var receipt = NewReceipt();
        receipt.AddLine(productId: 55, receivedQty: 10m, uomId: 1);

        Assert.True(receipt.Cancel().IsSuccess);
        Assert.True(receipt.Cancel().IsFailure);
        Assert.Equal(ReceiptStatus.Cancelled, receipt.Status);
    }

    [Fact]
    public void Issue_UpdateDraft_rewrites_the_header_and_keeps_the_document_number()
    {
        var issue = NewIssue();

        var result = issue.UpdateDraft(
            new DateOnly(2026, 9, 23), IssueType.WhTransfer,
            fromLocationId: 1, toLocationId: 2, requestId: 5, note: "yeni qeyd");

        Assert.True(result.IsSuccess);
        Assert.Equal("IS-2026-00099", issue.DocNo);
        Assert.Equal(IssueType.WhTransfer, issue.IssueType);
        Assert.Equal("yeni qeyd", issue.Note);
    }

    [Fact]
    public void Issue_UpdateDraft_refuses_the_same_location_on_both_sides()
    {
        var issue = NewIssue();

        var result = issue.UpdateDraft(
            new DateOnly(2026, 9, 23), IssueType.WhTransfer,
            fromLocationId: 7, toLocationId: 7, requestId: null, note: null);

        Assert.True(result.IsFailure);
        Assert.Equal(905u, issue.FromLocationId);
    }

    [Fact]
    public void Issue_UpdateDraft_refuses_a_dispatched_document()
    {
        var issue = NewIssue();
        issue.ReplaceLines([new IssueLineInput(ProductId: 55, Qty: 3m, UomId: 1)]);
        issue.MarkDispatched(dispatchGroupId: 800, DateTimeOffset.UnixEpoch);

        var result = issue.UpdateDraft(
            new DateOnly(2026, 9, 23), IssueType.WhTransfer, 1, 2, null, null);

        Assert.True(result.IsFailure);
    }
}
