namespace Wms.MasterData.Application;

/// <summary>
/// The <c>x-permission</c> values of <c>contracts/openapi/masterdata.v1.yaml</c>. The contract is authoritative:
/// a rename here without a contract change silently locks a screen out.
/// </summary>
public static class MasterDataPermissions
{
    public const string ProductView = "master.product.view";
    public const string ProductManage = "master.product.manage";

    /// <summary>Spec §7.1 / TOR §3.1, §40: a warehouse keeper must NOT have this.</summary>
    public const string ProductViewCost = "master.product.view_cost";

    public const string CategoryManage = "master.category.manage";
    public const string UomManage = "master.uom.manage";

    public const string SupplierView = "master.supplier.view";
    public const string SupplierManage = "master.supplier.manage";

    public const string LocationView = "master.location.view";
    public const string LocationManage = "master.location.manage";

    public const string CurrencyView = "master.currency.view";
    public const string CurrencyManage = "master.currency.manage";

    public const string ReasonView = "master.reason.view";
    public const string ReasonManage = "master.reason.manage";

    public const string SequenceView = "master.sequence.view";
}
