using Dapper;
using Wms.Common.Application.Abstractions;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Contracts;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Contracts;

/// <summary>
/// In-process <see cref="IInventoryReportingSource"/>: Dapper over the <c>inv_</c> tables (spec §3 — reports are
/// not written with EF Core). Every statement carries <c>tenant_id</c> explicitly, because Dapper bypasses the
/// EF global query filters (spec §12.9), and every statement applies the caller's location scope.
/// </summary>
/// <remarks>
/// The outflow documents (WASTE, SAMPLE, CONSUMPTION, RETURN) write two ledger lines: a negative one on the real
/// location and a positive one on the virtual counter-account (ADR-003). Inventory cannot see
/// <c>master_location.is_virtual</c>, so the aggregates select the side by sign instead — which is exactly the
/// same rule and needs no cross-schema join.
/// </remarks>
public sealed class InventoryReportingSource(InventoryDbContext db, ITenantContext tenantContext, IInventorySettings settings, IClock clock)
    : IInventoryReportingSource
{
    private static readonly string[] OutflowDocTypes = ["WASTE", "SAMPLE", "CONSUMPTION", "RETURN"];
    private static readonly string[] InflowDocTypes = ["RECEIPT", "OPENING"];

    public async Task<InventoryDashboardDto> GetDashboardAsync(InventoryDashboardRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var warningDays = await settings.GetIntAsync(InventorySettingKeys.ExpiryWarningDays, cancellationToken).ConfigureAwait(false);
        var criticalDays = await settings.GetIntAsync(InventorySettingKeys.ExpiryCriticalDays, cancellationToken).ConfigureAwait(false);
        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);

        var scope = request.Scope;
        var balanceLoc = Where(scope, "b") + Single(request.LocationId, "b");
        var batchLoc = Where(scope, "b") + Single(request.LocationId, "b");
        var wasteLoc = Where(scope, "w") + Single(request.LocationId, "w");
        var countLoc = Where(scope, "c") + Single(request.LocationId, "c");
        var receiptLoc = Where(scope, "r") + Single(request.LocationId, "r");
        var issueLoc = BothEnds(scope, "i") + SingleBothEnds(request.LocationId, "i");
        var requestLoc = BothEnds(scope, "q") + SingleBothEnds(request.LocationId, "q");

        var parameters = new DynamicParameters();
        parameters.Add("tenantId", tenantContext.TenantId);
        parameters.Add("locationIds", scope.LocationIds is { Count: > 0 } ids ? ids : null);
        parameters.Add("locationId", request.LocationId);
        parameters.Add("today", today.ToDateTime(TimeOnly.MinValue));
        parameters.Add("warnUntil", today.AddDays(warningDays).ToDateTime(TimeOnly.MinValue));
        parameters.Add("criticalUntil", today.AddDays(criticalDays).ToDateTime(TimeOnly.MinValue));
        parameters.Add("fromDate", request.PeriodFrom.ToDateTime(TimeOnly.MinValue));
        parameters.Add("toDate", request.PeriodTo.ToDateTime(TimeOnly.MinValue));
        parameters.Add("prevFrom", request.PreviousFrom.ToDateTime(TimeOnly.MinValue));
        parameters.Add("prevTo", request.PreviousTo.ToDateTime(TimeOnly.MinValue));

        var sql = $"""
            SELECT COUNT(*) AS BalanceRows,
                   COALESCE(SUM(b.qty_on_hand), 0) AS QtyOnHand,
                   COALESCE(SUM(b.qty_on_hand * b.avg_unit_cost), 0) AS StockValue
              FROM inv_balance b
             WHERE b.tenant_id = @tenantId AND b.qty_on_hand <> 0{balanceLoc};

            SELECT CAST(COALESCE(SUM(CASE WHEN bt.expiry_date <= @warnUntil AND bt.expiry_date > @criticalUntil THEN 1 ELSE 0 END), 0) AS SIGNED) AS Expiring,
                   CAST(COALESCE(SUM(CASE WHEN bt.expiry_date <= @criticalUntil AND bt.expiry_date >= @today THEN 1 ELSE 0 END), 0) AS SIGNED) AS Critical,
                   CAST(COALESCE(SUM(CASE WHEN bt.expiry_date < @today THEN 1 ELSE 0 END), 0) AS SIGNED) AS Expired
              FROM inv_balance b
              JOIN inv_batch bt ON bt.id = b.batch_id AND bt.tenant_id = b.tenant_id
             WHERE b.tenant_id = @tenantId AND b.batch_id <> 0 AND b.qty_on_hand > 0
               AND bt.expiry_date IS NOT NULL AND bt.status <> 'BLOCKED'{batchLoc};

            SELECT (SELECT COUNT(*) FROM inv_waste w
                     WHERE w.tenant_id = @tenantId AND w.status = 'PENDING_APPROVAL'{wasteLoc}) AS PendingWaste,
                   (SELECT COUNT(*) FROM inv_count c
                     WHERE c.tenant_id = @tenantId AND c.status = 'REVIEW'{countLoc}) AS CountsInReview,
                   (SELECT COUNT(*) FROM inv_stock_request q
                     WHERE q.tenant_id = @tenantId
                       AND q.status IN ('SUBMITTED','PICKING','PARTIALLY_ISSUED'){requestLoc}) AS OpenRequests;

            SELECT COALESCE(SUM(CASE WHEN r.doc_date BETWEEN @fromDate AND @toDate THEN 1 ELSE 0 END), 0) AS Current,
                   COALESCE(SUM(CASE WHEN r.doc_date BETWEEN @prevFrom AND @prevTo THEN 1 ELSE 0 END), 0) AS Previous
              FROM inv_goods_receipt r
             WHERE r.tenant_id = @tenantId AND r.status = 'POSTED'
               AND r.doc_date BETWEEN @prevFrom AND @toDate{receiptLoc};

            SELECT COALESCE(SUM(CASE WHEN w.doc_date BETWEEN @fromDate AND @toDate THEN wl.qty_base * COALESCE(wl.unit_cost, 0) ELSE 0 END), 0) AS Current,
                   COALESCE(SUM(CASE WHEN w.doc_date BETWEEN @prevFrom AND @prevTo THEN wl.qty_base * COALESCE(wl.unit_cost, 0) ELSE 0 END), 0) AS Previous
              FROM inv_waste w
              JOIN inv_waste_line wl ON wl.waste_id = w.id AND wl.tenant_id = w.tenant_id
             WHERE w.tenant_id = @tenantId AND w.status = 'POSTED'
               AND w.doc_date BETWEEN @prevFrom AND @toDate{wasteLoc};

            SELECT r.doc_date AS Day, COUNT(*) AS Value
              FROM inv_goods_receipt r
             WHERE r.tenant_id = @tenantId AND r.status = 'POSTED'
               AND r.doc_date BETWEEN @fromDate AND @toDate{receiptLoc}
             GROUP BY r.doc_date ORDER BY r.doc_date;

            SELECT i.doc_date AS Day, COUNT(*) AS Value
              FROM inv_issue i
             WHERE i.tenant_id = @tenantId AND i.status <> 'CANCELLED'
               AND i.doc_date BETWEEN @fromDate AND @toDate{issueLoc}
             GROUP BY i.doc_date ORDER BY i.doc_date;

            SELECT w.doc_date AS Day, SUM(wl.qty_base * COALESCE(wl.unit_cost, 0)) AS Value
              FROM inv_waste w
              JOIN inv_waste_line wl ON wl.waste_id = w.id AND wl.tenant_id = w.tenant_id
             WHERE w.tenant_id = @tenantId AND w.status = 'POSTED'
               AND w.doc_date BETWEEN @fromDate AND @toDate{wasteLoc}
             GROUP BY w.doc_date ORDER BY w.doc_date;
            """;

        var connection = db.Database.GetDbConnection();
        await db.Database.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            using var reader = await connection
                .QueryMultipleAsync(new CommandDefinition(sql, parameters, cancellationToken: cancellationToken))
                .ConfigureAwait(false);

            var stock = await reader.ReadSingleAsync<StockTotalsRow>().ConfigureAwait(false);
            var expiry = await reader.ReadSingleAsync<ExpiryCountsRow>().ConfigureAwait(false);
            var pending = await reader.ReadSingleAsync<PendingCountsRow>().ConfigureAwait(false);
            var receipts = await reader.ReadSingleAsync<PeriodPairRow>().ConfigureAwait(false);
            var waste = await reader.ReadSingleAsync<PeriodPairRow>().ConfigureAwait(false);
            var receiptSeries = (await reader.ReadAsync<SeriesRow>().ConfigureAwait(false)).ToList();
            var issueSeries = (await reader.ReadAsync<SeriesRow>().ConfigureAwait(false)).ToList();
            var wasteSeries = (await reader.ReadAsync<SeriesRow>().ConfigureAwait(false)).ToList();

            return new InventoryDashboardDto(
                stock.StockValue,
                stock.BalanceRows,
                stock.QtyOnHand,
                warningDays,
                criticalDays,
                (int)expiry.Expiring,
                (int)expiry.Critical,
                (int)expiry.Expired,
                (int)pending.PendingWaste,
                (int)pending.CountsInReview,
                (int)pending.OpenRequests,
                (int)receipts.Current,
                (int)receipts.Previous,
                waste.Current,
                waste.Previous,
                Points(receiptSeries),
                Points(issueSeries),
                Points(wasteSeries));
        }
        finally
        {
            await db.Database.CloseConnectionAsync().ConfigureAwait(false);
        }
    }

    public async Task<ReportRowSet<StockBalanceReportRow>> GetStockBalancesAsync(StockBalanceReportRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var where = $"""
             WHERE b.tenant_id = @tenantId{Where(request.Scope, "b")}{Single(request.LocationId, "b")}
               {(request.ProductId is null ? string.Empty : "AND b.product_id = @productId")}
               {(request.IncludeZero ? string.Empty : "AND b.qty_on_hand <> 0")}
            """;

        var order = Order(
            request.Slice,
            "LocationId, ProductId",
            new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["qtyOnHand"] = "QtyOnHand",
                ["totalValue"] = "TotalValue",
                ["productId"] = "ProductId",
                ["locationId"] = "LocationId",
            });

        var sql = $"""
            SELECT COUNT(*) FROM (SELECT 1 FROM inv_balance b {where} GROUP BY b.product_id, b.location_id) t;

            SELECT b.product_id AS ProductId, b.location_id AS LocationId,
                   SUM(b.qty_on_hand) AS QtyOnHand,
                   SUM(b.qty_reserved) AS QtyReserved,
                   SUM(b.qty_on_hand - b.qty_reserved) AS QtyAvailable,
                   CASE WHEN SUM(b.qty_on_hand) = 0 THEN 0
                        ELSE SUM(b.qty_on_hand * b.avg_unit_cost) / SUM(b.qty_on_hand) END AS AvgUnitCost,
                   SUM(b.qty_on_hand * b.avg_unit_cost) AS TotalValue,
                   CAST(COUNT(*) AS SIGNED) AS BatchCount
              FROM inv_balance b
            {where}
             GROUP BY b.product_id, b.location_id
             ORDER BY {order}
             LIMIT @take OFFSET @skip;
            """;

        var set = await ReadSetAsync<StockBalanceRow>(
            sql,
            Parameters(request.Scope, request.LocationId, request.Slice, p => p.Add("productId", request.ProductId)),
            cancellationToken).ConfigureAwait(false);

        return new ReportRowSet<StockBalanceReportRow>(
            [.. set.Rows.Select(r => new StockBalanceReportRow(
                r.ProductId, r.LocationId, r.QtyOnHand, r.QtyReserved, r.QtyAvailable,
                r.AvgUnitCost, r.TotalValue, (int)r.BatchCount))],
            set.Total);
    }

    public async Task<ReportRowSet<BatchStockReportRow>> GetBatchStockAsync(BatchStockReportRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var where = $"""
             WHERE b.tenant_id = @tenantId AND b.batch_id <> 0{Where(request.Scope, "b")}{Single(request.LocationId, "b")}
               {(request.ProductId is null ? string.Empty : "AND b.product_id = @productId")}
               {(request.ExpiringBefore is null ? string.Empty : "AND bt.expiry_date IS NOT NULL AND bt.expiry_date <= @expiringBefore")}
               {(request.BatchStatus is null ? string.Empty : "AND bt.status = @batchStatus")}
               {(request.IncludeZero ? string.Empty : "AND b.qty_on_hand <> 0")}
            """;

        var order = Order(
            request.Slice,
            "bt.expiry_date IS NULL, bt.expiry_date, b.location_id, b.product_id",
            new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["expiryDate"] = "bt.expiry_date IS NULL, bt.expiry_date",
                ["daysToExpiry"] = "bt.expiry_date IS NULL, bt.expiry_date",
                ["qtyOnHand"] = "b.qty_on_hand",
                ["totalValue"] = "b.qty_on_hand * b.avg_unit_cost",
                ["batchNo"] = "bt.batch_no",
            });

        var from = "FROM inv_balance b JOIN inv_batch bt ON bt.id = b.batch_id AND bt.tenant_id = b.tenant_id";
        var sql = $"""
            SELECT COUNT(*) {from} {where};

            SELECT bt.id AS BatchId, bt.batch_no AS BatchNo, b.product_id AS ProductId, b.location_id AS LocationId,
                   bt.expiry_date AS ExpiryDate, bt.production_date AS ProductionDate, bt.status AS BatchStatus,
                   CASE WHEN bt.expiry_date IS NULL THEN NULL ELSE DATEDIFF(bt.expiry_date, @today) END AS DaysToExpiry,
                   bt.supplier_id AS SupplierId, b.qty_on_hand AS QtyOnHand, b.avg_unit_cost AS AvgUnitCost,
                   b.qty_on_hand * b.avg_unit_cost AS TotalValue
            {from}
            {where}
             ORDER BY {order}
             LIMIT @take OFFSET @skip;
            """;

        var parameters = Parameters(request.Scope, request.LocationId, request.Slice, p =>
        {
            p.Add("productId", request.ProductId);
            p.Add("batchStatus", request.BatchStatus);
            p.Add("today", DateOnly.FromDateTime(clock.UtcNow.UtcDateTime).ToDateTime(TimeOnly.MinValue));
            p.Add("expiringBefore", request.ExpiringBefore?.ToDateTime(TimeOnly.MinValue));
        });

        var set = await ReadSetAsync<BatchStockRow>(sql, parameters, cancellationToken).ConfigureAwait(false);
        return new ReportRowSet<BatchStockReportRow>(
            [.. set.Rows.Select(r => new BatchStockReportRow(
                r.BatchId, r.BatchNo, r.ProductId, r.LocationId,
                Date(r.ExpiryDate), Date(r.ProductionDate), r.BatchStatus,
                r.DaysToExpiry is { } d ? (int)d : null,
                r.SupplierId, r.QtyOnHand, r.AvgUnitCost, r.TotalValue))],
            set.Total);
    }

    public async Task<ReportRowSet<MovementLedgerReportRow>> GetMovementsAsync(MovementReportRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var where = $"""
             WHERE m.tenant_id = @tenantId AND m.posted_at >= @fromAt AND m.posted_at < @toAt
               {Where(request.Scope, "m")}{Single(request.LocationId, "m")}
               {(request.ProductId is null ? string.Empty : "AND m.product_id = @productId")}
               {(request.DocType is null ? string.Empty : "AND g.doc_type = @docType")}
            """;

        var order = Order(
            request.Slice,
            "m.posted_at DESC, m.id DESC",
            new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["postedAt"] = "m.posted_at",
                ["docNo"] = "g.doc_no",
                ["qtyBase"] = "m.qty_base",
                ["docDate"] = "g.doc_date",
            });

        var from = "FROM inv_movement m JOIN inv_movement_group g ON g.id = m.group_id AND g.tenant_id = m.tenant_id";
        var sql = $"""
            SELECT COUNT(*) {from} {where};

            SELECT m.id AS MovementId, m.group_id AS GroupId, m.posted_at AS PostedAt, g.doc_date AS DocDate,
                   g.doc_type AS DocType, g.doc_no AS DocNo, m.product_id AS ProductId, m.location_id AS LocationId,
                   m.batch_id AS BatchId, bt.batch_no AS BatchNo, m.qty_base AS QtyBase, m.unit_cost AS UnitCost,
                   m.qty_base * m.unit_cost AS LineValue, g.reason_code_id AS ReasonCodeId
            {from}
              LEFT JOIN inv_batch bt ON bt.id = m.batch_id AND bt.tenant_id = m.tenant_id
            {where}
             ORDER BY {order}
             LIMIT @take OFFSET @skip;
            """;

        var parameters = Parameters(request.Scope, request.LocationId, request.Slice, p =>
        {
            p.Add("productId", request.ProductId);
            p.Add("docType", request.DocType);
            p.Add("fromAt", request.DateFrom.ToDateTime(TimeOnly.MinValue));
            p.Add("toAt", request.DateTo.AddDays(1).ToDateTime(TimeOnly.MinValue));
        });

        var set = await ReadSetAsync<MovementRow>(sql, parameters, cancellationToken).ConfigureAwait(false);
        return new ReportRowSet<MovementLedgerReportRow>(
            [.. set.Rows.Select(r => new MovementLedgerReportRow(
                r.MovementId, r.GroupId, new DateTimeOffset(DateTime.SpecifyKind(r.PostedAt, DateTimeKind.Utc)),
                Date(r.DocDate) ?? default, r.DocType, r.DocNo, r.ProductId, r.LocationId, r.BatchId, r.BatchNo,
                r.QtyBase, r.UnitCost, r.LineValue, r.ReasonCodeId))],
            set.Total);
    }

    public async Task<ReportRowSet<MovementAggregateReportRow>> GetMovementAggregateAsync(MovementAggregateReportRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var docType = (request.DocType ?? string.Empty).ToUpperInvariant();
        var (sideFilter, sign) = OutflowDocTypes.Contains(docType, StringComparer.Ordinal)
            ? (" AND m.qty_base < 0", -1)
            : InflowDocTypes.Contains(docType, StringComparer.Ordinal) ? (" AND m.qty_base > 0", 1) : (string.Empty, 1);

        var where = $"""
             WHERE m.tenant_id = @tenantId AND g.doc_type = @docType
               AND m.posted_at >= @fromAt AND m.posted_at < @toAt{sideFilter}
               {Where(request.Scope, "m")}{Single(request.LocationId, "m")}
               {(request.ProductId is null ? string.Empty : "AND m.product_id = @productId")}
            """;

        var order = Order(
            request.Slice,
            "QtyBase DESC",
            new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["qty"] = "QtyBase",
                ["totalValue"] = "TotalValue",
                ["productId"] = "ProductId",
                ["locationId"] = "LocationId",
            });

        var from = "FROM inv_movement m JOIN inv_movement_group g ON g.id = m.group_id AND g.tenant_id = m.tenant_id";
        var sql = $"""
            SELECT COUNT(*) FROM (SELECT 1 {from} {where} GROUP BY m.product_id, m.location_id) t;

            SELECT m.product_id AS ProductId, m.location_id AS LocationId,
                   SUM(m.qty_base * @sign) AS QtyBase,
                   SUM(m.qty_base * COALESCE(m.unit_cost, 0) * @sign) AS TotalValue,
                   CAST(COUNT(*) AS SIGNED) AS LineCount, MIN(g.doc_date) AS FirstDate, MAX(g.doc_date) AS LastDate
            {from}
            {where}
             GROUP BY m.product_id, m.location_id
             ORDER BY {order}
             LIMIT @take OFFSET @skip;
            """;

        var parameters = Parameters(request.Scope, request.LocationId, request.Slice, p =>
        {
            p.Add("productId", request.ProductId);
            p.Add("docType", docType);
            p.Add("sign", sign);
            p.Add("fromAt", request.DateFrom.ToDateTime(TimeOnly.MinValue));
            p.Add("toAt", request.DateTo.AddDays(1).ToDateTime(TimeOnly.MinValue));
        });

        var set = await ReadSetAsync<MovementAggregateRow>(sql, parameters, cancellationToken).ConfigureAwait(false);
        return new ReportRowSet<MovementAggregateReportRow>(
            [.. set.Rows.Select(r => new MovementAggregateReportRow(
                r.ProductId, r.LocationId, r.QtyBase, r.TotalValue, (int)r.LineCount,
                Date(r.FirstDate) ?? default, Date(r.LastDate) ?? default))],
            set.Total);
    }

    public async Task<ReportRowSet<CountVarianceReportRow>> GetCountVariancesAsync(CountVarianceReportRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var where = $"""
             WHERE cl.tenant_id = @tenantId
               AND DATE(COALESCE(c.frozen_at, c.created_at)) BETWEEN @fromDate AND @toDate
               {Where(request.Scope, "c")}{Single(request.LocationId, "c")}
               {(request.OnlyVariances ? "AND cl.variance_qty <> 0" : string.Empty)}
            """;

        var order = Order(
            request.Slice,
            "c.id DESC, cl.id",
            new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["varianceQty"] = "ABS(cl.variance_qty)",
                ["variancePct"] = "ABS(cl.variance_pct)",
                ["countDate"] = "COALESCE(c.frozen_at, c.created_at)",
                ["docNo"] = "c.doc_no",
            });

        var from = "FROM inv_count_line cl JOIN inv_count c ON c.id = cl.count_id AND c.tenant_id = cl.tenant_id";
        var sql = $"""
            SELECT COUNT(*) {from} {where};

            SELECT c.id AS CountId, c.doc_no AS DocNo, DATE(COALESCE(c.frozen_at, c.created_at)) AS CountDate,
                   c.status AS Status, c.location_id AS LocationId, cl.product_id AS ProductId, cl.batch_id AS BatchId,
                   bt.batch_no AS BatchNo, cl.book_qty AS SystemQty, COALESCE(cl.counted_qty, 0) AS CountedQty,
                   cl.variance_qty AS VarianceQty, cl.variance_pct AS VariancePct, cl.avg_unit_cost AS UnitCost,
                   cl.variance_qty * COALESCE(cl.avg_unit_cost, 0) AS VarianceValue
            {from}
              LEFT JOIN inv_batch bt ON bt.id = cl.batch_id AND bt.tenant_id = cl.tenant_id
            {where}
             ORDER BY {order}
             LIMIT @take OFFSET @skip;
            """;

        var parameters = Parameters(request.Scope, request.LocationId, request.Slice, p =>
        {
            p.Add("fromDate", request.DateFrom.ToDateTime(TimeOnly.MinValue));
            p.Add("toDate", request.DateTo.ToDateTime(TimeOnly.MinValue));
        });

        var set = await ReadSetAsync<CountVarianceRow>(sql, parameters, cancellationToken).ConfigureAwait(false);
        return new ReportRowSet<CountVarianceReportRow>(
            [.. set.Rows.Select(r => new CountVarianceReportRow(
                r.CountId, r.DocNo, Date(r.CountDate) ?? default, r.Status, r.LocationId, r.ProductId, r.BatchId,
                r.BatchNo, r.SystemQty, r.CountedQty, r.VarianceQty, r.VariancePct, r.UnitCost, r.VarianceValue))],
            set.Total);
    }

    public async Task<ReportRowSet<ReceiptVarianceReportRow>> GetReceiptVariancesAsync(ReceiptVarianceReportRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var where = $"""
             WHERE rl.tenant_id = @tenantId AND r.doc_date BETWEEN @fromDate AND @toDate
               {Where(request.Scope, "r")}{Single(request.LocationId, "r")}
               {(request.SupplierId is null ? string.Empty : "AND r.supplier_id = @supplierId")}
               {(request.OnlyVariances ? "AND (COALESCE(rl.rejected_qty, 0) <> 0 OR (rl.ordered_qty IS NOT NULL AND rl.ordered_qty <> rl.received_qty))" : string.Empty)}
            """;

        var order = Order(
            request.Slice,
            "r.doc_date DESC, r.id DESC, rl.line_no",
            new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["receiptDate"] = "r.doc_date",
                ["docNo"] = "r.doc_no",
                ["varianceQty"] = "ABS(rl.received_qty - COALESCE(rl.ordered_qty, rl.received_qty))",
                ["rejectedQty"] = "COALESCE(rl.rejected_qty, 0)",
            });

        var from = "FROM inv_goods_receipt_line rl JOIN inv_goods_receipt r ON r.id = rl.receipt_id AND r.tenant_id = rl.tenant_id";
        var sql = $"""
            SELECT COUNT(*) {from} {where};

            SELECT r.id AS ReceiptId, r.doc_no AS DocNo, r.doc_date AS ReceiptDate, r.status AS Status,
                   r.location_id AS LocationId, r.supplier_id AS SupplierId, rl.product_id AS ProductId,
                   COALESCE(rl.ordered_qty, 0) AS OrderedQty, rl.received_qty AS ReceivedQty,
                   rl.received_qty - COALESCE(rl.rejected_qty, 0) AS AcceptedQty,
                   COALESCE(rl.rejected_qty, 0) AS RejectedQty,
                   rl.received_qty - COALESCE(rl.ordered_qty, rl.received_qty) AS VarianceQty,
                   CASE WHEN COALESCE(rl.ordered_qty, 0) = 0 THEN 0
                        ELSE (rl.received_qty - rl.ordered_qty) * 100 / rl.ordered_qty END AS VariancePct,
                   rl.unit_price AS UnitCost
            {from}
            {where}
             ORDER BY {order}
             LIMIT @take OFFSET @skip;
            """;

        var parameters = Parameters(request.Scope, request.LocationId, request.Slice, p =>
        {
            p.Add("supplierId", request.SupplierId);
            p.Add("fromDate", request.DateFrom.ToDateTime(TimeOnly.MinValue));
            p.Add("toDate", request.DateTo.ToDateTime(TimeOnly.MinValue));
        });

        var set = await ReadSetAsync<ReceiptVarianceRow>(sql, parameters, cancellationToken).ConfigureAwait(false);
        return new ReportRowSet<ReceiptVarianceReportRow>(
            [.. set.Rows.Select(r => new ReceiptVarianceReportRow(
                r.ReceiptId, r.DocNo, Date(r.ReceiptDate) ?? default, r.Status, r.LocationId, r.SupplierId,
                r.ProductId, r.OrderedQty, r.ReceivedQty, r.AcceptedQty, r.RejectedQty, r.VarianceQty,
                r.VariancePct, r.UnitCost))],
            set.Total);
    }

    public async Task<ReportRowSet<StockCoverageReportRow>> GetStockCoverageAsync(StockCoverageReportRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var windowDays = Math.Clamp(request.WindowDays, 1, 3650);
        var where = $"""
             WHERE b.tenant_id = @tenantId AND b.qty_on_hand <> 0{Where(request.Scope, "b")}{Single(request.LocationId, "b")}
               {(request.ProductId is null ? string.Empty : "AND b.product_id = @productId")}
            """;

        var consumption = """
            LEFT JOIN (
                SELECT m.product_id AS product_id, m.location_id AS location_id, -SUM(m.qty_base) AS consumed
                  FROM inv_movement m
                  JOIN inv_movement_group g ON g.id = m.group_id AND g.tenant_id = m.tenant_id
                 WHERE m.tenant_id = @tenantId AND m.qty_base < 0 AND m.posted_at >= @windowFrom
                   AND g.doc_type IN ('CONSUMPTION','ISSUE','WASTE','SAMPLE','TRANSFER')
                 GROUP BY m.product_id, m.location_id
            ) c ON c.product_id = b.product_id AND c.location_id = b.location_id
            """;

        var sql = $"""
            SELECT COUNT(*) FROM (SELECT 1 FROM inv_balance b {where} GROUP BY b.product_id, b.location_id) t;

            SELECT b.product_id AS ProductId, b.location_id AS LocationId,
                   SUM(b.qty_on_hand) AS QtyOnHand,
                   COALESCE(MAX(c.consumed), 0) AS ConsumedQty,
                   SUM(b.qty_on_hand * b.avg_unit_cost) AS TotalValue,
                   CASE WHEN SUM(b.qty_on_hand) = 0 THEN 0
                        ELSE SUM(b.qty_on_hand * b.avg_unit_cost) / SUM(b.qty_on_hand) END AS AvgUnitCost
              FROM inv_balance b
            {consumption}
            {where}
             GROUP BY b.product_id, b.location_id
             ORDER BY b.location_id, b.product_id
             LIMIT @take OFFSET @skip;
            """;

        var parameters = Parameters(request.Scope, request.LocationId, request.Slice, p =>
        {
            p.Add("productId", request.ProductId);
            p.Add("windowFrom", clock.UtcNow.UtcDateTime.Date.AddDays(-windowDays));
        });

        var set = await ReadSetAsync<CoverageRow>(sql, parameters, cancellationToken).ConfigureAwait(false);
        return new ReportRowSet<StockCoverageReportRow>(
            [.. set.Rows.Select(r =>
            {
                var daily = Math.Round(r.ConsumedQty / windowDays, 4, MidpointRounding.AwayFromZero);
                decimal? coverage = daily <= 0m ? null : Math.Round(r.QtyOnHand / daily, 1, MidpointRounding.AwayFromZero);
                return new StockCoverageReportRow(
                    r.ProductId, r.LocationId, r.QtyOnHand, r.ConsumedQty, daily, coverage, r.AvgUnitCost, r.TotalValue);
            })],
            set.Total);
    }

    private static IReadOnlyList<DashboardDayPoint> Points(IEnumerable<SeriesRow> rows) =>
        [.. rows.Select(r => new DashboardDayPoint(DateOnly.FromDateTime(r.Day), r.Value))];

    private static DateOnly? Date(DateTime? value) => value is { } v ? DateOnly.FromDateTime(v) : null;

    /// <summary>Location restriction of spec §16. A restricted scope with no ids matches nothing — never everything.</summary>
    private static string Where(ReportingScope scope, string alias)
    {
        ArgumentNullException.ThrowIfNull(scope);
        if (!scope.IsRestricted)
        {
            return string.Empty;
        }

        return scope.LocationIds!.Count == 0 ? " AND 1 = 0" : $" AND {alias}.location_id IN @locationIds";
    }

    /// <summary>Documents visible through either end (an issue is visible to both the source and the target branch).</summary>
    private static string BothEnds(ReportingScope scope, string alias)
    {
        ArgumentNullException.ThrowIfNull(scope);
        if (!scope.IsRestricted)
        {
            return string.Empty;
        }

        return scope.LocationIds!.Count == 0
            ? " AND 1 = 0"
            : $" AND ({alias}.from_location_id IN @locationIds OR {alias}.to_location_id IN @locationIds)";
    }

    private static string Single(uint? locationId, string alias) =>
        locationId is null ? string.Empty : $" AND {alias}.location_id = @locationId";

    private static string SingleBothEnds(uint? locationId, string alias) =>
        locationId is null ? string.Empty : $" AND ({alias}.from_location_id = @locationId OR {alias}.to_location_id = @locationId)";

    private static string Order(ReportSlice slice, string naturalOrder, IReadOnlyDictionary<string, string> allowed)
    {
        if (slice.SortKey is null || !allowed.TryGetValue(slice.SortKey, out var expression))
        {
            return naturalOrder;
        }

        return slice.Descending ? expression + " DESC" : expression;
    }

    private DynamicParameters Parameters(ReportingScope scope, uint? locationId, ReportSlice slice, Action<DynamicParameters>? extra = null)
    {
        var parameters = new DynamicParameters();
        parameters.Add("tenantId", tenantContext.TenantId);
        parameters.Add("locationIds", scope.LocationIds is { Count: > 0 } ids ? ids : null);
        parameters.Add("locationId", locationId);
        parameters.Add("skip", slice.SafeSkip);
        parameters.Add("take", slice.SafeTake);
        extra?.Invoke(parameters);
        return parameters;
    }

    private async Task<ReportRowSet<T>> ReadSetAsync<T>(string sql, DynamicParameters parameters, CancellationToken cancellationToken)
    {
        var connection = db.Database.GetDbConnection();
        await db.Database.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            using var reader = await connection
                .QueryMultipleAsync(new CommandDefinition(sql, parameters, cancellationToken: cancellationToken))
                .ConfigureAwait(false);
            var total = await reader.ReadSingleAsync<long>().ConfigureAwait(false);
            var rows = (await reader.ReadAsync<T>().ConfigureAwait(false)).ToList();
            return new ReportRowSet<T>(rows, total);
        }
        finally
        {
            await db.Database.CloseConnectionAsync().ConfigureAwait(false);
        }
    }

    private sealed class StockTotalsRow
    {
        public long BalanceRows { get; set; }

        public decimal QtyOnHand { get; set; }

        public decimal StockValue { get; set; }
    }

    private sealed class ExpiryCountsRow
    {
        public long Expiring { get; set; }

        public long Critical { get; set; }

        public long Expired { get; set; }
    }

    private sealed class PendingCountsRow
    {
        public long PendingWaste { get; set; }

        public long CountsInReview { get; set; }

        public long OpenRequests { get; set; }
    }

    private sealed class PeriodPairRow
    {
        public decimal Current { get; set; }

        public decimal Previous { get; set; }
    }

    private sealed class SeriesRow
    {
        public DateTime Day { get; set; }

        public decimal Value { get; set; }
    }

    private sealed class StockBalanceRow
    {
        public uint ProductId { get; set; }

        public uint LocationId { get; set; }

        public decimal QtyOnHand { get; set; }

        public decimal QtyReserved { get; set; }

        public decimal QtyAvailable { get; set; }

        public decimal AvgUnitCost { get; set; }

        public decimal TotalValue { get; set; }

        public long BatchCount { get; set; }
    }

    private sealed class BatchStockRow
    {
        public long BatchId { get; set; }

        public string BatchNo { get; set; } = string.Empty;

        public uint ProductId { get; set; }

        public uint LocationId { get; set; }

        public DateTime? ExpiryDate { get; set; }

        public DateTime? ProductionDate { get; set; }

        public string BatchStatus { get; set; } = string.Empty;

        public long? DaysToExpiry { get; set; }

        public uint? SupplierId { get; set; }

        public decimal QtyOnHand { get; set; }

        public decimal AvgUnitCost { get; set; }

        public decimal TotalValue { get; set; }
    }

    private sealed class MovementRow
    {
        public long MovementId { get; set; }

        public long GroupId { get; set; }

        public DateTime PostedAt { get; set; }

        public DateTime? DocDate { get; set; }

        public string DocType { get; set; } = string.Empty;

        public string DocNo { get; set; } = string.Empty;

        public uint ProductId { get; set; }

        public uint LocationId { get; set; }

        public long? BatchId { get; set; }

        public string? BatchNo { get; set; }

        public decimal QtyBase { get; set; }

        public decimal? UnitCost { get; set; }

        public decimal? LineValue { get; set; }

        public uint? ReasonCodeId { get; set; }
    }

    private sealed class MovementAggregateRow
    {
        public uint ProductId { get; set; }

        public uint LocationId { get; set; }

        public decimal QtyBase { get; set; }

        public decimal TotalValue { get; set; }

        public long LineCount { get; set; }

        public DateTime? FirstDate { get; set; }

        public DateTime? LastDate { get; set; }
    }

    private sealed class CountVarianceRow
    {
        public long CountId { get; set; }

        public string DocNo { get; set; } = string.Empty;

        public DateTime? CountDate { get; set; }

        public string Status { get; set; } = string.Empty;

        public uint LocationId { get; set; }

        public uint ProductId { get; set; }

        public long? BatchId { get; set; }

        public string? BatchNo { get; set; }

        public decimal SystemQty { get; set; }

        public decimal CountedQty { get; set; }

        public decimal VarianceQty { get; set; }

        public decimal VariancePct { get; set; }

        public decimal? UnitCost { get; set; }

        public decimal? VarianceValue { get; set; }
    }

    private sealed class ReceiptVarianceRow
    {
        public long ReceiptId { get; set; }

        public string DocNo { get; set; } = string.Empty;

        public DateTime? ReceiptDate { get; set; }

        public string Status { get; set; } = string.Empty;

        public uint LocationId { get; set; }

        public uint? SupplierId { get; set; }

        public uint ProductId { get; set; }

        public decimal OrderedQty { get; set; }

        public decimal ReceivedQty { get; set; }

        public decimal AcceptedQty { get; set; }

        public decimal RejectedQty { get; set; }

        public decimal VarianceQty { get; set; }

        public decimal VariancePct { get; set; }

        public decimal? UnitCost { get; set; }
    }

    private sealed class CoverageRow
    {
        public uint ProductId { get; set; }

        public uint LocationId { get; set; }

        public decimal QtyOnHand { get; set; }

        public decimal ConsumedQty { get; set; }

        public decimal AvgUnitCost { get; set; }

        public decimal TotalValue { get; set; }
    }
}
