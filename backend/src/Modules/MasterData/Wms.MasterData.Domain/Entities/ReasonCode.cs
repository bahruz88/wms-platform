using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary>
/// <c>master_reason_code</c> (spec §8). Every manual correction must carry one (spec §12.6) — this is what replaces
/// the unexplained <c>+510</c> constant of the Excel sheet.
/// </summary>
public sealed class ReasonCode : Entity<ushort>, ITenantEntity, IVersioned
{
    public const int CodeMaxLength = 32;
    public const int NameMaxLength = 200;

    private ReasonCode()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    /// <summary>Immutable after creation: posted waste/adjustment/return documents reference it (spec §12.6).</summary>
    public ReasonGroup ReasonGroup { get; private set; }

    public bool RequiresApproval { get; private set; } = true;

    public bool RequiresPhoto { get; private set; }

    public bool IsActive { get; private set; } = true;

    public uint RowVersion { get; private set; } = 1;

    public static ReasonCode Create(uint tenantId, string code, string name, ReasonGroup reasonGroup, bool requiresApproval = true, bool requiresPhoto = false)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(code);
        return new ReasonCode
        {
            TenantId = tenantId,
            Code = NormalizeCode(code),
            Name = (name ?? string.Empty).Trim(),
            ReasonGroup = reasonGroup,
            RequiresApproval = requiresApproval,
            RequiresPhoto = requiresPhoto,
        };
    }

    public static string NormalizeCode(string? code) => (code ?? string.Empty).Trim().ToUpperInvariant();

    public void BumpVersion() => RowVersion++;

    public Result Rename(string name)
    {
        var normalized = (name ?? string.Empty).Trim();
        if (normalized.Length is 0 or > NameMaxLength)
        {
            return MasterDataErrors.InvalidReasonCode("name must be 1..200 characters.");
        }

        Name = normalized;
        return Result.Success();
    }

    /// <summary>Spec §12.6: the group decides which screens may pick the code, and posted documents already used it.</summary>
    public Result ChangeReasonGroup(ReasonGroup? reasonGroup)
    {
        if (reasonGroup is not { } requested || requested == ReasonGroup)
        {
            return Result.Success();
        }

        return MasterDataErrors.ReasonGroupImmutable(ReasonGroup.ToString(), requested.ToString());
    }

    public void SetApprovalRules(bool requiresApproval, bool requiresPhoto)
    {
        RequiresApproval = requiresApproval;
        RequiresPhoto = requiresPhoto;
    }

    public void SetActive(bool isActive) => IsActive = isActive;
}
