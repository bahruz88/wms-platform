using Wms.Common.Domain;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Entities;

/// <summary><c>proc_approval_rule</c> (spec §10, TOR §10/§36): parametric, never hard-coded.</summary>
public sealed class ApprovalRule : Entity<uint>, ITenantEntity
{
    private ApprovalRule()
    {
    }

    public uint TenantId { get; private set; }

    public string DocType { get; private set; } = string.Empty;

    public ApprovalProductType ProductType { get; private set; } = ApprovalProductType.Any;

    public decimal MinAmountBase { get; private set; }

    /// <summary>NULL = unlimited.</summary>
    public decimal? MaxAmountBase { get; private set; }

    public byte StepNo { get; private set; }

    public uint ApproverRoleId { get; private set; }

    public bool IsActive { get; private set; } = true;

    public static ApprovalRule Create(uint tenantId, string docType, byte stepNo, uint approverRoleId, decimal minAmountBase = 0m, decimal? maxAmountBase = null, ApprovalProductType productType = ApprovalProductType.Any)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(docType);
        return new ApprovalRule
        {
            TenantId = tenantId,
            DocType = docType,
            ProductType = productType,
            MinAmountBase = minAmountBase,
            MaxAmountBase = maxAmountBase,
            StepNo = stepNo,
            ApproverRoleId = approverRoleId,
        };
    }

    public bool Matches(string docType, decimal amountBase, ApprovalProductType productType) =>
        IsActive
        && string.Equals(DocType, docType, StringComparison.OrdinalIgnoreCase)
        && (ProductType == ApprovalProductType.Any || productType == ApprovalProductType.Any || ProductType == productType)
        && amountBase >= MinAmountBase
        && (MaxAmountBase is null || amountBase <= MaxAmountBase);
}

/// <summary><c>proc_approval_instance</c>: the running approval of one document.</summary>
public sealed class ApprovalInstance : AggregateRoot<long>, ITenantEntity
{
    private readonly List<ApprovalStep> _steps = [];

    private ApprovalInstance()
    {
    }

    public uint TenantId { get; private set; }

    public string DocType { get; private set; } = string.Empty;

    public long DocId { get; private set; }

    public byte CurrentStep { get; private set; } = 1;

    public ApprovalStatus Status { get; private set; } = ApprovalStatus.Pending;

    public IReadOnlyList<ApprovalStep> Steps => _steps.AsReadOnly();

    public static ApprovalInstance Start(uint tenantId, string docType, long docId, IEnumerable<ApprovalRule> rules)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(docType);
        ArgumentNullException.ThrowIfNull(rules);

        var instance = new ApprovalInstance { TenantId = tenantId, DocType = docType, DocId = docId };
        foreach (var rule in rules.OrderBy(r => r.StepNo))
        {
            instance._steps.Add(ApprovalStep.Create(rule.StepNo));
        }

        instance.CurrentStep = instance._steps.Count > 0 ? instance._steps[0].StepNo : (byte)1;
        return instance;
    }

    /// <summary>Records one approver's decision; a rejection ends the whole instance (spec §10).</summary>
    public Result Decide(byte stepNo, ApprovalDecision decision, uint approverUserId, DateTimeOffset decidedAt, uint? delegatedFromUserId = null, string? comment = null)
    {
        if (Status != ApprovalStatus.Pending)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(ApprovalInstance), Status.ToString(), decision.ToString());
        }

        var step = _steps.Find(s => s.StepNo == stepNo);
        if (step is null || stepNo != CurrentStep)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(ApprovalStep), $"step {CurrentStep}", $"step {stepNo}");
        }

        step.Decide(decision, approverUserId, decidedAt, delegatedFromUserId, comment);
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

    public uint? ApproverUserId { get; private set; }

    public uint? DelegatedFromUserId { get; private set; }

    public ApprovalDecision Decision { get; private set; } = ApprovalDecision.Pending;

    public DateTimeOffset? DecidedAt { get; private set; }

    public string? Comment { get; private set; }

    internal static ApprovalStep Create(byte stepNo) => new() { StepNo = stepNo };

    internal void Decide(ApprovalDecision decision, uint approverUserId, DateTimeOffset decidedAt, uint? delegatedFromUserId, string? comment)
    {
        Decision = decision;
        ApproverUserId = approverUserId;
        DelegatedFromUserId = delegatedFromUserId;
        DecidedAt = decidedAt;
        Comment = comment is { Length: > CommentMaxLength } c ? c[..CommentMaxLength] : comment;
    }
}
