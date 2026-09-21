namespace Wms.MasterData.Application;

public static class MasterDataPermissions
{
    public const string ProductView = "master.product.view";
    public const string ProductManage = "master.product.manage";

    /// <summary>Spec §7.1 / TOR §3.1, §40: a warehouse keeper must NOT have this.</summary>
    public const string ProductViewCost = "master.product.view_cost";

    public const string SupplierView = "master.supplier.view";
    public const string SupplierManage = "master.supplier.manage";
    public const string LocationView = "master.location.view";
    public const string LocationManage = "master.location.manage";
    public const string ReasonCodeManage = "master.reason_code.manage";
}
