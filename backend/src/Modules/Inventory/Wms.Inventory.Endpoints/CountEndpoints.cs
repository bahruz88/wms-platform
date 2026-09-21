using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Inventory.Application;
using Wms.Inventory.Application.Commands.Counts;
using Wms.Inventory.Application.Queries.Counts;
using Wms.Inventory.Contracts;

namespace Wms.Inventory.Endpoints;

/// <summary>
/// Inventory count (<c>inv_count</c>, TOR §21). Every mutating call returns the whole document, so the client
/// always has a fresh <c>rowVersion</c> for the next step.
/// </summary>
public static class CountEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/counts", ListAsync)
            .RequirePermission(InventoryPermissions.CountView)
            .WithName("listCounts");

        group.MapPost("/counts", CreateAsync)
            .RequirePermission(InventoryPermissions.CountCreate)
            .RequireIdempotencyKey()
            .WithName("createCount");

        group.MapGet("/counts/{id:long}", GetAsync)
            .RequirePermission(InventoryPermissions.CountView)
            .WithName("getCount");

        group.MapPost("/counts/{id:long}/freeze", FreezeAsync)
            .RequirePermission(InventoryPermissions.CountFreeze)
            .RequireIdempotencyKey()
            .WithName("freezeCount");

        group.MapPost("/counts/{id:long}/lines", SubmitLinesAsync)
            .RequirePermission(InventoryPermissions.CountEnter)
            .RequireIdempotencyKey()
            .WithName("submitCountLines");

        group.MapPost("/counts/{id:long}/submit", SubmitAsync)
            .RequirePermission(InventoryPermissions.CountEnter)
            .RequireIdempotencyKey()
            .WithName("submitCount");

        group.MapPost("/counts/{id:long}/approve", ApproveAsync)
            .RequirePermission(InventoryPermissions.AdjustmentApprove)
            .RequireIdempotencyKey()
            .WithName("approveCount");

        group.MapPost("/counts/{id:long}/post", PostAsync)
            .RequirePermission(InventoryPermissions.CountPost)
            .RequireIdempotencyKey()
            .WithName("postCount");

        group.MapPost("/counts/{id:long}/cancel", CancelAsync)
            .RequirePermission(InventoryPermissions.CountCreate)
            .RequireIdempotencyKey()
            .WithName("cancelCount");
    }

    private static async Task<IResult> ListAsync([AsParameters] CountsRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var query = new ListCountsQuery(
            request.Status, request.CountType, request.LocationId, request.DateFrom, request.DateTo,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(CountCreateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var result = await dispatcher.SendAsync(request.ToCommand(), cancellationToken).ConfigureAwait(false);
        if (result.IsFailure)
        {
            return result.Error.ToProblem();
        }

        var created = await LoadAsync(result.Value, dispatcher, cancellationToken).ConfigureAwait(false);
        return created.ToHttpResult(dto => TypedResults.Created($"{InventoryRoutes.Prefix}/counts/{dto.Id}", dto));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetCountQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static Task<IResult> FreezeAsync(long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        return RunAsync(new FreezeCountCommand(id, request.RowVersion), dispatcher, cancellationToken);
    }

    private static Task<IResult> SubmitLinesAsync(long id, CountLinesSubmitRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new SubmitCountLinesCommand(
            id,
            request.RowVersion,
            (request.Lines ?? []).Select(l => new CountLineInput(
                l.ProductId,
                l.BatchId,
                l.CountedQuantity?.Value ?? 0m,
                l.CountedQuantity?.UomId ?? 0,
                l.ReasonCodeId,
                l.Note)).ToList());
        return RunAsync(command, dispatcher, cancellationToken);
    }

    private static Task<IResult> SubmitAsync(long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        return RunAsync(new SubmitCountCommand(id, request.RowVersion), dispatcher, cancellationToken);
    }

    private static Task<IResult> ApproveAsync(long id, ApprovalDecisionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var approved = string.Equals(request.Decision, "APPROVED", StringComparison.OrdinalIgnoreCase);
        return RunAsync(new ApproveCountCommand(id, request.RowVersion, approved, request.Comment), dispatcher, cancellationToken);
    }

    private static async Task<IResult> PostAsync(
        long id,
        VersionedActionRequest request,
        HttpContext httpContext,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var idempotencyKey = IdempotencyKey.Require(httpContext);
        var result = await dispatcher
            .SendAsync(new PostCountCommand(id, request.RowVersion, idempotencyKey), cancellationToken)
            .ConfigureAwait(false);
        if (result.IsFailure)
        {
            return result.Error.ToProblem();
        }

        var dto = await LoadAsync(result.Value.CountId, dispatcher, cancellationToken).ConfigureAwait(false);
        return dto.ToOk();
    }

    private static Task<IResult> CancelAsync(long id, ReasonedActionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        return RunAsync(new CancelCountCommand(id, request.RowVersion, request.ReasonCodeId, request.Note), dispatcher, cancellationToken);
    }

    /// <summary>Runs a command that returns the count id, then re-reads the document for the response body.</summary>
    private static async Task<IResult> RunAsync(ICommand<long> command, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        if (result.IsFailure)
        {
            return result.Error.ToProblem();
        }

        var dto = await LoadAsync(result.Value, dispatcher, cancellationToken).ConfigureAwait(false);
        return dto.ToOk();
    }

    private static Task<Wms.Common.Domain.Result<Wms.Inventory.Application.Dtos.CountDto>> LoadAsync(
        long id,
        IDispatcher dispatcher,
        CancellationToken cancellationToken) =>
        dispatcher.QueryAsync(new GetCountQuery(id), cancellationToken);
}
