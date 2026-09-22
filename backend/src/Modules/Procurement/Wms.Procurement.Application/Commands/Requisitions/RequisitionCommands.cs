using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.MasterData.Contracts;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Commands.Requisitions;

/// <summary>One requested line of a PR (<c>RequisitionLineCreate</c>).</summary>
public sealed record RequisitionLineInput(uint ProductId, decimal Qty, ushort UomId, string? Note);

/// <summary><c>POST /api/v1/procurement/requisitions</c> (operationId <c>createRequisition</c>). Always DRAFT.</summary>
public sealed record CreateRequisitionCommand(
    DateOnly DocDate,
    uint RequesterLocationId,
    ProductType ProductType,
    Priority Priority,
    DateOnly? RequiredDate,
    string? Note,
    IReadOnlyList<RequisitionLineInput> Lines) : ICommand<RequisitionDto>;

/// <summary><c>PUT /api/v1/procurement/requisitions/{id}</c> (operationId <c>updateRequisition</c>). DRAFT only.</summary>
public sealed record UpdateRequisitionCommand(
    long RequisitionId,
    uint RowVersion,
    DateOnly DocDate,
    uint RequesterLocationId,
    ProductType ProductType,
    Priority Priority,
    DateOnly? RequiredDate,
    string? Note,
    IReadOnlyList<RequisitionLineInput> Lines) : ICommand<RequisitionDto>;

/// <summary><c>POST /requisitions/{id}/submit</c>.</summary>
public sealed record SubmitRequisitionCommand(long RequisitionId, uint RowVersion) : ICommand<RequisitionDto>;

/// <summary><c>POST /requisitions/{id}/reject</c> — <c>comment</c> is mandatory.</summary>
public sealed record RejectRequisitionCommand(long RequisitionId, uint RowVersion, string? Comment) : ICommand<RequisitionDto>;

/// <summary><c>POST /requisitions/{id}/cancel</c>.</summary>
public sealed record CancelRequisitionCommand(long RequisitionId, uint RowVersion, string? Comment) : ICommand<RequisitionDto>;

public sealed class CreateRequisitionCommandValidator : AbstractValidator<CreateRequisitionCommand>
{
    public CreateRequisitionCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.RequesterLocationId).GreaterThan(0u);
        RuleFor(c => c.Note).MaximumLength(Requisition.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(Line);
    }

    internal static void Line(InlineValidator<RequisitionLineInput> line)
    {
        ArgumentNullException.ThrowIfNull(line);
        line.RuleFor(l => l.ProductId).GreaterThan(0u);
        line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
        line.RuleFor(l => l.Qty).GreaterThan(0m);
        line.RuleFor(l => l.Note).MaximumLength(RequisitionLine.NoteMaxLength);
    }
}

public sealed class UpdateRequisitionCommandValidator : AbstractValidator<UpdateRequisitionCommand>
{
    public UpdateRequisitionCommandValidator()
    {
        RuleFor(c => c.RequisitionId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.RequesterLocationId).GreaterThan(0u);
        RuleFor(c => c.Note).MaximumLength(Requisition.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(CreateRequisitionCommandValidator.Line);
    }
}

public sealed class SubmitRequisitionCommandValidator : AbstractValidator<SubmitRequisitionCommand>
{
    public SubmitRequisitionCommandValidator()
    {
        RuleFor(c => c.RequisitionId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
    }
}

public sealed class RejectRequisitionCommandValidator : AbstractValidator<RejectRequisitionCommand>
{
    public RejectRequisitionCommandValidator()
    {
        RuleFor(c => c.RequisitionId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Comment).MaximumLength(Requisition.NoteMaxLength);
    }
}

public sealed class CancelRequisitionCommandValidator : AbstractValidator<CancelRequisitionCommand>
{
    public CancelRequisitionCommandValidator()
    {
        RuleFor(c => c.RequisitionId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Comment).MaximumLength(Requisition.NoteMaxLength);
    }
}

public sealed class CreateRequisitionCommandHandler(
    IRequisitionRepository requisitions,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    INumberSequenceService numberSequences,
    IProductCatalog products,
    ILocationCatalog locations,
    ITenantContext tenantContext) : ICommandHandler<CreateRequisitionCommand, RequisitionDto>
{
    public async Task<Result<RequisitionDto>> HandleAsync(CreateRequisitionCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var location = await locations.GetAsync(command.RequesterLocationId, cancellationToken).ConfigureAwait(false);
        if (location is null || !location.IsActive)
        {
            return ProcurementErrors.LocationNotFound(command.RequesterLocationId);
        }

        var loaded = await LineValidation
            .LoadProductsAsync(products, command.Lines.Select(l => l.ProductId).ToList(), cancellationToken)
            .ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var typed = LineValidation.EnsureProductType(loaded.Value, command.ProductType);
        if (typed.IsFailure)
        {
            return typed.Error;
        }

        var docNo = await numberSequences
            .NextAsync(DocumentNumberTypes.PurchaseRequisition, command.DocDate, cancellationToken)
            .ConfigureAwait(false);

        var created = Requisition.CreateDraft(
            tenantContext.TenantId, docNo, command.DocDate, command.RequesterLocationId,
            command.ProductType, command.Priority, command.RequiredDate, command.Note);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var requisition = created.Value;
        var lines = requisition.ReplaceLines(command.Lines.Select(l => new RequisitionLineDraft(l.ProductId, l.Qty, l.UomId, l.Note)));
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        requisitions.Add(requisition);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("proc_requisition", requisition.Id, AuditAction.Create, new { requisition.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await RequisitionResult.LoadAsync(queries, requisition.Id, cancellationToken).ConfigureAwait(false);
    }
}

public sealed class UpdateRequisitionCommandHandler(
    IRequisitionRepository requisitions,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    IProductCatalog products,
    ILocationCatalog locations,
    ITenantContext tenantContext) : ICommandHandler<UpdateRequisitionCommand, RequisitionDto>
{
    public async Task<Result<RequisitionDto>> HandleAsync(UpdateRequisitionCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var requisition = await requisitions.GetAsync(command.RequisitionId, cancellationToken).ConfigureAwait(false);
        if (requisition is null)
        {
            return ProcurementErrors.RequisitionNotFound(command.RequisitionId);
        }

        if (requisition.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var location = await locations.GetAsync(command.RequesterLocationId, cancellationToken).ConfigureAwait(false);
        if (location is null || !location.IsActive)
        {
            return ProcurementErrors.LocationNotFound(command.RequesterLocationId);
        }

        var loaded = await LineValidation
            .LoadProductsAsync(products, command.Lines.Select(l => l.ProductId).ToList(), cancellationToken)
            .ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var typed = LineValidation.EnsureProductType(loaded.Value, command.ProductType);
        if (typed.IsFailure)
        {
            return typed.Error;
        }

        var header = requisition.UpdateHeader(
            command.DocDate, command.RequesterLocationId, command.ProductType,
            command.Priority, command.RequiredDate, command.Note);
        if (header.IsFailure)
        {
            return header.Error;
        }

        var lines = requisition.ReplaceLines(command.Lines.Select(l => new RequisitionLineDraft(l.ProductId, l.Qty, l.UomId, l.Note)));
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        unitOfWork.Audit.Record("proc_requisition", requisition.Id, AuditAction.Update, new { requisition.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await RequisitionResult.LoadAsync(queries, requisition.Id, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary>Submit / reject / cancel share one shape: load, check the version, apply, audit, reload.</summary>
public sealed class RequisitionTransitionHandlers(
    IRequisitionRepository requisitions,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    ITenantContext tenantContext) :
    ICommandHandler<SubmitRequisitionCommand, RequisitionDto>,
    ICommandHandler<RejectRequisitionCommand, RequisitionDto>,
    ICommandHandler<CancelRequisitionCommand, RequisitionDto>
{
    public Task<Result<RequisitionDto>> HandleAsync(SubmitRequisitionCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(command.RequisitionId, command.RowVersion, r => r.Submit(), AuditAction.Update, "SUBMIT", cancellationToken);
    }

    public Task<Result<RequisitionDto>> HandleAsync(RejectRequisitionCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (string.IsNullOrWhiteSpace(command.Comment))
        {
            return Task.FromResult(Result.Failure<RequisitionDto>(ProcurementErrors.CommentRequired("comment")));
        }

        return ApplyAsync(command.RequisitionId, command.RowVersion, r => r.Reject(command.Comment!), AuditAction.Reject, "REJECT", cancellationToken);
    }

    public Task<Result<RequisitionDto>> HandleAsync(CancelRequisitionCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(command.RequisitionId, command.RowVersion, r => r.Cancel(command.Comment), AuditAction.Update, "CANCEL", cancellationToken);
    }

    private async Task<Result<RequisitionDto>> ApplyAsync(
        long requisitionId,
        uint rowVersion,
        Func<Requisition, Result> action,
        AuditAction auditAction,
        string transition,
        CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var requisition = await requisitions.GetAsync(requisitionId, cancellationToken).ConfigureAwait(false);
        if (requisition is null)
        {
            return ProcurementErrors.RequisitionNotFound(requisitionId);
        }

        if (requisition.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var applied = action(requisition);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        unitOfWork.Audit.Record("proc_requisition", requisition.Id, auditAction, new { requisition.DocNo, transition, status = requisition.Status.ToString() });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await RequisitionResult.LoadAsync(queries, requisition.Id, cancellationToken).ConfigureAwait(false);
    }
}

internal static class RequisitionResult
{
    public static async Task<Result<RequisitionDto>> LoadAsync(IProcurementQueries queries, long requisitionId, CancellationToken cancellationToken)
    {
        var dto = await queries.GetRequisitionAsync(requisitionId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.RequisitionNotFound(requisitionId) : Result.Success(dto);
    }
}
