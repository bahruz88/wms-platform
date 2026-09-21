namespace Wms.Inventory.Contracts;

/// <summary>
/// Ledger flows of one product at one location for a closed period, split by document type — the raw material of
/// the theoretical-vs-actual variance report (branch-operations.md §7). Quantities are in the product's base UoM
/// and are signed the way the report needs them: inflows positive, outflows positive in their own bucket.
/// </summary>
public sealed record StockPeriodFlowDto(
    uint ProductId,
    uint LocationId,
    decimal OpeningQty,
    decimal ReceivedQty,
    decimal ConsumedQty,
    decimal WasteQty,
    decimal SampleQty,
    decimal TransferNetQty,
    decimal CountAdjustQty,
    decimal ClosingQty,
    decimal AvgUnitCost);

/// <summary>Read-only ledger aggregation for other modules. Batch-level detail stays inside Inventory.</summary>
public interface IStockMovementReader
{
    /// <summary>
    /// Aggregates <c>inv_movement</c> between <paramref name="periodFrom"/> and <paramref name="periodTo"/>
    /// (both inclusive, by <c>posted_at</c> date). <c>OpeningQty</c> is the ledger position just before
    /// <paramref name="periodFrom"/> and <c>ClosingQty</c> the position at the end of <paramref name="periodTo"/>.
    /// </summary>
    Task<IReadOnlyList<StockPeriodFlowDto>> GetPeriodFlowsAsync(
        uint? locationId,
        uint? productId,
        DateOnly periodFrom,
        DateOnly periodTo,
        CancellationToken cancellationToken);
}
