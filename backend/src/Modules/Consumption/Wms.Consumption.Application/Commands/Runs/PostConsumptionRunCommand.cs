using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Contracts.Events;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Enums;
using Wms.Inventory.Contracts;

namespace Wms.Consumption.Application.Commands.Runs;

/// <summary>
/// <c>POST /api/v1/consumption/runs/{id}/post</c> (operationId <c>postConsumptionRun</c>).
/// CALCULATED -&gt; POSTED. Consumption does NOT touch the ledger: it hands the document to Inventory, which
/// does the whole posting in ONE transaction (lock, FEFO/FIFO allocation, movements, balances, outbox) and
/// answers with the quantity it could actually take. That answer is authoritative — it was produced while the
/// balances were locked — so the shortfall is recorded from it, not from the earlier planning read.
/// </summary>
public sealed record PostConsumptionRunCommand(long RunId, uint? RowVersion, Guid IdempotencyKey) : ICommand<ConsumptionRunDetailDto>;

public sealed class PostConsumptionRunCommandValidator : AbstractValidator<PostConsumptionRunCommand>
{
    public PostConsumptionRunCommandValidator()
    {
        RuleFor(c => c.RunId).GreaterThan(0L);
        RuleFor(c => c.IdempotencyKey).NotEqual(Guid.Empty);
    }
}

public sealed class PostConsumptionRunCommandHandler(
    IConsumptionRunRepository runs,
    ISalesImportRepository imports,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    IStockPostingService posting,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<PostConsumptionRunCommand, ConsumptionRunDetailDto>
{
    public const string SourceDocType = "CONSUMPTION_RUN";

    public async Task<Result<ConsumptionRunDetailDto>> HandleAsync(PostConsumptionRunCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var run = await runs.GetAsync(command.RunId, cancellationToken).ConfigureAwait(false);
        if (run is null)
        {
            return ConsumptionErrors.RunNotFound(command.RunId);
        }

        if (command.RowVersion is { } rowVersion && run.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (run.Status != ConsumptionRunStatus.Calculated)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(Domain.Entities.ConsumptionRun), run.Id, run.Status, ConsumptionRunStatus.Posted);
        }

        var import = await imports.GetAsync(run.ImportId, cancellationToken).ConfigureAwait(false);
        if (import is null)
        {
            return ConsumptionErrors.SalesImportNotFound(run.ImportId);
        }

        var request = new ConsumptionPostingRequest(
            run.DocNo,
            run.BusinessDate,
            run.LocationId,
            SourceDocType,
            run.Id,
            command.IdempotencyKey,
            Note: null,
            run.Lines.Select(l => new ConsumptionPostingLine(l.ProductId, l.TheoreticalQtyBase)).ToList());

        var outcome = await posting.PostConsumptionAsync(request, cancellationToken).ConfigureAwait(false);
        if (!outcome.IsSuccess)
        {
            var error = ConsumptionErrors.PostingFailed(outcome.ErrorCode ?? "POSTING_FAILED", outcome.ErrorMessage ?? "Inventory refused the posting.", outcome.ErrorStatus);
            run.MarkFailed(error.Message);
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            return error;
        }

        var postedByProduct = outcome.Lines.ToDictionary(l => l.ProductId);
        foreach (var line in run.Lines)
        {
            if (postedByProduct.TryGetValue(line.ProductId, out var settled))
            {
                line.Settle(settled.PostedQtyBase, settled.UnitCost);
                continue;
            }

            line.ResetToPlanned();
        }

        var now = clock.UtcNow;
        var marked = run.MarkPosted(outcome.MovementGroupId, now, currentUser.UserId);
        if (marked.IsFailure)
        {
            return marked.Error;
        }

        var consumed = import.MarkConsumed();
        if (consumed.IsFailure)
        {
            return consumed.Error;
        }

        unitOfWork.Audit.Record("cons_run", run.Id, AuditAction.Post, new
        {
            run.DocNo,
            movementGroupId = outcome.MovementGroupId,
            postedQty = run.TotalPostedQtyBase(),
            shortfallQty = run.TotalShortfallQtyBase(),
        });

        unitOfWork.Outbox.Enqueue(new ConsumptionPosted(
            tenantId,
            now,
            run.Id,
            run.DocNo,
            run.LocationId,
            run.BusinessDate,
            outcome.MovementGroupId,
            run.TotalPostedQtyBase(),
            run.TotalShortfallQtyBase(),
            run.Lines.Select(l => new Common.Contracts.Events.ConsumptionPostedLine(l.ProductId, l.PostedQtyBase, l.ShortfallQtyBase, l.BaseUomId)).ToList()));

        var shortfalls = run.Lines.Where(l => l.ShortfallQtyBase > 0m).ToList();
        if (shortfalls.Count > 0)
        {
            unitOfWork.Outbox.Enqueue(new ConsumptionShortfallDetected(
                tenantId,
                now,
                run.Id,
                run.DocNo,
                run.LocationId,
                run.BusinessDate,
                shortfalls
                    .Select(l => new ConsumptionShortfallLine(l.ProductId, l.TheoreticalQtyBase, l.PostedQtyBase, l.ShortfallQtyBase, l.BaseUomId))
                    .ToList()));
        }

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var includeCost = currentUser.HasPermission(ConsumptionPermissions.ViewCost);
        var dto = await queries.GetRunAsync(run.Id, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RunNotFound(run.Id) : Result.Success(dto);
    }
}
