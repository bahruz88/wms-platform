using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Commands.PurchaseOrders;
using Wms.Procurement.Application.Queries;
using Wms.Procurement.Contracts;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Endpoints;

/// <summary>
/// Operations <c>listPurchaseOrders</c>, <c>createPurchaseOrder</c>, <c>listOpenPurchaseOrdersForReceipt</c>,
/// <c>getPurchaseOrder</c>, <c>updatePurchaseOrder</c>, <c>submitPurchaseOrder</c>, <c>approvePurchaseOrder</c>,
/// <c>rejectPurchaseOrder</c>, <c>sendPurchaseOrder</c>, <c>closePurchaseOrder</c>, <c>cancelPurchaseOrder</c>.
/// </summary>
public static class PurchaseOrderEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/purchase-orders", ListAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderView)
            .WithName("listPurchaseOrders");

        group.MapPost("/purchase-orders", CreateAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderCreate)
            .RequireIdempotencyKey()
            .WithName("createPurchaseOrder");

        // Declared before "/purchase-orders/{id}" so the literal segment wins over the route parameter.
        group.MapGet("/purchase-orders/open-for-receipt", ListOpenAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderViewForReceipt)
            .WithName("listOpenPurchaseOrdersForReceipt");

        group.MapGet("/purchase-orders/{id:long}", GetAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderView)
            .WithName("getPurchaseOrder");

        group.MapPut("/purchase-orders/{id:long}", UpdateAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderCreate)
            .WithName("updatePurchaseOrder");

        group.MapPost("/purchase-orders/{id:long}/submit", SubmitAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderSubmit)
            .RequireIdempotencyKey()
            .WithName("submitPurchaseOrder");

        group.MapPost("/purchase-orders/{id:long}/approve", ApproveAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderApprove)
            .RequireIdempotencyKey()
            .WithName("approvePurchaseOrder");

        group.MapPost("/purchase-orders/{id:long}/reject", RejectAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderApprove)
            .RequireIdempotencyKey()
            .WithName("rejectPurchaseOrder");

        group.MapPost("/purchase-orders/{id:long}/send", SendAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderSend)
            .RequireIdempotencyKey()
            .WithName("sendPurchaseOrder");

        group.MapPost("/purchase-orders/{id:long}/close", CloseAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderClose)
            .RequireIdempotencyKey()
            .WithName("closePurchaseOrder");

        group.MapPost("/purchase-orders/{id:long}/cancel", CancelAsync)
            .RequirePermission(ProcurementPermissions.PurchaseOrderCreate)
            .RequireIdempotencyKey()
            .WithName("cancelPurchaseOrder");
    }

    private static async Task<IResult> ListAsync([AsParameters] PurchaseOrdersQueryRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var status = EnumQuery.Parse<PurchaseOrderStatus>(request.Status, "status");
        if (status.IsFailure)
        {
            return status.Error.ToProblem();
        }

        var productType = EnumQuery.Parse<ProductType>(request.ProductType, "productType");
        if (productType.IsFailure)
        {
            return productType.Error.ToProblem();
        }

        var query = new ListPurchaseOrdersQuery(
            status.Value, request.SupplierId, request.DeliveryLocationId, productType.Value,
            request.DateFrom, request.DateTo, request.Search, request.Sort,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ListOpenAsync(
        [AsParameters] OpenPurchaseOrdersQueryRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var query = new ListOpenPurchaseOrdersQuery(
            request.SupplierId, request.DeliveryLocationId, request.Search,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(PurchaseOrderCreateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(), cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ProcurementRoutes.Prefix}/purchase-orders/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetPurchaseOrderQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> UpdateAsync(long id, PurchaseOrderUpdateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> SubmitAsync(long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(new SubmitPurchaseOrderCommand(id, request.RowVersion), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ApproveAsync(long id, VersionedCommentRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new ApprovePurchaseOrderCommand(id, request.RowVersion, request.Comment);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> RejectAsync(long id, VersionedCommentRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new RejectPurchaseOrderCommand(id, request.RowVersion, request.Comment);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> SendAsync(long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(new SendPurchaseOrderCommand(id, request.RowVersion), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CloseAsync(long id, VersionedCommentRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new ClosePurchaseOrderCommand(id, request.RowVersion, request.Comment);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CancelAsync(long id, VersionedCommentRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new CancelPurchaseOrderCommand(id, request.RowVersion, request.Comment);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
