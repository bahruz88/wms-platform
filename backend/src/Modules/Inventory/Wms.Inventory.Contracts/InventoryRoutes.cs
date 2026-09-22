namespace Wms.Inventory.Contracts;

public static class InventoryRoutes
{
    public const string ModuleName = "Inventory";
    public const string Prefix = "/api/v1/inventory";
    public const string InternalStockLevel = Prefix + "/internal/stock-levels/{productId}/{locationId}";
    public const string InternalStockLevelsByProduct = Prefix + "/internal/stock-levels/{productId}";
    public const string InternalConsumptionPosting = Prefix + "/internal/consumption-postings";
    public const string InternalReversal = Prefix + "/internal/reversals";
    public const string InternalPeriodFlows = Prefix + "/internal/period-flows";
    public const string InternalLocationFrozen = Prefix + "/internal/locations/{locationId}/frozen";

    // Reporting aggregations (IInventoryReportingSource). POST, because a report filter does not fit a query
    // string safely — see the remark on the interface.
    public const string InternalReportDashboard = Prefix + "/internal/reporting/dashboard";
    public const string InternalReportStockBalances = Prefix + "/internal/reporting/stock-balances";
    public const string InternalReportBatchStock = Prefix + "/internal/reporting/batch-stock";
    public const string InternalReportMovements = Prefix + "/internal/reporting/movements";
    public const string InternalReportMovementAggregate = Prefix + "/internal/reporting/movement-aggregate";
    public const string InternalReportCountVariances = Prefix + "/internal/reporting/count-variances";
    public const string InternalReportReceiptVariances = Prefix + "/internal/reporting/receipt-variances";
    public const string InternalReportStockCoverage = Prefix + "/internal/reporting/stock-coverage";
}
