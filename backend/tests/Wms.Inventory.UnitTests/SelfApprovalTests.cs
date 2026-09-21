using Wms.Common.Application.Auditing;
using Wms.Inventory.Application.Commands.Counts;
using Wms.Inventory.Application.Commands.Waste;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>
/// Spec §12.6 / §7.1, TOR §21 — segregation of duties on approvals.
/// </summary>
/// <remarks>
/// The count handler already carried the rule but guarded it with <c>currentUser.UserId != 0</c>, and the
/// Keycloak token carried no internal identifier, so <c>UserId</c> was always 0 and the control silently
/// disabled itself in production. The waste document had no rule at all. These tests pin both, plus the
/// fail-closed behaviour when the caller cannot be resolved to an <c>iam_user</c> row.
/// </remarks>
public sealed class SelfApprovalTests
{
    private const uint Tenant = 1;
    private const uint Keeper = 42;
    private const uint Manager = 7;

    // ================================================================ counts

    [Fact]
    public async Task A_user_cannot_approve_a_count_they_entered()
    {
        var count = ReviewedCount(countedBy: Keeper, createdBy: Manager);
        var result = await ApproveCountAsync(count, approver: Keeper);

        Assert.True(result.IsFailure);
        Assert.Equal("SELF_APPROVAL_FORBIDDEN", result.Error.Code);
        Assert.Equal(403, result.Error.Status);
        Assert.Equal(CountStatus.Review, count.Status);
    }

    [Fact]
    public async Task A_user_cannot_approve_a_count_they_created()
    {
        var count = ReviewedCount(countedBy: Manager, createdBy: Keeper);
        var result = await ApproveCountAsync(count, approver: Keeper);

        Assert.True(result.IsFailure);
        Assert.Equal("SELF_APPROVAL_FORBIDDEN", result.Error.Code);
    }

    [Fact]
    public async Task Somebody_else_can_approve_the_count()
    {
        var count = ReviewedCount(countedBy: Keeper, createdBy: Keeper);
        var unitOfWork = new FakeInventoryUnitOfWork();
        var result = await ApproveCountAsync(count, approver: Manager, unitOfWork);

        Assert.True(result.IsSuccess);
        Assert.Equal(CountStatus.Approved, count.Status);
        Assert.Equal(Manager, count.ApprovedBy);
        Assert.Contains(unitOfWork.AuditTrail.Entries, e => e.EntityType == "inv_count" && e.Action == AuditAction.Approve);
    }

    [Fact]
    public async Task An_unresolved_principal_cannot_approve_a_count()
    {
        // Fail closed: with UserId = 0 the rule cannot be evaluated, so the approval is refused outright
        // instead of being waved through as it used to be.
        var count = ReviewedCount(countedBy: Keeper, createdBy: Keeper);
        var result = await ApproveCountAsync(count, approver: 0);

        Assert.True(result.IsFailure);
        Assert.Equal("APPROVER_UNKNOWN", result.Error.Code);
        Assert.Equal(CountStatus.Review, count.Status);
    }

    [Fact]
    public async Task Rejecting_your_own_count_is_allowed()
    {
        // Only approval is a segregation-of-duties decision; sending your own sheet back for a recount is not.
        var count = ReviewedCount(countedBy: Keeper, createdBy: Keeper);
        var result = await ApproveCountAsync(count, approver: Keeper, approved: false, comment: "yenidən say");

        Assert.True(result.IsSuccess);
        Assert.Equal(CountStatus.Counting, count.Status);
    }

    // ================================================================ waste

    [Fact]
    public async Task A_user_cannot_approve_a_waste_document_they_raised()
    {
        var waste = SubmittedWaste(createdBy: Keeper);
        var result = await ApproveWasteAsync(waste, approver: Keeper);

        Assert.True(result.IsFailure);
        Assert.Equal("SELF_APPROVAL_FORBIDDEN", result.Error.Code);
        Assert.Equal(403, result.Error.Status);
        Assert.Equal(WasteStatus.PendingApproval, waste.Status);
    }

    [Fact]
    public async Task Somebody_else_can_approve_the_waste_document()
    {
        var waste = SubmittedWaste(createdBy: Keeper);
        var unitOfWork = new FakeInventoryUnitOfWork();
        var result = await ApproveWasteAsync(waste, approver: Manager, unitOfWork);

        Assert.True(result.IsSuccess);
        Assert.Equal(WasteStatus.Approved, waste.Status);
        Assert.Equal(Manager, waste.ApprovedBy);
        Assert.Contains(unitOfWork.AuditTrail.Entries, e => e.EntityType == "inv_waste" && e.Action == AuditAction.Approve);
    }

    [Fact]
    public async Task An_unresolved_principal_cannot_approve_a_waste_document()
    {
        var waste = SubmittedWaste(createdBy: Keeper);
        var result = await ApproveWasteAsync(waste, approver: 0);

        Assert.True(result.IsFailure);
        Assert.Equal("APPROVER_UNKNOWN", result.Error.Code);
    }

    // ================================================================ builders

    private static StockCount ReviewedCount(uint countedBy, uint createdBy)
    {
        var count = StockCount.CreateDraft(Tenant, "CT-2026-00001", locationId: 10, CountType.Full, [], [], null).Value;
        count.MarkCreated(new DateTimeOffset(2026, 9, 20, 6, 0, 0, TimeSpan.Zero), createdBy);
        count.Freeze([new CountSnapshotRow(ProductId: 1, BatchId: StockCountLine.NoBatch, QtyOnHand: 100m, AvgUnitCost: 2m)], DateTimeOffset.UtcNow);
        count.CountLine(productId: 1, batchId: null, countedQtyBase: 98m, reasonCodeId: 1, note: null, countedBy: countedBy, now: DateTimeOffset.UtcNow);
        count.Submit(approvalThresholdPct: 2m);
        return count;
    }

    private static Waste SubmittedWaste(uint createdBy)
    {
        var waste = Waste.CreateDraft(Tenant, "WS-2026-00001", new DateOnly(2026, 9, 20), locationId: 10, reasonCodeId: 5, note: null).Value;
        waste.MarkCreated(new DateTimeOffset(2026, 9, 20, 6, 0, 0, TimeSpan.Zero), createdBy);
        waste.ReplaceLines([new StockOutLineInput(ProductId: 1, Qty: 2m, UomId: 1)]);
        waste.Submit();
        return waste;
    }

    private static Task<Wms.Common.Domain.Result<long>> ApproveCountAsync(
        StockCount count,
        uint approver,
        FakeInventoryUnitOfWork? unitOfWork = null,
        bool approved = true,
        string? comment = null)
    {
        var handler = new ApproveCountCommandHandler(
            unitOfWork ?? new FakeInventoryUnitOfWork(),
            new FakeStockCountRepository(count),
            new FakeTenantContext(Tenant),
            new FakeCurrentUser(approver),
            new FakeClock());
        return handler.HandleAsync(new ApproveCountCommand(count.Id, count.RowVersion, approved, comment), CancellationToken.None);
    }

    private static Task<Wms.Common.Domain.Result<long>> ApproveWasteAsync(
        Waste waste,
        uint approver,
        FakeInventoryUnitOfWork? unitOfWork = null)
    {
        var handler = new WasteStateHandler(
            unitOfWork ?? new FakeInventoryUnitOfWork(),
            new FakeWasteRepository(waste),
            new FakeTenantContext(Tenant),
            new FakeCurrentUser(approver),
            new FakeClock());
        return handler.HandleAsync(new ApproveWasteCommand(waste.Id, waste.RowVersion, Approved: true, Comment: null), CancellationToken.None);
    }
}
