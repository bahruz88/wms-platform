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
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.Application.Commands.PurchaseOrders;

/// <summary>One ordered line (<c>PurchaseOrderLineCreate</c>). A null <paramref name="VatRate"/> falls back to the product's rate.</summary>
public sealed record PurchaseOrderLineInput(
    uint ProductId,
    decimal Qty,
    ushort UomId,
    decimal UnitPrice,
    decimal? VatRate,
    long? RequisitionLineId);

/// <summary><c>POST /api/v1/procurement/purchase-orders</c> (operationId <c>createPurchaseOrder</c>). Always DRAFT.</summary>
public sealed record CreatePurchaseOrderCommand(
    DateOnly DocDate,
    uint SupplierId,
    string Currency,
    uint DeliveryLocationId,
    DateOnly? ExpectedDate,
    string? Incoterms,
    string? PaymentTerms,
    long? QuotationId,
    string? Note,
    IReadOnlyList<PurchaseOrderLineInput> Lines) : ICommand<PurchaseOrderDetailDto>;

/// <summary><c>PUT /purchase-orders/{id}</c> (operationId <c>updatePurchaseOrder</c>). DRAFT or REJECTED (which returns to DRAFT).</summary>
public sealed record UpdatePurchaseOrderCommand(
    long PurchaseOrderId,
    uint RowVersion,
    DateOnly DocDate,
    uint SupplierId,
    string Currency,
    uint DeliveryLocationId,
    DateOnly? ExpectedDate,
    string? Incoterms,
    string? PaymentTerms,
    long? QuotationId,
    string? Note,
    IReadOnlyList<PurchaseOrderLineInput> Lines) : ICommand<PurchaseOrderDetailDto>;

public sealed class CreatePurchaseOrderCommandValidator : AbstractValidator<CreatePurchaseOrderCommand>
{
    public CreatePurchaseOrderCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.DeliveryLocationId).GreaterThan(0u);
        RuleFor(c => c.Currency).NotEmpty().Length(3);
        RuleFor(c => c.Incoterms).MaximumLength(PurchaseOrder.IncotermsMaxLength);
        RuleFor(c => c.PaymentTerms).MaximumLength(PurchaseOrder.PaymentTermsMaxLength);
        RuleFor(c => c.Note).MaximumLength(PurchaseOrder.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(Line);
    }

    internal static void Line(InlineValidator<PurchaseOrderLineInput> line)
    {
        ArgumentNullException.ThrowIfNull(line);
        line.RuleFor(l => l.ProductId).GreaterThan(0u);
        line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
        line.RuleFor(l => l.Qty).GreaterThan(0m);
        line.RuleFor(l => l.UnitPrice).GreaterThanOrEqualTo(0m);
        line.RuleFor(l => l.VatRate).InclusiveBetween(0m, 100m).When(l => l.VatRate.HasValue);
    }
}

public sealed class UpdatePurchaseOrderCommandValidator : AbstractValidator<UpdatePurchaseOrderCommand>
{
    public UpdatePurchaseOrderCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.DeliveryLocationId).GreaterThan(0u);
        RuleFor(c => c.Currency).NotEmpty().Length(3);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(CreatePurchaseOrderCommandValidator.Line);
    }
}

/// <summary>What the two PO write paths share: master-data checks, the product type and the line drafts.</summary>
internal sealed record PurchaseOrderPreparation(
    ProductType ProductType,
    decimal FxRate,
    IReadOnlyList<PurchaseOrderLineDraft> Lines);

internal sealed class PurchaseOrderPreparer(
    IProductCatalog products,
    ISupplierCatalog suppliers,
    ILocationCatalog locations,
    ICurrencyRateReader currencyRates,
    IQuotationRepository quotations)
{
    public async Task<Result<PurchaseOrderPreparation>> PrepareAsync(
        DateOnly docDate,
        uint supplierId,
        string currency,
        uint deliveryLocationId,
        long? quotationId,
        IReadOnlyList<PurchaseOrderLineInput> lines,
        CancellationToken cancellationToken)
    {
        var supplier = await suppliers.GetAsync(supplierId, cancellationToken).ConfigureAwait(false);
        if (supplier is null || !supplier.IsActive)
        {
            return ProcurementErrors.SupplierNotFound(supplierId);
        }

        var location = await locations.GetAsync(deliveryLocationId, cancellationToken).ConfigureAwait(false);
        if (location is null || !location.IsActive || location.IsVirtual)
        {
            return ProcurementErrors.LocationNotFound(deliveryLocationId);
        }

        var loaded = await LineValidation
            .LoadProductsAsync(products, lines.Select(l => l.ProductId).ToList(), cancellationToken)
            .ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        // One PO carries one product type (contract: createPurchaseOrder).
        var productTypes = loaded.Value.Values.Select(p => LineValidation.ToProductType(p.ProductType)).Distinct().ToList();
        if (productTypes.Count != 1)
        {
            return ProcurementErrors.InvalidPurchaseOrder("A purchase order carries a single product type; FOOD and NON_FOOD cannot be mixed.");
        }

        var productType = productTypes[0];
        if (productType == ProductType.Food && !supplier.IsApprovedFoodSupplier)
        {
            return ProcurementErrors.FoodSupplierNotApproved(supplierId);
        }

        if (!location.AllowsFood && productType == ProductType.Food)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Location {location.Code} does not accept food.");
        }

        if (!location.AllowsNonFood && productType == ProductType.NonFood)
        {
            return ProcurementErrors.InvalidPurchaseOrder($"Location {location.Code} does not accept non-food.");
        }

        if (quotationId is { } id)
        {
            var quotation = await quotations.GetAsync(id, cancellationToken).ConfigureAwait(false);
            if (quotation is null)
            {
                return ProcurementErrors.QuotationNotFound(id);
            }

            if (quotation.SupplierId != supplierId || !string.Equals(quotation.Currency, currency, StringComparison.OrdinalIgnoreCase))
            {
                return ProcurementErrors.InvalidPurchaseOrder("supplier_id and currency must match the selected quotation.");
            }
        }

        var fxRate = await LineValidation.ResolveFxRateAsync(currencyRates, currency, docDate, cancellationToken).ConfigureAwait(false);
        if (fxRate.IsFailure)
        {
            return fxRate.Error;
        }

        var drafts = lines
            .Select(l => new PurchaseOrderLineDraft(
                l.ProductId, l.Qty, l.UomId, l.UnitPrice, l.VatRate ?? loaded.Value[l.ProductId].VatRate, l.RequisitionLineId))
            .ToList();

        return Result.Success(new PurchaseOrderPreparation(productType, fxRate.Value, drafts));
    }
}

public sealed class CreatePurchaseOrderCommandHandler(
    IPurchaseOrderRepository purchaseOrders,
    IRequisitionRepository requisitions,
    IQuotationRepository quotations,
    IApprovalRuleRepository approvalRules,
    ISplitCheckRepository splitChecks,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    IProcurementSettings settings,
    INumberSequenceService numberSequences,
    IProductCatalog products,
    ISupplierCatalog suppliers,
    ILocationCatalog locations,
    ICurrencyRateReader currencyRates,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<CreatePurchaseOrderCommand, PurchaseOrderDetailDto>
{
    public async Task<Result<PurchaseOrderDetailDto>> HandleAsync(CreatePurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var preparer = new PurchaseOrderPreparer(products, suppliers, locations, currencyRates, quotations);
        var prepared = await preparer
            .PrepareAsync(command.DocDate, command.SupplierId, command.Currency, command.DeliveryLocationId, command.QuotationId, command.Lines, cancellationToken)
            .ConfigureAwait(false);
        if (prepared.IsFailure)
        {
            return prepared.Error;
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.PurchaseOrder, command.DocDate, cancellationToken).ConfigureAwait(false);
        var created = PurchaseOrder.CreateDraft(
            tenantId, docNo, command.DocDate, command.SupplierId, command.Currency, prepared.Value.FxRate,
            command.DeliveryLocationId, prepared.Value.ProductType, command.ExpectedDate, command.Incoterms,
            command.PaymentTerms, command.Note, command.QuotationId);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var purchaseOrder = created.Value;
        var lines = purchaseOrder.ReplaceLines(prepared.Value.Lines);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        // A PO is assembled from PR lines by hand (TOR §9); each line records how much of its PR line it consumed.
        var conversion = await RegisterConversionsAsync(requisitions, purchaseOrder, cancellationToken).ConfigureAwait(false);
        if (conversion.IsFailure)
        {
            return conversion.Error;
        }

        // PR-splitting control (SoD, proc_split_check_log).
        var rules = await approvalRules.ListAsync(tenantId, ApprovalDocType.Po, activeOnly: true, cancellationToken).ConfigureAwait(false);
        var windowDays = settings.SplitCheckWindowDays;
        var windowStart = SplitCheckWindow.StartOf(command.DocDate, windowDays);
        var prior = await purchaseOrders
            .SumAmountBaseInWindowAsync(tenantId, command.SupplierId, windowStart, command.DocDate, null, cancellationToken)
            .ConfigureAwait(false);
        var splitCheck = SplitCheckWindow.Evaluate(
            rules, prepared.Value.ProductType, command.DocDate, windowDays, purchaseOrder.TotalAmountBase, prior);
        if (splitCheck.IsTriggered)
        {
            purchaseOrder.FlagSplitCheck(splitCheck.Warning);
        }

        purchaseOrders.Add(purchaseOrder);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        if (splitCheck.IsTriggered)
        {
            splitChecks.Add(SplitCheckLog.Record(
                tenantId, command.SupplierId, splitCheck.WindowStart, splitCheck.WindowEnd,
                splitCheck.CumulativeAmountBase, purchaseOrder.TotalAmountBase, purchaseOrder.Id,
                splitCheck.StepsForSingle, splitCheck.StepsForCumulative, splitCheck.Warning,
                clock.UtcNow, currentUser.UserId));
        }

        unitOfWork.Audit.Record(
            "proc_purchase_order",
            purchaseOrder.Id,
            AuditAction.Create,
            new { purchaseOrder.DocNo, purchaseOrder.TotalAmountBase, lines = command.Lines.Count, splitCheck = splitCheck.IsTriggered });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await PurchaseOrderResult.LoadAsync(queries, purchaseOrder.Id, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>Books <c>converted_qty</c> on every PR line the PO consumed (spec §12.8).</summary>
    internal static async Task<Result> RegisterConversionsAsync(
        IRequisitionRepository requisitions,
        PurchaseOrder purchaseOrder,
        CancellationToken cancellationToken)
    {
        var linked = purchaseOrder.Lines.Where(l => l.RequisitionLineId is not null).ToList();
        if (linked.Count == 0)
        {
            return Result.Success();
        }

        var sources = await requisitions
            .GetByLineIdsAsync(linked.Select(l => l.RequisitionLineId!.Value).Distinct().ToList(), cancellationToken)
            .ConfigureAwait(false);

        foreach (var line in linked)
        {
            var requisition = sources.FirstOrDefault(r => r.Lines.Any(rl => rl.Id == line.RequisitionLineId));
            if (requisition is null)
            {
                return ProcurementErrors.InvalidPurchaseOrder($"Requisition line {line.RequisitionLineId} was not found.");
            }

            var registered = requisition.RegisterConversion(line.RequisitionLineId!.Value, line.Qty);
            if (registered.IsFailure)
            {
                return registered;
            }
        }

        return Result.Success();
    }
}

public sealed class UpdatePurchaseOrderCommandHandler(
    IPurchaseOrderRepository purchaseOrders,
    IQuotationRepository quotations,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    IProductCatalog products,
    ISupplierCatalog suppliers,
    ILocationCatalog locations,
    ICurrencyRateReader currencyRates,
    ITenantContext tenantContext) : ICommandHandler<UpdatePurchaseOrderCommand, PurchaseOrderDetailDto>
{
    public async Task<Result<PurchaseOrderDetailDto>> HandleAsync(UpdatePurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var purchaseOrder = await purchaseOrders.GetAsync(command.PurchaseOrderId, cancellationToken).ConfigureAwait(false);
        if (purchaseOrder is null)
        {
            return ProcurementErrors.PurchaseOrderNotFound(command.PurchaseOrderId);
        }

        if (purchaseOrder.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        // A rejected PO comes back to the creator for correction (contract: updatePurchaseOrder).
        if (purchaseOrder.Status == PurchaseOrderStatus.Rejected)
        {
            var returned = purchaseOrder.ReturnToDraft();
            if (returned.IsFailure)
            {
                return returned.Error;
            }
        }

        var preparer = new PurchaseOrderPreparer(products, suppliers, locations, currencyRates, quotations);
        var prepared = await preparer
            .PrepareAsync(command.DocDate, command.SupplierId, command.Currency, command.DeliveryLocationId, command.QuotationId, command.Lines, cancellationToken)
            .ConfigureAwait(false);
        if (prepared.IsFailure)
        {
            return prepared.Error;
        }

        var header = purchaseOrder.UpdateHeader(
            command.DocDate, command.SupplierId, command.Currency, prepared.Value.FxRate, command.DeliveryLocationId,
            prepared.Value.ProductType, command.ExpectedDate, command.Incoterms, command.PaymentTerms, command.Note, command.QuotationId);
        if (header.IsFailure)
        {
            return header.Error;
        }

        var lines = purchaseOrder.ReplaceLines(prepared.Value.Lines);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        unitOfWork.Audit.Record(
            "proc_purchase_order",
            purchaseOrder.Id,
            AuditAction.Update,
            new { purchaseOrder.DocNo, purchaseOrder.TotalAmountBase, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await PurchaseOrderResult.LoadAsync(queries, purchaseOrder.Id, cancellationToken).ConfigureAwait(false);
    }
}

internal static class PurchaseOrderResult
{
    public static async Task<Result<PurchaseOrderDetailDto>> LoadAsync(IProcurementQueries queries, long purchaseOrderId, CancellationToken cancellationToken)
    {
        var dto = await queries.GetPurchaseOrderAsync(purchaseOrderId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.PurchaseOrderNotFound(purchaseOrderId) : Result.Success(dto);
    }
}
