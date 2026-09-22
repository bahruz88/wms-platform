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
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.Application.Commands.Quotations;

/// <summary>One priced line of a supplier offer (<c>QuotationLineCreate</c>).</summary>
public sealed record QuotationLineInput(uint ProductId, decimal Qty, ushort UomId, decimal UnitPrice, long? RfqLineId, string? Note);

/// <summary><c>POST /api/v1/procurement/quotations</c> (operationId <c>createQuotation</c>).</summary>
public sealed record CreateQuotationCommand(
    long? RfqId,
    uint SupplierId,
    string? QuoteNo,
    DateOnly QuoteDate,
    DateOnly? ValidUntil,
    string Currency,
    ushort? DeliveryDays,
    string? PaymentTerms,
    IReadOnlyList<QuotationLineInput> Lines) : ICommand<QuotationDto>;

/// <summary><c>PUT /quotations/{id}</c> (operationId <c>updateQuotation</c>).</summary>
public sealed record UpdateQuotationCommand(
    long QuotationId,
    uint RowVersion,
    long? RfqId,
    uint SupplierId,
    string? QuoteNo,
    DateOnly QuoteDate,
    DateOnly? ValidUntil,
    string Currency,
    ushort? DeliveryDays,
    string? PaymentTerms,
    IReadOnlyList<QuotationLineInput> Lines) : ICommand<QuotationDto>;

/// <summary><c>POST /quotations/{id}/select</c> — the cheapest-offer rule of spec §10 lives here.</summary>
public sealed record SelectQuotationCommand(long QuotationId, uint RowVersion, string? SelectionNote) : ICommand<QuotationDto>;

public sealed class CreateQuotationCommandValidator : AbstractValidator<CreateQuotationCommand>
{
    public CreateQuotationCommandValidator()
    {
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.QuoteDate).NotEqual(default(DateOnly));
        RuleFor(c => c.Currency).NotEmpty().Length(3);
        RuleFor(c => c.QuoteNo).MaximumLength(Quotation.QuoteNoMaxLength);
        RuleFor(c => c.PaymentTerms).MaximumLength(Quotation.PaymentTermsMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(Line);
    }

    internal static void Line(InlineValidator<QuotationLineInput> line)
    {
        ArgumentNullException.ThrowIfNull(line);
        line.RuleFor(l => l.ProductId).GreaterThan(0u);
        line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
        line.RuleFor(l => l.Qty).GreaterThan(0m);
        line.RuleFor(l => l.UnitPrice).GreaterThanOrEqualTo(0m);
        line.RuleFor(l => l.Note).MaximumLength(QuotationLine.NoteMaxLength);
    }
}

public sealed class UpdateQuotationCommandValidator : AbstractValidator<UpdateQuotationCommand>
{
    public UpdateQuotationCommandValidator()
    {
        RuleFor(c => c.QuotationId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.Currency).NotEmpty().Length(3);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(CreateQuotationCommandValidator.Line);
    }
}

public sealed class SelectQuotationCommandValidator : AbstractValidator<SelectQuotationCommand>
{
    public SelectQuotationCommandValidator()
    {
        RuleFor(c => c.QuotationId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.SelectionNote).MaximumLength(Quotation.SelectionNoteMaxLength);
    }
}

/// <summary>Shared assembly of a quotation from its command payload: FX rate, UoM factors, lines, totals.</summary>
internal sealed class QuotationAssembler(IProductCatalog products, ICurrencyRateReader currencyRates, ISupplierCatalog suppliers)
{
    public async Task<Result<IReadOnlyList<QuotationLineDraft>>> BuildLinesAsync(
        IReadOnlyList<QuotationLineInput> lines,
        DateOnly quoteDate,
        CancellationToken cancellationToken)
    {
        var loaded = await LineValidation
            .LoadProductsAsync(products, lines.Select(l => l.ProductId).ToList(), cancellationToken)
            .ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var factors = await LineValidation
            .LoadUomFactorsAsync(products, lines.Select(l => (l.ProductId, l.UomId)), quoteDate, cancellationToken)
            .ConfigureAwait(false);
        if (factors.IsFailure)
        {
            return factors.Error;
        }

        var drafts = lines
            .Select(l => new QuotationLineDraft(
                l.ProductId, l.Qty, l.UomId, l.UnitPrice, factors.Value[(l.ProductId, l.UomId)], l.RfqLineId, l.Note))
            .ToList();
        return Result.Success<IReadOnlyList<QuotationLineDraft>>(drafts);
    }

    public async Task<Result<decimal>> ResolveFxRateAsync(string currency, DateOnly quoteDate, CancellationToken cancellationToken) =>
        await LineValidation.ResolveFxRateAsync(currencyRates, currency, quoteDate, cancellationToken).ConfigureAwait(false);

    public async Task<Result> EnsureSupplierAsync(uint supplierId, CancellationToken cancellationToken)
    {
        var supplier = await suppliers.GetAsync(supplierId, cancellationToken).ConfigureAwait(false);
        return supplier is null || !supplier.IsActive ? ProcurementErrors.SupplierNotFound(supplierId) : Result.Success();
    }
}

public sealed class CreateQuotationCommandHandler(
    IQuotationRepository quotations,
    IRfqRepository rfqs,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    IProductCatalog products,
    ISupplierCatalog suppliers,
    ICurrencyRateReader currencyRates,
    ITenantContext tenantContext) : ICommandHandler<CreateQuotationCommand, QuotationDto>
{
    public async Task<Result<QuotationDto>> HandleAsync(CreateQuotationCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var assembler = new QuotationAssembler(products, currencyRates, suppliers);
        var supplierKnown = await assembler.EnsureSupplierAsync(command.SupplierId, cancellationToken).ConfigureAwait(false);
        if (supplierKnown.IsFailure)
        {
            return supplierKnown.Error;
        }

        if (command.RfqId is { } rfqId)
        {
            var rfq = await rfqs.GetAsync(rfqId, cancellationToken).ConfigureAwait(false);
            if (rfq is null)
            {
                return ProcurementErrors.RfqNotFound(rfqId);
            }

            if (!rfq.AcceptsQuotations())
            {
                return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), rfq.Status.ToString(), "quotation entered");
            }
        }

        var fxRate = await assembler.ResolveFxRateAsync(command.Currency, command.QuoteDate, cancellationToken).ConfigureAwait(false);
        if (fxRate.IsFailure)
        {
            return fxRate.Error;
        }

        var created = Quotation.Create(
            tenantContext.TenantId, command.RfqId, command.SupplierId, command.QuoteNo, command.QuoteDate,
            command.ValidUntil, command.Currency, fxRate.Value, command.DeliveryDays, command.PaymentTerms);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var drafts = await assembler.BuildLinesAsync(command.Lines, command.QuoteDate, cancellationToken).ConfigureAwait(false);
        if (drafts.IsFailure)
        {
            return drafts.Error;
        }

        var quotation = created.Value;
        var lines = quotation.ReplaceLines(drafts.Value);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        quotations.Add(quotation);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            "proc_quotation",
            quotation.Id,
            AuditAction.Create,
            new { quotation.RfqId, quotation.SupplierId, quotation.TotalAmountBase });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await QuotationResult.LoadAsync(queries, quotation.Id, cancellationToken).ConfigureAwait(false);
    }
}

public sealed class UpdateQuotationCommandHandler(
    IQuotationRepository quotations,
    IRfqRepository rfqs,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    IProductCatalog products,
    ISupplierCatalog suppliers,
    ICurrencyRateReader currencyRates,
    ITenantContext tenantContext) : ICommandHandler<UpdateQuotationCommand, QuotationDto>
{
    public async Task<Result<QuotationDto>> HandleAsync(UpdateQuotationCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var quotation = await quotations.GetAsync(command.QuotationId, cancellationToken).ConfigureAwait(false);
        if (quotation is null)
        {
            return ProcurementErrors.QuotationNotFound(command.QuotationId);
        }

        if (quotation.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (quotation.IsSelected)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Quotation), "SELECTED", "updated");
        }

        if (command.RfqId is { } rfqId)
        {
            var rfq = await rfqs.GetAsync(rfqId, cancellationToken).ConfigureAwait(false);
            if (rfq is null)
            {
                return ProcurementErrors.RfqNotFound(rfqId);
            }

            if (!rfq.AcceptsQuotations())
            {
                return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), rfq.Status.ToString(), "quotation updated");
            }
        }

        var assembler = new QuotationAssembler(products, currencyRates, suppliers);
        var supplierKnown = await assembler.EnsureSupplierAsync(command.SupplierId, cancellationToken).ConfigureAwait(false);
        if (supplierKnown.IsFailure)
        {
            return supplierKnown.Error;
        }

        var fxRate = await assembler.ResolveFxRateAsync(command.Currency, command.QuoteDate, cancellationToken).ConfigureAwait(false);
        if (fxRate.IsFailure)
        {
            return fxRate.Error;
        }

        var header = quotation.UpdateHeader(
            command.RfqId, command.SupplierId, command.QuoteNo, command.QuoteDate, command.ValidUntil,
            command.Currency, fxRate.Value, command.DeliveryDays, command.PaymentTerms);
        if (header.IsFailure)
        {
            return header.Error;
        }

        var drafts = await assembler.BuildLinesAsync(command.Lines, command.QuoteDate, cancellationToken).ConfigureAwait(false);
        if (drafts.IsFailure)
        {
            return drafts.Error;
        }

        var lines = quotation.ReplaceLines(drafts.Value);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        unitOfWork.Audit.Record("proc_quotation", quotation.Id, AuditAction.Update, new { quotation.RfqId, quotation.TotalAmountBase });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await QuotationResult.LoadAsync(queries, quotation.Id, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary>
/// <c>selectQuotation</c>. The offer with the lowest <c>total_amount_base</c> of the same RFQ is the cheapest;
/// choosing any other one without a <c>selectionNote</c> is <c>422 SELECTION_NOTE_REQUIRED</c> (spec §10).
/// The previous selection of the same RFQ is released, and the choice is written to <c>common_audit_log</c>.
/// </summary>
public sealed class SelectQuotationCommandHandler(
    IQuotationRepository quotations,
    IRfqRepository rfqs,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    ITenantContext tenantContext) : ICommandHandler<SelectQuotationCommand, QuotationDto>
{
    public async Task<Result<QuotationDto>> HandleAsync(SelectQuotationCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var quotation = await quotations.GetAsync(command.QuotationId, cancellationToken).ConfigureAwait(false);
        if (quotation is null)
        {
            return ProcurementErrors.QuotationNotFound(command.QuotationId);
        }

        if (quotation.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var siblings = new List<Quotation> { quotation };
        if (quotation.RfqId is { } rfqId)
        {
            var rfq = await rfqs.GetAsync(rfqId, cancellationToken).ConfigureAwait(false);
            if (rfq is null)
            {
                return ProcurementErrors.RfqNotFound(rfqId);
            }

            if (!rfq.AcceptsSelection())
            {
                return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), rfq.Status.ToString(), "quotation selected");
            }

            siblings = (await quotations.GetByRfqAsync(rfqId, cancellationToken).ConfigureAwait(false)).ToList();
            if (!siblings.Exists(q => q.Id == quotation.Id))
            {
                siblings.Add(quotation);
            }
        }

        var cheapestId = QuotationRanking.CheapestQuotationId(
            siblings.Select(q => new RankedQuotation(q.Id, q.Lines.Count == 0 ? null : q.TotalAmountBase)));

        var justified = QuotationRanking.EnsureSelectionJustified(quotation.Id, cheapestId, command.SelectionNote);
        if (justified.IsFailure)
        {
            return justified.Error;
        }

        foreach (var sibling in siblings.Where(q => q.Id != quotation.Id && q.IsSelected))
        {
            sibling.Deselect();
        }

        var selected = quotation.Select(cheapestId is null || cheapestId == quotation.Id, command.SelectionNote);
        if (selected.IsFailure)
        {
            return selected.Error;
        }

        unitOfWork.Audit.Record(
            "proc_quotation",
            quotation.Id,
            AuditAction.Approve,
            new
            {
                transition = "SELECT",
                quotation.RfqId,
                quotation.SupplierId,
                quotation.TotalAmountBase,
                cheapestQuotationId = cheapestId,
                isCheapest = cheapestId is null || cheapestId == quotation.Id,
                quotation.SelectionNote,
            });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await QuotationResult.LoadAsync(queries, quotation.Id, cancellationToken).ConfigureAwait(false);
    }
}

internal static class QuotationResult
{
    public static async Task<Result<QuotationDto>> LoadAsync(IProcurementQueries queries, long quotationId, CancellationToken cancellationToken)
    {
        var dto = await queries.GetQuotationAsync(quotationId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.QuotationNotFound(quotationId) : Result.Success(dto);
    }
}
