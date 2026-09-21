using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.MasterData.Application;
using Wms.MasterData.Application.Commands;
using Wms.MasterData.Application.Queries;
using Wms.MasterData.Contracts;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Endpoints;

/// <summary>Product categories and units of measure (masterdata.v1.yaml, tags <c>Categories</c> and <c>Uoms</c>).</summary>
public static class CatalogEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        MapCategories(group);
        MapUoms(group);
    }

    private static void MapCategories(RouteGroupBuilder group)
    {
        group.MapGet("/categories", async (string? productType, IDispatcher dispatcher, CancellationToken ct) =>
            {
                if (!EnumQuery.TryParse<ProductType>(productType, out var parsed))
                {
                    return new Error("BAD_REQUEST", EnumQuery.Invalid<ProductType>("productType", productType), 400).ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetCategoriesQuery(parsed), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("listCategories");

        group.MapPost("/categories", async (CategoryCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateCategoryCommand(
                    request.ParentId,
                    request.Code ?? string.Empty,
                    request.Name ?? string.Empty,
                    request.ProductType,
                    request.DefaultIssueStrategy);

                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                return result.ToCreated(c => $"{MasterDataRoutes.Prefix}/categories/{c.Id}");
            })
            .RequirePermission(MasterDataPermissions.CategoryManage)
            .RequireIdempotencyKey()
            .WithName("createCategory");

        group.MapGet("/categories/{id}", async (uint id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetCategoryQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("getCategory");

        group.MapPut("/categories/{id}", async (uint id, CategoryUpdateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new UpdateCategoryCommand(
                    id,
                    request.RowVersion,
                    request.ParentId,
                    request.Name ?? string.Empty,
                    request.DefaultIssueStrategy,
                    request.IsActive,
                    request.ProductType);

                return (await dispatcher.SendAsync(command, ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.CategoryManage)
            .WithName("updateCategory");
    }

    private static void MapUoms(RouteGroupBuilder group)
    {
        group.MapGet("/uoms", async (string? uomClass, IDispatcher dispatcher, CancellationToken ct) =>
            {
                if (!EnumQuery.TryParse<UomClass>(uomClass, out var parsed))
                {
                    return new Error("BAD_REQUEST", EnumQuery.Invalid<UomClass>("uomClass", uomClass), 400).ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetUomsQuery(parsed), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("listUoms");

        group.MapPost("/uoms", async (UomCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateUomCommand(request.Code ?? string.Empty, request.Name ?? string.Empty, request.UomClass, request.Decimals);
                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                return result.ToCreated(u => $"{MasterDataRoutes.Prefix}/uoms/{u.Id}");
            })
            .RequirePermission(MasterDataPermissions.UomManage)
            .RequireIdempotencyKey()
            .WithName("createUom");

        group.MapGet("/uoms/{id}", async (ushort id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetUomQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("getUom");
    }
}
