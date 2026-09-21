using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Inventory.Application;
using Wms.Inventory.Application.Commands.Issues;
using Wms.Inventory.Application.Commands.Ledger;
using Wms.Inventory.Application.Commands.Returns;
using Wms.Inventory.Application.Commands.Samples;
using Wms.Inventory.Application.Commands.StockRequests;
using Wms.Inventory.Application.Commands.Waste;
using Wms.Inventory.Application.Queries.Documents;
using Wms.Inventory.Contracts;

namespace Wms.Inventory.Endpoints;

/// <summary>
/// Stock requests, issues/transfers, waste, samples, returns to vendor, batches and the ledger.
/// Every mutating call answers with the whole document so the client always holds a fresh <c>rowVersion</c>.
/// </summary>
public static class DocumentEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        MapStockRequests(group);
        MapIssues(group);
        MapWaste(group);
        MapSamples(group);
        MapReturns(group);
        MapBatches(group);
        MapLedger(group);
    }

    // ================================================================ stock requests

    private static void MapStockRequests(RouteGroupBuilder group)
    {
        group.MapGet("/stock-requests", async ([AsParameters] DocumentListRequest request, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new ListStockRequestsQuery(request.ToQuery()), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.RequestView)
            .WithName("listStockRequests");

        group.MapPost("/stock-requests", async (StockRequestCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateStockRequestCommand(
                    request.DocDate, request.FromLocationId, request.ToLocationId, request.RequiredDate, request.Note,
                    (request.Lines ?? []).Select(l => new StockRequestLineCommand(l.ProductId, l.Qty, l.UomId, l.Note)).ToList());
                var created = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (created.IsFailure)
                {
                    return created.Error.ToProblem();
                }

                var dto = await dispatcher.QueryAsync(new GetStockRequestQuery(created.Value), ct).ConfigureAwait(false);
                return dto.ToHttpResult(d => TypedResults.Created($"{InventoryRoutes.Prefix}/stock-requests/{d.Id}", d));
            })
            .RequirePermission(InventoryPermissions.RequestCreate)
            .RequireIdempotencyKey()
            .WithName("createStockRequest");

        group.MapGet("/stock-requests/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetStockRequestQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.RequestView)
            .WithName("getStockRequest");

        group.MapPut("/stock-requests/{id:long}", async (long id, StockRequestUpdateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new UpdateStockRequestCommand(
                    id, request.RowVersion, request.DocDate, request.RequiredDate, request.Note,
                    (request.Lines ?? []).Select(l => new StockRequestLineCommand(l.ProductId, l.Qty, l.UomId, l.Note)).ToList());
                return await RunAsync(command, dispatcher, i => new GetStockRequestQuery(i), ct).ConfigureAwait(false);
            })
            .RequirePermission(InventoryPermissions.RequestCreate)
            .WithName("updateStockRequest");

        group.MapPost("/stock-requests/{id:long}/submit", async (long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                return await RunAsync(new SubmitStockRequestCommand(id, request.RowVersion), dispatcher, i => new GetStockRequestQuery(i), ct).ConfigureAwait(false);
            })
            .RequirePermission(InventoryPermissions.RequestCreate)
            .RequireIdempotencyKey()
            .WithName("submitStockRequest");

        group.MapPost("/stock-requests/{id:long}/cancel", async (long id, ReasonedActionRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                return await RunAsync(new CancelStockRequestCommand(id, request.RowVersion, request.Note), dispatcher, i => new GetStockRequestQuery(i), ct).ConfigureAwait(false);
            })
            .RequirePermission(InventoryPermissions.RequestCreate)
            .RequireIdempotencyKey()
            .WithName("cancelStockRequest");
    }

    // ================================================================ issues and transfers

    private static void MapIssues(RouteGroupBuilder group)
    {
        group.MapGet("/issues", async ([AsParameters] DocumentListRequest request, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new ListIssuesQuery(request.ToQuery()), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.IssueView)
            .WithName("listIssues");

        group.MapPost("/issues", async (IssueCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateIssueCommand(
                    request.DocDate, request.IssueType, request.FromLocationId, request.ToLocationId,
                    request.RequestId, request.Note, (request.Lines ?? []).Select(l => l.ToInput()).ToList());
                var created = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (created.IsFailure)
                {
                    return created.Error.ToProblem();
                }

                var dto = await dispatcher.QueryAsync(new GetIssueQuery(created.Value), ct).ConfigureAwait(false);
                return dto.ToHttpResult(d => TypedResults.Created($"{InventoryRoutes.Prefix}/issues/{d.Id}", d));
            })
            .RequirePermission(InventoryPermissions.IssueCreate)
            .RequireIdempotencyKey()
            .WithName("createIssue");

        group.MapGet("/issues/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetIssueQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.IssueView)
            .WithName("getIssue");

        group.MapPost("/issues/{id:long}/dispatch", async (
                long id, VersionedActionRequest request, HttpContext http, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var key = IdempotencyKey.Require(http);
                var result = await dispatcher.SendAsync(new DispatchIssueCommand(id, request.RowVersion, key), ct).ConfigureAwait(false);
                if (result.IsFailure)
                {
                    return result.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetIssueQuery(result.Value.IssueId), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(InventoryPermissions.IssueDispatch)
            .RequireIdempotencyKey()
            .WithName("dispatchIssue");

        group.MapPost("/issues/{id:long}/confirm-receipt", async (
                long id, IssueConfirmReceiptRequest request, HttpContext http, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var key = IdempotencyKey.Require(http);
                var command = new ConfirmIssueReceiptCommand(
                    id, request.RowVersion, key, (request.Lines ?? []).Select(l => l.ToInput()).ToList());
                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (result.IsFailure)
                {
                    return result.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetIssueQuery(result.Value.IssueId), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(InventoryPermissions.IssueConfirm)
            .RequireIdempotencyKey()
            .WithName("confirmIssueReceipt");

        group.MapPost("/issues/{id:long}/cancel", async (long id, ReasonedActionRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                return await RunAsync(new CancelIssueCommand(id, request.RowVersion, request.Note), dispatcher, i => new GetIssueQuery(i), ct).ConfigureAwait(false);
            })
            .RequirePermission(InventoryPermissions.IssueCreate)
            .RequireIdempotencyKey()
            .WithName("cancelIssue");
    }

    // ================================================================ waste

    private static void MapWaste(RouteGroupBuilder group)
    {
        group.MapGet("/waste", async ([AsParameters] DocumentListRequest request, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new ListWasteQuery(request.ToQuery()), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.WasteView)
            .WithName("listWaste");

        group.MapPost("/waste", async (WasteCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateWasteCommand(
                    request.DocDate, request.LocationId, request.ReasonCodeId, request.Note,
                    (request.Lines ?? []).Select(l => l.ToInput()).ToList());
                var created = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (created.IsFailure)
                {
                    return created.Error.ToProblem();
                }

                var dto = await dispatcher.QueryAsync(new GetWasteQuery(created.Value), ct).ConfigureAwait(false);
                return dto.ToHttpResult(d => TypedResults.Created($"{InventoryRoutes.Prefix}/waste/{d.Id}", d));
            })
            .RequirePermission(InventoryPermissions.WasteCreate)
            .RequireIdempotencyKey()
            .WithName("createWaste");

        group.MapGet("/waste/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetWasteQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.WasteView)
            .WithName("getWaste");

        group.MapPost("/waste/{id:long}/submit", async (long id, VersionedActionRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                return await RunAsync(new SubmitWasteCommand(id, request.RowVersion), dispatcher, i => new GetWasteQuery(i), ct).ConfigureAwait(false);
            })
            .RequirePermission(InventoryPermissions.WasteCreate)
            .RequireIdempotencyKey()
            .WithName("submitWaste");

        group.MapPost("/waste/{id:long}/approve", async (long id, ApprovalDecisionRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var approved = string.Equals(request.Decision, "APPROVED", StringComparison.OrdinalIgnoreCase);
                return await RunAsync(new ApproveWasteCommand(id, request.RowVersion, approved, request.Comment), dispatcher, i => new GetWasteQuery(i), ct).ConfigureAwait(false);
            })
            .RequirePermission(InventoryPermissions.WasteApprove)
            .RequireIdempotencyKey()
            .WithName("approveWaste");

        group.MapPost("/waste/{id:long}/post", async (
                long id, VersionedActionRequest request, HttpContext http, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var key = IdempotencyKey.Require(http);
                var result = await dispatcher.SendAsync(new PostWasteCommand(id, request.RowVersion, key), ct).ConfigureAwait(false);
                if (result.IsFailure)
                {
                    return result.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetWasteQuery(result.Value.WasteId), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(InventoryPermissions.WastePost)
            .RequireIdempotencyKey()
            .WithName("postWaste");
    }

    // ================================================================ samples

    private static void MapSamples(RouteGroupBuilder group)
    {
        group.MapGet("/samples", async ([AsParameters] DocumentListRequest request, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new ListSamplesQuery(request.ToQuery()), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.SampleView)
            .WithName("listSamples");

        group.MapPost("/samples", async (SampleCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateSampleCommand(
                    request.DocDate, request.LocationId, request.Authority, request.Purpose, request.ReasonCodeId,
                    (request.Lines ?? []).Select(l => l.ToInput()).ToList());
                var created = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (created.IsFailure)
                {
                    return created.Error.ToProblem();
                }

                var dto = await dispatcher.QueryAsync(new GetSampleQuery(created.Value), ct).ConfigureAwait(false);
                return dto.ToHttpResult(d => TypedResults.Created($"{InventoryRoutes.Prefix}/samples/{d.Id}", d));
            })
            .RequirePermission(InventoryPermissions.SampleCreate)
            .RequireIdempotencyKey()
            .WithName("createSample");

        group.MapGet("/samples/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetSampleQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.SampleView)
            .WithName("getSample");

        group.MapPost("/samples/{id:long}/post", async (
                long id, VersionedActionRequest request, HttpContext http, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var key = IdempotencyKey.Require(http);
                var result = await dispatcher.SendAsync(new PostSampleCommand(id, request.RowVersion, key), ct).ConfigureAwait(false);
                if (result.IsFailure)
                {
                    return result.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetSampleQuery(result.Value.SampleId), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(InventoryPermissions.SamplePost)
            .RequireIdempotencyKey()
            .WithName("postSample");
    }

    // ================================================================ return to vendor

    private static void MapReturns(RouteGroupBuilder group)
    {
        group.MapGet("/return-to-vendor", async ([AsParameters] DocumentListRequest request, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new ListReturnsToVendorQuery(request.ToQuery()), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.ReturnView)
            .WithName("listReturnsToVendor");

        group.MapPost("/return-to-vendor", async (ReturnToVendorCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateReturnToVendorCommand(
                    request.DocDate, request.SupplierId, request.LocationId, request.ReceiptId, request.ReasonCodeId,
                    request.ClaimAmount, request.Note, (request.Lines ?? []).Select(l => l.ToInput()).ToList());
                var created = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (created.IsFailure)
                {
                    return created.Error.ToProblem();
                }

                var dto = await dispatcher.QueryAsync(new GetReturnToVendorQuery(created.Value), ct).ConfigureAwait(false);
                return dto.ToHttpResult(d => TypedResults.Created($"{InventoryRoutes.Prefix}/return-to-vendor/{d.Id}", d));
            })
            .RequirePermission(InventoryPermissions.ReturnCreate)
            .RequireIdempotencyKey()
            .WithName("createReturnToVendor");

        group.MapGet("/return-to-vendor/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetReturnToVendorQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.ReturnView)
            .WithName("getReturnToVendor");

        group.MapPost("/return-to-vendor/{id:long}/send", async (
                long id, VersionedActionRequest request, HttpContext http, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var key = IdempotencyKey.Require(http);
                var result = await dispatcher.SendAsync(new SendReturnToVendorCommand(id, request.RowVersion, key), ct).ConfigureAwait(false);
                if (result.IsFailure)
                {
                    return result.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetReturnToVendorQuery(result.Value.ReturnId), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(InventoryPermissions.ReturnPost)
            .RequireIdempotencyKey()
            .WithName("sendReturnToVendor");

        group.MapPost("/return-to-vendor/{id:long}/close", async (long id, ReturnToVendorCloseRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CloseReturnToVendorCommand(id, request.RowVersion, request.Outcome, request.ClaimAmount, request.OutcomeNote);
                return await RunAsync(command, dispatcher, i => new GetReturnToVendorQuery(i), ct).ConfigureAwait(false);
            })
            .RequirePermission(InventoryPermissions.ReturnCreate)
            .RequireIdempotencyKey()
            .WithName("closeReturnToVendor");
    }

    // ================================================================ batches

    private static void MapBatches(RouteGroupBuilder group)
    {
        group.MapGet("/batches", async ([AsParameters] BatchesRequest request, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(request.ToQuery(), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.BatchView)
            .WithName("listBatches");

        group.MapGet("/batches/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetBatchQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.BatchView)
            .WithName("getBatch");

        group.MapPost("/batches/{id:long}/status", async (long id, BatchStatusChangeRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new ChangeBatchStatusCommand(id, request.RowVersion, request.Status, request.ReasonCodeId, request.Note);
                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (result.IsFailure)
                {
                    return result.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetBatchQuery(result.Value), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(InventoryPermissions.BatchManage)
            .RequireIdempotencyKey()
            .WithName("changeBatchStatus");
    }

    // ================================================================ ledger

    private static void MapLedger(RouteGroupBuilder group)
    {
        group.MapGet("/movements", async ([AsParameters] MovementsRequest request, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(request.ToQuery(), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.MovementView)
            .WithName("listMovements");

        group.MapGet("/movement-groups/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetMovementGroupQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(InventoryPermissions.MovementView)
            .WithName("getMovementGroup");

        group.MapPost("/movement-groups/{id:long}/reverse", async (
                long id, MovementGroupReverseRequest request, HttpContext http, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var key = IdempotencyKey.Require(http);
                var result = await dispatcher
                    .SendAsync(new ReverseMovementGroupCommand(id, request.ReasonCodeId, request.Note, key), ct)
                    .ConfigureAwait(false);
                if (result.IsFailure)
                {
                    return result.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetMovementGroupQuery(result.Value.ReversalGroupId), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(InventoryPermissions.MovementReverse)
            .RequireIdempotencyKey()
            .WithName("reverseMovementGroup");
    }

    /// <summary>Runs a command that returns the document id, then re-reads the document for the response body.</summary>
    private static async Task<IResult> RunAsync<TQuery>(
        ICommand<long> command,
        IDispatcher dispatcher,
        Func<long, TQuery> toQuery,
        CancellationToken cancellationToken)
        where TQuery : class
    {
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        if (result.IsFailure)
        {
            return result.Error.ToProblem();
        }

        var query = toQuery(result.Value);
        return query switch
        {
            GetStockRequestQuery q => (await dispatcher.QueryAsync(q, cancellationToken).ConfigureAwait(false)).ToOk(),
            GetIssueQuery q => (await dispatcher.QueryAsync(q, cancellationToken).ConfigureAwait(false)).ToOk(),
            GetWasteQuery q => (await dispatcher.QueryAsync(q, cancellationToken).ConfigureAwait(false)).ToOk(),
            GetSampleQuery q => (await dispatcher.QueryAsync(q, cancellationToken).ConfigureAwait(false)).ToOk(),
            GetReturnToVendorQuery q => (await dispatcher.QueryAsync(q, cancellationToken).ConfigureAwait(false)).ToOk(),
            _ => TypedResults.Ok(new CreatedResponse(result.Value)),
        };
    }
}
