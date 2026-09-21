using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Contracts;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.Ledger;

/// <summary>
/// <c>POST /api/v1/inventory/batches/{id}/status</c> — block, quarantine or release a batch.
/// <c>EXPIRED</c> is only ever set by the ExpiryScanner job and cannot be undone by hand.
/// </summary>
public sealed record ChangeBatchStatusCommand(long BatchId, uint RowVersion, string Status, ushort ReasonCodeId, string? Note) : ICommand<long>;

public sealed class ChangeBatchStatusCommandValidator : AbstractValidator<ChangeBatchStatusCommand>
{
    public ChangeBatchStatusCommandValidator()
    {
        RuleFor(c => c.BatchId).GreaterThan(0L);
        RuleFor(c => c.Status).NotEmpty();
        RuleFor(c => c.ReasonCodeId).GreaterThan((ushort)0);
        RuleFor(c => c.Note).MaximumLength(500);
    }
}

public sealed class ChangeBatchStatusCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IBatchRepository batches,
    IReasonCodeCatalog reasonCodes,
    ITenantContext tenantContext) : ICommandHandler<ChangeBatchStatusCommand, long>
{
    public async Task<Result<long>> HandleAsync(ChangeBatchStatusCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var batch = await batches.GetAsync(command.BatchId, cancellationToken).ConfigureAwait(false);
        if (batch is null)
        {
            return InventoryErrors.BatchNotFound(command.BatchId);
        }

        if (batch.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var reason = await reasonCodes.GetAsync(command.ReasonCodeId, cancellationToken).ConfigureAwait(false);
        if (reason is null || !reason.IsActive)
        {
            return InventoryErrors.ReasonCodeNotFound(command.ReasonCodeId, ReasonGroups.Adjustment);
        }

        var target = (command.Status ?? string.Empty).Trim().ToUpperInvariant();
        var result = target switch
        {
            "ACTIVE" => batch.Release(),
            "BLOCKED" => batch.Block(),
            "QUARANTINE" => batch.Quarantine(),

            // Only the ExpiryScanner job may set EXPIRED, and nothing brings a batch back from it.
            "EXPIRED" => InventoryErrors.InvalidBatchTransition(batch.Status, BatchStatus.Expired),
            _ => InventoryErrors.InvalidBatch($"'{command.Status}' is not a batch status."),
        };
        if (result.IsFailure)
        {
            return result.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_batch", batch.Id, AuditAction.Update, new
        {
            action = "STATUS_CHANGE",
            batch.BatchNo,
            status = batch.Status.ToString(),
            command.ReasonCodeId,
            command.Note,
        });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return batch.Id;
    }
}

public sealed record ReverseMovementGroupResult(long ReversalGroupId, string DocNo);

/// <summary>
/// <c>POST /api/v1/inventory/movement-groups/{id}/reverse</c> — storno (spec §12.6). A posted document is never
/// edited or deleted; it is answered with a mirror-image group, so both the mistake and the correction stay on
/// the record.
/// </summary>
public sealed record ReverseMovementGroupCommand(long GroupId, ushort ReasonCodeId, string? Note, Guid IdempotencyKey) : ICommand<ReverseMovementGroupResult>;

public sealed class ReverseMovementGroupCommandValidator : AbstractValidator<ReverseMovementGroupCommand>
{
    public ReverseMovementGroupCommandValidator()
    {
        RuleFor(c => c.GroupId).GreaterThan(0L);
        RuleFor(c => c.ReasonCodeId).GreaterThan((ushort)0);
        RuleFor(c => c.IdempotencyKey).NotEqual(Guid.Empty);
        RuleFor(c => c.Note).MaximumLength(MovementGroup.NoteMaxLength);
    }
}

public sealed class ReverseMovementGroupCommandHandler(
    IStockPostingService posting,
    IReasonCodeCatalog reasonCodes,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<ReverseMovementGroupCommand, ReverseMovementGroupResult>
{
    public async Task<Result<ReverseMovementGroupResult>> HandleAsync(ReverseMovementGroupCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var reason = await reasonCodes.GetAsync(command.ReasonCodeId, cancellationToken).ConfigureAwait(false);
        if (reason is null || !reason.IsActive)
        {
            return InventoryErrors.ReasonCodeNotFound(command.ReasonCodeId, ReasonGroups.Adjustment);
        }

        var outcome = await posting.ReverseAsync(
            new StockReversalRequest(
                command.GroupId,
                DateOnly.FromDateTime(clock.UtcNow.UtcDateTime),
                command.ReasonCodeId,
                command.IdempotencyKey,
                command.Note),
            cancellationToken).ConfigureAwait(false);

        return outcome.IsSuccess
            ? new ReverseMovementGroupResult(outcome.MovementGroupId!.Value, outcome.DocNo)
            : new Error(outcome.ErrorCode ?? "INTERNAL_ERROR", outcome.ErrorMessage ?? "Reversal failed.", outcome.ErrorStatus);
    }
}
