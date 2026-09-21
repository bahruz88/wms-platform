using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Application.Abstractions;

/// <summary>
/// One product to move. Exactly one of the two locations may be zero for a document that only has one side —
/// in practice every WMS document has two, because the ledger must balance (ADR-003).
/// </summary>
/// <param name="Key">Opaque caller key (usually the document line id or line number) echoed back in the result.</param>
/// <param name="ProductId">Product to move.</param>
/// <param name="Qty">Quantity in <paramref name="UomId"/>, always positive.</param>
/// <param name="UomId">The UoM the user entered; the engine converts to base and freezes the factor (spec §12.1).</param>
/// <param name="FromLocationId">Where the stock leaves; drives the FEFO/FIFO allocation.</param>
/// <param name="ToLocationId">Where it arrives.</param>
/// <param name="BatchId">Explicit batch. Null lets the engine allocate per <c>product.issue_strategy</c>.</param>
public sealed record PostingLine(
    long Key,
    uint ProductId,
    decimal Qty,
    ushort UomId,
    uint FromLocationId,
    uint ToLocationId,
    long? BatchId = null);

/// <summary>What the engine actually took for one <see cref="PostingLine"/>.</summary>
public sealed record PostedLine(
    long Key,
    uint ProductId,
    decimal QtyBase,
    long? BatchId,
    long? SuggestedBatchId,
    decimal? UnitCost);

/// <summary>A document the engine should turn into one balanced <c>inv_movement_group</c>.</summary>
public sealed record PostingRequest(
    DocType DocType,
    string DocNo,
    DateOnly DocDate,
    Guid IdempotencyKey,
    string SourceDocType,
    long SourceDocId,
    ushort? ReasonCodeId,
    string? Note,
    IReadOnlyList<PostingLine> Lines)
{
    /// <summary>Locations allowed to go negative — the virtual counter-accounts of the ledger (ADR-003).</summary>
    public IReadOnlyCollection<uint> VirtualLocationIds { get; init; } = [];
}

public sealed record PostingResult(long MovementGroupId, string DocNo, bool Replayed, IReadOnlyList<PostedLine> Lines);

/// <summary>
/// The one place a warehouse document becomes ledger rows. It must be called inside the caller's transaction so
/// the document status change and the movements commit together (spec §12.2).
///
/// <para>For every line it locks the source balances with <c>SELECT ... FOR UPDATE</c>, runs the FEFO/FIFO
/// allocation (skipping BLOCKED / EXPIRED / QUARANTINE batches, spec §12.4), writes the matching
/// <c>−qty</c> / <c>+qty</c> pair and applies the balance projection. Unlike the consumption path it does
/// <b>not</b> cap the quantity: a shortfall here is an error (<c>409 INSUFFICIENT_STOCK</c>), because a human
/// said they were moving this much.</para>
/// </summary>
public interface IDocumentPostingEngine
{
    Task<Result<PostingResult>> PostAsync(PostingRequest request, CancellationToken cancellationToken);
}
