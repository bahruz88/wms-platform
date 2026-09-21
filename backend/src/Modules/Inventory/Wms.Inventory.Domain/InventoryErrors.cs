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

    // ---------------------------------------------------------------- Counts (spec §9.6, §12.6, §12.7)
    public static Error CountNotFound(long countId) =>
        new("COUNT_NOT_FOUND", $"Inventory count {countId} was not found.", 404);

    public static Error InvalidCount(string reason) =>
        new("INVALID_COUNT", reason, 422);

    public static Error InvalidCountTransition(CountStatus from, CountStatus to) =>
        new("INVALID_STATE_TRANSITION", $"An inventory count cannot go from {from} to {to}.", 409);

    public static Error CountAlreadyOpen(uint locationId, string docNo) =>
        new("COUNT_ALREADY_OPEN", $"Location {locationId} already has an open inventory count ({docNo}).", 422);

    public static Error CountScopeRequired(string countType, string field) =>
        new("COUNT_SCOPE_REQUIRED", $"A {countType} count needs {field}.", 422);

    public static Error CountLinesIncomplete(IReadOnlyCollection<uint> productIds) =>
        new(
            "COUNT_LINES_INCOMPLETE",
            $"Every line needs a counted quantity before review; {productIds.Count} product(s) are still open: {string.Join(", ", productIds.Take(10))}.",
            422);

    public static Error CountEmpty(long countId) =>
        new("COUNT_EMPTY", $"Inventory count {countId} has no lines; freeze it first.", 422);

    /// <summary>Spec §12.6: a non-zero variance must say why.</summary>
    public static Error ReasonCodeRequired(uint productId) =>
        new("REASON_CODE_REQUIRED", $"Product {productId} has a non-zero variance; reason_code_id is mandatory (spec §12.6).", 422);

    public static Error ReasonCodeNotFound(ushort reasonCodeId, string expectedGroup) =>
        new("REASON_CODE_NOT_FOUND", $"Reason code {reasonCodeId} does not exist, is inactive, or is not in the {expectedGroup} group.", 422);

    /// <summary>Spec §7.1 / TOR §21: the person who counted may not approve their own variance.</summary>
    public static Error ClaimCurrencyMismatch(string supplied, string expected) =>
        new(
            "CLAIM_CURRENCY_MISMATCH",
            $"claimAmount.currency '{supplied}' differs from the tenant base currency '{expected}'; inv_return_to_vendor stores the amount in the base currency only.",
            422);

    public static Error SettingNotFound(string key) =>
        new("SETTING_NOT_FOUND", $"'{key}' is not an inv_setting key.", 404);

    public static Error InvalidSettingValue(string key, string reason) =>
        new("INVALID_SETTING_VALUE", $"inv_setting '{key}': {reason}", 422);

    public static Error SelfApprovalForbidden() =>
        new("SELF_APPROVAL_FORBIDDEN", "The user who raised the document cannot approve it (segregation of duties).", 403);

    /// <summary>Fail-closed: without a resolved <c>iam_user</c> row the self-approval rule cannot be evaluated.</summary>
    public static Error ApproverUnknown() =>
        new("APPROVER_UNKNOWN", "The approving user could not be resolved to an iam_user row.", 403);

    public static Error ApprovalCommentRequired() =>
        new("APPROVAL_COMMENT_REQUIRED", "A rejection must carry a comment.", 422);

    // ---------------------------------------------------------------- Stock requests, issues, waste, samples, RTV
    public static Error DocumentNotFound(string document, long id) =>
        new("NOT_FOUND", $"The {document} {id} was not found.", 404);

    public static Error InvalidDocument(string reason) =>
        new("INVALID_DOCUMENT", reason, 422);

    public static Error DocumentNotDraft(string document, long id, string status) =>
        new("INVALID_STATE_TRANSITION", $"The {document} {id} is {status}; only a DRAFT document can be changed.", 409);

    public static Error InvalidDocumentTransition(string document, string from, string to) =>
        new("INVALID_STATE_TRANSITION", $"A {document} cannot go from {from} to {to}.", 409);

    public static Error SameLocation() =>
        new("SAME_LOCATION", "The source and target locations must differ.", 422);

    public static Error IssueLineNotFound(long lineId) =>
        new("ISSUE_LINE_NOT_FOUND", $"Issue line {lineId} does not belong to this document.", 422);

    public static Error IssueLinesUnconfirmed(IReadOnlyCollection<ushort> lineNos) =>
        new(
            "ISSUE_LINES_UNCONFIRMED",
            $"Every dispatched line must be confirmed; line(s) {string.Join(", ", lineNos)} are still open.",
            422);

    /// <summary>A branch that received something other than what was sent must say why (TOR §17).</summary>
    public static Error DiscrepancyReasonRequired(ushort lineNo) =>
        new("DISCREPANCY_REASON_REQUIRED", $"Line {lineNo}: a receipt discrepancy needs a reason code and a note.", 422);

    /// <summary>Spec §12.4: picking a batch other than the FEFO/FIFO suggestion is allowed, but must be explained.</summary>
    public static Error BatchOverrideReasonRequired(ushort lineNo) =>
        new("BATCH_OVERRIDE_REASON_REQUIRED", $"Line {lineNo}: choosing a batch other than the suggested one needs a reason code.", 422);

    public static Error PhotoRequired(ushort reasonCodeId) =>
        new("PHOTO_REQUIRED", $"Reason code {reasonCodeId} requires at least one photo attachment.", 422);

    public static Error MovementGroupNotFound(long groupId) =>
        new("NOT_FOUND", $"Movement group {groupId} was not found.", 404);

    public static Error AlreadyReversed(long groupId) =>
        new("INVALID_STATE_TRANSITION", $"Movement group {groupId} is already reversed.", 409);

    public static Error BatchNotFound(long batchId) =>
        new("BATCH_NOT_FOUND", $"Batch {batchId} was not found.", 404);
}
