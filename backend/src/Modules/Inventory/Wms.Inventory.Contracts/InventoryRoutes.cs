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
}
