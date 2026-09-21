namespace Wms.Inventory.Contracts;

/// <summary>One product the caller wants removed from a branch location, in the product's base UoM.</summary>
public sealed record ConsumptionPostingLine(uint ProductId, decimal RequestedQtyBase);

/// <summary>
/// Request of a <c>CONSUMPTION</c> movement group (ADR-012). The caller (Consumption) owns the document and its
/// number; Inventory owns the ledger, the batch allocation and the balances.
/// </summary>
public sealed record ConsumptionPostingRequest(
    string DocNo,
    DateOnly BusinessDate,
    uint LocationId,
    string SourceDocType,
    long SourceDocId,
    Guid IdempotencyKey,
    string? Note,
    IReadOnlyList<ConsumptionPostingLine> Lines);

/// <summary>What the ledger actually took per product. <c>Posted + Shortfall = Requested</c>; stock never goes negative.</summary>
public sealed record ConsumptionPostedLine(
    uint ProductId,
    decimal PostedQtyBase,
    decimal ShortfallQtyBase,
    ushort BaseUomId,
    decimal? UnitCost);

/// <summary>
/// Outcome of a posting. Contracts assemblies may only reference <c>Wms.Common.Contracts</c> (ADR-001), so this
/// carries the RFC 7807 <c>code</c>/status as data instead of using <c>Result&lt;T&gt;</c> from Wms.Common.Domain.
/// </summary>
public sealed record StockPostingOutcome(
    bool IsSuccess,
    string? ErrorCode,
    string? ErrorMessage,
    int ErrorStatus,
    long? MovementGroupId,
    string DocNo,
    IReadOnlyList<ConsumptionPostedLine> Lines)
{
    public static StockPostingOutcome Success(long? movementGroupId, string docNo, IReadOnlyList<ConsumptionPostedLine> lines) =>
        new(true, null, null, 200, movementGroupId, docNo, lines);

    public static StockPostingOutcome Failure(string code, string message, int status) =>
        new(false, code, message, status, null, string.Empty, []);
}

public sealed record StockReversalRequest(long MovementGroupId, DateOnly DocDate, ushort ReasonCodeId, Guid IdempotencyKey, string? Note);

public sealed record StockReversalOutcome(bool IsSuccess, string? ErrorCode, string? ErrorMessage, int ErrorStatus, long? MovementGroupId, string DocNo)
{
    public static StockReversalOutcome Success(long movementGroupId, string docNo) => new(true, null, null, 200, movementGroupId, docNo);

    public static StockReversalOutcome Failure(string code, string message, int status) => new(false, code, message, status, null, string.Empty);
}

/// <summary>
/// The write side of Inventory that other modules may use (ADR-002/ADR-012): "post this document for me".
/// Everything inside — the count-freeze check, <c>SELECT ... FOR UPDATE</c> on the balances, FEFO/FIFO batch
/// allocation that skips BLOCKED/EXPIRED/QUARANTINE batches, the movement lines, the balance projection and the
/// outbox — happens in ONE Inventory transaction. Callers never touch <c>inv_*</c> tables.
/// </summary>
public interface IStockPostingService
{
    Task<StockPostingOutcome> PostConsumptionAsync(ConsumptionPostingRequest request, CancellationToken cancellationToken);

    /// <summary>Storno of a previously posted group (spec §12.6): a REVERSAL group with inverted signs.</summary>
    Task<StockReversalOutcome> ReverseAsync(StockReversalRequest request, CancellationToken cancellationToken);

    /// <summary>
    /// Spec §12.7: an inventory count freezes a location. Callers use it to fail early with
    /// <c>409 LOCATION_FROZEN</c>; the posting itself re-checks it inside its own transaction.
    /// </summary>
    Task<bool> IsLocationFrozenAsync(uint locationId, CancellationToken cancellationToken);
}
