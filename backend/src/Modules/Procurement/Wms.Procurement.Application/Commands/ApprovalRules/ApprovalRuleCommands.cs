using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Commands.ApprovalRules;

/// <summary><c>POST /api/v1/procurement/approval-rules</c> (operationId <c>createApprovalRule</c>).</summary>
public sealed record CreateApprovalRuleCommand(
    ApprovalDocType DocType,
    ApprovalProductType ProductType,
    decimal MinAmountBase,
    decimal? MaxAmountBase,
    byte StepNo,
    uint ApproverRoleId,
    string ApproverRoleCode) : ICommand<ApprovalRuleDto>;

/// <summary><c>PUT /approval-rules/{id}</c> (operationId <c>updateApprovalRule</c>).</summary>
public sealed record UpdateApprovalRuleCommand(
    uint RuleId,
    uint RowVersion,
    ApprovalDocType DocType,
    ApprovalProductType ProductType,
    decimal MinAmountBase,
    decimal? MaxAmountBase,
    byte StepNo,
    uint ApproverRoleId,
    string ApproverRoleCode,
    bool IsActive) : ICommand<ApprovalRuleDto>;

public sealed class CreateApprovalRuleCommandValidator : AbstractValidator<CreateApprovalRuleCommand>
{
    public CreateApprovalRuleCommandValidator()
    {
        RuleFor(c => c.StepNo).GreaterThan((byte)0);
        RuleFor(c => c.ApproverRoleId).GreaterThan(0u);
        RuleFor(c => c.ApproverRoleCode).NotEmpty().MaximumLength(ApprovalRule.RoleCodeMaxLength);
        RuleFor(c => c.MinAmountBase).GreaterThanOrEqualTo(0m);
        RuleFor(c => c.MaxAmountBase).GreaterThanOrEqualTo(c => c.MinAmountBase).When(c => c.MaxAmountBase.HasValue);
    }
}

public sealed class UpdateApprovalRuleCommandValidator : AbstractValidator<UpdateApprovalRuleCommand>
{
    public UpdateApprovalRuleCommandValidator()
    {
        RuleFor(c => c.RuleId).GreaterThan(0u);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.StepNo).GreaterThan((byte)0);
        RuleFor(c => c.ApproverRoleId).GreaterThan(0u);
        RuleFor(c => c.ApproverRoleCode).NotEmpty().MaximumLength(ApprovalRule.RoleCodeMaxLength);
        RuleFor(c => c.MinAmountBase).GreaterThanOrEqualTo(0m);
        RuleFor(c => c.MaxAmountBase).GreaterThanOrEqualTo(c => c.MinAmountBase).When(c => c.MaxAmountBase.HasValue);
    }
}

public sealed class ApprovalRuleCommandHandlers(
    IApprovalRuleRepository rules,
    IProcurementQueries queries,
    IProcurementUnitOfWork unitOfWork,
    ITenantContext tenantContext) :
    ICommandHandler<CreateApprovalRuleCommand, ApprovalRuleDto>,
    ICommandHandler<UpdateApprovalRuleCommand, ApprovalRuleDto>
{
    public async Task<Result<ApprovalRuleDto>> HandleAsync(CreateApprovalRuleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var overlap = await EnsureNoOverlapAsync(
            command.DocType, command.ProductType, command.StepNo, command.MinAmountBase, command.MaxAmountBase, null, cancellationToken)
            .ConfigureAwait(false);
        if (overlap.IsFailure)
        {
            return overlap.Error;
        }

        var created = ApprovalRule.Create(
            tenantContext.TenantId, command.DocType, command.StepNo, command.ApproverRoleId, command.ApproverRoleCode,
            command.MinAmountBase, command.MaxAmountBase, command.ProductType);
        if (created.IsFailure)
        {
            return created.Error;
        }

        rules.Add(created.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            "proc_approval_rule",
            created.Value.Id,
            AuditAction.Create,
            new { docType = command.DocType.ToString(), command.StepNo, command.MinAmountBase, command.MaxAmountBase, command.ApproverRoleCode });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await LoadAsync(created.Value.Id, cancellationToken).ConfigureAwait(false);
    }

    public async Task<Result<ApprovalRuleDto>> HandleAsync(UpdateApprovalRuleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var rule = await rules.GetAsync(command.RuleId, cancellationToken).ConfigureAwait(false);
        if (rule is null)
        {
            return ProcurementErrors.ApprovalRuleNotFound(command.RuleId);
        }

        if (rule.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (command.IsActive)
        {
            var overlap = await EnsureNoOverlapAsync(
                command.DocType, command.ProductType, command.StepNo, command.MinAmountBase, command.MaxAmountBase, rule.Id, cancellationToken)
                .ConfigureAwait(false);
            if (overlap.IsFailure)
            {
                return overlap.Error;
            }
        }

        var updated = rule.Update(
            command.DocType, command.ProductType, command.MinAmountBase, command.MaxAmountBase,
            command.StepNo, command.ApproverRoleId, command.ApproverRoleCode, command.IsActive);
        if (updated.IsFailure)
        {
            return updated.Error;
        }

        unitOfWork.Audit.Record(
            "proc_approval_rule",
            rule.Id,
            AuditAction.Update,
            new { docType = command.DocType.ToString(), command.StepNo, command.MinAmountBase, command.MaxAmountBase, command.IsActive });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return await LoadAsync(rule.Id, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>
    /// Two active rules for the same <c>(docType, productType, stepNo)</c> may not answer for the same amount,
    /// otherwise the chain would be ambiguous (contract: <c>422</c>).
    /// </summary>
    private async Task<Result> EnsureNoOverlapAsync(
        ApprovalDocType docType,
        ApprovalProductType productType,
        byte stepNo,
        decimal minAmountBase,
        decimal? maxAmountBase,
        uint? excludeRuleId,
        CancellationToken cancellationToken)
    {
        var existing = await rules.ListAsync(tenantContext.TenantId, docType, activeOnly: true, cancellationToken).ConfigureAwait(false);
        var clash = existing.Any(r =>
            r.Id != excludeRuleId
            && r.StepNo == stepNo
            && r.ProductType == productType
            && r.OverlapsBand(minAmountBase, maxAmountBase));

        return clash
            ? ProcurementErrors.ApprovalRuleOverlap(docType.ToString(), productType.ToString(), stepNo)
            : Result.Success();
    }

    private async Task<Result<ApprovalRuleDto>> LoadAsync(uint ruleId, CancellationToken cancellationToken)
    {
        var dto = await queries.GetApprovalRuleAsync(ruleId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ProcurementErrors.ApprovalRuleNotFound(ruleId) : Result.Success(dto);
    }
}
