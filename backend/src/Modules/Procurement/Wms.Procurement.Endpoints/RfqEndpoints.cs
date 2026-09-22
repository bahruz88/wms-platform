using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Commands.Rfqs;
using Wms.Procurement.Application.Queries;
using Wms.Procurement.Contracts;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Endpoints;

/// <summary>Operations <c>listRfqs</c>, <c>createRfq</c>, <c>getRfq</c>, <c>sendRfq</c>, <c>closeRfq</c>, <c>getRfqComparison</c>.</summary>
public static class RfqEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/rfqs", ListAsync)
            .RequirePermission(ProcurementPermissions.RfqView)
            .WithName("listRfqs");

        group.MapPost("/rfqs", CreateAsync)
            .RequirePermission(ProcurementPermissions.RfqCreate)
            .RequireIdempotencyKey()
            .WithName("createRfq");

        group.MapGet("/rfqs/{id:long}", GetAsync)
            .RequirePermission(ProcurementPermissions.RfqView)
            .WithName("getRfq");

        group.MapPost("/rfqs/{id:long}/send", SendAsync)
            .RequirePermission(ProcurementPermissions.RfqCreate)
            .RequireIdempotencyKey()
            .WithName("sendRfq");

        group.MapPost("/rfqs/{id:long}/close", CloseAsync)
            .RequirePermission(ProcurementPermissions.RfqCreate)
            .RequireIdempotencyKey()
            .WithName("closeRfq");

        group.MapGet("/rfqs/{id:long}/comparison", ComparisonAsync)
            .RequirePermission(ProcurementPermissions.QuotationView)
            .WithName("getRfqComparison");
    }

    private static async Task<IResult> ListAsync([AsParameters] RfqsQueryRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var status = EnumQuery.Parse<RfqStatus>(request.Status, "status");
        if (status.IsFailure)
        {
            return status.Error.ToProblem();
        }

        var query = new ListRfqsQuery(
            status.Value, request.SupplierId, request.DateFrom, request.DateTo, request.Search, request.Sort,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(RfqCreateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(), cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ProcurementRoutes.Prefix}/rfqs/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetRfqQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> SendAsync(long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(new SendRfqCommand(id, request.RowVersion), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CloseAsync(long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(new CloseRfqCommand(id, request.RowVersion), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ComparisonAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetRfqComparisonQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
