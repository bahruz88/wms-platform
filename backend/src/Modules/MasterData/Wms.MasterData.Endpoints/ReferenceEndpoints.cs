using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.MasterData.Application;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Commands;
using Wms.MasterData.Application.Queries;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Endpoints;

/// <summary>
/// Currency rates, reason codes and number sequences (masterdata.v1.yaml, tags <c>CurrencyRates</c>,
/// <c>ReasonCodes</c>, <c>NumberSequences</c>). <c>GET /reason-codes</c> feeds every cancel, waste and
/// adjustment form — a reason code is mandatory on all of them (spec §12.6).
/// </summary>
public static class ReferenceEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        MapCurrencyRates(group);
        MapReasonCodes(group);
        MapNumberSequences(group);
    }

    private static void MapCurrencyRates(RouteGroupBuilder group)
    {
        group.MapGet("/currency-rates", async ([AsParameters] CurrencyRatesRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var filter = new CurrencyRateFilter(request.Currency, request.Date, request.DateFrom, request.DateTo);
                var query = new GetCurrencyRatesQuery(filter, new PagingRequest(request.Page, request.Size).ToPageRequest());
                return (await dispatcher.QueryAsync(query, ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.CurrencyView)
            .WithName("listCurrencyRates");

        // The contract answers 200 for both the insert and the update case.
        group.MapPost("/currency-rates", async (CurrencyRateUpsertRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new UpsertCurrencyRateCommand(request.Currency ?? string.Empty, request.RateDate, request.RateToBase);
                return (await dispatcher.SendAsync(command, ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.CurrencyManage)
            .RequireIdempotencyKey()
            .WithName("upsertCurrencyRate");
    }

    private static void MapReasonCodes(RouteGroupBuilder group)
    {
        group.MapGet("/reason-codes", async (string? reasonGroup, bool? isActive, IDispatcher dispatcher, CancellationToken ct) =>
            {
                if (!EnumQuery.TryParse<ReasonGroup>(reasonGroup, out var parsed))
                {
                    return new Error("BAD_REQUEST", EnumQuery.Invalid<ReasonGroup>("reasonGroup", reasonGroup), 400).ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetReasonCodesQuery(parsed, isActive), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.ReasonView)
            .WithName("listReasonCodes");

        group.MapPost("/reason-codes", async (ReasonCodeCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateReasonCodeCommand(
                    request.Code ?? string.Empty,
                    request.Name ?? string.Empty,
                    request.ReasonGroup,
                    request.RequiresApproval ?? true,
                    request.RequiresPhoto ?? false);

                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                return result.ToHttpResult(r => TypedResults.Created((string?)null, r));
            })
            .RequirePermission(MasterDataPermissions.ReasonManage)
            .RequireIdempotencyKey()
            .WithName("createReasonCode");

        group.MapPut("/reason-codes/{id}", async (ushort id, ReasonCodeUpdateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new UpdateReasonCodeCommand(
                    id,
                    request.RowVersion,
                    request.Name ?? string.Empty,
                    request.RequiresApproval,
                    request.RequiresPhoto,
                    request.IsActive,
                    request.ReasonGroup);

                return (await dispatcher.SendAsync(command, ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.ReasonManage)
            .WithName("updateReasonCode");
    }

    private static void MapNumberSequences(RouteGroupBuilder group) =>
        group.MapGet("/number-sequences", async (string? docType, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetNumberSequencesQuery(docType), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.SequenceView)
            .WithName("listNumberSequences");
}
