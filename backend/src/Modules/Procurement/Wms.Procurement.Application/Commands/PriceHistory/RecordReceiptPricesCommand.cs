using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Contracts.Events;
using Wms.Common.Domain;
using Wms.MasterData.Contracts;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Entities;

namespace Wms.Procurement.Application.Commands.PriceHistory;

/// <summary>One accepted line of a goods receipt, as Inventory reports it back to Procurement.</summary>
public sealed record ReceiptLineInput(long PurchaseOrderLineId, decimal ReceivedQty);

/// <summary>
/// <c>POST /api/v1/procurement/internal/purchase-orders/{id}/receipts</c>. Inventory owns the ledger and the
/// receipt document; Procurement owns <c>received_qty</c>, the PO status and the price history. Booking a
/// receipt therefore comes back here: the PO lines are updated and one <c>proc_price_history</c> row per
/// product is appended with the previous price, the difference and the percentage (TOR §25).
/// </summary>
public sealed record RecordReceiptPricesCommand(
    long PurchaseOrderId,
    long GoodsReceiptId,
    DateOnly ReceiptDate,
    IReadOnlyList<ReceiptLineInput> Lines) : ICommand<int>;

public sealed class RecordReceiptPricesCommandValidator : AbstractValidator<RecordReceiptPricesCommand>
{
    public RecordReceiptPricesCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.ReceiptDate).NotEqual(default(DateOnly));
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.PurchaseOrderLineId).GreaterThan(0L);
            line.RuleFor(l => l.ReceivedQty).GreaterThan(0m);
        });
    }
}

public sealed class RecordReceiptPricesCommandHandler(
    IPurchaseOrderRepository purchaseOrders,
    IPriceHistoryRepository priceHistory,
    IProcurementUnitOfWork unitOfWork,
    IProductCatalog products,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<RecordReceiptPricesCommand, int>
{
    public async Task<Result<int>> HandleAsync(RecordReceiptPricesCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var purchaseOrder = await purchaseOrders.GetAsync(command.PurchaseOrderId, cancellationToken).ConfigureAwait(false);
        if (purchaseOrder is null)
        {
            return ProcurementErrors.PurchaseOrderNotFound(command.PurchaseOrderId);
        }

        var now = clock.UtcNow;
        var written = 0;

        foreach (var input in command.Lines)
        {
            var line = purchaseOrder.Lines.FirstOrDefault(l => l.Id == input.PurchaseOrderLineId);
            if (line is null)
            {
                return ProcurementErrors.InvalidPurchaseOrder($"Line {input.PurchaseOrderLineId} does not belong to purchase order {purchaseOrder.DocNo}.");
            }

            var registered = purchaseOrder.RegisterReceipt(line.Id, input.ReceivedQty);
            if (registered.IsFailure)
            {
                return registered.Error;
            }

            // The history is kept per base UoM so prices of different pack sizes stay comparable (spec §12.1).
            var factor = await products.GetUomFactorAsync(line.ProductId, line.UomId, purchaseOrder.DocDate, cancellationToken).ConfigureAwait(false);
            if (factor is not > 0m)
            {
                return new Error(
                    "UOM_FACTOR_NOT_FOUND",
                    $"No conversion factor is defined for product {line.ProductId} in UoM {line.UomId} on {purchaseOrder.DocDate:yyyy-MM-dd}.",
                    422);
            }

            var unitPriceBase = Quantity.Round(line.UnitPrice / factor.Value * purchaseOrder.FxRate, Money.StorageDecimals);
            var previous = await priceHistory
                .GetLastPriceBaseAsync(tenantId, line.ProductId, purchaseOrder.SupplierId, command.ReceiptDate, cancellationToken)
                .ConfigureAwait(false);

            var entry = PriceHistoryEntry.Record(
                tenantId, line.ProductId, purchaseOrder.SupplierId, purchaseOrder.Id, command.ReceiptDate,
                line.UnitPrice, purchaseOrder.Currency, unitPriceBase, previous, now, currentUser.UserId);
            if (entry.IsFailure)
            {
                return entry.Error;
            }

            priceHistory.Add(entry.Value);
            written++;

            if (entry.Value.IsPriceChange())
            {
                unitOfWork.Outbox.Enqueue(new PriceChanged(
                    tenantId,
                    now,
                    line.ProductId,
                    purchaseOrder.SupplierId,
                    command.ReceiptDate,
                    purchaseOrder.Currency,
                    line.UnitPrice,
                    unitPriceBase,
                    entry.Value.PrevPriceBase,
                    entry.Value.DiffAmount,
                    entry.Value.DiffPct));
            }
        }

        unitOfWork.Audit.Record(
            "proc_purchase_order",
            purchaseOrder.Id,
            AuditAction.Update,
            new { purchaseOrder.DocNo, transition = "RECEIPT", command.GoodsReceiptId, priceRows = written, status = purchaseOrder.Status.ToString() });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return Result.Success(written);
    }
}
