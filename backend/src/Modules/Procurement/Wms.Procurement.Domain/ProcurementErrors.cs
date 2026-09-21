using Wms.Common.Domain;

namespace Wms.Procurement.Domain;

public static class ProcurementErrors
{
    public static Error InvalidRequisition(string reason) => new("INVALID_REQUISITION", reason, 422);

    public static Error InvalidPurchaseOrder(string reason) => new("INVALID_PURCHASE_ORDER", reason, 422);

    public static Error PurchaseOrderNotFound(long id) => new("PURCHASE_ORDER_NOT_FOUND", $"Purchase order {id} was not found.", 404);

    public static Error InvalidStatusTransition(string entity, string from, string to) =>
        new("INVALID_STATUS_TRANSITION", $"{entity} cannot move from {from} to {to}.", 409);

    public static Error NoApprovalRule(decimal amountBase) =>
        new("NO_APPROVAL_RULE", $"No approval rule matches an amount of {amountBase} in the tenant base currency.", 422);

    public static Error SelectionNoteRequired() =>
        new("SELECTION_NOTE_REQUIRED", "A quotation other than the cheapest was selected; selection_note is mandatory.", 422);
}
