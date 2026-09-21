using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain.Entities;

/// <summary>Batch / lot — a first-class object (spec §9.2). Two deliveries of the same SKU are two rows.</summary>
public sealed class Batch : AuditableEntity<long>, ITenantEntity
{
    public const int BatchNoMaxLength = 64;

    private Batch()
    {
    }

    public uint TenantId { get; private set; }

    public uint ProductId { get; private set; }

    public string BatchNo { get; private set; } = string.Empty;

    public DateOnly? ProductionDate { get; private set; }

    public DateOnly? ExpiryDate { get; private set; }

    public uint? SupplierId { get; private set; }

    /// <summary>FIFO tie-breaker (spec §12.4).</summary>
    public DateTimeOffset ReceivedAt { get; private set; }

    public BatchStatus Status { get; private set; }

    public static Result<Batch> Create(
        uint tenantId,
        uint productId,
        string batchNo,
        DateOnly? productionDate,
        DateOnly? expiryDate,
        uint? supplierId,
        DateTimeOffset receivedAt)
    {
        var normalized = (batchNo ?? string.Empty).Trim();
        if (normalized.Length is 0 or > BatchNoMaxLength)
        {
            return InventoryErrors.InvalidBatch($"batch_no must be 1..{BatchNoMaxLength} characters.");
        }

        if (productionDate is not null && expiryDate is not null && expiryDate < productionDate)
        {
            return InventoryErrors.InvalidBatch("expiry_date cannot be earlier than production_date.");
        }

        return new Batch
        {
            TenantId = tenantId,
            ProductId = productId,
            BatchNo = normalized,
            ProductionDate = productionDate,
            ExpiryDate = expiryDate,
            SupplierId = supplierId,
            ReceivedAt = receivedAt,
            Status = BatchStatus.Active,
        };
    }

    public bool IsAllocatable() => Status == BatchStatus.Active;

    public bool IsExpiredOn(DateOnly date) => ExpiryDate is { } expiry && expiry < date;

    public Result Block() => Transition(BatchStatus.Blocked, from: [BatchStatus.Active, BatchStatus.Quarantine]);

    public Result Quarantine() => Transition(BatchStatus.Quarantine, from: [BatchStatus.Active, BatchStatus.Blocked]);

    public Result Release() => Transition(BatchStatus.Active, from: [BatchStatus.Blocked, BatchStatus.Quarantine]);

    /// <summary>Set by the ExpiryScanner job (spec §15); terminal.</summary>
    public Result MarkExpired() => Transition(BatchStatus.Expired, from: [BatchStatus.Active, BatchStatus.Blocked, BatchStatus.Quarantine]);

    private Result Transition(BatchStatus to, BatchStatus[] from)
    {
        if (Status == to)
        {
            return Result.Success();
        }

        if (!from.Contains(Status))
        {
            return InventoryErrors.InvalidBatchTransition(Status, to);
        }

        Status = to;
        return Result.Success();
    }
}
