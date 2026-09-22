using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Commands.PriceHistory;
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

        RequisitionEndpoints.Map(group);
        RfqEndpoints.Map(group);
        QuotationEndpoints.Map(group);
        PurchaseOrderEndpoints.Map(group);
        ApprovalEndpoints.Map(group);
        MapInternal(group);
    }

    /// <summary>Module-to-module routes (spec §4.2); never part of the public contract.</summary>
    private static void MapInternal(RouteGroupBuilder group)
    {
        group.MapGet("/internal/purchase-orders/{purchaseOrderId:long}",
                async (long purchaseOrderId, IPurchaseOrderReader reader, CancellationToken cancellationToken) =>
                {
                    var po = await reader.GetAsync(purchaseOrderId, cancellationToken).ConfigureAwait(false);
                    return po is null ? Results.NotFound() : Results.Ok(po);
                })
            .WithName("InternalPurchaseOrder")
            .ExcludeFromDescription();

        // Inventory books the ledger; Procurement owns received_qty, the PO status and the price history.
        group.MapPost("/internal/purchase-orders/{purchaseOrderId:long}/receipts",
                async (long purchaseOrderId, ReceiptRegistrationRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
                {
                    ArgumentNullException.ThrowIfNull(request);
                    var command = new RecordReceiptPricesCommand(
                        purchaseOrderId,
                        request.GoodsReceiptId,
                        request.ReceiptDate,
                        (request.Lines ?? []).Select(l => new ReceiptLineInput(l.PurchaseOrderLineId, l.ReceivedQty)).ToList());
                    var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
                    return result.ToOk();
                })
            .WithName("InternalPurchaseOrderReceipt")
            .ExcludeFromDescription();
    }
}
