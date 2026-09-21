using System.Globalization;
using Wms.Common.Domain;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Domain;

/// <summary>Error catalogue of the Inventory module. Codes surface as RFC 7807 <c>code</c> (spec §13.3).</summary>
public static class InventoryErrors
{
    public static Error InsufficientStock(uint productId, uint locationId, decimal available, decimal requested) =>
        new(
            "INSUFFICIENT_STOCK",
            string.Create(CultureInfo.InvariantCulture, $"Product {productId} at location {locationId}: available {available:0.0000}, requested {requested:0.0000}."),
            409);

    public static Error InsufficientStockForAllocation(decimal available, decimal requested) =>
        new(
            "INSUFFICIENT_STOCK",
            string.Create(CultureInfo.InvariantCulture, $"Allocatable quantity {available:0.0000} is below the requested {requested:0.0000}."),
            409);

    public static Error LocationFrozen(uint locationId) =>
        new("LOCATION_FROZEN", $"Location {locationId} is frozen by an inventory count; operations are blocked.", 409);

    public static Error EmptyMovementGroup() =>
        new("EMPTY_MOVEMENT_GROUP", "A movement group needs at least two lines (double-entry).", 422);

    public static Error ZeroQuantityLine(int lineNo) =>
        new("ZERO_QUANTITY_LINE", $"Line {lineNo} has a zero base quantity after conversion and rounding.", 422);

    public static Error UnbalancedMovementGroup(decimal sum) =>
        new(
            "UNBALANCED_MOVEMENT_GROUP",
            string.Create(CultureInfo.InvariantCulture, $"Movement group does not balance to zero (SUM(qty_base) = {sum:0.0000})."),
            422);

    public static Error BalanceKeyMismatch() =>
        new("BALANCE_KEY_MISMATCH", "The movement does not belong to this balance row (tenant/product/location/batch).", 422);

    public static Error ReceiptNotFound(long receiptId) =>
        new("RECEIPT_NOT_FOUND", $"Goods receipt {receiptId} was not found.", 404);

    public static Error ReceiptNotDraft(long receiptId, ReceiptStatus status) =>
        new("RECEIPT_NOT_DRAFT", $"Goods receipt {receiptId} is {status}; only DRAFT receipts can be changed or posted.", 409);

    public static Error ReceiptHasNoLines(long receiptId) =>
        new("RECEIPT_HAS_NO_LINES", $"Goods receipt {receiptId} has no lines to post.", 422);

    public static Error InvalidReceiptLine(string reason) =>
        new("INVALID_RECEIPT_LINE", reason, 422);

    public static Error VarianceNoteRequired(int lineNo) =>
        new("VARIANCE_NOTE_REQUIRED", $"Line {lineNo}: received quantity differs from the ordered quantity beyond tolerance; variance_note is mandatory.", 422);

    public static Error ProductNotFound(uint productId) =>
        new("PRODUCT_NOT_FOUND", $"Product {productId} does not exist or is inactive.", 422);

    public static Error UomFactorNotFound(uint productId, ushort uomId, DateOnly date) =>
        new("UOM_FACTOR_NOT_FOUND", $"No conversion factor for product {productId} and UoM {uomId} valid on {date:yyyy-MM-dd}.", 422);

    public static Error FxRateMissing(string currency, DateOnly date) =>
        new("FX_RATE_MISSING", $"No CBAR rate for {currency} on {date:yyyy-MM-dd}; the receipt is blocked (spec §12.5).", 422);

    public static Error VirtualLocationMissing(string locationType) =>
        new("VIRTUAL_LOCATION_MISSING", $"The tenant has no {locationType} virtual location configured.", 422);

    public static Error LocationNotFound(uint locationId) =>
        new("LOCATION_NOT_FOUND", $"Location {locationId} does not exist or is inactive.", 422);

    public static Error BatchRequired(uint productId) =>
        new("BATCH_REQUIRED", $"Product {productId} requires a batch number.", 422);

    public static Error ExpiryRequired(uint productId) =>
        new("EXPIRY_REQUIRED", $"Product {productId} requires an expiry date.", 422);

    public static Error InvalidBatch(string reason) =>
        new("INVALID_BATCH", reason, 422);

    public static Error BatchNotAllocatable(long batchId, BatchStatus status) =>
        new("BATCH_NOT_ALLOCATABLE", $"Batch {batchId} is {status} and cannot be issued.", 409);

    public static Error InvalidBatchTransition(BatchStatus from, BatchStatus to) =>
        new("INVALID_BATCH_TRANSITION", $"Batch status cannot change from {from} to {to}.", 409);

    public static Error InvalidQuantity(string reason) =>
        new("INVALID_QUANTITY", reason, 422);
}
