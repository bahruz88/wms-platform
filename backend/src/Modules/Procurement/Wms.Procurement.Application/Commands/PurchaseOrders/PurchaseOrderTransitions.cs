using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Commands.Approvals;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Commands.PurchaseOrders;

/// <summary><c>POST /purchase-orders/{id}/submit</c> — selects the approval chain and opens the instance.</summary>
public sealed record SubmitPurchaseOrderCommand(long PurchaseOrderId, uint RowVersion) : ICommand<PurchaseOrderDetailDto>;

/// <summary><c>POST /purchase-orders/{id}/approve</c> — the PO short cut of <c>decideApproval</c>.</summary>
public sealed record ApprovePurchaseOrderCommand(long PurchaseOrderId, uint RowVersion, string? Comment) : ICommand<PurchaseOrderDetailDto>;

/// <summary><c>POST /purchase-orders/{id}/reject</c> — <c>comment</c> is mandatory.</summary>
public sealed record RejectPurchaseOrderCommand(long PurchaseOrderId, uint RowVersion, string? Comment) : ICommand<PurchaseOrderDetailDto>;

/// <summary><c>POST /purchase-orders/{id}/send</c>.</summary>
public sealed record SendPurchaseOrderCommand(long PurchaseOrderId, uint RowVersion) : ICommand<PurchaseOrderDetailDto>;

/// <summary><c>POST /purchase-orders/{id}/close</c>.</summary>
public sealed record ClosePurchaseOrderCommand(long PurchaseOrderId, uint RowVersion, string? Comment) : ICommand<PurchaseOrderDetailDto>;

/// <summary><c>POST /purchase-orders/{id}/cancel</c>.</summary>
public sealed record CancelPurchaseOrderCommand(long PurchaseOrderId, uint RowVersion, string? Comment) : ICommand<PurchaseOrderDetailDto>;

public sealed class SubmitPurchaseOrderCommandValidator : AbstractValidator<SubmitPurchaseOrderCommand>
{
    public SubmitPurchaseOrderCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
    }
}

public sealed class ApprovePurchaseOrderCommandValidator : AbstractValidator<ApprovePurchaseOrderCommand>
{
    public ApprovePurchaseOrderCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Comment).MaximumLength(ApprovalStep.CommentMaxLength);
    }
}

public sealed class RejectPurchaseOrderCommandValidator : AbstractValidator<RejectPurchaseOrderCommand>
{
    public RejectPurchaseOrderCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Comment).MaximumLength(ApprovalStep.CommentMaxLength);
    }
}

public sealed class SendPurchaseOrderCommandValidator : AbstractValidator<SendPurchaseOrderCommand>
{
    public SendPurchaseOrderCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
    }
}

public sealed class ClosePurchaseOrderCommandValidator : AbstractValidator<ClosePurchaseOrderCommand>
{
    public ClosePurchaseOrderCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Comment).MaximumLength(PurchaseOrder.NoteMaxLength);
    }
}

public sealed class CancelPurchaseOrderCommandValidator : AbstractValidator<CancelPurchaseOrderCommand>
{
    public CancelPurchaseOrderCommandValidator()
    {
        RuleFor(c => c.PurchaseOrderId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Comment).MaximumLength(PurchaseOrder.NoteMaxLength);
    }
}

/// <summary>
/// The state machine of a purchase order after it leaves DRAFT. <c>submit</c> opens the approval instance,
/// <c>approve</c>/<c>reject</c> decide its current step, and the last approved step flips the PO to APPROVED
/// and publishes <c>PurchaseOrderApproved</c> through the outbox (spec §14.1).
/// </summary>
public sealed class PurchaseOrderTransitionHandlers(
    IPurchaseOrderRepository purchaseOrders,
    IApprovalInstanceRepository approvals,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    ApprovalEngine approvalEngine,
    ITenantContext tenantContext,
    IClock clock) :
    ICommandHandler<SubmitPurchaseOrderCommand, PurchaseOrderDetailDto>,
    ICommandHandler<ApprovePurchaseOrderCommand, PurchaseOrderDetailDto>,
    ICommandHandler<RejectPurchaseOrderCommand, PurchaseOrderDetailDto>,
    ICommandHandler<SendPurchaseOrderCommand, PurchaseOrderDetailDto>,
    ICommandHandler<ClosePurchaseOrderCommand, PurchaseOrderDetailDto>,
    ICommandHandler<CancelPurchaseOrderCommand, PurchaseOrderDetailDto>
{
    public async Task<Result<PurchaseOrderDetailDto>> HandleAsync(SubmitPurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        var loaded = await LoadAsync(command.PurchaseOrderId, command.RowVersion, cancellationToken).ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var purchaseOrder = loaded.Value;
        var submitted = purchaseOrder.SubmitForApproval();
        if (submitted.IsFailure)
        {
            return submitted.Error;
        }

        var instance = await approvalEngine.StartAsync(
            ApprovalDocType.Po,
            purchaseOrder.Id,
            purchaseOrder.DocNo,
            purchaseOrder.TotalAmountBase,
            ApprovalProductTypes.From(purchaseOrder.ProductType),
            purchaseOrder.CreatedBy,
            cancellationToken).ConfigureAwait(false);
        if (instance.IsFailure)
        {
            return instance.Error;
        }

        unitOfWork.Audit.Record(
            "proc_purchase_order",
            purchaseOrder.Id,
            AuditAction.Update,
            new { purchaseOrder.DocNo, transition = "SUBMIT", steps = instance.Value.Steps.Count, purchaseOrder.TotalAmountBase });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await PurchaseOrderResult.LoadAsync(queries, purchaseOrder.Id, cancellationToken).ConfigureAwait(false);
    }

    public Task<Result<PurchaseOrderDetailDto>> HandleAsync(ApprovePurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return DecideAsync(command.PurchaseOrderId, command.RowVersion, ApprovalDecision.Approved, command.Comment, cancellationToken);
    }

    public Task<Result<PurchaseOrderDetailDto>> HandleAsync(RejectPurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (string.IsNullOrWhiteSpace(command.Comment))
        {
            return Task.FromResult(Result.Failure<PurchaseOrderDetailDto>(ProcurementErrors.CommentRequired("comment")));
        }

        return DecideAsync(command.PurchaseOrderId, command.RowVersion, ApprovalDecision.Rejected, command.Comment, cancellationToken);
    }

    public async Task<Result<PurchaseOrderDetailDto>> HandleAsync(SendPurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        var loaded = await LoadAsync(command.PurchaseOrderId, command.RowVersion, cancellationToken).ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var purchaseOrder = loaded.Value;
        var sent = purchaseOrder.MarkSent(clock.UtcNow);
        if (sent.IsFailure)
        {
            return sent.Error;
        }

        unitOfWork.Audit.Record("proc_purchase_order", purchaseOrder.Id, AuditAction.Update, new { purchaseOrder.DocNo, transition = "SEND" });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await PurchaseOrderResult.LoadAsync(queries, purchaseOrder.Id, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<PurchaseOrderDetailDto>> HandleAsync(ClosePurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        var loaded = await LoadAsync(command.PurchaseOrderId, command.RowVersion, cancellationToken).ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var purchaseOrder = loaded.Value;
        var closed = purchaseOrder.Close(command.Comment);
        if (closed.IsFailure)
        {
            return closed.Error;
        }

        unitOfWork.Audit.Record("proc_purchase_order", purchaseOrder.Id, AuditAction.Update, new { purchaseOrder.DocNo, transition = "CLOSE" });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await PurchaseOrderResult.LoadAsync(queries, purchaseOrder.Id, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<PurchaseOrderDetailDto>> HandleAsync(CancelPurchaseOrderCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        var loaded = await LoadAsync(command.PurchaseOrderId, command.RowVersion, cancellationToken).ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var purchaseOrder = loaded.Value;
        var cancelled = purchaseOrder.Cancel(command.Comment);
        if (cancelled.IsFailure)
        {
            return cancelled.Error;
        }

        var instance = await approvals
            .GetLatestForDocumentAsync(purchaseOrder.TenantId, ApprovalDocType.Po, purchaseOrder.Id, cancellationToken)
            .ConfigureAwait(false);
        if (instance is { Status: ApprovalStatus.Pending })
        {
            instance.Cancel();
        }

        unitOfWork.Audit.Record("proc_purchase_order", purchaseOrder.Id, AuditAction.Update, new { purchaseOrder.DocNo, transition = "CANCEL" });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await PurchaseOrderResult.LoadAsync(queries, purchaseOrder.Id, cancellationToken).ConfigureAwait(false);
    }

    private async Task<Result<PurchaseOrderDetailDto>> DecideAsync(
        long purchaseOrderId,
        uint rowVersion,
        ApprovalDecision decision,
        string? comment,
        CancellationToken cancellationToken)
    {
        var loaded = await LoadAsync(purchaseOrderId, rowVersion, cancellationToken).ConfigureAwait(false);
        if (loaded.IsFailure)
        {
            return loaded.Error;
        }

        var purchaseOrder = loaded.Value;
        if (purchaseOrder.Status != PurchaseOrderStatus.PendingApproval)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(PurchaseOrder), purchaseOrder.Status.ToString(), decision.ToString());
        }

        var instance = await approvals
            .GetLatestForDocumentAsync(purchaseOrder.TenantId, ApprovalDocType.Po, purchaseOrder.Id, cancellationToken)
            .ConfigureAwait(false);
        if (instance is null)
        {
            return ProcurementErrors.ApprovalNotFound(purchaseOrder.Id);
        }

        var outcome = await approvalEngine.DecideAsync(instance, decision, comment, expectedStepNo: null, cancellationToken).ConfigureAwait(false);
        if (outcome.IsFailure)
        {
            return outcome.Error;
        }

        var applied = PurchaseOrderApprovalEffect.Apply(purchaseOrder, outcome.Value, comment, unitOfWork, approvalEngine);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        unitOfWork.Audit.Record(
            "proc_purchase_order",
            purchaseOrder.Id,
            decision == ApprovalDecision.Approved ? AuditAction.Approve : AuditAction.Reject,
            new { purchaseOrder.DocNo, step = outcome.Value.StepNo, approvalStatus = instance.Status.ToString(), comment });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await PurchaseOrderResult.LoadAsync(queries, purchaseOrder.Id, cancellationToken).ConfigureAwait(false);
    }

    private async Task<Result<PurchaseOrder>> LoadAsync(long purchaseOrderId, uint rowVersion, CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var purchaseOrder = await purchaseOrders.GetAsync(purchaseOrderId, cancellationToken).ConfigureAwait(false);
        if (purchaseOrder is null)
        {
            return ProcurementErrors.PurchaseOrderNotFound(purchaseOrderId);
        }

        return purchaseOrder.RowVersion != rowVersion ? CommonErrors.StaleVersion() : Result.Success(purchaseOrder);
    }
}

/// <summary>What an approval decision means for the purchase order behind it.</summary>
internal static class PurchaseOrderApprovalEffect
{
    public static Result Apply(
        PurchaseOrder purchaseOrder,
        ApprovalDecisionOutcome outcome,
        string? comment,
        IProcurementUnitOfWork unitOfWork,
        ApprovalEngine approvalEngine)
    {
        ArgumentNullException.ThrowIfNull(purchaseOrder);
        ArgumentNullException.ThrowIfNull(outcome);
        ArgumentNullException.ThrowIfNull(unitOfWork);
        ArgumentNullException.ThrowIfNull(approvalEngine);

        if (outcome.IsRejected)
        {
            return purchaseOrder.Reject(comment ?? string.Empty);
        }

        if (!outcome.IsFinalApproval)
        {
            // An intermediate step keeps the document in PENDING_APPROVAL.
            return Result.Success();
        }

        var approved = purchaseOrder.Approve();
        if (approved.IsFailure)
        {
            return approved;
        }

        unitOfWork.Outbox.Enqueue(approvalEngine.BuildPurchaseOrderApproved(purchaseOrder));
        return Result.Success();
    }
}
