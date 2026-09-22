using Wms.Common.Domain;

namespace Wms.Procurement.Domain.Entities;

/// <summary>
/// <c>proc_split_check_log</c> (spec §10 — "TOR-da yox idi — SoD riski"): the audit trail of the PR-splitting
/// control. One row per purchase order whose supplier's rolling-window total crossed an approval threshold
/// that the single order on its own would not have reached.
/// </summary>
public sealed class SplitCheckLog : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private SplitCheckLog()
    {
    }

    public uint TenantId { get; private set; }

    public uint SupplierId { get; private set; }

    /// <summary>First day of the rolling window the cumulative amount was measured over.</summary>
    public DateOnly WindowStart { get; private set; }

    public DateOnly WindowEnd { get; private set; }

    public decimal CumulativeAmountBase { get; private set; }

    /// <summary>The order whose creation tripped the control.</summary>
    public long? TriggeredPoId { get; private set; }

    public decimal TriggeredAmountBase { get; private set; }

    /// <summary>Approval steps the single order needs versus the steps the cumulative amount would need.</summary>
    public byte StepsForSingle { get; private set; }

    public byte StepsForCumulative { get; private set; }

    public string? Note { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public uint CreatedBy { get; private set; }

    public static SplitCheckLog Record(
        uint tenantId,
        uint supplierId,
        DateOnly windowStart,
        DateOnly windowEnd,
        decimal cumulativeAmountBase,
        decimal triggeredAmountBase,
        long? triggeredPoId,
        byte stepsForSingle,
        byte stepsForCumulative,
        string? note,
        DateTimeOffset now,
        uint createdBy) => new()
        {
            TenantId = tenantId,
            SupplierId = supplierId,
            WindowStart = windowStart,
            WindowEnd = windowEnd,
            CumulativeAmountBase = Quantity.Round(cumulativeAmountBase, Money.StorageDecimals),
            TriggeredAmountBase = Quantity.Round(triggeredAmountBase, Money.StorageDecimals),
            TriggeredPoId = triggeredPoId,
            StepsForSingle = stepsForSingle,
            StepsForCumulative = stepsForCumulative,
            Note = Requisition.Truncate(note, NoteMaxLength),
            CreatedAt = now,
            CreatedBy = createdBy,
        };

    /// <summary>Attaches the PO id once the order has been persisted and has a key.</summary>
    public void AttachPurchaseOrder(long purchaseOrderId) => TriggeredPoId = purchaseOrderId;
}
