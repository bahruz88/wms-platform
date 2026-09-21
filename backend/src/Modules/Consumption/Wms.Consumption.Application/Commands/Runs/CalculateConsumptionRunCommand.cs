using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Application.Commands.Runs;

/// <summary>
/// <c>POST /api/v1/consumption/runs/{id}/calculate</c> (operationId <c>calculateConsumptionRun</c>).
/// Recalculates a DRAFT/CALCULATED document — e.g. after a sales line was corrected or a missing recipe added.
/// A POSTED document is never recalculated (<c>409 INVALID_STATE_TRANSITION</c>).
/// </summary>
public sealed record CalculateConsumptionRunCommand(long RunId, uint? RowVersion) : ICommand<ConsumptionRunDetailDto>;

public sealed class CalculateConsumptionRunCommandValidator : AbstractValidator<CalculateConsumptionRunCommand>
{
    public CalculateConsumptionRunCommandValidator() => RuleFor(c => c.RunId).GreaterThan(0L);
}

public sealed class CalculateConsumptionRunCommandHandler(
    IConsumptionRunRepository runs,
    ISalesImportRepository imports,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ConsumptionCalculator calculator,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<CalculateConsumptionRunCommand, ConsumptionRunDetailDto>
{
    public async Task<Result<ConsumptionRunDetailDto>> HandleAsync(CalculateConsumptionRunCommand command, CancellationToken cancellationToken)
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

        if (command.RowVersion is { } rowVersion && run.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (run.Status == ConsumptionRunStatus.Posted)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(Domain.Entities.ConsumptionRun), run.Id, run.Status, ConsumptionRunStatus.Calculated);
        }

        var import = await imports.GetAsync(run.ImportId, cancellationToken).ConfigureAwait(false);
        if (import is null)
        {
            return ConsumptionErrors.SalesImportNotFound(run.ImportId);
        }

        var calculation = await calculator.CalculateAsync(tenantContext.TenantId, import, cancellationToken).ConfigureAwait(false);
        if (calculation.IsFailure)
        {
            // The document survives its own failure so the reason can be investigated (status FAILED).
            run.MarkFailed(calculation.Error.Message);
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            return calculation.Error;
        }

        var applied = run.ApplyCalculation(calculation.Value.Lines, calculation.Value.UnmappedCount, clock.UtcNow);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        unitOfWork.Audit.Record("cons_run", run.Id, AuditAction.Update, new
        {
            run.DocNo,
            lineCount = calculation.Value.Lines.Count,
            unmapped = calculation.Value.UnmappedCount,
        });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var includeCost = currentUser.HasPermission(ConsumptionPermissions.ViewCost);
        var dto = await queries.GetRunAsync(run.Id, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RunNotFound(run.Id) : Result.Success(dto);
    }
}
