namespace Wms.Inventory.Contracts;

/// <summary>
/// The spec §16 location restriction as it crosses a module boundary. A <c>*.Contracts</c> assembly may only
/// reference <c>Wms.Common.Contracts</c> (ADR-001), so <c>LocationScope</c> itself cannot travel; this is its
/// wire shape and it keeps the same fail-closed distinction: <see cref="LocationIds"/> <c>null</c> means "no
/// restriction", an empty list means "no location at all" — never "everything".
/// </summary>
public sealed record ReportingScope(IReadOnlyList<uint>? LocationIds)
{
    public static ReportingScope Unrestricted { get; } = new((IReadOnlyList<uint>?)null);

    public static ReportingScope Nothing { get; } = new([]);

    public bool IsRestricted => LocationIds is not null;

    public static ReportingScope RestrictedTo(IEnumerable<uint>? locationIds)
    {
        if (locationIds is null)
        {
            return Nothing;
        }

        return new ReportingScope(locationIds.Where(id => id != 0).Distinct().Order().ToList());
    }
}

/// <summary>
/// Zero-based window over a report result set (the caller pages; the source never returns everything).
/// <paramref name="SortKey"/> is a column key the caller has already validated against the report definition;
/// a key the source does not know falls back to that report's natural order.
/// </summary>
public sealed record ReportSlice(int Skip, int Take, string? SortKey = null, bool Descending = false)
{
    /// <summary>Hard ceiling of one source call — the same 20 000 safety net the balance list uses.</summary>
    public const int MaxTake = 20_000;

    public int SafeSkip => Math.Max(0, Skip);

    public int SafeTake => Math.Clamp(Take, 1, MaxTake);
}

/// <summary>One page of report rows plus the total the filter matches.</summary>
public sealed record ReportRowSet<T>(IReadOnlyList<T> Rows, long Total)
{
    public static ReportRowSet<T> Empty { get; } = new([], 0);
}

/// <summary><c>inv_balance</c> aggregated over batches: one row per product/location.</summary>
public sealed record StockBalanceReportRow(
    uint ProductId,
    uint LocationId,
    decimal QtyOnHand,
    decimal QtyReserved,
    decimal QtyAvailable,
    decimal AvgUnitCost,
    decimal TotalValue,
    int BatchCount);

/// <summary><c>inv_balance</c> joined to <c>inv_batch</c>: one row per batch.</summary>
public sealed record BatchStockReportRow(
    long BatchId,
    string BatchNo,
    uint ProductId,
    uint LocationId,
    DateOnly? ExpiryDate,
    DateOnly? ProductionDate,
    string BatchStatus,
    int? DaysToExpiry,
    uint? SupplierId,
    decimal QtyOnHand,
    decimal AvgUnitCost,
    decimal TotalValue);

/// <summary>One <c>inv_movement</c> line with its group header.</summary>
public sealed record MovementLedgerReportRow(
    long MovementId,
    long GroupId,
    DateTimeOffset PostedAt,
    DateOnly DocDate,
    string DocType,
    string DocNo,
    uint ProductId,
    uint LocationId,
    long? BatchId,
    string? BatchNo,
    decimal QtyBase,
    decimal? UnitCost,
    decimal? LineValue,
    uint? ReasonCodeId);

/// <summary><c>inv_movement</c> summed per product/location for one document type over a period.</summary>
public sealed record MovementAggregateReportRow(
    uint ProductId,
    uint LocationId,
    decimal QtyBase,
    decimal TotalValue,
    int LineCount,
    DateOnly FirstDate,
    DateOnly LastDate);

/// <summary>A counted line of <c>inv_count</c> whose counted quantity differs from the system quantity (spec §12.7).</summary>
public sealed record CountVarianceReportRow(
    long CountId,
    string DocNo,
    DateOnly CountDate,
    string Status,
    uint LocationId,
    uint ProductId,
    long? BatchId,
    string? BatchNo,
    decimal SystemQty,
    decimal CountedQty,
    decimal VarianceQty,
    decimal VariancePct,
    decimal? UnitCost,
    decimal? VarianceValue);

/// <summary>A goods-receipt line whose received quantity differs from the ordered quantity (spec §12.2).</summary>
public sealed record ReceiptVarianceReportRow(
    long ReceiptId,
    string DocNo,
    DateOnly ReceiptDate,
    string Status,
    uint LocationId,
    uint? SupplierId,
    uint ProductId,
    decimal OrderedQty,
    decimal ReceivedQty,
    decimal AcceptedQty,
    decimal RejectedQty,
    decimal VarianceQty,
    decimal VariancePct,
    decimal? UnitCost);

/// <summary>Stock on hand against the consumption of the trailing window — how many days the stock lasts.</summary>
public sealed record StockCoverageReportRow(
    uint ProductId,
    uint LocationId,
    decimal QtyOnHand,
    decimal ConsumedQty,
    decimal AvgDailyConsumption,
    decimal? CoverageDays,
    decimal AvgUnitCost,
    decimal TotalValue);

/// <summary>One point of a daily dashboard series.</summary>
public sealed record DashboardDayPoint(DateOnly Date, decimal Value);

/// <summary>
/// Everything the Reporting dashboard needs from the <c>inv</c> schema, in one round trip. Costs are always
/// returned; whether they reach the client is decided by Reporting against <c>master.product.view_cost</c>.
/// </summary>
public sealed record InventoryDashboardDto(
    decimal StockValueTotal,
    long BalanceRowCount,
    decimal QtyOnHandTotal,
    int ExpiryWarningDays,
    int ExpiryCriticalDays,
    int ExpiringBatchCount,
    int CriticalBatchCount,
    int ExpiredBatchCount,
    int PendingWasteApprovals,
    int CountsAwaitingReview,
    int OpenStockRequests,
    int ReceiptCount,
    int ReceiptCountPrevious,
    decimal WasteValue,
    decimal WasteValuePrevious,
    IReadOnlyList<DashboardDayPoint> ReceiptsPerDay,
    IReadOnlyList<DashboardDayPoint> IssuesPerDay,
    IReadOnlyList<DashboardDayPoint> WasteValuePerDay);

/// <summary>Request of <see cref="IInventoryReportingSource.GetDashboardAsync"/>.</summary>
public sealed record InventoryDashboardRequest(
    ReportingScope Scope,
    uint? LocationId,
    DateOnly PeriodFrom,
    DateOnly PeriodTo,
    DateOnly PreviousFrom,
    DateOnly PreviousTo);

/// <summary>Request of <see cref="IInventoryReportingSource.GetStockBalancesAsync"/>.</summary>
public sealed record StockBalanceReportRequest(
    ReportingScope Scope,
    uint? LocationId,
    uint? ProductId,
    bool IncludeZero,
    ReportSlice Slice);

/// <summary>Request of <see cref="IInventoryReportingSource.GetBatchStockAsync"/>.</summary>
public sealed record BatchStockReportRequest(
    ReportingScope Scope,
    uint? LocationId,
    uint? ProductId,
    DateOnly? ExpiringBefore,
    string? BatchStatus,
    bool IncludeZero,
    ReportSlice Slice);

/// <summary>Request of <see cref="IInventoryReportingSource.GetMovementsAsync"/>.</summary>
public sealed record MovementReportRequest(
    ReportingScope Scope,
    DateOnly DateFrom,
    DateOnly DateTo,
    string? DocType,
    uint? LocationId,
    uint? ProductId,
    ReportSlice Slice);

/// <summary>Request of <see cref="IInventoryReportingSource.GetMovementAggregateAsync"/>.</summary>
public sealed record MovementAggregateReportRequest(
    ReportingScope Scope,
    DateOnly DateFrom,
    DateOnly DateTo,
    string DocType,
    uint? LocationId,
    uint? ProductId,
    ReportSlice Slice);

/// <summary>Request of <see cref="IInventoryReportingSource.GetCountVariancesAsync"/>.</summary>
public sealed record CountVarianceReportRequest(
    ReportingScope Scope,
    DateOnly DateFrom,
    DateOnly DateTo,
    uint? LocationId,
    bool OnlyVariances,
    ReportSlice Slice);

/// <summary>Request of <see cref="IInventoryReportingSource.GetReceiptVariancesAsync"/>.</summary>
public sealed record ReceiptVarianceReportRequest(
    ReportingScope Scope,
    DateOnly DateFrom,
    DateOnly DateTo,
    uint? LocationId,
    uint? SupplierId,
    bool OnlyVariances,
    ReportSlice Slice);

/// <summary>Request of <see cref="IInventoryReportingSource.GetStockCoverageAsync"/>.</summary>
public sealed record StockCoverageReportRequest(
    ReportingScope Scope,
    uint? LocationId,
    uint? ProductId,
    int WindowDays,
    ReportSlice Slice);

/// <summary>
/// Read-only aggregation of the <c>inv</c> schema for the Reporting module (spec §5: Reporting owns no
/// operational table and never joins into another module's schema). Every call is location-scoped by the
/// caller's <see cref="ReportingScope"/> and returns ids only — product, location and supplier labels are
/// resolved by Reporting through <c>Wms.MasterData.Contracts</c>.
/// </summary>
/// <remarks>
/// Every request travels as one object so the HTTP transport (<c>ModuleTransport=Http</c>) can POST it as a
/// body: a report filter easily carries a dozen values and the existing GET-with-query-string stubs already
/// hit HTTP 414 at roughly 1 300 identifiers (ROADMAP §4).
/// </remarks>
public interface IInventoryReportingSource
{
    Task<InventoryDashboardDto> GetDashboardAsync(InventoryDashboardRequest request, CancellationToken cancellationToken);

    Task<ReportRowSet<StockBalanceReportRow>> GetStockBalancesAsync(StockBalanceReportRequest request, CancellationToken cancellationToken);

    Task<ReportRowSet<BatchStockReportRow>> GetBatchStockAsync(BatchStockReportRequest request, CancellationToken cancellationToken);

    Task<ReportRowSet<MovementLedgerReportRow>> GetMovementsAsync(MovementReportRequest request, CancellationToken cancellationToken);

    /// <summary>Outflow document types (WASTE, CONSUMPTION, SAMPLE, RETURN) come back as positive quantities.</summary>
    Task<ReportRowSet<MovementAggregateReportRow>> GetMovementAggregateAsync(MovementAggregateReportRequest request, CancellationToken cancellationToken);

    Task<ReportRowSet<CountVarianceReportRow>> GetCountVariancesAsync(CountVarianceReportRequest request, CancellationToken cancellationToken);

    Task<ReportRowSet<ReceiptVarianceReportRow>> GetReceiptVariancesAsync(ReceiptVarianceReportRequest request, CancellationToken cancellationToken);

    Task<ReportRowSet<StockCoverageReportRow>> GetStockCoverageAsync(StockCoverageReportRequest request, CancellationToken cancellationToken);
}
