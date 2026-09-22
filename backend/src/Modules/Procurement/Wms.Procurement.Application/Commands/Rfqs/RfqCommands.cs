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

namespace Wms.Procurement.Application.Commands.Rfqs;

/// <summary>One requested line of an RFQ (<c>RfqLineCreate</c>).</summary>
public sealed record RfqLineInput(uint ProductId, decimal Qty, ushort UomId, long? RequisitionLineId, string? Note);

/// <summary><c>POST /api/v1/procurement/rfqs</c> (operationId <c>createRfq</c>). Always DRAFT.</summary>
public sealed record CreateRfqCommand(
    DateOnly DocDate,
    DateOnly? DueDate,
    IReadOnlyList<uint> SupplierIds,
    IReadOnlyList<RfqLineInput> Lines,
    string? Note) : ICommand<RfqDto>;

/// <summary><c>POST /rfqs/{id}/send</c>.</summary>
public sealed record SendRfqCommand(long RfqId, uint RowVersion) : ICommand<RfqDto>;

/// <summary><c>POST /rfqs/{id}/close</c>.</summary>
public sealed record CloseRfqCommand(long RfqId, uint RowVersion) : ICommand<RfqDto>;

public sealed class CreateRfqCommandValidator : AbstractValidator<CreateRfqCommand>
{
    public CreateRfqCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.SupplierIds).NotNull().Must(s => s.Where(id => id != 0).Distinct().Count() >= Rfq.MinimumSuppliers)
            .WithMessage($"Ən azı {Rfq.MinimumSuppliers} təchizatçı seçilməlidir.");
        RuleFor(c => c.Note).MaximumLength(Rfq.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.Qty).GreaterThan(0m);
            line.RuleFor(l => l.Note).MaximumLength(RfqLine.NoteMaxLength);
        });
    }
}

public sealed class SendRfqCommandValidator : AbstractValidator<SendRfqCommand>
{
    public SendRfqCommandValidator()
    {
        RuleFor(c => c.RfqId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
    }
}

public sealed class CloseRfqCommandValidator : AbstractValidator<CloseRfqCommand>
{
    public CloseRfqCommandValidator()
    {
        RuleFor(c => c.RfqId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
    }
}

public sealed class CreateRfqCommandHandler(
    IRfqRepository rfqs,
    IRequisitionRepository requisitions,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    INumberSequenceService numberSequences,
    IProductCatalog products,
    ISupplierCatalog suppliers,
    ITenantContext tenantContext) : ICommandHandler<CreateRfqCommand, RfqDto>
{
    /// <summary><c>master_number_sequence.doc_type</c> of a price request; the row is created on first use.</summary>
    public const string DocumentNumberType = "RFQ";

    public async Task<Result<RfqDto>> HandleAsync(CreateRfqCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var supplierIds = command.SupplierIds.Where(id => id != 0).Distinct().ToList();
        var known = (await suppliers.GetManyAsync(supplierIds, cancellationToken).ConfigureAwait(false)).ToDictionary(s => s.Id);
        foreach (var supplierId in supplierIds)
        {
            if (!known.TryGetValue(supplierId, out var supplier) || !supplier.IsActive)
            {
                return ProcurementErrors.SupplierNotFound(supplierId);
            }
        }

        var loaded = await LineValidation
            .LoadProductsAsync(products, command.Lines.Select(l => l.ProductId).ToList(), cancellationToken)
            .ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberType, command.DocDate, cancellationToken).ConfigureAwait(false);
        var created = Rfq.CreateDraft(tenantContext.TenantId, docNo, command.DocDate, command.DueDate, command.Note);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var rfq = created.Value;
        var lines = rfq.ReplaceLines(command.Lines.Select(l => new RfqLineDraft(l.ProductId, l.Qty, l.UomId, l.RequisitionLineId, l.Note)));
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        var invited = rfq.ReplaceSuppliers(supplierIds);
        if (invited.IsFailure)
        {
            return invited.Error;
        }

        // Every PR touched by this request moves into procurement (contract: createRfq).
        var requisitionLineIds = command.Lines.Where(l => l.RequisitionLineId is not null).Select(l => l.RequisitionLineId!.Value).Distinct().ToList();
        var sourceRequisitions = await requisitions.GetByLineIdsAsync(requisitionLineIds, cancellationToken).ConfigureAwait(false);
        foreach (var requisition in sourceRequisitions)
        {
            var moved = requisition.MarkInProcurement();
            if (moved.IsFailure)
            {
                return moved.Error;
            }
        }

        rfqs.Add(rfq);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            "proc_rfq",
            rfq.Id,
            AuditAction.Create,
            new { rfq.DocNo, suppliers = supplierIds.Count, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await RfqResult.LoadAsync(queries, rfq.Id, cancellationToken).ConfigureAwait(false);
    }
}

public sealed class RfqTransitionHandlers(
    IRfqRepository rfqs,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    ITenantContext tenantContext) :
    ICommandHandler<SendRfqCommand, RfqDto>,
    ICommandHandler<CloseRfqCommand, RfqDto>
{
    public Task<Result<RfqDto>> HandleAsync(SendRfqCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(command.RfqId, command.RowVersion, r => r.Send(), "SEND", cancellationToken);
    }

    public Task<Result<RfqDto>> HandleAsync(CloseRfqCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return ApplyAsync(command.RfqId, command.RowVersion, r => r.Close(), "CLOSE", cancellationToken);
    }

    private async Task<Result<RfqDto>> ApplyAsync(
        long rfqId,
        uint rowVersion,
        Func<Rfq, Result> action,
        string transition,
        CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var rfq = await rfqs.GetAsync(rfqId, cancellationToken).ConfigureAwait(false);
        if (rfq is null)
        {
            return ProcurementErrors.RfqNotFound(rfqId);
        }

        if (rfq.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var applied = action(rfq);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        unitOfWork.Audit.Record("proc_rfq", rfq.Id, AuditAction.Update, new { rfq.DocNo, transition, status = rfq.Status.ToString() });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await RfqResult.LoadAsync(queries, rfq.Id, cancellationToken).ConfigureAwait(false);
    }
}

internal static class RfqResult
{
    public static async Task<Result<RfqDto>> LoadAsync(IProcurementQueries queries, long rfqId, CancellationToken cancellationToken)
    {
        var dto = await queries.GetRfqAsync(rfqId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.RfqNotFound(rfqId) : Result.Success(dto);
    }
}
