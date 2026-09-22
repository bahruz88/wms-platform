using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Application.Commands.GoodsReceipts;

/// <summary>
/// Replaces a DRAFT goods receipt (<c>PUT /api/v1/inventory/goods-receipts/{id}</c>).
///
/// The contract replaces lines wholesale rather than patching them, so the handler clears the
/// existing set and re-adds the incoming one; line numbers are positional and would otherwise
/// carry gaps from the previous version.
/// </summary>
public sealed record UpdateGoodsReceiptCommand(
    long ReceiptId,
    uint RowVersion,
    DateOnly DocDate,
    long? PurchaseOrderId,
    uint SupplierId,
    uint LocationId,
    decimal? TemperatureC,
    QualityStatus QualityStatus,
    string? PackagingNote,
    IReadOnlyList<CreateGoodsReceiptLine> Lines) : ICommand<long>;

public sealed class UpdateGoodsReceiptCommandValidator : AbstractValidator<UpdateGoodsReceiptCommand>
{
    public UpdateGoodsReceiptCommandValidator()
    {
        RuleFor(c => c.ReceiptId).GreaterThan(0L);
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.PackagingNote).MaximumLength(GoodsReceipt.PackagingNoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.ReceivedQty).GreaterThan(0m);
            line.RuleFor(l => l.RejectedQty).GreaterThanOrEqualTo(0m);
            line.RuleFor(l => l.UnitPrice).GreaterThanOrEqualTo(0m).When(l => l.UnitPrice.HasValue);
            line.RuleFor(l => l.Currency).Length(3).When(l => l.Currency is not null);
            line.RuleFor(l => l.BatchNo).MaximumLength(GoodsReceiptLine.BatchNoMaxLength);
            line.RuleFor(l => l.VarianceNote).MaximumLength(GoodsReceiptLine.VarianceNoteMaxLength);
        });
    }
}

public sealed class UpdateGoodsReceiptCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IGoodsReceiptRepository receipts,
    ITenantContext tenantContext) : ICommandHandler<UpdateGoodsReceiptCommand, long>
{
    public async Task<Result<long>> HandleAsync(UpdateGoodsReceiptCommand command, CancellationToken cancellationToken)
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

        var header = receipt.UpdateDraft(
            command.DocDate,
            command.PurchaseOrderId,
            command.SupplierId,
            command.LocationId,
            command.TemperatureC,
            command.QualityStatus,
            command.PackagingNote);
        if (header.IsFailure)
        {
            return header.Error;
        }

        var cleared = receipt.ClearLines();
        if (cleared.IsFailure)
        {
            return cleared.Error;
        }

        foreach (var line in command.Lines)
        {
            var added = receipt.AddLine(
                line.ProductId, line.ReceivedQty, line.UomId, line.PoLineId, line.OrderedQty, line.RejectedQty,
                line.BatchNo, line.ProductionDate, line.ExpiryDate, line.UnitPrice, line.Currency, line.VarianceNote);
            if (added.IsFailure)
            {
                return added.Error;
            }
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_goods_receipt", receipt.Id, AuditAction.Update, new { receipt.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return receipt.Id;
    }
}
