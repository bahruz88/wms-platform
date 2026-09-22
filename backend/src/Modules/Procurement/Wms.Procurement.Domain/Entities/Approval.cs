using Wms.Common.Domain;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Entities;

/// <summary><c>proc_approval_rule</c> (spec §10, TOR §10/§36): parametric, never hard-coded.</summary>
public sealed class ApprovalRule : AuditableEntity<uint>, ITenantEntity
{
    public const int RoleCodeMaxLength = 48;

    private ApprovalRule()
    {
    }

    public uint TenantId { get; private set; }

    public ApprovalDocType DocType { get; private set; }

    public ApprovalProductType ProductType { get; private set; } = ApprovalProductType.Any;

    public decimal MinAmountBase { get; private set; }

    /// <summary>NULL = unlimited.</summary>
    public decimal? MaxAmountBase { get; private set; }

    public byte StepNo { get; private set; }

    public uint ApproverRoleId { get; private set; }

    /// <summary>Denormalised <c>iam_role.code</c>: the step must name the role without reaching into Identity's tables.</summary>
    public string ApproverRoleCode { get; private set; } = string.Empty;

    public bool IsActive { get; private set; } = true;

    public static Result<ApprovalRule> Create(
        uint tenantId,
        ApprovalDocType docType,
        byte stepNo,
        uint approverRoleId,
        string approverRoleCode,
        decimal minAmountBase = 0m,
        decimal? maxAmountBase = null,
        ApprovalProductType productType = ApprovalProductType.Any)
    {
        var validated = Validate(stepNo, approverRoleId, approverRoleCode, minAmountBase, maxAmountBase);
        if (validated.IsFailure)
        {
            return validated.Error;
        }

        return new ApprovalRule
        {
            TenantId = tenantId,
            DocType = docType,
            ProductType = productType,
            MinAmountBase = minAmountBase,
            MaxAmountBase = maxAmountBase,
            StepNo = stepNo,
            ApproverRoleId = approverRoleId,
            ApproverRoleCode = approverRoleCode.Trim().ToUpperInvariant(),
        };
    }

    public Result Update(
        ApprovalDocType docType,
        ApprovalProductType productType,
        decimal minAmountBase,
        decimal? maxAmountBase,
        byte stepNo,
        uint approverRoleId,
        string approverRoleCode,
        bool isActive)
    {
        var validated = Validate(stepNo, approverRoleId, approverRoleCode, minAmountBase, maxAmountBase);
        if (validated.IsFailure)
        {
            return validated;
        }

        DocType = docType;
        ProductType = productType;
        MinAmountBase = minAmountBase;
        MaxAmountBase = maxAmountBase;
        StepNo = stepNo;
        ApproverRoleId = approverRoleId;
        ApproverRoleCode = approverRoleCode.Trim().ToUpperInvariant();
        IsActive = isActive;
        return Result.Success();
    }

    /// <summary>
    /// A rule applies when it is active, the document type matches, the product type matches (or the rule is ANY)
    /// and the base amount falls inside <c>[min, max]</c>.
    /// </summary>
    public bool Matches(ApprovalDocType docType, decimal amountBase, ApprovalProductType productType) =>
        IsActive
        && DocType == docType
        && (ProductType == ApprovalProductType.Any || productType == ApprovalProductType.Any || ProductType == productType)
        && amountBase >= MinAmountBase
        && (MaxAmountBase is null || amountBase <= MaxAmountBase);

    /// <summary>True when two rules for the same key would both answer for part of the same amount band.</summary>
    public bool OverlapsBand(decimal otherMin, decimal? otherMax) =>
        otherMin <= (MaxAmountBase ?? decimal.MaxValue) && MinAmountBase <= (otherMax ?? decimal.MaxValue);

    private static Result Validate(byte stepNo, uint approverRoleId, string approverRoleCode, decimal minAmountBase, decimal? maxAmountBase)
    {
        if (stepNo == 0)
        {
            return ProcurementErrors.InvalidApprovalRule("step_no must be 1 or greater.");
        }

        if (approverRoleId == 0)
        {
            return ProcurementErrors.InvalidApprovalRule("approver_role_id is required.");
        }

        if (string.IsNullOrWhiteSpace(approverRoleCode) || approverRoleCode.Length > RoleCodeMaxLength)
        {
            return ProcurementErrors.InvalidApprovalRule($"approver_role_code must be 1..{RoleCodeMaxLength} characters.");
        }

        if (minAmountBase < 0m)
        {
            return ProcurementErrors.InvalidApprovalRule("min_amount_base cannot be negative.");
        }

        if (maxAmountBase is { } max && max < minAmountBase)
        {
            return ProcurementErrors.InvalidApprovalRule("max_amount_base cannot be lower than min_amount_base.");
        }

        return Result.Success();
    }
}

/// <summary><c>proc_approval_instance</c>: the running approval of one document.</summary>
public sealed class ApprovalInstance : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;

    /// <summary>Matches <c>iam_user.username</c>.</summary>
    public const int UsernameMaxLength = 64;

    private readonly List<ApprovalStep> _steps = [];

    private ApprovalInstance()
    {
    }

    public uint TenantId { get; private set; }

    public ApprovalDocType DocType { get; private set; }

    public long DocId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    /// <summary>The AZN amount the rules were selected with (contract: <c>amountBase</c>).</summary>
    public decimal? AmountBase { get; private set; }

    /// <summary>The user who raised the document — SoD: they may not decide (spec §12.6).</summary>
    public uint RequestedBy { get; private set; }

    /// <summary>
    /// The requester's username, denormalised at submit time for the same reason as
    /// <see cref="ApprovalStep.ApproverRoleCode"/>: the approval inbox has to name the person who is waiting on
    /// a decision, and spec §5 does not let Procurement read <c>iam_user</c>.
    /// </summary>
    public string? RequestedByUsername { get; private set; }

    public byte CurrentStep { get; private set; } = 1;

    public ApprovalStatus Status { get; private set; } = ApprovalStatus.Pending;

    public IReadOnlyList<ApprovalStep> Steps => _steps.AsReadOnly();

    public static Result<ApprovalInstance> Start(
        uint tenantId,
        ApprovalDocType docType,
        long docId,
        string docNo,
        decimal? amountBase,
        uint requestedBy,
        IEnumerable<ApprovalRule> rules,
        string? requestedByUsername = null)
    {
        ArgumentNullException.ThrowIfNull(rules);

        var instance = new ApprovalInstance
        {
            TenantId = tenantId,
            DocType = docType,
            DocId = docId,
            DocNo = Requisition.Truncate(docNo, DocNoMaxLength) ?? string.Empty,
            AmountBase = amountBase,
            RequestedBy = requestedBy,
            RequestedByUsername = Requisition.Truncate(requestedByUsername, UsernameMaxLength),
        };

        foreach (var rule in rules.OrderBy(r => r.StepNo))
        {
            instance._steps.Add(ApprovalStep.Create(rule.StepNo, rule.ApproverRoleId, rule.ApproverRoleCode));
        }

        if (instance._steps.Count == 0)
        {
            return ProcurementErrors.NoApprovalRule(amountBase ?? 0m);
        }

        instance.CurrentStep = instance._steps[0].StepNo;
        return instance;
    }

    public ApprovalStep? CurrentPendingStep() =>
        Status == ApprovalStatus.Pending ? _steps.Find(s => s.StepNo == CurrentStep && s.Decision == ApprovalDecision.Pending) : null;

    /// <summary>Records one approver's decision; a rejection ends the whole instance (spec §10).</summary>
    public Result Decide(
        byte stepNo,
        ApprovalDecision decision,
        uint approverUserId,
        DateTimeOffset decidedAt,
        uint? delegatedFromUserId = null,
        string? comment = null,
        string? approverUsername = null,
        string? delegatedFromUsername = null)
    {
        if (Status != ApprovalStatus.Pending)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(ApprovalInstance), Status.ToString(), decision.ToString());
        }

        if (decision == ApprovalDecision.Rejected && string.IsNullOrWhiteSpace(comment))
        {
            return ProcurementErrors.CommentRequired("comment");
        }

        var step = _steps.Find(s => s.StepNo == stepNo);
        if (step is null || stepNo != CurrentStep || step.Decision != ApprovalDecision.Pending)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(ApprovalStep), $"step {CurrentStep}", $"step {stepNo}");
        }

        step.Decide(decision, approverUserId, decidedAt, delegatedFromUserId, comment, approverUsername, delegatedFromUsername);
        if (decision == ApprovalDecision.Rejected)
        {
            Status = ApprovalStatus.Rejected;
            return Result.Success();
        }

        var next = _steps.Where(s => s.StepNo > stepNo).OrderBy(s => s.StepNo).FirstOrDefault();
        if (next is null)
        {
            Status = ApprovalStatus.Approved;
        }
        else
        {
            CurrentStep = next.StepNo;
        }

        return Result.Success();
    }

    public void Cancel() => Status = ApprovalStatus.Cancelled;
}

/// <summary><c>proc_approval_step</c>.</summary>
public sealed class ApprovalStep : Entity<long>
{
    public const int CommentMaxLength = 1000;

    private ApprovalStep()
    {
    }

    public long InstanceId { get; private set; }

    public byte StepNo { get; private set; }

    public uint ApproverRoleId { get; private set; }

    public string ApproverRoleCode { get; private set; } = string.Empty;

    public uint? ApproverUserId { get; private set; }

    /// <summary>Denormalised like <see cref="ApproverRoleCode"/>; the approval trail has to be readable on its own.</summary>
    public string? ApproverUsername { get; private set; }

    public uint? DelegatedFromUserId { get; private set; }

    public string? DelegatedFromUsername { get; private set; }

    public ApprovalDecision Decision { get; private set; } = ApprovalDecision.Pending;

    public DateTimeOffset? DecidedAt { get; private set; }

    public string? Comment { get; private set; }

    internal static ApprovalStep Create(byte stepNo, uint approverRoleId, string approverRoleCode) =>
        new() { StepNo = stepNo, ApproverRoleId = approverRoleId, ApproverRoleCode = approverRoleCode };

    internal void Decide(
        ApprovalDecision decision,
        uint approverUserId,
        DateTimeOffset decidedAt,
        uint? delegatedFromUserId,
        string? comment,
        string? approverUsername = null,
        string? delegatedFromUsername = null)
    {
        Decision = decision;
        ApproverUserId = approverUserId;
        ApproverUsername = Requisition.Truncate(approverUsername, ApprovalInstance.UsernameMaxLength);
        DelegatedFromUserId = delegatedFromUserId;
        DelegatedFromUsername = Requisition.Truncate(delegatedFromUsername, ApprovalInstance.UsernameMaxLength);
        DecidedAt = decidedAt;
        Comment = Requisition.Truncate(comment, CommentMaxLength);
    }
}
