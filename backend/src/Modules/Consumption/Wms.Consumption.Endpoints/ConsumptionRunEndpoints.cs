using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Consumption.Application;
using Wms.Consumption.Application.Commands.Runs;
using Wms.Consumption.Application.Queries;
using Wms.Consumption.Application.Queries.Variance;
using Wms.Consumption.Contracts;

namespace Wms.Consumption.Endpoints;

/// <summary>
/// Operations <c>listConsumptionRuns</c>, <c>createConsumptionRun</c>, <c>getConsumptionRun</c>,
/// <c>calculateConsumptionRun</c>, <c>postConsumptionRun</c>, <c>reverseConsumptionRun</c>,
/// <c>getConsumptionVariance</c>, <c>getPortionCompliance</c>.
/// </summary>
public static class ConsumptionRunEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/runs", ListAsync)
            .RequirePermission(ConsumptionPermissions.RunCalculate)
            .WithName("listConsumptionRuns");

        group.MapPost("/runs", CreateAsync)
            .RequirePermission(ConsumptionPermissions.RunCalculate)
            .RequireIdempotencyKey()
            .WithName("createConsumptionRun");

        group.MapGet("/runs/{id:long}", GetAsync)
            .RequirePermission(ConsumptionPermissions.RunCalculate)
            .WithName("getConsumptionRun");

        group.MapPost("/runs/{id:long}/calculate", CalculateAsync)
            .RequirePermission(ConsumptionPermissions.RunCalculate)
            .RequireIdempotencyKey()
            .WithName("calculateConsumptionRun");

        group.MapPost("/runs/{id:long}/post", PostAsync)
            .RequirePermission(ConsumptionPermissions.RunPost)
            .RequireIdempotencyKey()
            .WithName("postConsumptionRun");

        group.MapPost("/runs/{id:long}/reverse", ReverseAsync)
            .RequirePermission(ConsumptionPermissions.MovementReverse)
            .RequireIdempotencyKey()
            .WithName("reverseConsumptionRun");

        group.MapGet("/variance", VarianceAsync)
            .RequirePermission(ConsumptionPermissions.VarianceView)
            .WithName("getConsumptionVariance");

        group.MapGet("/portion-compliance", PortionComplianceAsync)
            .RequirePermission(ConsumptionPermissions.VarianceView)
            .WithName("getPortionCompliance");
    }

    private static async Task<IResult> ListAsync(
        [AsParameters] ConsumptionRunsRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var query = new GetConsumptionRunsQuery(
            request.LocationId, request.DateFrom, request.DateTo, request.Status, request.HasShortfall,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(
        ConsumptionRunCreateRequest request,
        HttpContext httpContext,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var key = IdempotencyKey.Require(httpContext);
        var command = new CreateConsumptionRunCommand(request.SalesImportId, request.PostImmediately ?? false, key);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ConsumptionRoutes.Prefix}/runs/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetConsumptionRunQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CalculateAsync(
        long id,
        VersionedActionRequest? request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var result = await dispatcher.SendAsync(new CalculateConsumptionRunCommand(id, request?.RowVersion), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> PostAsync(
        long id,
        VersionedActionRequest? request,
        HttpContext httpContext,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var key = IdempotencyKey.Require(httpContext);
        var result = await dispatcher.SendAsync(new PostConsumptionRunCommand(id, request?.RowVersion, key), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ReverseAsync(
        long id,
        ReasonedActionRequest request,
        HttpContext httpContext,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var key = IdempotencyKey.Require(httpContext);
        var result = await dispatcher
            .SendAsync(new ReverseConsumptionRunCommand(id, request.ReasonCodeId, request.Note, key), cancellationToken)
            .ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> VarianceAsync(
        [AsParameters] VarianceRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var query = new GetConsumptionVarianceQuery(
            request.LocationId, request.ProductId, request.PeriodFrom, request.PeriodTo, request.MinAbsVariancePct,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> PortionComplianceAsync(
        [AsParameters] PortionComplianceRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var query = new GetPortionComplianceQuery(
            request.LocationId, request.MenuItemId, request.PeriodFrom, request.PeriodTo,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
