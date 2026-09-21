using Wms.Common.Domain;

namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// Row of <c>inv_count_line</c> (spec §9.6). <see cref="BookQty"/> is frozen at
/// <see cref="StockCount.Freeze"/> time and never changes afterwards — that is what makes the variance meaningful
/// even though stock keeps moving elsewhere.
/// </summary>
public sealed class StockCountLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    /// <summary>Mirrors <see cref="StockBalance.NoBatch"/>: <c>0</c> is stored for a batch-less row.</summary>
    public const long NoBatch = 0;

    private StockCountLine()
    {
    }

    public uint TenantId { get; private set; }

    public long CountId { get; private set; }

    public uint ProductId { get; private set; }

    /// <summary>Null for a batch-less product (the DDL allows NULL here, unlike <c>inv_balance</c>).</summary>
    public long? BatchId { get; private set; }

    /// <summary>System quantity at the instant of the freeze, in base UoM.</summary>
    public decimal BookQty { get; private set; }

    public decimal? CountedQty { get; private set; }

    public decimal? VarianceQty { get; private set; }

    public decimal? VariancePct { get; private set; }

    public ushort? ReasonCodeId { get; private set; }

    public string? Note { get; private set; }

    public uint? CountedBy { get; private set; }

    public DateTimeOffset? CountedAt { get; private set; }

    /// <summary>Moving-average cost captured at freeze time, so the variance can be valued without a second lookup.</summary>
    public decimal AvgUnitCost { get; private set; }

    public bool IsCounted => CountedQty is not null;

    public bool HasVariance => VarianceQty is { } variance && variance != 0m;

    internal static StockCountLine Snapshot(uint tenantId, uint productId, long? batchId, decimal bookQty, decimal avgUnitCost) =>
        new()
        {
            TenantId = tenantId,
            ProductId = productId,
            BatchId = batchId is null or NoBatch ? null : batchId,
            BookQty = bookQty,
            AvgUnitCost = avgUnitCost,
        };

    /// <summary>
    /// Records the counted quantity and derives the variance. A non-zero variance without a reason code is rejected
    /// (spec §12.6) — this is what replaces the unexplained <c>+510</c> constant of the Excel sheet.
    /// </summary>
    internal Result Count(decimal countedQtyBase, ushort? reasonCodeId, string? note, uint countedBy, DateTimeOffset countedAt)
    {
        if (countedQtyBase < 0m)
        {
            return InventoryErrors.InvalidQuantity("counted_qty cannot be negative.");
        }

        var variance = countedQtyBase - BookQty;
        if (variance != 0m && reasonCodeId is null or 0)
        {
            return InventoryErrors.ReasonCodeRequired(ProductId);
        }

        CountedQty = countedQtyBase;
        VarianceQty = variance;
        VariancePct = VariancePercent(BookQty, variance);
        ReasonCodeId = variance == 0m ? null : reasonCodeId;
        Note = note is { Length: > NoteMaxLength } trimmed ? trimmed[..NoteMaxLength] : note;
        CountedBy = countedBy;
        CountedAt = countedAt;
        return Result.Success();
    }

    /// <summary>
    /// <c>variance ÷ book × 100</c>, DECIMAL(9,4). A variance found where the book said zero is reported as 100 %
    /// (the alternative, dividing by zero, has no useful answer).
    /// </summary>
    public static decimal VariancePercent(decimal bookQty, decimal varianceQty)
    {
        if (varianceQty == 0m)
        {
            return 0m;
        }

        if (bookQty == 0m)
        {
            return varianceQty > 0m ? 100m : -100m;
        }

        return Math.Round(varianceQty / Math.Abs(bookQty) * 100m, 4, MidpointRounding.AwayFromZero);
    }
}
