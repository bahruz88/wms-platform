using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.MasterData.Application;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Commands;
using Wms.MasterData.Application.Queries;
using Wms.MasterData.Contracts;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Endpoints;

/// <summary>Suppliers with their certificates, and locations (masterdata.v1.yaml, tags <c>Suppliers</c>, <c>Locations</c>).</summary>
public static class PartnerEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        MapSuppliers(group);
        MapLocations(group);
    }

    private static void MapSuppliers(RouteGroupBuilder group)
    {
        group.MapGet("/suppliers", async ([AsParameters] SuppliersRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var filter = new SupplierFilter(request.Q, request.ApprovedFoodOnly, request.IsActive, request.Sort);
                var query = new GetSuppliersQuery(filter, new PagingRequest(request.Page, request.Size).ToPageRequest());
                return (await dispatcher.QueryAsync(query, ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.SupplierView)
            .WithName("listSuppliers");

        group.MapPost("/suppliers", async (SupplierCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var created = await dispatcher
                    .SendAsync(new CreateSupplierCommand(request.Code ?? string.Empty, request.ToProfile()), ct)
                    .ConfigureAwait(false);
                if (created.IsFailure)
                {
                    return created.Error.ToProblem();
                }

                var dto = await dispatcher.QueryAsync(new GetSupplierQuery(created.Value), ct).ConfigureAwait(false);
                return dto.ToHttpResult(s => TypedResults.Created($"{MasterDataRoutes.Prefix}/suppliers/{s.Id}", s));
            })
            .RequirePermission(MasterDataPermissions.SupplierManage)
            .RequireIdempotencyKey()
            .WithName("createSupplier");

        group.MapGet("/suppliers/{id}", async (uint id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetSupplierQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.SupplierView)
            .WithName("getSupplier");

        group.MapPut("/suppliers/{id}", async (uint id, SupplierUpdateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new UpdateSupplierCommand(id, request.RowVersion, request.Code ?? string.Empty, request.ToProfile(), request.IsActive);
                var updated = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (updated.IsFailure)
                {
                    return updated.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetSupplierQuery(updated.Value), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.SupplierManage)
            .WithName("updateSupplier");

        group.MapGet("/suppliers/{id}/certificates", async (uint id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetSupplierCertificatesQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.SupplierView)
            .WithName("listSupplierCertificates");

        group.MapPost("/suppliers/{id}/certificates", async (uint id, SupplierCertificateCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new AddSupplierCertificateCommand(
                    id, request.CertType ?? string.Empty, request.CertNumber, request.IssuedDate, request.ExpiryDate, request.AttachmentId);
                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                return result.ToHttpResult(c => TypedResults.Created($"{MasterDataRoutes.Prefix}/suppliers/{id}/certificates", c));
            })
            .RequirePermission(MasterDataPermissions.SupplierManage)
            .RequireIdempotencyKey()
            .WithName("addSupplierCertificate");
    }

    private static void MapLocations(RouteGroupBuilder group)
    {
        group.MapGet("/locations", async ([AsParameters] LocationsRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                if (!EnumQuery.TryParse<LocationType>(request.LocationType, out var locationType))
                {
                    return new Error("BAD_REQUEST", EnumQuery.Invalid<LocationType>("locationType", request.LocationType), 400).ToProblem();
                }

                var filter = new LocationFilter(locationType, request.ParentId, request.IncludeVirtual ?? false, request.IsActive);
                return (await dispatcher.QueryAsync(new GetLocationsQuery(filter), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.LocationView)
            .WithName("listLocations");

        group.MapPost("/locations", async (LocationCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateLocationCommand(
                    request.ParentId,
                    request.Code ?? string.Empty,
                    request.Name ?? string.Empty,
                    request.LocationType,
                    request.AllowsFood ?? true,
                    request.AllowsNonFood ?? true);

                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                return result.ToCreated(l => $"{MasterDataRoutes.Prefix}/locations/{l.Id}");
            })
            .RequirePermission(MasterDataPermissions.LocationManage)
            .RequireIdempotencyKey()
            .WithName("createLocation");

        group.MapGet("/locations/{id}", async (uint id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetLocationQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.LocationView)
            .WithName("getLocation");

        group.MapPut("/locations/{id}", async (uint id, LocationUpdateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new UpdateLocationCommand(
                    id,
                    request.RowVersion,
                    request.ParentId,
                    request.Name ?? string.Empty,
                    request.AllowsFood,
                    request.AllowsNonFood,
                    request.IsActive,
                    request.LocationType);

                return (await dispatcher.SendAsync(command, ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.LocationManage)
            .WithName("updateLocation");
    }
}
