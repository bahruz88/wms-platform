namespace Wms.MasterData.Contracts;

/// <summary>Values of <c>master_reason_code.reason_group</c> (spec §8).</summary>
public static class ReasonGroups
{
    public const string Waste = "WASTE";
    public const string Adjustment = "ADJUSTMENT";
    public const string Return = "RETURN";
    public const string Sample = "SAMPLE";
    public const string Transfer = "TRANSFER";
}

/// <summary>Reason code as seen by other modules — every manual correction must carry one (spec §12.6).</summary>
public sealed record ReasonCodeRefDto(
    ushort Id,
    string Code,
    string Name,
    string ReasonGroup,
    bool RequiresApproval,
    bool RequiresPhoto,
    bool IsActive);

public interface IReasonCodeCatalog
{
    Task<ReasonCodeRefDto?> GetAsync(long reasonCodeId, CancellationToken cancellationToken);

    Task<IReadOnlyList<ReasonCodeRefDto>> GetManyAsync(IReadOnlyCollection<ushort> reasonCodeIds, CancellationToken cancellationToken);
}
