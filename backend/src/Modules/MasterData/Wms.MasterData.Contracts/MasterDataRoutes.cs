namespace Wms.MasterData.Contracts;

public static class MasterDataRoutes
{
    public const string ModuleName = "MasterData";
    public const string Prefix = "/api/v1/masterdata";
    public const string InternalProduct = Prefix + "/internal/products/{productId}";
    public const string InternalUomFactor = Prefix + "/internal/products/{productId}/uom-factor";
    public const string InternalLocation = Prefix + "/internal/locations/{locationId}";
    public const string InternalVirtualLocation = Prefix + "/internal/locations/virtual/{locationType}";
    public const string InternalNextNumber = Prefix + "/internal/number-sequences/{docType}/next";
    public const string InternalBaseCurrency = Prefix + "/internal/currency/base";
    public const string InternalRate = Prefix + "/internal/currency/{currency}/rate";
}
