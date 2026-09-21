using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Modules;
using Wms.Consumption.Application;
using Wms.Consumption.Contracts;
using Wms.Consumption.Infrastructure;

namespace Wms.Consumption.Endpoints;

/// <summary>
/// <c>--Modules=consumption</c> (CONVENTIONS.md). Route prefix <c>/api/v1/consumption</c>, table prefix
/// <c>cons_</c>. Deployed together with <c>wms-inventory</c>: the engine is tightly coupled to Inventory and
/// runs on the same nightly schedule (ADR-012).
/// </summary>
public sealed class ConsumptionModule : IModule
{
    public const string ModuleName = "consumption";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddConsumptionApplication();
        services.AddConsumptionInfrastructure(configuration);
    }

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(ConsumptionRoutes.Prefix).WithTags("Consumption").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("ConsumptionPing");

        MenuItemEndpoints.Map(group);
        RecipeEndpoints.Map(group);
        SalesImportEndpoints.Map(group);
        ConsumptionRunEndpoints.Map(group);
    }
}
