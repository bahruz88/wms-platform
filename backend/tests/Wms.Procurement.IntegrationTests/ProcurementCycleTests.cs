using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;
using Wms.Procurement.Application.Commands.ApprovalRules;
using Wms.Procurement.Application.Commands.Approvals;
using Wms.Procurement.Application.Commands.PriceHistory;
using Wms.Procurement.Application.Commands.PurchaseOrders;
using Wms.Procurement.Application.Commands.Quotations;
using Wms.Procurement.Application.Commands.Requisitions;
using Wms.Procurement.Application.Commands.Rfqs;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Application.Queries;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.IntegrationTests;

/// <summary>
/// Faza 2 end to end against a real MySQL: a requisition becomes an RFQ, two suppliers quote, the dearer one is
/// refused without a justification, the chosen quotation becomes a purchase order, the two-step approval chain
/// is selected from <c>proc_approval_rule</c> and decided — once directly, once by delegation — and the receipt
/// writes the price history and the <c>PriceChanged</c> event.
/// </summary>
[Collection(ProcurementCollection.Name)]
[Trait("Category", "Integration")]
public sealed class ProcurementCycleTests(ProcurementFixture fixture)
{
    private const uint TenantId = ProcurementFixture.TenantId;
    private static readonly DateOnly DocDate = new(2026, 9, 21);

    [Fact]
    public async Task A_requisition_becomes_an_approved_purchase_order_through_the_rule_driven_chain()
    {
        var cancellationToken = TestCancellation.Token;
        await fixture.ResetApprovalRulesAsync(cancellationToken).ConfigureAwait(true);
        var seed = await SeedAsync("CYCLE", cancellationToken).ConfigureAwait(true);
        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        ActAsBuyer();

        // 1. Two approval bands: one step up to 5 000 AZN, a second one above it.
        await CreateRuleAsync(dispatcher, step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER", cancellationToken).ConfigureAwait(true);
        await CreateRuleAsync(dispatcher, step: 2, min: 5_000m, max: null, role: "ADMIN", cancellationToken).ConfigureAwait(true);

        // 2. The branch raises a requisition. It is DRAFT and nothing converts it by itself (TOR §9).
        var created = await dispatcher.SendAsync(
            new CreateRequisitionCommand(
                DocDate, seed.LocationId, Wms.Procurement.Domain.Enums.ProductType.Food, Priority.High, DocDate.AddDays(7), "Həftəlik tələbat",
                [new RequisitionLineInput(seed.ChickenId, 100m, seed.KilogramUomId, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(created.IsSuccess, Describe(created));
        Assert.Equal(RequisitionStatus.Draft, created.Value.Status);
        Assert.StartsWith("PR-2026-", created.Value.DocNo, StringComparison.Ordinal);
        Assert.Equal(0m, created.Value.Lines[0].ConvertedQty);

        var requisitionId = created.Value.Id;
        var submitted = await dispatcher.SendAsync(
            new SubmitRequisitionCommand(requisitionId, created.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(submitted.IsSuccess, Describe(submitted));
        Assert.Equal(RequisitionStatus.Submitted, submitted.Value.Status);

        var requisitionLineId = submitted.Value.Lines[0].Id;

        // 3. An RFQ to two suppliers; the requisition moves into procurement.
        var rfq = await dispatcher.SendAsync(
            new CreateRfqCommand(
                DocDate, DocDate.AddDays(3), [seed.CheapSupplierId, seed.FastSupplierId],
                [new RfqLineInput(seed.ChickenId, 100m, seed.KilogramUomId, requisitionLineId, null)], null),
            cancellationToken).ConfigureAwait(true);
        Assert.True(rfq.IsSuccess, Describe(rfq));
        Assert.Equal(2, rfq.Value.SupplierCount);

        var sentRfq = await dispatcher.SendAsync(new SendRfqCommand(rfq.Value.Id, rfq.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(sentRfq.IsSuccess, Describe(sentRfq));
        Assert.Equal(RfqStatus.Sent, sentRfq.Value.Status);

        var afterRfq = await dispatcher.QueryAsync(new GetRequisitionQuery(requisitionId), cancellationToken).ConfigureAwait(true);
        Assert.Equal(RequisitionStatus.InProcurement, afterRfq.Value.Status);
        Assert.Contains(rfq.Value.Id, afterRfq.Value.RfqIds);

        // 4. Two offers: 60 AZN/kg and 66 AZN/kg.
        var cheap = await CreateQuotationAsync(dispatcher, rfq.Value.Id, seed, seed.CheapSupplierId, 60m, deliveryDays: 10, cancellationToken).ConfigureAwait(true);
        var dear = await CreateQuotationAsync(dispatcher, rfq.Value.Id, seed, seed.FastSupplierId, 66m, deliveryDays: 2, cancellationToken).ConfigureAwait(true);

        var comparison = await dispatcher.QueryAsync(new GetRfqComparisonQuery(rfq.Value.Id), cancellationToken).ConfigureAwait(true);
        Assert.True(comparison.IsSuccess, Describe(comparison));
        Assert.Equal(cheap.Id, comparison.Value.CheapestQuotationId);
        Assert.Equal(2, comparison.Value.Quotations.Count);
        var row = Assert.Single(comparison.Value.Rows);
        Assert.Equal(2, row.Cells.Count);
        Assert.Single(row.Cells, c => c.IsLowest && c.QuotationId == cheap.Id);

        // 5. Choosing the dearer offer without a reason is refused; with a reason it is accepted.
        var refused = await dispatcher.SendAsync(new SelectQuotationCommand(dear.Id, dear.RowVersion, null), cancellationToken).ConfigureAwait(true);
        Assert.True(refused.IsFailure);
        Assert.Equal("SELECTION_NOTE_REQUIRED", refused.Error.Code);
        Assert.Equal(422, refused.Error.Status);

        var selected = await dispatcher.SendAsync(
            new SelectQuotationCommand(dear.Id, dear.RowVersion, "Çatdırılma 2 gün, kampaniya müddəti qısadır"), cancellationToken).ConfigureAwait(true);
        Assert.True(selected.IsSuccess, Describe(selected));
        Assert.True(selected.Value.IsSelected);
        Assert.False(selected.Value.IsCheapest);

        // 6. The purchase order: 100 kg at 66 AZN + 18 % VAT = 7 788 AZN, so both approval steps apply.
        var po = await dispatcher.SendAsync(
            new CreatePurchaseOrderCommand(
                DocDate, seed.FastSupplierId, "AZN", seed.WarehouseId, DocDate.AddDays(2), "DDP", "30 gün",
                selected.Value.Id, null,
                [new PurchaseOrderLineInput(seed.ChickenId, 100m, seed.KilogramUomId, 66m, 18m, requisitionLineId)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(po.IsSuccess, Describe(po));
        Assert.Equal(6_600m, po.Value.Subtotal);
        Assert.Equal(1_188m, po.Value.VatAmount);
        Assert.Equal(7_788m, po.Value.TotalAmount);
        Assert.Equal(7_788m, po.Value.TotalAmountBase);
        Assert.Equal(PurchaseOrderStatus.Draft, po.Value.Status);
        Assert.Null(po.Value.SplitCheckWarning);

        // The PR line is fully converted, so the requisition closes as CONVERTED_TO_PO (spec §12.8).
        var converted = await dispatcher.QueryAsync(new GetRequisitionQuery(requisitionId), cancellationToken).ConfigureAwait(true);
        Assert.Equal(RequisitionStatus.ConvertedToPo, converted.Value.Status);
        Assert.Equal(100m, converted.Value.Lines[0].ConvertedQty);
        Assert.Contains(po.Value.Id, converted.Value.PurchaseOrderIds);

        // 7. Submitting selects the two-step chain.
        var pending = await dispatcher.SendAsync(new SubmitPurchaseOrderCommand(po.Value.Id, po.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(pending.IsSuccess, Describe(pending));
        Assert.Equal(PurchaseOrderStatus.PendingApproval, pending.Value.Status);
        Assert.NotNull(pending.Value.Approval);
        Assert.Equal(2, pending.Value.Approval!.Steps.Count);
        Assert.Equal("PROCUREMENT_MANAGER", pending.Value.Approval.Steps[0].ApproverRoleCode);
        Assert.Equal("ADMIN", pending.Value.Approval.Steps[1].ApproverRoleCode);
        Assert.Equal(7_788m, pending.Value.Approval.AmountBase);

        // 8. Separation of duties: the buyer cannot approve their own order.
        var selfApproval = await dispatcher.SendAsync(
            new ApprovePurchaseOrderCommand(po.Value.Id, pending.Value.RowVersion, null), cancellationToken).ConfigureAwait(true);
        Assert.True(selfApproval.IsFailure);
        Assert.Equal("SELF_APPROVAL_FORBIDDEN", selfApproval.Error.Code);

        // 9. Step 1 is decided by the manager.
        ActAsManager();
        var step1 = await dispatcher.SendAsync(
            new ApprovePurchaseOrderCommand(po.Value.Id, pending.Value.RowVersion, "Razıyam"), cancellationToken).ConfigureAwait(true);
        Assert.True(step1.IsSuccess, Describe(step1));
        Assert.Equal(PurchaseOrderStatus.PendingApproval, step1.Value.Status);
        Assert.Equal((byte)2, step1.Value.Approval!.CurrentStep);

        // 10. Step 2 is decided by a deputy who holds an in-force delegation from the admin.
        ActAsDeputyWithDelegationFromAdmin();
        var step2 = await dispatcher.SendAsync(
            new ApprovePurchaseOrderCommand(po.Value.Id, step1.Value.RowVersion, "Delegasiya ilə"), cancellationToken).ConfigureAwait(true);
        Assert.True(step2.IsSuccess, Describe(step2));
        Assert.Equal(PurchaseOrderStatus.Approved, step2.Value.Status);
        Assert.Equal(ApprovalStatus.Approved, step2.Value.Approval!.Status);

        var delegatedStep = step2.Value.Approval.Steps[1];
        Assert.Equal(ApprovalDecision.Approved, delegatedStep.Decision);
        Assert.Equal(ProcurementFixture.TestDeputyId, delegatedStep.ApproverUser!.Id);
        Assert.Equal(ProcurementFixture.TestAdminId, delegatedStep.DelegatedFromUser!.Id);

        // PurchaseOrderApproved went to the outbox inside the same transaction (spec §14.1).
        await using (var procurement = fixture.Procurement())
        {
            var events = await procurement.Outbox.AsNoTracking()
                .Where(o => o.EventType == "PurchaseOrderApproved")
                .CountAsync(cancellationToken).ConfigureAwait(true);
            Assert.True(events >= 1);
        }

        // 11. Send, then receive half of it: the PO becomes PARTIALLY_RECEIVED and a price row appears.
        ActAsBuyer();
        var sent = await dispatcher.SendAsync(new SendPurchaseOrderCommand(po.Value.Id, step2.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(sent.IsSuccess, Describe(sent));
        Assert.Equal(PurchaseOrderStatus.SentToSupplier, sent.Value.Status);
        Assert.NotNull(sent.Value.SentAt);

        var openForReceipt = await dispatcher.QueryAsync(
            new ListOpenPurchaseOrdersQuery(null, null, null, PageRequest.Default), cancellationToken).ConfigureAwait(true);
        Assert.Contains(openForReceipt.Value.Items, o => o.Id == po.Value.Id);

        var poLineId = sent.Value.Lines[0].Id;
        var receipt = await dispatcher.SendAsync(
            new RecordReceiptPricesCommand(po.Value.Id, GoodsReceiptId: 1, DocDate, [new ReceiptLineInput(poLineId, 40m)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(receipt.IsSuccess, Describe(receipt));

        var received = await dispatcher.QueryAsync(new GetPurchaseOrderQuery(po.Value.Id), cancellationToken).ConfigureAwait(true);
        Assert.Equal(PurchaseOrderStatus.PartiallyReceived, received.Value.Status);
        Assert.Equal(40m, received.Value.Lines[0].ReceivedQty);
        Assert.Equal(60m, received.Value.Lines[0].RemainingQty);
        Assert.Equal(40m, received.Value.ReceivedPct);

        var history = await dispatcher.QueryAsync(
            new ListPriceHistoryQuery(seed.ChickenId, seed.FastSupplierId, null, null, null, null, PageRequest.Default),
            cancellationToken).ConfigureAwait(true);
        var priceRow = Assert.Single(history.Value.Items);
        Assert.Equal(66m, priceRow.UnitPrice);
        Assert.Equal(66m, priceRow.UnitPriceBase);
        Assert.Null(priceRow.PrevPriceBase);
        Assert.Null(priceRow.DiffPct);
    }

    [Fact]
    public async Task A_second_receipt_at_a_new_price_records_the_difference_and_publishes_price_changed()
    {
        var cancellationToken = TestCancellation.Token;
        await fixture.ResetApprovalRulesAsync(cancellationToken).ConfigureAwait(true);
        var seed = await SeedAsync("PRICE", cancellationToken).ConfigureAwait(true);
        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        ActAsBuyer();
        await CreateRuleAsync(dispatcher, step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER", cancellationToken).ConfigureAwait(true);

        var first = await ReceiveOrderAsync(dispatcher, seed, unitPrice: 10m, DocDate, cancellationToken).ConfigureAwait(true);
        var second = await ReceiveOrderAsync(dispatcher, seed, unitPrice: 12.50m, DocDate.AddDays(1), cancellationToken).ConfigureAwait(true);

        Assert.NotEqual(first, second);

        var history = await dispatcher.QueryAsync(
            new ListPriceHistoryQuery(seed.ChickenId, seed.CheapSupplierId, null, null, null, null, PageRequest.Default),
            cancellationToken).ConfigureAwait(true);
        Assert.Equal(2, history.Value.Items.Count);

        var newest = history.Value.Items[0];
        Assert.Equal(12.50m, newest.UnitPriceBase);
        Assert.Equal(10m, newest.PrevPriceBase);
        Assert.Equal(2.50m, newest.DiffAmount);
        Assert.Equal(25m, newest.DiffPct);

        await using var procurement = fixture.Procurement();
        var published = await procurement.Outbox.AsNoTracking()
            .Where(o => o.EventType == "PriceChanged")
            .CountAsync(cancellationToken).ConfigureAwait(true);
        Assert.True(published >= 1, "PriceChanged must be enqueued when the price moves (TOR §25).");
    }

    [Fact]
    public async Task Small_orders_to_one_supplier_that_together_cross_a_band_raise_the_split_check()
    {
        var cancellationToken = TestCancellation.Token;
        await fixture.ResetApprovalRulesAsync(cancellationToken).ConfigureAwait(true);
        var seed = await SeedAsync("SPLIT", cancellationToken).ConfigureAwait(true);
        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        ActAsBuyer();
        await CreateRuleAsync(dispatcher, step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER", cancellationToken).ConfigureAwait(true);
        await CreateRuleAsync(dispatcher, step: 2, min: 5_000m, max: null, role: "ADMIN", cancellationToken).ConfigureAwait(true);

        // Four orders of 1 500 AZN each: the fourth takes the rolling window past 5 000.
        PurchaseOrderDetailDto? last = null;
        for (var i = 0; i < 4; i++)
        {
            var order = await dispatcher.SendAsync(
                new CreatePurchaseOrderCommand(
                    DocDate, seed.CheapSupplierId, "AZN", seed.WarehouseId, null, null, null, null, null,
                    [new PurchaseOrderLineInput(seed.ChickenId, 100m, seed.KilogramUomId, 15m, 0m, null)]),
                cancellationToken).ConfigureAwait(true);
            Assert.True(order.IsSuccess, Describe(order));
            Assert.Equal(1_500m, order.Value.TotalAmountBase);
            last = order.Value;
        }

        Assert.NotNull(last);
        Assert.NotNull(last!.SplitCheckWarning);
        Assert.Contains("PR bölünməsi şübhəsi", last.SplitCheckWarning!, StringComparison.Ordinal);

        await using var procurement = fixture.Procurement();
        var logs = await procurement.SplitCheckLogs.AsNoTracking()
            .Where(l => l.SupplierId == seed.CheapSupplierId)
            .ToListAsync(cancellationToken).ConfigureAwait(true);
        var log = Assert.Single(logs);
        Assert.Equal(6_000m, log.CumulativeAmountBase);
        Assert.Equal(1, log.StepsForSingle);
        Assert.Equal(2, log.StepsForCumulative);
        Assert.Equal(last.Id, log.TriggeredPoId);
    }

    [Fact]
    public async Task A_rejected_purchase_order_goes_back_to_draft_and_a_stale_row_version_is_refused()
    {
        var cancellationToken = TestCancellation.Token;
        await fixture.ResetApprovalRulesAsync(cancellationToken).ConfigureAwait(true);
        var seed = await SeedAsync("REJECT", cancellationToken).ConfigureAwait(true);
        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        ActAsBuyer();
        await CreateRuleAsync(dispatcher, step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER", cancellationToken).ConfigureAwait(true);

        var po = await dispatcher.SendAsync(
            new CreatePurchaseOrderCommand(
                DocDate, seed.CheapSupplierId, "AZN", seed.WarehouseId, null, null, null, null, null,
                [new PurchaseOrderLineInput(seed.ChickenId, 10m, seed.KilogramUomId, 50m, 0m, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(po.IsSuccess, Describe(po));

        var pending = await dispatcher.SendAsync(new SubmitPurchaseOrderCommand(po.Value.Id, po.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(pending.IsSuccess, Describe(pending));

        // An out-of-date rowVersion is 409 STALE_VERSION (spec §13.5).
        ActAsManager();
        var stale = await dispatcher.SendAsync(
            new ApprovePurchaseOrderCommand(po.Value.Id, po.Value.RowVersion, null), cancellationToken).ConfigureAwait(true);
        Assert.True(stale.IsFailure);
        Assert.Equal("STALE_VERSION", stale.Error.Code);
        Assert.Equal(409, stale.Error.Status);

        // Rejecting without a comment is 422.
        var noComment = await dispatcher.SendAsync(
            new RejectPurchaseOrderCommand(po.Value.Id, pending.Value.RowVersion, "  "), cancellationToken).ConfigureAwait(true);
        Assert.True(noComment.IsFailure);
        Assert.Equal(422, noComment.Error.Status);

        var rejected = await dispatcher.SendAsync(
            new RejectPurchaseOrderCommand(po.Value.Id, pending.Value.RowVersion, "Qiymət bazardan yüksəkdir"), cancellationToken).ConfigureAwait(true);
        Assert.True(rejected.IsSuccess, Describe(rejected));
        Assert.Equal(PurchaseOrderStatus.Rejected, rejected.Value.Status);

        // The buyer corrects it; the update brings the order back to DRAFT.
        ActAsBuyer();
        var corrected = await dispatcher.SendAsync(
            new UpdatePurchaseOrderCommand(
                po.Value.Id, rejected.Value.RowVersion, DocDate, seed.CheapSupplierId, "AZN", seed.WarehouseId,
                null, null, null, null, "Qiymət yenidən danışıldı",
                [new PurchaseOrderLineInput(seed.ChickenId, 10m, seed.KilogramUomId, 40m, 0m, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(corrected.IsSuccess, Describe(corrected));
        Assert.Equal(PurchaseOrderStatus.Draft, corrected.Value.Status);
        Assert.Equal(400m, corrected.Value.TotalAmountBase);
    }

    [Fact]
    public async Task A_food_order_to_an_unapproved_supplier_is_refused()
    {
        var cancellationToken = TestCancellation.Token;
        await fixture.ResetApprovalRulesAsync(cancellationToken).ConfigureAwait(true);
        var seed = await SeedAsync("FOODSUP", cancellationToken).ConfigureAwait(true);
        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        ActAsBuyer();
        var refused = await dispatcher.SendAsync(
            new CreatePurchaseOrderCommand(
                DocDate, seed.UnapprovedSupplierId, "AZN", seed.WarehouseId, null, null, null, null, null,
                [new PurchaseOrderLineInput(seed.ChickenId, 1m, seed.KilogramUomId, 10m, 0m, null)]),
            cancellationToken).ConfigureAwait(true);

        Assert.True(refused.IsFailure);
        Assert.Equal("SUPPLIER_NOT_APPROVED_FOR_FOOD", refused.Error.Code);
        Assert.Equal(422, refused.Error.Status);
    }

    [Fact]
    public async Task A_purchase_order_in_a_foreign_currency_without_a_rate_is_blocked()
    {
        var cancellationToken = TestCancellation.Token;
        await fixture.ResetApprovalRulesAsync(cancellationToken).ConfigureAwait(true);
        var seed = await SeedAsync("FX", cancellationToken).ConfigureAwait(true);
        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        ActAsBuyer();
        var blocked = await dispatcher.SendAsync(
            new CreatePurchaseOrderCommand(
                DocDate.AddYears(1), seed.CheapSupplierId, "EUR", seed.WarehouseId, null, null, null, null, null,
                [new PurchaseOrderLineInput(seed.ChickenId, 1m, seed.KilogramUomId, 10m, 0m, null)]),
            cancellationToken).ConfigureAwait(true);

        Assert.True(blocked.IsFailure);
        Assert.Equal("FX_RATE_MISSING", blocked.Error.Code);
        Assert.Equal(409, blocked.Error.Status);
    }

    [Fact]
    public async Task Pending_approvals_reach_the_role_holder_and_the_delegate_but_never_the_requester()
    {
        var cancellationToken = TestCancellation.Token;
        await fixture.ResetApprovalRulesAsync(cancellationToken).ConfigureAwait(true);
        var seed = await SeedAsync("PENDING", cancellationToken).ConfigureAwait(true);
        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        ActAsBuyer();
        await CreateRuleAsync(dispatcher, step: 1, min: 0m, max: null, role: "PROCUREMENT_MANAGER", cancellationToken).ConfigureAwait(true);

        var po = await dispatcher.SendAsync(
            new CreatePurchaseOrderCommand(
                DocDate, seed.CheapSupplierId, "AZN", seed.WarehouseId, null, null, null, null, null,
                [new PurchaseOrderLineInput(seed.ChickenId, 2m, seed.KilogramUomId, 25m, 0m, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(po.IsSuccess, Describe(po));
        var pending = await dispatcher.SendAsync(new SubmitPurchaseOrderCommand(po.Value.Id, po.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(pending.IsSuccess, Describe(pending));

        // The requester never sees their own document in the queue (spec §12.6).
        var mine = await dispatcher.QueryAsync(new ListPendingApprovalsQuery(null, PageRequest.Default), cancellationToken).ConfigureAwait(true);
        Assert.DoesNotContain(mine.Value.Items, i => i.DocId == po.Value.Id);

        ActAsManager();
        var theirs = await dispatcher.QueryAsync(new ListPendingApprovalsQuery(ApprovalDocType.Po, PageRequest.Default), cancellationToken).ConfigureAwait(true);
        var item = Assert.Single(theirs.Value.Items, i => i.DocId == po.Value.Id);
        Assert.Equal((byte)1, item.StepNo);
        Assert.Equal(50m, item.AmountBase);
        Assert.Equal(ProcurementFixture.TestBuyerId, item.RequestedBy.Id);

        // The generic decide endpoint moves the purchase order too.
        var decided = await dispatcher.SendAsync(
            new DecideApprovalCommand(item.ApprovalId, ApprovalDecision.Approved, "OK", ExpectedStepNo: 1), cancellationToken).ConfigureAwait(true);
        Assert.True(decided.IsSuccess, Describe(decided));
        Assert.Equal(ApprovalStatus.Approved, decided.Value.Status);

        var after = await dispatcher.QueryAsync(new GetPurchaseOrderQuery(po.Value.Id), cancellationToken).ConfigureAwait(true);
        Assert.Equal(PurchaseOrderStatus.Approved, after.Value.Status);

        // Deciding again from a stale screen is refused.
        var again = await dispatcher.SendAsync(
            new DecideApprovalCommand(item.ApprovalId, ApprovalDecision.Approved, "OK", 1), cancellationToken).ConfigureAwait(true);
        Assert.True(again.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", again.Error.Code);
    }

    // ---------------------------------------------------------------- helpers

    private void ActAsBuyer()
    {
        fixture.User.ActAs(ProcurementFixture.TestBuyerId, "PROCUREMENT_OFFICER");
        fixture.Directory.Reset();
        fixture.Directory.RolesByUser[ProcurementFixture.TestBuyerId] = ["PROCUREMENT_OFFICER"];
    }

    private void ActAsManager()
    {
        fixture.User.ActAs(ProcurementFixture.TestManagerId, "PROCUREMENT_MANAGER");
        fixture.Directory.Reset();
        fixture.Directory.RolesByUser[ProcurementFixture.TestManagerId] = ["PROCUREMENT_MANAGER"];
    }

    private void ActAsDeputyWithDelegationFromAdmin()
    {
        fixture.User.ActAs(ProcurementFixture.TestDeputyId, "BRANCH_USER");
        fixture.Directory.Reset();
        fixture.Directory.RolesByUser[ProcurementFixture.TestDeputyId] = ["BRANCH_USER"];
        fixture.Directory.Delegations.Add(
            new ActiveDelegation(ProcurementFixture.TestAdminId, ProcurementFixture.TestDeputyId, ["ADMIN"]));
    }

    private static async Task CreateRuleAsync(
        IDispatcher dispatcher,
        byte step,
        decimal min,
        decimal? max,
        string role,
        CancellationToken cancellationToken)
    {
        var created = await dispatcher.SendAsync(
            new CreateApprovalRuleCommand(ApprovalDocType.Po, ApprovalProductType.Any, min, max, step, (uint)(step + 100), role),
            cancellationToken).ConfigureAwait(true);
        Assert.True(created.IsSuccess, Describe(created));
    }

    private static async Task<QuotationDto> CreateQuotationAsync(
        IDispatcher dispatcher,
        long rfqId,
        Seed seed,
        uint supplierId,
        decimal unitPrice,
        ushort deliveryDays,
        CancellationToken cancellationToken)
    {
        var quotation = await dispatcher.SendAsync(
            new CreateQuotationCommand(
                rfqId, supplierId, $"Q-{supplierId}", DocDate, DocDate.AddDays(30), "AZN", deliveryDays, "30 gün",
                [new QuotationLineInput(seed.ChickenId, 100m, seed.KilogramUomId, unitPrice, null, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(quotation.IsSuccess, Describe(quotation));
        return quotation.Value;
    }

    /// <summary>Creates, approves, sends and receives one order; returns the purchase order id.</summary>
    private async Task<long> ReceiveOrderAsync(
        IDispatcher dispatcher,
        Seed seed,
        decimal unitPrice,
        DateOnly docDate,
        CancellationToken cancellationToken)
    {
        ActAsBuyer();
        var po = await dispatcher.SendAsync(
            new CreatePurchaseOrderCommand(
                docDate, seed.CheapSupplierId, "AZN", seed.WarehouseId, null, null, null, null, null,
                [new PurchaseOrderLineInput(seed.ChickenId, 10m, seed.KilogramUomId, unitPrice, 0m, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(po.IsSuccess, Describe(po));

        var pending = await dispatcher.SendAsync(new SubmitPurchaseOrderCommand(po.Value.Id, po.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(pending.IsSuccess, Describe(pending));

        ActAsManager();
        var approved = await dispatcher.SendAsync(
            new ApprovePurchaseOrderCommand(po.Value.Id, pending.Value.RowVersion, null), cancellationToken).ConfigureAwait(true);
        Assert.True(approved.IsSuccess, Describe(approved));

        ActAsBuyer();
        var sent = await dispatcher.SendAsync(new SendPurchaseOrderCommand(po.Value.Id, approved.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(sent.IsSuccess, Describe(sent));

        var receipt = await dispatcher.SendAsync(
            new RecordReceiptPricesCommand(po.Value.Id, po.Value.Id, docDate, [new ReceiptLineInput(sent.Value.Lines[0].Id, 10m)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(receipt.IsSuccess, Describe(receipt));
        return po.Value.Id;
    }

    private async Task<Seed> SeedAsync(string suffix, CancellationToken cancellationToken)
    {
        await using var master = fixture.MasterData();

        var kilogram = Uom.Create(TenantId, $"KG{suffix}", "kiloqram", UomClass.Mass, decimals: 4).Value;
        master.Uoms.Add(kilogram);

        var category = ProductCategory.Create(TenantId, $"FOOD{suffix}", "Qida", MasterData.Domain.Enums.ProductType.Food);
        master.Categories.Add(category);
        await master.SaveChangesAsync(cancellationToken).ConfigureAwait(true);

        var chicken = Product.Create(TenantId, $"CHK-{suffix}", "Toyuq", category.Id, kilogram.Id, new DateOnly(2026, 1, 1)).Value;
        master.Products.Add(chicken);

        var warehouse = Location.Create(TenantId, $"WH{suffix}", "Mərkəzi anbar", LocationType.CentralWarehouse).Value;
        var branch = Location.Create(TenantId, $"BR{suffix}", "Filial", LocationType.Restaurant).Value;
        master.Locations.AddRange(warehouse, branch);

        var cheap = Supplier.Create(TenantId, $"SUP-C-{suffix}", "Ucuz təchizatçı").Value;
        cheap.ApproveAsFoodSupplier();
        var fast = Supplier.Create(TenantId, $"SUP-F-{suffix}", "Sürətli təchizatçı").Value;
        fast.ApproveAsFoodSupplier();
        var unapproved = Supplier.Create(TenantId, $"SUP-U-{suffix}", "Təsdiqlənməmiş təchizatçı").Value;
        master.Suppliers.AddRange(cheap, fast, unapproved);

        await master.SaveChangesAsync(cancellationToken).ConfigureAwait(true);

        return new Seed(warehouse.Id, branch.Id, kilogram.Id, chicken.Id, cheap.Id, fast.Id, unapproved.Id);
    }

    private static string Describe<T>(Result<T> result) =>
        result.IsSuccess ? string.Empty : $"{result.Error.Code}: {result.Error.Message}";

    private sealed record Seed(
        uint WarehouseId,
        uint LocationId,
        ushort KilogramUomId,
        uint ChickenId,
        uint CheapSupplierId,
        uint FastSupplierId,
        uint UnapprovedSupplierId);
}
