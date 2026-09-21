using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.Returns;

/// <summary><c>POST /api/v1/inventory/return-to-vendor</c> — DRAFT return document.</summary>
public sealed record CreateReturnToVendorCommand(
    DateOnly DocDate,
    uint SupplierId,
    uint LocationId,
    long? ReceiptId,
    ushort ReasonCodeId,
    decimal? ClaimAmount,
    string? Note,
    IReadOnlyList<StockOutLineInput> Lines) : ICommand<long>;

public sealed class CreateReturnToVendorCommandValidator : AbstractValidator<CreateReturnToVendorCommand>
{
    public CreateReturnToVendorCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.ReasonCodeId).GreaterThan((ushort)0);
        RuleFor(c => c.ClaimAmount).GreaterThanOrEqualTo(0m).When(c => c.ClaimAmount.HasValue);
        RuleFor(c => c.Note).MaximumLength(ReturnToVendor.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.Qty).GreaterThan(0m);
        });
    }
}

public sealed class CreateReturnToVendorCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IReturnToVendorRepository returns,
    ILocationCatalog locations,
    ISupplierCatalog suppliers,
    IReasonCodeCatalog reasonCodes,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext) : ICommandHandler<CreateReturnToVendorCommand, long>
{
    public async Task<Result<long>> HandleAsync(CreateReturnToVendorCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var location = await locations.GetAsync(command.LocationId, cancellationToken).ConfigureAwait(false);
        if (location is null || !location.IsActive || location.IsVirtual)
        {
            return InventoryErrors.LocationNotFound(command.LocationId);
        }

        var supplier = await suppliers.GetAsync(command.SupplierId, cancellationToken).ConfigureAwait(false);
        if (supplier is null || !supplier.IsActive)
        {
            return InventoryErrors.InvalidDocument($"Supplier {command.SupplierId} does not exist or is inactive.");
        }

        var reason = await reasonCodes.GetAsync(command.ReasonCodeId, cancellationToken).ConfigureAwait(false);
        if (reason is null || !reason.IsActive || !string.Equals(reason.ReasonGroup, ReasonGroups.Return, StringComparison.Ordinal))
        {
            return InventoryErrors.ReasonCodeNotFound(command.ReasonCodeId, ReasonGroups.Return);
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.ReturnToVendor, command.DocDate, cancellationToken).ConfigureAwait(false);
        var document = ReturnToVendor.CreateDraft(
            tenantContext.TenantId, docNo, command.DocDate, command.SupplierId, command.LocationId,
            command.ReceiptId, command.ReasonCodeId, command.ClaimAmount, command.Note);
        if (document.IsFailure)
        {
            return document.Error;
        }

        var lines = document.Value.ReplaceLines(command.Lines);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        returns.Add(document.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("inv_return_to_vendor", document.Value.Id, AuditAction.Create, new { document.Value.DocNo, command.SupplierId, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return document.Value.Id;
    }
}

public sealed record ReturnToVendorSendResult(long ReturnId, long MovementGroupId, string DocNo);

/// <summary><c>POST /api/v1/inventory/return-to-vendor/{id}/send</c> — location −qty / V_SUPPLIER +qty.</summary>
public sealed record SendReturnToVendorCommand(long ReturnId, uint RowVersion, Guid IdempotencyKey) : ICommand<ReturnToVendorSendResult>;

public sealed class SendReturnToVendorCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IReturnToVendorRepository returns,
    IDocumentPostingEngine posting,
    ILocationCatalog locations,
    ILocationFreezeChecker freezeChecker,
    ITenantContext tenantContext) : ICommandHandler<SendReturnToVendorCommand, ReturnToVendorSendResult>
{
    public async Task<Result<ReturnToVendorSendResult>> HandleAsync(SendReturnToVendorCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var document = await returns.GetAsync(command.ReturnId, cancellationToken).ConfigureAwait(false);
        if (document is null)
        {
            return InventoryErrors.DocumentNotFound("return to vendor", command.ReturnId);
        }

        if (document.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (document.Status != RtvStatus.Draft)
        {
            return InventoryErrors.InvalidDocumentTransition("return to vendor", document.Status.ToString(), nameof(RtvStatus.Sent));
        }

        if (await freezeChecker.IsFrozenAsync(document.LocationId, cancellationToken).ConfigureAwait(false))
        {
            return InventoryErrors.LocationFrozen(document.LocationId);
        }

        var supplierLocation = await locations.GetVirtualAsync(LocationTypes.VSupplier, cancellationToken).ConfigureAwait(false);
        if (supplierLocation is null)
        {
            return InventoryErrors.VirtualLocationMissing(LocationTypes.VSupplier);
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var request = new PostingRequest(
            DocType.Return,
            document.DocNo,
            document.DocDate,
            command.IdempotencyKey,
            SourceDocType: "RTV",
            SourceDocId: document.Id,
            ReasonCodeId: document.ReasonCodeId,
            Note: document.Note,
            Lines: document.Lines
                .Select(l => new PostingLine(l.Id, l.ProductId, l.Qty, l.UomId, document.LocationId, supplierLocation.Id, l.BatchId))
                .ToList())
        {
            VirtualLocationIds = [supplierLocation.Id],
        };

        var posted = await posting.PostAsync(request, cancellationToken).ConfigureAwait(false);
        if (posted.IsFailure)
        {
            return posted.Error;
        }

        document.RecordPostedLines(posted.Value.Lines
            .Select(l => new PostedLineResult(l.Key, l.QtyBase, l.BatchId, l.SuggestedBatchId, l.UnitCost))
            .ToList());

        var sent = document.MarkSent(posted.Value.MovementGroupId);
        if (sent.IsFailure)
        {
            return sent.Error;
        }

        unitOfWork.Audit.Record("inv_return_to_vendor", document.Id, AuditAction.Post, new { document.DocNo, movementGroupId = posted.Value.MovementGroupId });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new ReturnToVendorSendResult(document.Id, posted.Value.MovementGroupId, document.DocNo);
    }
}

/// <summary><c>POST /api/v1/inventory/return-to-vendor/{id}/close</c> — records the supplier's answer; no stock moves.</summary>
public sealed record CloseReturnToVendorCommand(long ReturnId, uint RowVersion, string Outcome, decimal? ClaimAmount, string? OutcomeNote) : ICommand<long>;

public sealed class CloseReturnToVendorCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IReturnToVendorRepository returns,
    ITenantContext tenantContext) : ICommandHandler<CloseReturnToVendorCommand, long>
{
    public async Task<Result<long>> HandleAsync(CloseReturnToVendorCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var document = await returns.GetAsync(command.ReturnId, cancellationToken).ConfigureAwait(false);
        if (document is null)
        {
            return InventoryErrors.DocumentNotFound("return to vendor", command.ReturnId);
        }

        if (document.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var closed = document.Close(command.Outcome ?? string.Empty, command.ClaimAmount, command.OutcomeNote);
        if (closed.IsFailure)
        {
            return closed.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_return_to_vendor", document.Id, AuditAction.Update, new { action = "CLOSE", document.DocNo, document.Outcome, document.ClaimAmount });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return document.Id;
    }
}
