using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.UnitTests;

/// <summary>The PR and PO state machines and the arithmetic of spec §10 / §12.8.</summary>
public sealed class PurchaseOrderLifecycleTests
{
    private const uint TenantId = 1;
    private static readonly DateOnly DocDate = new(2026, 9, 21);

    [Fact]
    public void Line_total_includes_vat_while_the_header_subtotal_does_not()
    {
        var po = Draft();
        po.ReplaceLines([new PurchaseOrderLineDraft(ProductId: 5, Qty: 10m, UomId: 1, UnitPrice: 12.50m, VatRate: 18m, null)]);

        Assert.Equal(125m, po.Subtotal);
        Assert.Equal(22.50m, po.VatAmount);
        Assert.Equal(147.50m, po.TotalAmount);
        Assert.Equal(147.50m, po.Lines[0].LineTotal);
    }

    [Fact]
    public void The_base_amount_uses_the_frozen_fx_rate()
    {
        var po = PurchaseOrder.CreateDraft(TenantId, "PO-2026-00002", DocDate, 9, "USD", 1.70m, 3, ProductType.NonFood).Value;
        po.ReplaceLines([new PurchaseOrderLineDraft(5, 10m, 1, 10m, 0m, null)]);

        Assert.Equal(100m, po.TotalAmount);
        Assert.Equal(170m, po.TotalAmountBase);
    }

    [Fact]
    public void A_zero_amount_order_cannot_be_submitted()
    {
        var po = Draft();
        po.ReplaceLines([new PurchaseOrderLineDraft(5, 10m, 1, 0m, 0m, null)]);

        var submitted = po.SubmitForApproval();

        Assert.True(submitted.IsFailure);
        Assert.Equal(422, submitted.Error.Status);
    }

    [Fact]
    public void An_unapproved_order_cannot_be_sent_to_the_supplier()
    {
        var po = Draft();
        po.ReplaceLines([new PurchaseOrderLineDraft(5, 1m, 1, 100m, 0m, null)]);
        po.SubmitForApproval();

        var sent = po.MarkSent(DateTimeOffset.UnixEpoch);

        Assert.True(sent.IsFailure);
        Assert.Equal("APPROVAL_REQUIRED", sent.Error.Code);
        Assert.Equal(409, sent.Error.Status);
    }

    [Fact]
    public void A_rejected_order_needs_a_comment_and_returns_to_draft_for_correction()
    {
        var po = Draft();
        po.ReplaceLines([new PurchaseOrderLineDraft(5, 1m, 1, 100m, 0m, null)]);
        po.SubmitForApproval();

        Assert.True(po.Reject("   ").IsFailure);
        Assert.True(po.Reject("Qiymət yüksəkdir").IsSuccess);
        Assert.Equal(PurchaseOrderStatus.Rejected, po.Status);

        Assert.True(po.ReturnToDraft().IsSuccess);
        Assert.Equal(PurchaseOrderStatus.Draft, po.Status);
    }

    [Fact]
    public void A_sent_order_can_only_be_closed_with_a_comment()
    {
        var po = Sent();

        Assert.True(po.Close(null).IsFailure);
        Assert.True(po.Close("Təchizatçı çatdıra bilmədi").IsSuccess);
        Assert.Equal(PurchaseOrderStatus.Closed, po.Status);
    }

    [Fact]
    public void A_sent_order_is_closed_not_cancelled()
    {
        var po = Sent();

        var cancelled = po.Cancel("səhv sifariş");

        Assert.True(cancelled.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", cancelled.Error.Code);
    }

    [Fact]
    public void Receipts_move_the_order_from_partially_to_fully_received()
    {
        var po = Sent();
        var line = po.Lines[0];

        Assert.True(po.RegisterReceipt(line.Id, 4m).IsSuccess);
        Assert.Equal(PurchaseOrderStatus.PartiallyReceived, po.Status);
        Assert.Equal(40m, po.ReceivedPct());

        Assert.True(po.RegisterReceipt(line.Id, 6m).IsSuccess);
        Assert.Equal(PurchaseOrderStatus.FullyReceived, po.Status);
        Assert.Equal(100m, po.ReceivedPct());
        Assert.Equal(0m, po.Lines[0].RemainingQty());
    }

    [Fact]
    public void A_requisition_line_tracks_partial_conversion_and_never_over_converts()
    {
        var pr = Requisition.CreateDraft(TenantId, "PR-2026-00001", DocDate, 3, ProductType.Food).Value;
        pr.ReplaceLines([new RequisitionLineDraft(5, 10m, 1, null)]);
        pr.Submit();
        var lineId = pr.Lines[0].Id;

        Assert.True(pr.RegisterConversion(lineId, 4m).IsSuccess);
        Assert.Equal(RequisitionStatus.InProcurement, pr.Status);
        Assert.Equal(6m, pr.Lines[0].RemainingQty());

        Assert.True(pr.RegisterConversion(lineId, 7m).IsFailure);

        Assert.True(pr.RegisterConversion(lineId, 6m).IsSuccess);
        Assert.Equal(RequisitionStatus.ConvertedToPo, pr.Status);
    }

    [Fact]
    public void A_requisition_is_never_converted_automatically()
    {
        var pr = Requisition.CreateDraft(TenantId, "PR-2026-00002", DocDate, 3, ProductType.Food).Value;
        pr.ReplaceLines([new RequisitionLineDraft(5, 10m, 1, null)]);

        Assert.Equal(RequisitionStatus.Draft, pr.Status);
        Assert.True(pr.Submit().IsSuccess);
        Assert.Equal(RequisitionStatus.Submitted, pr.Status);
    }

    [Fact]
    public void Rejecting_a_requisition_requires_a_comment()
    {
        var pr = Requisition.CreateDraft(TenantId, "PR-2026-00003", DocDate, 3, ProductType.Food).Value;
        pr.ReplaceLines([new RequisitionLineDraft(5, 1m, 1, null)]);
        pr.Submit();

        Assert.True(pr.Reject(" ").IsFailure);
        Assert.True(pr.Reject("Büdcə yoxdur").IsSuccess);
        Assert.Equal("Büdcə yoxdur", pr.RejectComment);
    }

    [Fact]
    public void An_rfq_needs_at_least_two_suppliers_before_it_is_sent()
    {
        var rfq = Rfq.CreateDraft(TenantId, "RFQ-2026-00001", DocDate, null, null).Value;
        rfq.ReplaceLines([new RfqLineDraft(5, 10m, 1, null, null)]);

        Assert.True(rfq.ReplaceSuppliers([7u]).IsFailure);
        Assert.True(rfq.ReplaceSuppliers([7u, 8u]).IsSuccess);
        Assert.True(rfq.Send().IsSuccess);
        Assert.Equal(RfqStatus.Sent, rfq.Status);

        Assert.True(rfq.Close().IsSuccess);
        Assert.False(rfq.AcceptsQuotations());
    }

    private static PurchaseOrder Draft() =>
        PurchaseOrder.CreateDraft(TenantId, "PO-2026-00001", DocDate, 9, "AZN", 1m, 3, ProductType.Food).Value;

    private static PurchaseOrder Sent()
    {
        var po = Draft();
        po.ReplaceLines([new PurchaseOrderLineDraft(5, 10m, 1, 100m, 0m, null)]);
        po.SubmitForApproval();
        po.Approve();
        po.MarkSent(DateTimeOffset.UnixEpoch);
        return po;
    }
}
