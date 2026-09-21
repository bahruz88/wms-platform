using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Modules;
using Wms.Inventory.Application;
using Wms.Inventory.Contracts;
using Wms.Inventory.Infrastructure;

namespace Wms.Inventory.Endpoints;

/// <summary><c>--Modules=inventory</c> (CONVENTIONS.md). Route prefix <c>/api/v1/inventory</c>, table prefix <c>inv_</c>.</summary>
public sealed class InventoryModule : IModule
{
    public const string ModuleName = "inventory";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddInventoryApplication();
        services.AddInventoryInfrastructure(configuration);
    }

    public void RegisterRemoteContracts(IServiceCollection services, IConfiguration configuration) =>
        services.AddInventoryRemoteContracts(configuration);

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(InventoryRoutes.Prefix).WithTags("Inventory").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("InventoryPing");

        GoodsReceiptEndpoints.Map(group);
        BalanceEndpoints.Map(group);
        CountEndpoints.Map(group);
        DocumentEndpoints.Map(group);
        SettingEndpoints.Map(group);
        InternalEndpoints.Map(group);
    }
}
