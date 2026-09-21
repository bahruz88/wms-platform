using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Enums;
using Wms.Inventory.Contracts;

namespace Wms.Consumption.Application.Commands.Runs;

/// <summary>
/// <c>POST /api/v1/consumption/runs/{id}/reverse</c> (operationId <c>reverseConsumptionRun</c>).
/// <c>inv_movement</c> is append-only, so a posted document is never edited: Inventory writes a REVERSAL group
/// and this document becomes REVERSED, which frees the day for a new one. <c>reasonCodeId</c> is mandatory
/// (spec §12.6).
/// </summary>
public sealed record ReverseConsumptionRunCommand(long RunId, ushort ReasonCodeId, string? Note, Guid IdempotencyKey)
    : ICommand<ConsumptionRunDetailDto>;

public sealed class ReverseConsumptionRunCommandValidator : AbstractValidator<ReverseConsumptionRunCommand>
{
    public ReverseConsumptionRunCommandValidator()
    {
        RuleFor(c => c.RunId).GreaterThan(0L);
        RuleFor(c => c.ReasonCodeId).GreaterThan((ushort)0);
        RuleFor(c => c.IdempotencyKey).NotEqual(Guid.Empty);
    }
}

public sealed class ReverseConsumptionRunCommandHandler(
    IConsumptionRunRepository runs,
    ISalesImportRepository imports,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    IStockPostingService posting,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<ReverseConsumptionRunCommand, ConsumptionRunDetailDto>
{
    public async Task<Result<ConsumptionRunDetailDto>> HandleAsync(ReverseConsumptionRunCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var run = await runs.GetAsync(command.RunId, cancellationToken).ConfigureAwait(false);
        if (run is null)
        {
            return ConsumptionErrors.RunNotFound(command.RunId);
        }

        if (run.Status != ConsumptionRunStatus.Posted)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(Domain.Entities.ConsumptionRun), run.Id, run.Status, ConsumptionRunStatus.Reversed);
        }

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        if (run.MovementGroupId is { } groupId)
        {
            var outcome = await posting
                .ReverseAsync(new StockReversalRequest(groupId, today, command.ReasonCodeId, command.IdempotencyKey, command.Note), cancellationToken)
                .ConfigureAwait(false);
            if (!outcome.IsSuccess)
            {
                return ConsumptionErrors.PostingFailed(
                    outcome.ErrorCode ?? "REVERSAL_FAILED", outcome.ErrorMessage ?? "Inventory refused the reversal.", outcome.ErrorStatus);
            }
        }

        var reversed = run.MarkReversed();
        if (reversed.IsFailure)
        {
            return reversed.Error;
        }

        var import = await imports.GetAsync(run.ImportId, cancellationToken).ConfigureAwait(false);
        import?.ReopenAfterReversal();

        unitOfWork.Audit.Record("cons_run", run.Id, AuditAction.Reverse, new { run.DocNo, command.ReasonCodeId, command.Note });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var includeCost = currentUser.HasPermission(ConsumptionPermissions.ViewCost);
        var dto = await queries.GetRunAsync(run.Id, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RunNotFound(run.Id) : Result.Success(dto);
    }
}
