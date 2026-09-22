using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Commands.GoodsReceipts;

/// <summary>
/// Cancels a DRAFT goods receipt (<c>POST /api/v1/inventory/goods-receipts/{id}/cancel</c>).
///
/// A POSTED receipt is never cancelled — it has already moved the ledger, and the ledger is
/// append-only (ADR-003). Undoing one is a reversal (<c>reverseMovementGroup</c>), which writes a
/// mirror group rather than erasing the original.
/// </summary>
public sealed record CancelGoodsReceiptCommand(long ReceiptId, uint RowVersion, string? Note) : ICommand<long>;

public sealed class CancelGoodsReceiptCommandValidator : AbstractValidator<CancelGoodsReceiptCommand>
{
    public CancelGoodsReceiptCommandValidator()
    {
        RuleFor(c => c.ReceiptId).GreaterThan(0L);
        RuleFor(c => c.Note).MaximumLength(500);
    }
}

public sealed class CancelGoodsReceiptCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IGoodsReceiptRepository receipts,
    ITenantContext tenantContext) : ICommandHandler<CancelGoodsReceiptCommand, long>
{
    public async Task<Result<long>> HandleAsync(CancelGoodsReceiptCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var receipt = await receipts.GetAsync(command.ReceiptId, cancellationToken).ConfigureAwait(false);
        if (receipt is null)
        {
            return InventoryErrors.DocumentNotFound("goods_receipt", command.ReceiptId);
        }

        if (receipt.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var cancelled = receipt.Cancel();
        if (cancelled.IsFailure)
        {
            return cancelled.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_goods_receipt", receipt.Id, AuditAction.Update, new { action = "CANCEL", receipt.DocNo, command.Note });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return receipt.Id;
    }
}
