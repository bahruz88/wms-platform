using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary>
/// <c>master_reason_code</c> (spec §8). Every manual correction must carry one (spec §12.6) — this is what replaces
/// the unexplained <c>+510</c> constant of the Excel sheet.
/// </summary>
public sealed class ReasonCode : Entity<ushort>, ITenantEntity
{
    private ReasonCode()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public ReasonGroup ReasonGroup { get; private set; }

    public bool RequiresApproval { get; private set; } = true;

    public bool RequiresPhoto { get; private set; }

    public bool IsActive { get; private set; } = true;

    public static ReasonCode Create(uint tenantId, string code, string name, ReasonGroup reasonGroup, bool requiresApproval = true, bool requiresPhoto = false)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(code);
        return new ReasonCode
        {
            TenantId = tenantId,
            Code = code.Trim().ToUpperInvariant(),
            Name = (name ?? string.Empty).Trim(),
            ReasonGroup = reasonGroup,
            RequiresApproval = requiresApproval,
            RequiresPhoto = requiresPhoto,
        };
    }
}
