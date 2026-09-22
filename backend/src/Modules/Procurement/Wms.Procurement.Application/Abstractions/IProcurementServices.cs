using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain.Services;

namespace Wms.Procurement.Application.Abstractions;

public interface IProcurementReferenceDataLoader
{
    Task<ProcurementReferenceSet> LoadAsync(ProcurementReferenceRequest request, CancellationToken cancellationToken);
}

/// <summary>
/// The approval directory: which roles a user holds and which delegations are in force for them
/// (<c>iam_user_role</c> / <c>iam_delegation</c>, spec §7). Procurement may not reference Identity (spec §5),
/// so this port is declared here and the adapter is supplied by the host.
/// </summary>
public interface IApprovalDirectory
{
    /// <summary>Role codes the user holds directly.</summary>
    Task<IReadOnlyCollection<string>> GetRoleCodesAsync(uint userId, CancellationToken cancellationToken);

    /// <summary>Delegations that are in force for <paramref name="toUserId"/> on <paramref name="onDate"/>, with the delegator's roles.</summary>
    Task<IReadOnlyList<ActiveDelegation>> GetDelegationsToAsync(uint toUserId, DateOnly onDate, CancellationToken cancellationToken);
}

/// <summary>Tenant-tunable numbers of the module. Values live in configuration; the defaults are the spec's.</summary>
public interface IProcurementSettings
{
    /// <summary>Length in days of the PR-splitting rolling window (<c>proc_split_check_log</c>).</summary>
    int SplitCheckWindowDays { get; }
}
