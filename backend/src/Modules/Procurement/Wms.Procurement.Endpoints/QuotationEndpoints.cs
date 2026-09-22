using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Commands.Quotations;
using Wms.Procurement.Application.Queries;
using Wms.Procurement.Contracts;

namespace Wms.Procurement.Endpoints;

/// <summary>Operations <c>listQuotations</c>, <c>createQuotation</c>, <c>getQuotation</c>, <c>updateQuotation</c>, <c>selectQuotation</c>.</summary>
public static class QuotationEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/quotations", ListAsync)
            .RequirePermission(ProcurementPermissions.QuotationView)
            .WithName("listQuotations");

        group.MapPost("/quotations", CreateAsync)
            .RequirePermission(ProcurementPermissions.QuotationCreate)
            .RequireIdempotencyKey()
            .WithName("createQuotation");

        group.MapGet("/quotations/{id:long}", GetAsync)
            .RequirePermission(ProcurementPermissions.QuotationView)
            .WithName("getQuotation");

        group.MapPut("/quotations/{id:long}", UpdateAsync)
            .RequirePermission(ProcurementPermissions.QuotationCreate)
            .WithName("updateQuotation");

        group.MapPost("/quotations/{id:long}/select", SelectAsync)
            .RequirePermission(ProcurementPermissions.QuotationSelect)
            .RequireIdempotencyKey()
            .WithName("selectQuotation");
    }

    private static async Task<IResult> ListAsync([AsParameters] QuotationsQueryRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var query = new ListQuotationsQuery(
            request.RfqId, request.SupplierId, request.IsSelected, request.DateFrom, request.DateTo, request.Sort,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(QuotationCreateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(), cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ProcurementRoutes.Prefix}/quotations/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetQuotationQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> UpdateAsync(long id, QuotationUpdateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> SelectAsync(long id, QuotationSelectRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new SelectQuotationCommand(id, request.RowVersion, request.SelectionNote);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
