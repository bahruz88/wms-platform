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

/// <summary>Products and their versioned unit-of-measure rows (masterdata.v1.yaml, tag <c>Products</c>).</summary>
public static class ProductEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/products", async ([AsParameters] ProductsRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                if (!EnumQuery.TryParse<ProductType>(request.ProductType, out var productType))
                {
                    return new Error("BAD_REQUEST", EnumQuery.Invalid<ProductType>("productType", request.ProductType), 400).ToProblem();
                }

                var filter = new ProductFilter(
                    request.Q, request.CategoryId, productType, request.SupplierId, request.Barcode, request.IsActive, request.Sort);
                var query = new GetProductsQuery(filter, new PagingRequest(request.Page, request.Size).ToPageRequest());
                return (await dispatcher.QueryAsync(query, ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("listProducts");

        group.MapPost("/products", async (ProductCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new CreateProductCommand(
                    request.Sku ?? string.Empty,
                    request.Name ?? string.Empty,
                    request.Barcode,
                    request.CategoryId,
                    request.Brand,
                    request.BaseUomId,
                    request.DefaultSupplierId,
                    request.MinStock,
                    request.MaxStock,
                    request.ReorderPoint,
                    request.VatRate,
                    request.RequiresBatch ?? false,
                    request.RequiresExpiry ?? false,
                    request.IssueStrategy,
                    request.ShelfLifeDays,
                    (request.AdditionalUoms ?? []).ConvertAll(u => u.ToInput()));

                var created = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (created.IsFailure)
                {
                    return created.Error.ToProblem();
                }

                var dto = await dispatcher.QueryAsync(new GetProductQuery(created.Value), ct).ConfigureAwait(false);
                return dto.ToHttpResult(p => TypedResults.Created($"{MasterDataRoutes.Prefix}/products/{p.Id}", p));
            })
            .RequirePermission(MasterDataPermissions.ProductManage)
            .RequireIdempotencyKey()
            .WithName("createProduct");

        group.MapGet("/products/{id}", async (uint id, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetProductQuery(id), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("getProduct");

        group.MapPut("/products/{id}", async (uint id, ProductUpdateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new UpdateProductCommand(
                    id,
                    request.RowVersion,
                    request.Name ?? string.Empty,
                    request.Barcode,
                    request.CategoryId,
                    request.Brand,
                    request.DefaultSupplierId,
                    request.MinStock,
                    request.MaxStock,
                    request.ReorderPoint,
                    request.VatRate,
                    request.RequiresBatch,
                    request.RequiresExpiry,
                    request.IssueStrategy,
                    request.ShelfLifeDays,
                    request.ImageAttachmentId,
                    request.IsActive,
                    request.Sku,
                    request.BaseUomId);

                var updated = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                if (updated.IsFailure)
                {
                    return updated.Error.ToProblem();
                }

                return (await dispatcher.QueryAsync(new GetProductQuery(updated.Value), ct).ConfigureAwait(false)).ToOk();
            })
            .RequirePermission(MasterDataPermissions.ProductManage)
            .WithName("updateProduct");

        group.MapGet("/products/{id}/uoms", async (uint id, DateOnly? asOf, IDispatcher dispatcher, CancellationToken ct) =>
                (await dispatcher.QueryAsync(new GetProductUomsQuery(id, asOf), ct).ConfigureAwait(false)).ToOk())
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("listProductUoms");

        group.MapPost("/products/{id}/uoms", async (uint id, ProductUomCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = new AddProductUomCommand(
                    id,
                    request.UomId,
                    request.FactorToBase,
                    request.IsPurchaseDefault ?? false,
                    request.IsIssueDefault ?? false,
                    request.ValidFrom);

                var result = await dispatcher.SendAsync(command, ct).ConfigureAwait(false);
                return result.ToHttpResult(uom => TypedResults.Created($"{MasterDataRoutes.Prefix}/products/{id}/uoms", uom));
            })
            .RequirePermission(MasterDataPermissions.ProductManage)
            .RequireIdempotencyKey()
            .WithName("addProductUom");
    }
}
