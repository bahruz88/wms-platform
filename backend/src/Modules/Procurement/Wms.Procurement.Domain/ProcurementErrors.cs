using Wms.Common.Domain;

namespace Wms.Procurement.Domain;

/// <summary>
/// RFC 7807 <c>code</c> values of <c>contracts/openapi/procurement.v1.yaml</c>. The contract is the authority:
/// every code spelled out in an operation description appears here exactly once.
/// </summary>
public static class ProcurementErrors
{
    public static Error InvalidRequisition(string reason) => new("INVALID_REQUISITION", reason, 422);

    public static Error InvalidRfq(string reason) => new("INVALID_RFQ", reason, 422);

    public static Error InvalidQuotation(string reason) => new("INVALID_QUOTATION", reason, 422);

    public static Error InvalidPurchaseOrder(string reason) => new("INVALID_PURCHASE_ORDER", reason, 422);

    public static Error InvalidApprovalRule(string reason) => new("INVALID_APPROVAL_RULE", reason, 422);

    public static Error RequisitionNotFound(long id) => new("NOT_FOUND", $"Requisition {id} was not found.", 404);

    public static Error RfqNotFound(long id) => new("NOT_FOUND", $"RFQ {id} was not found.", 404);

    public static Error QuotationNotFound(long id) => new("NOT_FOUND", $"Quotation {id} was not found.", 404);

    public static Error PurchaseOrderNotFound(long id) => new("NOT_FOUND", $"Purchase order {id} was not found.", 404);

    public static Error ApprovalNotFound(long id) => new("NOT_FOUND", $"Approval instance {id} was not found.", 404);

    public static Error ApprovalRuleNotFound(uint id) => new("NOT_FOUND", $"Approval rule {id} was not found.", 404);

    /// <summary>Contract code <c>INVALID_STATE_TRANSITION</c> (409).</summary>
    public static Error InvalidStatusTransition(string entity, string from, string to) =>
        new("INVALID_STATE_TRANSITION", $"{entity} cannot move from {from} to {to}.", 409);

    public static Error NoApprovalRule(decimal amountBase) =>
        new(
            "NO_APPROVAL_RULE",
            $"No approval rule matches an amount of {amountBase} in the tenant base currency.",
            422,
            new Dictionary<string, string[]>(StringComparer.Ordinal) { ["approval"] = ["Qayda tapılmadı"] });

    public static Error SelectionNoteRequired() =>
        new("SELECTION_NOTE_REQUIRED", "A quotation other than the cheapest was selected; selection_note is mandatory.", 422);

    /// <summary>Spec §12.5: a document may never fall back to an older rate.</summary>
    public static Error FxRateMissing(string currency, DateOnly date) =>
        new("FX_RATE_MISSING", $"No {currency} rate is published for {date:yyyy-MM-dd}.", 409);

    public static Error ApprovalRequired(string docNo) =>
        new("APPROVAL_REQUIRED", $"Purchase order {docNo} has not been approved yet.", 409);

    public static Error CommentRequired(string field) =>
        new(
            "VALIDATION_FAILED",
            "A comment is mandatory for this decision.",
            422,
            new Dictionary<string, string[]>(StringComparer.Ordinal) { [field] = ["Şərh məcburidir"] });

    /// <summary>Spec §12.6 / TOR §10: the person who raised the document may not approve it.</summary>
    public static Error SelfApprovalForbidden() =>
        new("SELF_APPROVAL_FORBIDDEN", "The user who created the document cannot approve it.", 403);

    public static Error NotAnApprover(string roleCode) =>
        new("FORBIDDEN", $"The current step must be decided by role '{roleCode}' or a user it delegated to.", 403);

    public static Error FoodSupplierNotApproved(uint supplierId) =>
        new("SUPPLIER_NOT_APPROVED_FOR_FOOD", $"Supplier {supplierId} is not an approved food supplier (TOR §11).", 422);

    public static Error ProductTypeMismatch(uint productId, string expected) =>
        new(
            "PRODUCT_TYPE_MISMATCH",
            $"Product {productId} does not belong to product type {expected}.",
            422,
            new Dictionary<string, string[]>(StringComparer.Ordinal) { ["lines"] = [$"Məhsul {productId} sənədin məhsul tipinə uyğun deyil"] });

    public static Error ApprovalRuleOverlap(string docType, string productType, byte stepNo) =>
        new(
            "APPROVAL_RULE_OVERLAP",
            $"An active rule for ({docType}, {productType}, step {stepNo}) already covers part of this amount band.",
            422);

    public static Error SupplierNotFound(uint supplierId) => new("NOT_FOUND", $"Supplier {supplierId} was not found.", 404);

    public static Error ProductNotFound(uint productId) => new("NOT_FOUND", $"Product {productId} was not found.", 404);

    public static Error LocationNotFound(uint locationId) => new("NOT_FOUND", $"Location {locationId} was not found.", 404);
}
