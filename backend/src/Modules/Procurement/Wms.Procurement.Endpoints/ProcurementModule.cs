using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Queries;
using Wms.Procurement.Contracts;
using Wms.Procurement.Infrastructure;

namespace Wms.Procurement.Endpoints;

/// <summary><c>--Modules=procurement</c>. Route prefix <c>/api/v1/procurement</c>, table prefix <c>proc_</c>.</summary>
public sealed class ProcurementModule : IModule
{
    public const string ModuleName = "procurement";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddProcurementApplication();
        services.AddProcurementInfrastructure(configuration);
    }

    public void RegisterRemoteContracts(IServiceCollection services, IConfiguration configuration) =>
        services.AddProcurementRemoteContracts(configuration);

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(ProcurementRoutes.Prefix).WithTags("Procurement").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("ProcurementPing");

        group.MapGet("/purchase-orders", async ([AsParameters] PurchaseOrdersRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var query = new GetPurchaseOrdersQuery(request.SupplierId, request.Status, new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(ProcurementPermissions.PurchaseOrderView)
            .WithName("GetPurchaseOrders");

        group.MapGet("/internal/purchase-orders/{purchaseOrderId:long}",
                async (long purchaseOrderId, IPurchaseOrderReader reader, CancellationToken cancellationToken) =>
                {
                    var po = await reader.GetAsync(purchaseOrderId, cancellationToken).ConfigureAwait(false);
                    return po is null ? Results.NotFound() : Results.Ok(po);
                })
            .WithName("InternalPurchaseOrder")
            .ExcludeFromDescription();
    }
}

public sealed record PurchaseOrdersRequest(uint? SupplierId, string? Status, int? Page, int? Size);
