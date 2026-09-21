using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.GoodsReceipts;

public sealed record CreateGoodsReceiptLine(
    uint ProductId,
    decimal ReceivedQty,
    ushort UomId,
    long? PoLineId = null,
    decimal? OrderedQty = null,
    decimal RejectedQty = 0m,
    string? BatchNo = null,
    DateOnly? ProductionDate = null,
    DateOnly? ExpiryDate = null,
    decimal? UnitPrice = null,
    string? Currency = null,
    string? VarianceNote = null);

/// <summary>Creates a DRAFT goods receipt (<c>POST /api/v1/inventory/goods-receipts</c>). Returns the new id.</summary>
public sealed record CreateGoodsReceiptCommand(
    DateOnly DocDate,
    long? PurchaseOrderId,
    uint SupplierId,
    uint LocationId,
    decimal? TemperatureC,
    QualityStatus QualityStatus,
    string? PackagingNote,
    IReadOnlyList<CreateGoodsReceiptLine> Lines) : ICommand<long>;

public sealed class CreateGoodsReceiptCommandValidator : AbstractValidator<CreateGoodsReceiptCommand>
{
    public CreateGoodsReceiptCommandValidator()
    {
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

public sealed class CreateGoodsReceiptCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IGoodsReceiptRepository receipts,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext) : ICommandHandler<CreateGoodsReceiptCommand, long>
{
    public async Task<Result<long>> HandleAsync(CreateGoodsReceiptCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.GoodsReceipt, command.DocDate, cancellationToken).ConfigureAwait(false);

        var receipt = GoodsReceipt.CreateDraft(
            tenantContext.TenantId,
            docNo,
            command.DocDate,
            command.PurchaseOrderId,
            command.SupplierId,
            command.LocationId,
            command.TemperatureC,
            command.QualityStatus,
            command.PackagingNote);
        if (receipt.IsFailure)
        {
            return receipt.Error;
        }

        foreach (var line in command.Lines)
        {
            var added = receipt.Value.AddLine(
                line.ProductId, line.ReceivedQty, line.UomId, line.PoLineId, line.OrderedQty, line.RejectedQty,
                line.BatchNo, line.ProductionDate, line.ExpiryDate, line.UnitPrice, line.Currency, line.VarianceNote);
            if (added.IsFailure)
            {
                return added.Error;
            }
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        receipts.Add(receipt.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("inv_goods_receipt", receipt.Value.Id, AuditAction.Create, new { receipt.Value.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return receipt.Value.Id;
    }
}
