using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Queries.Settings;

/// <summary><c>GET /api/v1/inventory/settings</c> (inventory.v1.yaml <c>listInventorySettings</c>).</summary>
public sealed record GetInventorySettingsQuery : IQuery<IReadOnlyList<InventorySettingDto>>;

public sealed class GetInventorySettingsQueryHandler(IInventorySettings settings, ITenantContext tenantContext)
    : IQueryHandler<GetInventorySettingsQuery, IReadOnlyList<InventorySettingDto>>
{
    public async Task<Result<IReadOnlyList<InventorySettingDto>>> HandleAsync(
        GetInventorySettingsQuery query,
        CancellationToken cancellationToken)
    {
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var rows = new List<InventorySettingDto>(InventorySettingKeys.Definitions.Count);
        foreach (var definition in InventorySettingKeys.Definitions)
        {
            // A key with no row yet reports its documented default, so the list is never partially blank.
            var value = await settings.GetAsync(definition.Key, cancellationToken).ConfigureAwait(false);
            rows.Add(InventorySettingDto.From(definition, value));
        }

        return rows;
    }
}
