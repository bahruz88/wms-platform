using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;

namespace Wms.Consumption.Application.Commands.Runs;

/// <summary>
/// <c>POST /api/v1/consumption/runs</c> (operationId <c>createConsumptionRun</c>): opens the document for a
/// SUBMITTED sales import and calculates it immediately (DRAFT -&gt; CALCULATED).
/// </summary>
public sealed record CreateConsumptionRunCommand(long SalesImportId, bool PostImmediately, Guid IdempotencyKey)
    : ICommand<ConsumptionRunDetailDto>;

public sealed class CreateConsumptionRunCommandValidator : AbstractValidator<CreateConsumptionRunCommand>
{
    public CreateConsumptionRunCommandValidator() => RuleFor(c => c.SalesImportId).GreaterThan(0L);
}

public sealed class CreateConsumptionRunCommandHandler(
    ISalesImportRepository imports,
    IConsumptionRunRepository runs,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ConsumptionCalculator calculator,
    INumberSequenceService numberSequences,
    IStockPostingService posting,
    IDispatcher dispatcher,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<CreateConsumptionRunCommand, ConsumptionRunDetailDto>
{
    public async Task<Result<ConsumptionRunDetailDto>> HandleAsync(CreateConsumptionRunCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var import = await imports.GetAsync(command.SalesImportId, cancellationToken).ConfigureAwait(false);
        if (import is null)
        {
            return ConsumptionErrors.SalesImportNotFound(command.SalesImportId);
        }

        if (import.Status != SalesImportStatus.Submitted)
        {
            return ConsumptionErrors.SalesImportNotSubmitted(import.Id, import.Status);
        }

        // Invariant 2: one consumption document per branch-day.
        // uq_run_day allows exactly one row per branch-day; a reversed day is redone on the same document
        // through POST /runs/{id}/calculate, not by inserting a second one.
        var duplicate = await runs.FindByDayAsync(tenantId, import.LocationId, import.BusinessDate, cancellationToken).ConfigureAwait(false);
        if (duplicate is not null)
        {
            return ConsumptionErrors.DuplicateBusinessDate(import.LocationId, import.BusinessDate);
        }

        if (command.PostImmediately && !currentUser.HasPermission(ConsumptionPermissions.RunPost))
        {
            return CommonErrors.Forbidden(ConsumptionPermissions.RunPost);
        }

        // Invariant 7: a location frozen for counting is not touched; the job retries on the next run.
        if (await posting.IsLocationFrozenAsync(import.LocationId, cancellationToken).ConfigureAwait(false))
        {
            return ConsumptionErrors.LocationFrozen(import.LocationId);
        }

        var docNo = await numberSequences
            .NextAsync(DocumentNumberTypes.Consumption, import.BusinessDate, cancellationToken)
            .ConfigureAwait(false);

        var draft = ConsumptionRun.CreateDraft(tenantId, docNo, import.LocationId, import.BusinessDate, import.Id);
        if (draft.IsFailure)
        {
            return draft.Error;
        }

        var calculation = await calculator.CalculateAsync(tenantId, import, cancellationToken).ConfigureAwait(false);
        if (calculation.IsFailure)
        {
            return calculation.Error;
        }

        var applied = draft.Value.ApplyCalculation(calculation.Value.Lines, calculation.Value.UnmappedCount, clock.UtcNow);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        runs.Add(draft.Value);
        unitOfWork.Audit.Record("cons_run", 0, AuditAction.Create, new
        {
            docNo,
            import.LocationId,
            import.BusinessDate,
            lineCount = calculation.Value.Lines.Count,
            unmapped = calculation.Value.UnmappedCount,
        });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        if (command.PostImmediately)
        {
            return await dispatcher
                .SendAsync(new PostConsumptionRunCommand(draft.Value.Id, null, command.IdempotencyKey), cancellationToken)
                .ConfigureAwait(false);
        }

        var includeCost = currentUser.HasPermission(ConsumptionPermissions.ViewCost);
        var dto = await queries.GetRunAsync(draft.Value.Id, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RunNotFound(draft.Value.Id) : Result.Success(dto);
    }
}
