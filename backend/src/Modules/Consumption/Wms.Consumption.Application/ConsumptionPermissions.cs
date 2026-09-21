namespace Wms.Consumption.Application;

/// <summary>Permission codes of the module (<c>iam_permission.code</c>, branch-operations.md §8).</summary>
public static class ConsumptionPermissions
{
    public const string RecipeManage = "cons.recipe.manage";
    public const string RecipeView = "cons.recipe.view";
    public const string SalesImport = "cons.sales.import";
    public const string RunCalculate = "cons.run.calculate";
    public const string RunPost = "cons.run.post";
    public const string VarianceView = "cons.variance.view";

    /// <summary>Owned by Inventory; the contract puts the storno of a consumption document behind it.</summary>
    public const string MovementReverse = "inv.movement.reverse";

    /// <summary>Owned by MasterData but enforced here: without it cost fields are omitted from DTOs (spec §16).</summary>
    public const string ViewCost = "master.product.view_cost";
}
