using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Commands.PurchaseOrders;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Commands.Approvals;

/// <summary>
/// <c>POST /api/v1/procurement/approvals/{id}/decide</c> (operationId <c>decideApproval</c>) — the generic
/// decision endpoint shared by PO, WASTE and COUNT_ADJUST. For a PO the underlying document moves too.
/// </summary>
public sealed record DecideApprovalCommand(
    long ApprovalId,
    ApprovalDecision Decision,
    string? Comment,
    int? ExpectedStepNo) : ICommand<ApprovalInstanceDto>;

public sealed class DecideApprovalCommandValidator : AbstractValidator<DecideApprovalCommand>
{
    public DecideApprovalCommandValidator()
    {
        RuleFor(c => c.ApprovalId).GreaterThan(0L);
        RuleFor(c => c.Decision).Must(d => d is ApprovalDecision.Approved or ApprovalDecision.Rejected)
            .WithMessage("decision must be APPROVED or REJECTED.");
        RuleFor(c => c.Comment).MaximumLength(ApprovalStep.CommentMaxLength);
        RuleFor(c => c.ExpectedStepNo).GreaterThan(0).When(c => c.ExpectedStepNo.HasValue);
    }
}

public sealed class DecideApprovalCommandHandler(
    IApprovalInstanceRepository approvals,
    IPurchaseOrderRepository purchaseOrders,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    ApprovalEngine approvalEngine,
    ITenantContext tenantContext) : ICommandHandler<DecideApprovalCommand, ApprovalInstanceDto>
{
    public async Task<Result<ApprovalInstanceDto>> HandleAsync(DecideApprovalCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        if (command.Decision == ApprovalDecision.Rejected && string.IsNullOrWhiteSpace(command.Comment))
        {
            return ProcurementErrors.CommentRequired("comment");
        }

        var instance = await approvals.GetAsync(command.ApprovalId, cancellationToken).ConfigureAwait(false);
        if (instance is null)
        {
            return ProcurementErrors.ApprovalNotFound(command.ApprovalId);
        }

        var outcome = await approvalEngine
            .DecideAsync(instance, command.Decision, command.Comment, command.ExpectedStepNo, cancellationToken)
            .ConfigureAwait(false);
        if (outcome.IsFailure)
        {
            return outcome.Error;
        }

        if (instance.DocType == ApprovalDocType.Po)
        {
            var purchaseOrder = await purchaseOrders.GetAsync(instance.DocId, cancellationToken).ConfigureAwait(false);
            if (purchaseOrder is null)
            {
                return ProcurementErrors.PurchaseOrderNotFound(instance.DocId);
            }

            var applied = PurchaseOrderApprovalEffect.Apply(purchaseOrder, outcome.Value, command.Comment, unitOfWork, approvalEngine);
            if (applied.IsFailure)
            {
                return applied.Error;
            }
        }

        unitOfWork.Audit.Record(
            "proc_approval_instance",
            instance.Id,
            command.Decision == ApprovalDecision.Approved ? AuditAction.Approve : AuditAction.Reject,
            new
            {
                docType = instance.DocType.ToString(),
                instance.DocId,
                instance.DocNo,
                step = outcome.Value.StepNo,
                status = instance.Status.ToString(),
                command.Comment,
            });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetApprovalAsync(instance.Id, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.ApprovalNotFound(instance.Id) : Result.Success(dto);
    }
}
