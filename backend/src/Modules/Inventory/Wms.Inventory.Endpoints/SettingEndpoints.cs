using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Inventory.Application;
using Wms.Inventory.Application.Commands.Settings;
using Wms.Inventory.Application.Queries.Settings;

namespace Wms.Inventory.Endpoints;

/// <summary><c>inv_setting</c> endpoints of inventory.v1.yaml (spec §9.1, TOR §36).</summary>
internal static class SettingEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        group.MapGet("/settings", async (IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetInventorySettingsQuery(), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(InventoryPermissions.SettingsView)
            .WithName("GetInventorySettings");

        group.MapPut("/settings/{key}", async (string key, UpdateSettingRequest body, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher
                    .SendAsync(new UpdateInventorySettingCommand(key, body.Value), cancellationToken)
                    .ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(InventoryPermissions.SettingsManage)
            .WithName("UpdateInventorySetting");
    }
}

/// <summary>Body of <c>PUT /api/v1/inventory/settings/{key}</c>.</summary>
public sealed record UpdateSettingRequest(string Value);
