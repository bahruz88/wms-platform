using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.StockRequests;

public sealed record StockRequestLineCommand(uint ProductId, decimal Qty, ushort UomId, string? Note);

/// <summary><c>POST /api/v1/inventory/stock-requests</c> — the branch asks the warehouse for goods (TOR §16).</summary>
public sealed record CreateStockRequestCommand(
    DateOnly DocDate,
    uint FromLocationId,
    uint ToLocationId,
    DateOnly? RequiredDate,
    string? Note,
    IReadOnlyList<StockRequestLineCommand> Lines) : ICommand<long>;

public sealed class CreateStockRequestCommandValidator : AbstractValidator<CreateStockRequestCommand>
{
    public CreateStockRequestCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.FromLocationId).GreaterThan(0u);
        RuleFor(c => c.ToLocationId).GreaterThan(0u);
        RuleFor(c => c.Note).MaximumLength(StockRequest.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.Qty).GreaterThan(0m);
            line.RuleFor(l => l.Note).MaximumLength(StockRequestLine.NoteMaxLength);
        });
    }
}

public sealed class CreateStockRequestCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockRequestRepository requests,
    ILocationCatalog locations,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext) : ICommandHandler<CreateStockRequestCommand, long>
{
    public async Task<Result<long>> HandleAsync(CreateStockRequestCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        foreach (var locationId in new[] { command.FromLocationId, command.ToLocationId })
        {
            var location = await locations.GetAsync(locationId, cancellationToken).ConfigureAwait(false);
            if (location is null || !location.IsActive || location.IsVirtual)
            {
                return InventoryErrors.LocationNotFound(locationId);
            }
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.StockRequest, command.DocDate, cancellationToken).ConfigureAwait(false);
        var request = StockRequest.CreateDraft(
            tenantContext.TenantId, docNo, command.DocDate, command.FromLocationId, command.ToLocationId,
            command.RequiredDate, command.Note);
        if (request.IsFailure)
        {
            return request.Error;
        }

        var lines = request.Value.ReplaceLines(
            command.Lines.Select(l => (l.ProductId, l.Qty, l.UomId, l.Note)).ToList());
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        requests.Add(request.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("inv_stock_request", request.Value.Id, AuditAction.Create, new { request.Value.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return request.Value.Id;
    }
}

/// <summary><c>PUT /api/v1/inventory/stock-requests/{id}</c> — DRAFT only; lines are replaced wholesale.</summary>
public sealed record UpdateStockRequestCommand(
    long RequestId,
    uint RowVersion,
    DateOnly DocDate,
    DateOnly? RequiredDate,
    string? Note,
    IReadOnlyList<StockRequestLineCommand> Lines) : ICommand<long>;

public sealed class UpdateStockRequestCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockRequestRepository requests,
    ITenantContext tenantContext) : ICommandHandler<UpdateStockRequestCommand, long>
{
    public async Task<Result<long>> HandleAsync(UpdateStockRequestCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var request = await requests.GetAsync(command.RequestId, cancellationToken).ConfigureAwait(false);
        if (request is null)
        {
            return InventoryErrors.DocumentNotFound("stock request", command.RequestId);
        }

        if (request.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var lines = request.ReplaceLines(command.Lines.Select(l => (l.ProductId, l.Qty, l.UomId, l.Note)).ToList());
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_stock_request", request.Id, AuditAction.Update, new { request.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return request.Id;
    }
}

/// <summary><c>POST /api/v1/inventory/stock-requests/{id}/submit</c> — DRAFT → SUBMITTED.</summary>
public sealed record SubmitStockRequestCommand(long RequestId, uint RowVersion) : ICommand<long>;

/// <summary><c>POST /api/v1/inventory/stock-requests/{id}/cancel</c>.</summary>
public sealed record CancelStockRequestCommand(long RequestId, uint RowVersion, string? Note) : ICommand<long>;

public sealed class StockRequestStateHandler(
    IInventoryUnitOfWork unitOfWork,
    IStockRequestRepository requests,
    ITenantContext tenantContext) :
    ICommandHandler<SubmitStockRequestCommand, long>,
    ICommandHandler<CancelStockRequestCommand, long>
{
    public Task<Result<long>> HandleAsync(SubmitStockRequestCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(command.RequestId, command.RowVersion, r => r.Submit(), "SUBMIT", cancellationToken);
    }

    public Task<Result<long>> HandleAsync(CancelStockRequestCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(command.RequestId, command.RowVersion, r => r.Cancel(), "CANCEL", cancellationToken);
    }

    private async Task<Result<long>> ApplyAsync(long requestId, uint rowVersion, Func<StockRequest, Result> action, string auditAction, CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var request = await requests.GetAsync(requestId, cancellationToken).ConfigureAwait(false);
        if (request is null)
        {
            return InventoryErrors.DocumentNotFound("stock request", requestId);
        }

        if (request.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var result = action(request);
        if (result.IsFailure)
        {
            return result.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_stock_request", request.Id, AuditAction.Update, new { action = auditAction, request.DocNo, status = request.Status.ToString() });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return request.Id;
    }
}
