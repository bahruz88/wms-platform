using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §12.6 and §12.7 — the inventory count aggregate: freeze, variance, approval, posting.</summary>
public sealed class StockCountTests
{
    private const uint Tenant = 1;
    private const uint Location = 10;
    private static readonly DateTimeOffset Now = new(2026, 9, 21, 8, 0, 0, TimeSpan.Zero);

    private static StockCount Draft(CountType type = CountType.Full, uint[]? products = null, uint[]? categories = null)
    {
        var count = StockCount.CreateDraft(Tenant, "IC-2026-00001", Location, type, categories ?? [], products ?? [], note: null);
        Assert.True(count.IsSuccess);
        return count.Value;
    }

    private static StockCount Frozen(params CountSnapshotRow[] snapshot)
    {
        var count = Draft();
        Assert.True(count.Freeze(snapshot, Now).IsSuccess);
        return count;
    }

    [Fact]
    public void A_spot_count_without_products_is_rejected()
    {
        var count = StockCount.CreateDraft(Tenant, "IC-1", Location, CountType.Spot, [], [], null);

        Assert.True(count.IsFailure);
        Assert.Equal("COUNT_SCOPE_REQUIRED", count.Error.Code);
        Assert.Equal(422, count.Error.Status);
    }

    [Fact]
    public void A_cycle_count_accepts_a_category_scope_alone()
    {
        var count = StockCount.CreateDraft(Tenant, "IC-1", Location, CountType.Cycle, [7u], [], null);

        Assert.True(count.IsSuccess);
        Assert.Equal([7u], count.Value.ScopeCategories());
        Assert.Empty(count.Value.ScopeProducts());
    }

    [Fact]
    public void Freeze_writes_book_qty_at_that_instant_and_blocks_the_location()
    {
        var count = Frozen(
            new CountSnapshotRow(2, 0, 40m, 1.5m),
            new CountSnapshotRow(1, 5, 12.5m, 3m));

        Assert.Equal(CountStatus.Frozen, count.Status);
        Assert.Equal(Now, count.FrozenAt);
        Assert.True(count.IsFreezing);

        // Ordered by product then batch, and book_qty is the balance as it stood at the freeze.
        Assert.Collection(
            count.Lines,
            line =>
            {
                Assert.Equal(1u, line.ProductId);
                Assert.Equal(5L, line.BatchId);
                Assert.Equal(12.5m, line.BookQty);
            },
            line =>
            {
                Assert.Equal(2u, line.ProductId);
                Assert.Null(line.BatchId);
                Assert.Equal(40m, line.BookQty);
            });
    }

    [Fact]
    public void Freezing_twice_is_rejected()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 10m, 0m));

        var again = count.Freeze([], Now);

        Assert.True(again.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", again.Error.Code);
        Assert.Equal(409, again.Error.Status);
    }

    [Fact]
    public void Counting_a_line_derives_the_variance_and_moves_the_document_to_counting()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 2m));

        var result = count.CountLine(1, null, 90m, reasonCodeId: 4, note: "spillage", countedBy: 7, Now);

        Assert.True(result.IsSuccess);
        Assert.Equal(CountStatus.Counting, count.Status);
        var line = count.Lines[0];
        Assert.Equal(90m, line.CountedQty);
        Assert.Equal(-10m, line.VarianceQty);
        Assert.Equal(-10m, line.VariancePct);
        Assert.Equal((ushort)4, line.ReasonCodeId);
        Assert.Equal(7u, line.CountedBy);
    }

    [Fact]
    public void A_non_zero_variance_without_a_reason_code_is_rejected()
    {
        // Spec §12.6: this is the rule that makes the Excel "+510" impossible.
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));

        var result = count.CountLine(1, null, 105m, reasonCodeId: null, note: null, countedBy: 7, Now);

        Assert.True(result.IsFailure);
        Assert.Equal("REASON_CODE_REQUIRED", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Fact]
    public void A_line_that_matches_the_book_needs_no_reason_code()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));

        var result = count.CountLine(1, null, 100m, reasonCodeId: null, note: null, countedBy: 7, Now);

        Assert.True(result.IsSuccess);
        Assert.Equal(0m, count.Lines[0].VarianceQty);
        Assert.Null(count.Lines[0].ReasonCodeId);
    }

    [Fact]
    public void Counting_the_same_product_twice_upserts_rather_than_duplicating()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));

        Assert.True(count.CountLine(1, null, 95m, 4, "first pass", 7, Now).IsSuccess);
        Assert.True(count.CountLine(1, null, 98m, 4, "recount", 7, Now).IsSuccess);

        Assert.Single(count.Lines);
        Assert.Equal(98m, count.Lines[0].CountedQty);
        Assert.Equal(-2m, count.Lines[0].VarianceQty);
    }

    [Fact]
    public void A_product_found_that_was_not_in_the_snapshot_is_added_with_a_zero_book_qty()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));

        Assert.True(count.CountLine(9, null, 4m, reasonCodeId: 4, note: "found on shelf", countedBy: 7, Now).IsSuccess);

        var added = count.Lines.Single(l => l.ProductId == 9);
        Assert.Equal(0m, added.BookQty);
        Assert.Equal(4m, added.VarianceQty);
        Assert.Equal(100m, added.VariancePct);
    }

    [Fact]
    public void Submit_requires_every_line_to_be_counted()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 10m, 0m), new CountSnapshotRow(2, 0, 20m, 0m));
        Assert.True(count.CountLine(1, null, 10m, null, null, 7, Now).IsSuccess);

        var submitted = count.Submit(approvalThresholdPct: 2m);

        Assert.True(submitted.IsFailure);
        Assert.Equal("COUNT_LINES_INCOMPLETE", submitted.Error.Code);
        Assert.Equal(422, submitted.Error.Status);
    }

    [Theory]
    [InlineData(100, 99, 2, false)]   // 1 % variance, threshold 2 % → no approval needed
    [InlineData(100, 97, 2, true)]    // 3 % variance → beyond the threshold
    [InlineData(100, 98, 2, false)]   // exactly 2 % → "greater than", so still inside
    [InlineData(100, 103, 2, true)]   // a surplus counts just as much as a shortage
    public void Submit_flags_approval_only_beyond_the_threshold(decimal book, decimal counted, decimal thresholdPct, bool expected)
    {
        var count = Frozen(new CountSnapshotRow(1, 0, book, 0m));
        Assert.True(count.CountLine(1, null, counted, reasonCodeId: 4, note: "n", countedBy: 7, Now).IsSuccess);

        Assert.True(count.Submit(thresholdPct).IsSuccess);

        Assert.Equal(CountStatus.Review, count.Status);
        Assert.Equal(expected, count.RequiresApproval);
    }

    [Fact]
    public void Approve_then_post_releases_the_location_and_records_the_adjust_group()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 2m));
        Assert.True(count.CountLine(1, null, 95m, 4, "n", 7, Now).IsSuccess);
        Assert.True(count.Submit(2m).IsSuccess);

        Assert.True(count.Approve(approvedBy: 9, approvedAt: Now).IsSuccess);
        Assert.Equal(CountStatus.Approved, count.Status);
        Assert.True(count.IsFreezing);

        Assert.True(count.MarkPosted(adjustGroupId: 555).IsSuccess);
        Assert.Equal(CountStatus.Posted, count.Status);
        Assert.Equal(555L, count.AdjustGroupId);
        Assert.False(count.IsFreezing);
    }

    [Fact]
    public void Posting_before_approval_is_rejected()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));
        Assert.True(count.CountLine(1, null, 100m, null, null, 7, Now).IsSuccess);
        Assert.True(count.Submit(2m).IsSuccess);

        var posted = count.MarkPosted(1);

        Assert.True(posted.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", posted.Error.Code);
    }

    [Fact]
    public void Rejecting_a_review_sends_it_back_for_a_recount()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));
        Assert.True(count.CountLine(1, null, 90m, 4, "n", 7, Now).IsSuccess);
        Assert.True(count.Submit(2m).IsSuccess);

        Assert.True(count.Reject().IsSuccess);

        Assert.Equal(CountStatus.Counting, count.Status);
        Assert.True(count.IsFreezing);
    }

    [Fact]
    public void Cancelling_lifts_the_freeze_without_touching_the_ledger()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));

        Assert.True(count.Cancel("miscounted shelf").IsSuccess);

        Assert.Equal(CountStatus.Cancelled, count.Status);
        Assert.False(count.IsFreezing);
        Assert.Null(count.AdjustGroupId);
    }

    [Fact]
    public void A_posted_count_cannot_be_cancelled()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));
        Assert.True(count.CountLine(1, null, 100m, null, null, 7, Now).IsSuccess);
        Assert.True(count.Submit(2m).IsSuccess);
        Assert.True(count.Approve(9, Now).IsSuccess);
        Assert.True(count.MarkPosted(null).IsSuccess);

        var cancelled = count.Cancel(null);

        Assert.True(cancelled.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", cancelled.Error.Code);
    }

    [Theory]
    [InlineData(100, 10, 10)]
    [InlineData(100, -10, -10)]
    [InlineData(0, 5, 100)]       // nothing on the books, something on the shelf
    [InlineData(0, -5, -100)]
    [InlineData(100, 0, 0)]
    [InlineData(30, 1, 3.3333)]   // DECIMAL(9,4), away from zero
    public void Variance_percent_follows_the_decimal_9_4_contract(decimal book, decimal variance, decimal expected) =>
        Assert.Equal(expected, StockCountLine.VariancePercent(book, variance));

    [Fact]
    public void Freezing_statuses_are_exactly_the_ones_that_block_a_location()
    {
        // Spec §12.7: the block starts at FROZEN and is only lifted by POSTED or CANCELLED.
        Assert.Equal(
            [CountStatus.Frozen, CountStatus.Counting, CountStatus.Review, CountStatus.Approved],
            StockCount.FreezingStatuses);
        Assert.DoesNotContain(CountStatus.Posted, StockCount.FreezingStatuses);
        Assert.DoesNotContain(CountStatus.Cancelled, StockCount.FreezingStatuses);
        Assert.DoesNotContain(CountStatus.Draft, StockCount.FreezingStatuses);
    }

    [Fact]
    public void Open_statuses_keep_a_second_count_off_the_same_location()
    {
        Assert.Contains(CountStatus.Draft, StockCount.OpenStatuses);
        Assert.DoesNotContain(CountStatus.Posted, StockCount.OpenStatuses);
        Assert.DoesNotContain(CountStatus.Cancelled, StockCount.OpenStatuses);
    }

    [Fact]
    public void A_negative_counted_quantity_is_rejected()
    {
        var count = Frozen(new CountSnapshotRow(1, 0, 100m, 0m));

        var result = count.CountLine(1, null, -1m, 4, "n", 7, Now);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_QUANTITY", result.Error.Code);
    }

    [Fact]
    public void Lines_cannot_be_counted_before_the_freeze()
    {
        var count = Draft();

        var result = count.CountLine(1, null, 10m, null, null, 7, Now);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", result.Error.Code);
    }
}
