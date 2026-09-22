using Wms.Common.Application.Abstractions;
using Wms.MasterData.Contracts;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Application.Dtos;
using Wms.Procurement.Domain.Services;
using Wms.Procurement.Infrastructure.Persistence;

namespace Wms.Procurement.Infrastructure.Services;

/// <summary>Batches the master-data lookups one page of procurement documents needs (spec §4.2, §13.4).</summary>
public sealed class ProcurementReferenceDataLoader(
    IProductCatalog products,
    ILocationCatalog locations,
    IUomCatalog uoms,
    ISupplierCatalog suppliers) : IProcurementReferenceDataLoader
{
    public async Task<ProcurementReferenceSet> LoadAsync(ProcurementReferenceRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        var productMap = request.ProductIds.Count == 0
            ? new Dictionary<uint, ProductDto>()
            : (await products.GetManyAsync(request.ProductIds, cancellationToken).ConfigureAwait(false)).ToDictionary(p => p.Id);

        var locationMap = request.LocationIds.Count == 0
            ? new Dictionary<uint, LocationDto>()
            : (await locations.GetManyAsync(request.LocationIds, cancellationToken).ConfigureAwait(false)).ToDictionary(l => l.Id);

        var uomMap = request.UomIds.Count == 0
            ? new Dictionary<ushort, UomRefDto>()
            : (await uoms.GetManyAsync(request.UomIds, cancellationToken).ConfigureAwait(false)).ToDictionary(u => u.Id);

        var supplierMap = request.SupplierIds.Count == 0
            ? new Dictionary<uint, MasterData.Contracts.SupplierRefDto>()
            : (await suppliers.GetManyAsync(request.SupplierIds, cancellationToken).ConfigureAwait(false)).ToDictionary(s => s.Id);

        // Users are resolved by the approval directory; a document only carries their ids (spec §5 forbids
        // Procurement -> Identity, so an unresolved id degrades to an empty name rather than failing the page).
        var userMap = request.UserIds.ToDictionary(id => id, UserRefDto.Unknown);

        return new ProcurementReferenceSet(productMap, locationMap, uomMap, supplierMap, userMap);
    }
}

/// <summary>
/// Default <see cref="IApprovalDirectory"/>. Roles come from the caller's own token, which is what the realm
/// grants today; delegations need <c>iam_delegation</c> and are therefore empty until an Identity-backed
/// adapter is registered over this one (see the module README).
/// </summary>
public sealed class ClaimsApprovalDirectory(ICurrentUser currentUser) : IApprovalDirectory
{
    public Task<IReadOnlyCollection<string>> GetRoleCodesAsync(uint userId, CancellationToken cancellationToken)
    {
        // Only the current principal's roles are knowable from the token.
        var roles = userId == currentUser.UserId || currentUser.UserId == 0
            ? currentUser.Roles
            : (IReadOnlyCollection<string>)[];
        return Task.FromResult(roles);
    }

    public Task<IReadOnlyList<ActiveDelegation>> GetDelegationsToAsync(uint toUserId, DateOnly onDate, CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<ActiveDelegation>>([]);
}

/// <summary>Configuration-backed <see cref="IProcurementSettings"/> (<c>Procurement:SplitCheckWindowDays</c>).</summary>
public sealed class ProcurementSettings : IProcurementSettings
{
    public const string SectionName = "Procurement";

    public ProcurementSettings(IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        var configured = configuration.GetSection(SectionName).GetValue<int?>(nameof(SplitCheckWindowDays));
        SplitCheckWindowDays = configured is > 0 ? configured.Value : SplitCheckWindow.DefaultWindowDays;
    }

    public int SplitCheckWindowDays { get; }
}

/// <summary>Design-time / test construction without configuration.</summary>
public sealed class FixedProcurementSettings(int splitCheckWindowDays) : IProcurementSettings
{
    public int SplitCheckWindowDays { get; } = splitCheckWindowDays > 0 ? splitCheckWindowDays : SplitCheckWindow.DefaultWindowDays;
}
