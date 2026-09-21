using Dapper;
using Wms.Common.Application.Abstractions;
using Wms.Inventory.Contracts;
using Wms.Inventory.Infrastructure.Persistence;

namespace Wms.Inventory.Infrastructure.Contracts;

/// <summary>
/// In-process <see cref="IStockMovementReader"/>. One pass over <c>inv_movement</c> per request, split by
/// <c>doc_type</c>: the opening position is everything posted before the period, the buckets are the flows inside
/// it. <c>COUNT_ADJUST</c> is kept separate because it IS the variance the report wants to explain.
/// </summary>
public sealed class StockMovementReader(InventoryDbContext db, ITenantContext tenantContext) : IStockMovementReader
{
    private const string Sql = """
        SELECT m.product_id  AS ProductId,
               m.location_id AS LocationId,
               COALESCE(SUM(CASE WHEN m.posted_at <  @fromAt THEN m.qty_base END), 0) AS OpeningQty,
               COALESCE(SUM(CASE WHEN m.posted_at >= @fromAt AND m.posted_at < @toAt AND eff.doc_type = 'RECEIPT'                THEN  m.qty_base END), 0) AS ReceivedQty,
               COALESCE(SUM(CASE WHEN m.posted_at >= @fromAt AND m.posted_at < @toAt AND eff.doc_type = 'CONSUMPTION'            THEN -m.qty_base END), 0) AS ConsumedQty,
               COALESCE(SUM(CASE WHEN m.posted_at >= @fromAt AND m.posted_at < @toAt AND eff.doc_type = 'WASTE'                  THEN -m.qty_base END), 0) AS WasteQty,
               COALESCE(SUM(CASE WHEN m.posted_at >= @fromAt AND m.posted_at < @toAt AND eff.doc_type = 'SAMPLE'                 THEN -m.qty_base END), 0) AS SampleQty,
               COALESCE(SUM(CASE WHEN m.posted_at >= @fromAt AND m.posted_at < @toAt AND eff.doc_type IN ('TRANSFER','ISSUE')    THEN  m.qty_base END), 0) AS TransferNetQty,
               COALESCE(SUM(CASE WHEN m.posted_at >= @fromAt AND m.posted_at < @toAt AND eff.doc_type = 'COUNT_ADJUST'           THEN  m.qty_base END), 0) AS CountAdjustQty,
               COALESCE(SUM(CASE WHEN m.posted_at <  @toAt THEN m.qty_base END), 0) AS ClosingQty,
               COALESCE(MAX(b.avg_unit_cost), 0) AS AvgUnitCost
          FROM inv_movement m
          JOIN inv_movement_group g ON g.id = m.group_id
          -- A REVERSAL carries no bucket of its own: it belongs to the document it cancels, with the
          -- opposite sign. Grouping by location already keeps the counter-account out of this row, so the
          -- buckets need no sign filter and a storno simply nets its original off again.
          JOIN inv_movement_group eff ON eff.id = COALESCE(g.reverses_group_id, g.id)
          LEFT JOIN inv_balance b ON b.tenant_id = m.tenant_id AND b.product_id = m.product_id
                                 AND b.location_id = m.location_id AND b.batch_id = 0
         WHERE m.tenant_id = @tenantId
           AND m.posted_at < @toAt
           AND (@locationId IS NULL OR m.location_id = @locationId)
           AND (@productId  IS NULL OR m.product_id  = @productId)
         GROUP BY m.product_id, m.location_id
         ORDER BY m.location_id, m.product_id
        """;

    public async Task<IReadOnlyList<StockPeriodFlowDto>> GetPeriodFlowsAsync(
        uint? locationId,
        uint? productId,
        DateOnly periodFrom,
        DateOnly periodTo,
        CancellationToken cancellationToken)
    {
        var parameters = new
        {
            tenantId = tenantContext.TenantId,
            locationId,
            productId,
            fromAt = periodFrom.ToDateTime(TimeOnly.MinValue),
            toAt = periodTo.AddDays(1).ToDateTime(TimeOnly.MinValue),
        };

        var connection = db.Database.GetDbConnection();
        await db.Database.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            var rows = await connection
                .QueryAsync<StockPeriodFlowDto>(new CommandDefinition(Sql, parameters, cancellationToken: cancellationToken))
                .ConfigureAwait(false);
            return rows.ToList();
        }
        finally
        {
            await db.Database.CloseConnectionAsync().ConfigureAwait(false);
        }
    }
}
