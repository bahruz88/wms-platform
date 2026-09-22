using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Commands.Requisitions;
using Wms.Procurement.Application.Queries;
using Wms.Procurement.Contracts;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Endpoints;

/// <summary>
/// Operations <c>listRequisitions</c>, <c>createRequisition</c>, <c>getRequisition</c>, <c>updateRequisition</c>,
/// <c>submitRequisition</c>, <c>rejectRequisition</c>, <c>cancelRequisition</c>.
/// </summary>
public static class RequisitionEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/requisitions", ListAsync)
            .RequirePermission(ProcurementPermissions.RequisitionView)
            .WithName("listRequisitions");

        group.MapPost("/requisitions", CreateAsync)
            .RequirePermission(ProcurementPermissions.RequisitionCreate)
            .RequireIdempotencyKey()
            .WithName("createRequisition");

        group.MapGet("/requisitions/{id:long}", GetAsync)
            .RequirePermission(ProcurementPermissions.RequisitionView)
            .WithName("getRequisition");

        group.MapPut("/requisitions/{id:long}", UpdateAsync)
            .RequirePermission(ProcurementPermissions.RequisitionCreate)
            .WithName("updateRequisition");

        group.MapPost("/requisitions/{id:long}/submit", SubmitAsync)
            .RequirePermission(ProcurementPermissions.RequisitionSubmit)
            .RequireIdempotencyKey()
            .WithName("submitRequisition");

        group.MapPost("/requisitions/{id:long}/reject", RejectAsync)
            .RequirePermission(ProcurementPermissions.RequisitionReject)
            .RequireIdempotencyKey()
            .WithName("rejectRequisition");

        group.MapPost("/requisitions/{id:long}/cancel", CancelAsync)
            .RequirePermission(ProcurementPermissions.RequisitionCreate)
            .RequireIdempotencyKey()
            .WithName("cancelRequisition");
    }

    private static async Task<IResult> ListAsync(
        [AsParameters] RequisitionsQueryRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var status = EnumQuery.Parse<RequisitionStatus>(request.Status, "status");
        if (status.IsFailure)
        {
            return status.Error.ToProblem();
        }

        var productType = EnumQuery.Parse<ProductType>(request.ProductType, "productType");
        if (productType.IsFailure)
        {
            return productType.Error.ToProblem();
        }

        var priority = EnumQuery.Parse<Priority>(request.Priority, "priority");
        if (priority.IsFailure)
        {
            return priority.Error.ToProblem();
        }

        var query = new ListRequisitionsQuery(
            status.Value, productType.Value, priority.Value, request.RequesterLocationId,
            request.DateFrom, request.DateTo, request.Search, request.Sort,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(RequisitionCreateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(), cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ProcurementRoutes.Prefix}/requisitions/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetRequisitionQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> UpdateAsync(long id, RequisitionUpdateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> SubmitAsync(long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(new SubmitRequisitionCommand(id, request.RowVersion), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> RejectAsync(long id, VersionedCommentRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(new RejectRequisitionCommand(id, request.RowVersion, request.Comment), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CancelAsync(long id, VersionedCommentRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(new CancelRequisitionCommand(id, request.RowVersion, request.Comment), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
