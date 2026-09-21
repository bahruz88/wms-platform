using System.Globalization;
using Wms.Common.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Domain;

/// <summary>
/// Error catalogue of the Consumption module. Every <see cref="Error.Code"/> surfaces as the RFC 7807 <c>code</c>
/// extension documented in <c>contracts/openapi/consumption.v1.yaml</c>.
/// </summary>
public static class ConsumptionErrors
{
    public static Error MenuItemNotFound(long menuItemId) =>
        new("NOT_FOUND", $"Menu item {menuItemId} was not found.", 404);

    public static Error RecipeNotFound(long recipeId) =>
        new("NOT_FOUND", $"Recipe version {recipeId} was not found.", 404);

    public static Error SalesImportNotFound(long importId) =>
        new("NOT_FOUND", $"Sales import {importId} was not found.", 404);

    public static Error RunNotFound(long runId) =>
        new("NOT_FOUND", $"Consumption run {runId} was not found.", 404);

    public static Error DuplicateCode(string code) =>
        new("DUPLICATE_CODE", $"Menu item code '{code}' already exists for this tenant.", 409);

    public static Error DuplicatePosCode(string posCode) =>
        new("DUPLICATE_CODE", $"POS code '{posCode}' is already mapped to another menu item.", 409);

    /// <summary>Invariant 2: one document per (location, business_date) for both sales imports and runs.</summary>
    public static Error DuplicateBusinessDate(uint locationId, DateOnly businessDate) =>
        new(
            "DUPLICATE_BUSINESS_DATE",
            $"Location {locationId} already has a document for {businessDate:yyyy-MM-dd}; correct it or reverse it instead of creating a second one.",
            409);

    /// <summary>Invariant 6: a sub-recipe cycle stops the calculation.</summary>
    public static Error RecipeCycle(IReadOnlyList<uint> path) =>
        new("RECIPE_CYCLE", $"Sub-recipe cycle detected: {string.Join(" -> ", path)}.", 422);

    public static Error RecipeDepthExceeded(int maxDepth, IReadOnlyList<uint> path) =>
        new("RECIPE_DEPTH_EXCEEDED", $"Sub-recipe nesting exceeds the maximum depth of {maxDepth}: {string.Join(" -> ", path)}.", 422);

    public static Error RecipeEmpty(long recipeId) =>
        new("RECIPE_EMPTY", $"Recipe version {recipeId} has no component lines; an empty recipe cannot be activated or exploded.", 422);

    /// <summary>Invariant 4: the recipe version and the conversion factor of the business date are frozen into the ledger.</summary>
    public static Error PeriodClosed(DateOnly businessDate) =>
        new(
            "PERIOD_CLOSED",
            $"A consumption document is already posted on or after {businessDate:yyyy-MM-dd}; a recipe version cannot start before a posted day.",
            409);

    public static Error UomFactorMissing(uint productId, ushort uomId, DateOnly date) =>
        new("UOM_FACTOR_MISSING", $"No conversion factor for product {productId} and UoM {uomId} valid on {date:yyyy-MM-dd}.", 422);

    public static Error UomFactorMissing(uint productId, ushort uomId) =>
        new("UOM_FACTOR_MISSING", $"No conversion factor for product {productId} and UoM {uomId} on the business date.", 422);

    /// <summary>A SUB_RECIPE line points at a menu item that has no effective recipe version on the business date.</summary>
    public static Error SubRecipeMissing(uint menuItemId) =>
        new("RECIPE_EMPTY", $"Sub-recipe menu item {menuItemId} has no recipe version effective on the business date.", 422);

    public static Error InvalidStateTransition(string entity, object id, object from, object to) =>
        new("INVALID_STATE_TRANSITION", $"{entity} {id} is {from}; the operation requires a different state (target {to}).", 409);

    public static Error LocationFrozen(uint locationId) =>
        new("LOCATION_FROZEN", $"Location {locationId} is frozen by an inventory count; consumption is not posted.", 409);

    public static Error FileTooLarge(long bytes, long maxBytes) =>
        new(
            "FILE_TOO_LARGE",
            string.Create(CultureInfo.InvariantCulture, $"The uploaded file is {bytes} bytes; the limit is {maxBytes} bytes."),
            422);

    public static Error ProductNotFound(uint productId) =>
        new("PRODUCT_NOT_FOUND", $"Product {productId} does not exist or is inactive.", 422);

    public static Error LocationNotFound(uint locationId) =>
        new("LOCATION_NOT_FOUND", $"Location {locationId} does not exist or is inactive.", 422);

    public static Error VirtualLocationMissing(string locationType) =>
        new("VIRTUAL_LOCATION_MISSING", $"The tenant has no {locationType} virtual location configured.", 422);

    public static Error InvalidRecipeLine(string reason) =>
        new("INVALID_RECIPE_LINE", reason, 422);

    public static Error InvalidMenuItem(string reason) =>
        new("INVALID_MENU_ITEM", reason, 422);

    public static Error InvalidSalesLine(string reason) =>
        new("INVALID_SALES_LINE", reason, 422);

    public static Error SalesImportNotSubmitted(long importId, SalesImportStatus status) =>
        new("INVALID_STATE_TRANSITION", $"Sales import {importId} is {status}; a consumption run needs a SUBMITTED import.", 422);

    public static Error CsvParseFailed(string reason) =>
        new("CSV_PARSE_FAILED", reason, 422);

    public static Error PostingFailed(string code, string message, int status) =>
        new(code, message, status);
}
