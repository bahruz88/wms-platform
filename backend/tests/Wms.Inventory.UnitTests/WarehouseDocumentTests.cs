using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>Issue / transfer (spec §12.3): the two-step IN_TRANSIT mechanism and its discrepancy rules.</summary>
public sealed class IssueTests
{
    private const uint Tenant = 1;
    private static readonly DateOnly DocDate = new(2026, 9, 21);
    private static readonly DateTimeOffset Now = new(2026, 9, 21, 8, 0, 0, TimeSpan.Zero);

    private static Issue Draft(params IssueLineInput[] lines)
    {
        var issue = Issue.CreateDraft(Tenant, "IS-2026-00001", DocDate, IssueType.BranchIssue, 10, 20, null, null);
        Assert.True(issue.IsSuccess);
        Assert.True(issue.Value.ReplaceLines(lines.Length == 0 ? [new IssueLineInput(1, 10m, 3)] : lines).IsSuccess);
        return issue.Value;
    }

    private static Issue Dispatched(params IssueLineInput[] lines)
    {
        var issue = Draft(lines);
        AssignLineIds(issue);
        Assert.True(issue.MarkDispatched(dispatchGroupId: 100, Now).IsSuccess);
        return issue;
    }

    /// <summary>EF assigns line ids on insert; in a pure unit test we stand in for it via the recorded dispatch.</summary>
    private static void AssignLineIds(Issue issue)
    {
        var results = issue.Lines
            .Select((line, index) => new PostedLineResult(line.Id, line.Qty, line.BatchId, line.BatchId, 1m))
            .ToList();
        Assert.True(issue.RecordDispatch(results).IsSuccess);
    }

    [Fact]
    public void Source_and_target_must_differ()
    {
        var issue = Issue.CreateDraft(Tenant, "IS-1", DocDate, IssueType.WhTransfer, 10, 10, null, null);

        Assert.True(issue.IsFailure);
        Assert.Equal("SAME_LOCATION", issue.Error.Code);
        Assert.Equal(422, issue.Error.Status);
    }

    [Fact]
    public void Dispatch_moves_the_document_to_dispatched()
    {
        var issue = Dispatched();

        Assert.Equal(IssueStatus.Dispatched, issue.Status);
        Assert.Equal(100L, issue.DispatchGroupId);
        Assert.Equal(Now, issue.DispatchedAt);
    }

    [Fact]
    public void An_empty_issue_cannot_be_dispatched()
    {
        var issue = Issue.CreateDraft(Tenant, "IS-1", DocDate, IssueType.BranchIssue, 10, 20, null, null).Value;

        var dispatched = issue.MarkDispatched(1, Now);

        Assert.True(dispatched.IsFailure);
        Assert.Equal("INVALID_DOCUMENT", dispatched.Error.Code);
    }

    [Fact]
    public void Dispatching_twice_is_rejected()
    {
        var issue = Dispatched();

        var again = issue.MarkDispatched(101, Now);

        Assert.True(again.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", again.Error.Code);
        Assert.Equal(409, again.Error.Status);
    }

    [Fact]
    public void A_clean_confirmation_lands_in_received()
    {
        var issue = Dispatched();
        var lineId = issue.Lines[0].Id;

        var confirmed = issue.ConfirmReceipt([new IssueReceiptInput(lineId, 10m, null, null)], receivedBy: 5, Now);

        Assert.True(confirmed.IsSuccess);
        Assert.Equal(IssueStatus.Received, issue.Status);
        Assert.False(issue.HasDiscrepancy);
        Assert.Equal(0m, issue.Lines[0].DiscrepancyQty);
        Assert.Equal(5u, issue.ReceivedBy);
    }

    [Fact]
    public void A_short_delivery_needs_a_reason_and_a_note()
    {
        var issue = Dispatched();
        var lineId = issue.Lines[0].Id;

        var confirmed = issue.ConfirmReceipt([new IssueReceiptInput(lineId, 8m, null, null)], 5, Now);

        Assert.True(confirmed.IsFailure);
        Assert.Equal("DISCREPANCY_REASON_REQUIRED", confirmed.Error.Code);
        Assert.Equal(422, confirmed.Error.Status);
    }

    [Fact]
    public void An_explained_short_delivery_lands_in_discrepancy()
    {
        // The two missing units stay in IN_TRANSIT on purpose: a visible loss, not a silent one.
        var issue = Dispatched();
        var lineId = issue.Lines[0].Id;

        var confirmed = issue.ConfirmReceipt([new IssueReceiptInput(lineId, 8m, 12, "two crates broken")], 5, Now);

        Assert.True(confirmed.IsSuccess);
        Assert.Equal(IssueStatus.Discrepancy, issue.Status);
        Assert.True(issue.HasDiscrepancy);
        Assert.Equal(2m, issue.Lines[0].DiscrepancyQty);
        Assert.Equal((ushort)12, issue.Lines[0].DiscrepancyReasonCodeId);
    }

    [Fact]
    public void A_branch_cannot_confirm_more_than_was_sent()
    {
        var issue = Dispatched();
        var lineId = issue.Lines[0].Id;

        var confirmed = issue.ConfirmReceipt([new IssueReceiptInput(lineId, 11m, 12, "extra")], 5, Now);

        Assert.True(confirmed.IsFailure);
        Assert.Equal("INVALID_QUANTITY", confirmed.Error.Code);
    }

    [Fact]
    public void Every_dispatched_line_must_be_confirmed()
    {
        var issue = Dispatched(new IssueLineInput(1, 10m, 3), new IssueLineInput(2, 5m, 3));
        var firstLineId = issue.Lines[0].Id;

        var confirmed = issue.ConfirmReceipt([new IssueReceiptInput(firstLineId, 10m, null, null)], 5, Now);

        Assert.True(confirmed.IsFailure);
        Assert.Equal("ISSUE_LINES_UNCONFIRMED", confirmed.Error.Code);
    }

    [Fact]
    public void Confirming_a_line_from_another_document_is_rejected()
    {
        var issue = Dispatched();

        var confirmed = issue.ConfirmReceipt([new IssueReceiptInput(9999, 1m, null, null)], 5, Now);

        Assert.True(confirmed.IsFailure);
        Assert.Equal("ISSUE_LINE_NOT_FOUND", confirmed.Error.Code);
    }

    [Fact]
    public void Confirmation_before_dispatch_is_rejected()
    {
        var issue = Draft();

        var confirmed = issue.ConfirmReceipt([new IssueReceiptInput(1, 1m, null, null)], 5, Now);

        Assert.True(confirmed.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", confirmed.Error.Code);
    }

    [Fact]
    public void A_batch_picked_against_the_suggestion_needs_a_reason_code()
    {
        // Spec §12.4: overriding FEFO/FIFO is allowed, but it has to be explained.
        var issue = Draft(new IssueLineInput(1, 10m, 3, BatchId: 77));

        var recorded = issue.RecordDispatch([new PostedLineResult(issue.Lines[0].Id, 10m, 77, SuggestedBatchId: 42, UnitCost: 1m)]);

        Assert.True(recorded.IsFailure);
        Assert.Equal("BATCH_OVERRIDE_REASON_REQUIRED", recorded.Error.Code);
        Assert.Equal(422, recorded.Error.Status);
    }

    [Fact]
    public void An_explained_batch_override_is_accepted()
    {
        var issue = Draft(new IssueLineInput(1, 10m, 3, BatchId: 77, BatchOverrideReasonCodeId: 31, BatchOverrideNote: "customer request"));

        var recorded = issue.RecordDispatch([new PostedLineResult(issue.Lines[0].Id, 10m, 77, SuggestedBatchId: 42, UnitCost: 1m)]);

        Assert.True(recorded.IsSuccess);
        Assert.Equal(42L, issue.Lines[0].SuggestedBatchId);
        Assert.Equal(77L, issue.Lines[0].BatchId);
    }

    [Fact]
    public void Taking_the_suggested_batch_needs_no_reason_code()
    {
        var issue = Draft(new IssueLineInput(1, 10m, 3, BatchId: 42));

        var recorded = issue.RecordDispatch([new PostedLineResult(issue.Lines[0].Id, 10m, 42, SuggestedBatchId: 42, UnitCost: 1m)]);

        Assert.True(recorded.IsSuccess);
    }

    [Fact]
    public void Only_a_draft_issue_can_be_cancelled()
    {
        Assert.True(Draft().Cancel().IsSuccess);

        var dispatched = Dispatched();
        var cancelled = dispatched.Cancel();

        Assert.True(cancelled.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", cancelled.Error.Code);
    }
}

/// <summary>Waste (TOR §22): draft → approval → ledger, and the transitions that are refused.</summary>
public sealed class WasteTests
{
    private const uint Tenant = 1;
    private static readonly DateOnly DocDate = new(2026, 9, 21);
    private static readonly DateTimeOffset Now = new(2026, 9, 21, 8, 0, 0, TimeSpan.Zero);

    private static Waste Draft()
    {
        var waste = Waste.CreateDraft(Tenant, "WS-2026-00001", DocDate, locationId: 10, reasonCodeId: 5, note: null);
        Assert.True(waste.IsSuccess);
        Assert.True(waste.Value.ReplaceLines([new StockOutLineInput(1, 3m, 3)]).IsSuccess);
        return waste.Value;
    }

    [Fact]
    public void A_waste_document_needs_a_location_and_a_reason_code()
    {
        var waste = Waste.CreateDraft(Tenant, "WS-1", DocDate, locationId: 0, reasonCodeId: 5, note: null);

        Assert.True(waste.IsFailure);
        Assert.Equal("INVALID_DOCUMENT", waste.Error.Code);
    }

    [Fact]
    public void The_happy_path_runs_draft_to_posted()
    {
        var waste = Draft();

        Assert.True(waste.Submit().IsSuccess);
        Assert.Equal(WasteStatus.PendingApproval, waste.Status);

        Assert.True(waste.Approve(approvedBy: 9, Now, "agreed").IsSuccess);
        Assert.Equal(WasteStatus.Approved, waste.Status);
        Assert.Equal(9u, waste.ApprovedBy);

        Assert.True(waste.MarkPosted(movementGroupId: 300).IsSuccess);
        Assert.Equal(WasteStatus.Posted, waste.Status);
        Assert.Equal(300L, waste.MovementGroupId);
    }

    [Fact]
    public void An_unapproved_waste_cannot_be_posted()
    {
        var waste = Draft();
        Assert.True(waste.Submit().IsSuccess);

        var posted = waste.MarkPosted(1);

        Assert.True(posted.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", posted.Error.Code);
        Assert.Equal(409, posted.Error.Status);
    }

    [Fact]
    public void A_rejected_waste_can_be_corrected_and_resubmitted()
    {
        var waste = Draft();
        Assert.True(waste.Submit().IsSuccess);
        Assert.True(waste.Reject(9, Now, "photo missing").IsSuccess);
        Assert.Equal(WasteStatus.Rejected, waste.Status);

        Assert.True(waste.Submit().IsSuccess);
        Assert.Equal(WasteStatus.PendingApproval, waste.Status);
    }

    [Fact]
    public void Lines_cannot_be_replaced_once_the_document_left_draft()
    {
        var waste = Draft();
        Assert.True(waste.Submit().IsSuccess);

        var replaced = waste.ReplaceLines([new StockOutLineInput(2, 1m, 3)]);

        Assert.True(replaced.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", replaced.Error.Code);
    }

    [Fact]
    public void Posting_records_the_base_quantity_and_the_batch_the_ledger_took()
    {
        var waste = Draft();
        Assert.True(waste.Submit().IsSuccess);
        Assert.True(waste.Approve(9, Now, null).IsSuccess);

        waste.RecordPostedLines([new PostedLineResult(waste.Lines[0].Id, 3000m, BatchId: 12, SuggestedBatchId: 12, UnitCost: 0.004m)]);

        Assert.Equal(3000m, waste.Lines[0].QtyBase);
        Assert.Equal(12L, waste.Lines[0].BatchId);
        Assert.Equal(0.004m, waste.Lines[0].UnitCost);
    }
}

/// <summary>Sample (TOR §23) and return to vendor: the two remaining stock-out documents.</summary>
public sealed class SampleAndReturnTests
{
    private const uint Tenant = 1;
    private static readonly DateOnly DocDate = new(2026, 9, 21);

    [Fact]
    public void A_sample_defaults_to_the_food_safety_authority()
    {
        var sample = Sample.CreateDraft(Tenant, "SM-1", DocDate, 10, authority: null, purpose: null, reasonCodeId: null);

        Assert.True(sample.IsSuccess);
        Assert.Equal("AQTA", sample.Value.Authority);
        Assert.Equal(SimpleDocStatus.Draft, sample.Value.Status);
    }

    [Fact]
    public void A_sample_status_is_derived_from_the_movement_group()
    {
        var sample = Sample.CreateDraft(Tenant, "SM-1", DocDate, 10, null, null, null).Value;
        Assert.True(sample.ReplaceLines([new StockOutLineInput(1, 2m, 3)]).IsSuccess);

        Assert.True(sample.MarkPosted(400).IsSuccess);

        Assert.Equal(SimpleDocStatus.Posted, sample.Status);
        Assert.Equal(400L, sample.MovementGroupId);
    }

    [Fact]
    public void A_posted_sample_cannot_be_posted_again()
    {
        var sample = Sample.CreateDraft(Tenant, "SM-1", DocDate, 10, null, null, null).Value;
        Assert.True(sample.ReplaceLines([new StockOutLineInput(1, 2m, 3)]).IsSuccess);
        Assert.True(sample.MarkPosted(400).IsSuccess);

        var again = sample.MarkPosted(401);

        Assert.True(again.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", again.Error.Code);
    }

    [Fact]
    public void A_return_runs_draft_to_sent_to_closed()
    {
        var document = ReturnToVendor.CreateDraft(Tenant, "RV-1", DocDate, supplierId: 4, locationId: 10, receiptId: null, reasonCodeId: 8, claimAmount: 120m, note: null);
        Assert.True(document.IsSuccess);
        Assert.True(document.Value.ReplaceLines([new StockOutLineInput(1, 5m, 3)]).IsSuccess);

        Assert.True(document.Value.MarkSent(movementGroupId: 500).IsSuccess);
        Assert.Equal(RtvStatus.Sent, document.Value.Status);

        Assert.True(document.Value.Close("ACCEPTED", claimAmount: 100m, outcomeNote: "credit note issued").IsSuccess);
        Assert.Equal(RtvStatus.Closed, document.Value.Status);
        Assert.Equal("ACCEPTED", document.Value.Outcome);
        Assert.Equal(100m, document.Value.ClaimAmount);
    }

    [Fact]
    public void A_return_cannot_be_closed_before_it_is_sent()
    {
        var document = ReturnToVendor.CreateDraft(Tenant, "RV-1", DocDate, 4, 10, null, 8, null, null).Value;

        var closed = document.Close("ACCEPTED", null, null);

        Assert.True(closed.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", closed.Error.Code);
    }

    [Fact]
    public void An_unknown_outcome_is_rejected()
    {
        var document = ReturnToVendor.CreateDraft(Tenant, "RV-1", DocDate, 4, 10, null, 8, null, null).Value;
        Assert.True(document.ReplaceLines([new StockOutLineInput(1, 5m, 3)]).IsSuccess);
        Assert.True(document.MarkSent(500).IsSuccess);

        var closed = document.Close("MAYBE", null, null);

        Assert.True(closed.IsFailure);
        Assert.Equal("INVALID_DOCUMENT", closed.Error.Code);
    }
}

/// <summary>Stock request (TOR §16): the branch asks, the warehouse answers with issues.</summary>
public sealed class StockRequestTests
{
    private const uint Tenant = 1;
    private static readonly DateOnly DocDate = new(2026, 9, 21);

    private static StockRequest Draft()
    {
        var request = StockRequest.CreateDraft(Tenant, "SR-2026-00001", DocDate, fromLocationId: 10, toLocationId: 20, requiredDate: null, note: null);
        Assert.True(request.IsSuccess);
        Assert.True(request.Value.ReplaceLines([(1u, 10m, (ushort)3, null), (2u, 5m, (ushort)3, null)]).IsSuccess);
        return request.Value;
    }

    [Fact]
    public void A_request_cannot_point_at_its_own_location()
    {
        var request = StockRequest.CreateDraft(Tenant, "SR-1", DocDate, 10, 10, null, null);

        Assert.True(request.IsFailure);
        Assert.Equal("SAME_LOCATION", request.Error.Code);
    }

    [Fact]
    public void Submitting_puts_the_request_in_the_warehouse_queue()
    {
        var request = Draft();

        Assert.True(request.Submit().IsSuccess);

        Assert.Equal(StockRequestStatus.Submitted, request.Status);
    }

    [Fact]
    public void A_partially_served_request_reports_partially_issued()
    {
        var request = Draft();
        Assert.True(request.Submit().IsSuccess);

        request.RecordIssued(new Dictionary<ushort, decimal> { [request.Lines[0].LineNo] = 10m });

        Assert.Equal(StockRequestStatus.PartiallyIssued, request.Status);
        Assert.Equal(10m, request.Lines[0].IssuedQty);
        Assert.Equal(0m, request.Lines[1].IssuedQty);
    }

    [Fact]
    public void A_fully_served_request_reports_issued()
    {
        var request = Draft();
        Assert.True(request.Submit().IsSuccess);

        request.RecordIssued(new Dictionary<ushort, decimal>
        {
            [request.Lines[0].LineNo] = 10m,
            [request.Lines[1].LineNo] = 5m,
        });

        Assert.Equal(StockRequestStatus.Issued, request.Status);
    }

    [Fact]
    public void Lines_cannot_be_changed_after_submission()
    {
        var request = Draft();
        Assert.True(request.Submit().IsSuccess);

        var replaced = request.ReplaceLines([(1u, 1m, (ushort)3, null)]);

        Assert.True(replaced.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", replaced.Error.Code);
    }
}
