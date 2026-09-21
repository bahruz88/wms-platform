namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// What the ledger actually took for one document line, handed back to the aggregate so it can record the frozen
/// base quantity, the batch that was picked and the unit cost. Keeping this a domain type lets the aggregates stay
/// the only writers of their own lines (spec Əlavə A: <c>private set</c> + factory/behaviour methods).
/// </summary>
/// <param name="LineId">Id of the document line the result belongs to.</param>
/// <param name="QtyBase">Quantity actually moved, in the product's base UoM.</param>
/// <param name="BatchId">Batch the allocation took from; null for a batch-less product.</param>
/// <param name="SuggestedBatchId">What FEFO/FIFO would have picked, so an override can be challenged (spec §12.4).</param>
/// <param name="UnitCost">Weighted moving-average cost per base UoM at posting time (spec §12.5).</param>
public sealed record PostedLineResult(
    long LineId,
    decimal QtyBase,
    long? BatchId,
    long? SuggestedBatchId,
    decimal? UnitCost);
