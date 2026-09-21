namespace Wms.Consumption.Domain.Enums;

/// <summary><c>cons_recipe.status</c>. A menu item has at most one ACTIVE version per day (branch-operations.md §4).</summary>
public enum RecipeStatus
{
    Draft,
    Active,
    Archived,
}

/// <summary><c>cons_recipe_line.component_type</c>: a warehouse product, or a semi-finished item prepared in the branch.</summary>
public enum ComponentType
{
    FoodProduct,
    SubRecipe,
}

/// <summary><c>cons_sales_import.source</c> (ADR-012). All three sources share the same downstream flow.</summary>
public enum SalesSource
{
    Pos,
    Csv,
    Manual,
}

/// <summary><c>cons_sales_import.status</c>. CONSUMED means a consumption run for this import has been posted.</summary>
public enum SalesImportStatus
{
    Draft,
    Submitted,
    Consumed,
    Cancelled,
}

/// <summary><c>cons_run.status</c>. FAILED keeps the document so the reason can be investigated.</summary>
public enum ConsumptionRunStatus
{
    Draft,
    Calculated,
    Posted,
    Failed,
    Reversed,
}
