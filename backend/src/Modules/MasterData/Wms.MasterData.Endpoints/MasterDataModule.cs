using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.MasterData.Application;
using Wms.MasterData.Application.Queries;
using Wms.MasterData.Contracts;
using Wms.MasterData.Infrastructure;

namespace Wms.MasterData.Endpoints;

/// <summary><c>--Modules=masterdata</c>. Route prefix <c>/api/v1/masterdata</c>, table prefix <c>master_</c>.</summary>
public sealed class MasterDataModule : IModule
{
    public const string ModuleName = "masterdata";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddMasterDataApplication();
        services.AddMasterDataInfrastructure(configuration);
    }

    public void RegisterRemoteContracts(IServiceCollection services, IConfiguration configuration) =>
        services.AddMasterDataRemoteContracts(configuration);

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(MasterDataRoutes.Prefix).WithTags("MasterData").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("MasterDataPing");

        group.MapGet("/products", async ([AsParameters] ProductsRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var query = new GetProductsQuery(request.Search, request.CategoryId, request.IsActive, new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(MasterDataPermissions.ProductView)
            .WithName("GetProducts");

        group.MapGet("/locations", async ([AsParameters] PagingRequest paging, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetLocationsQuery(paging.ToPageRequest()), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(MasterDataPermissions.LocationView)
            .WithName("GetLocations");

        MapInternalEndpoints(group);
    }

    /// <summary>Endpoints backing the MasterData contracts over HTTP (spec §4.2).</summary>
    private static void MapInternalEndpoints(RouteGroupBuilder group)
    {
        group.MapGet("/internal/products/{productId:long}", async (long productId, IProductCatalog catalog, CancellationToken cancellationToken) =>
            {
                var product = await catalog.GetAsync(productId, cancellationToken).ConfigureAwait(false);
                return product is null ? Results.NotFound() : Results.Ok(product);
            })
            .WithName("InternalProduct")
            .ExcludeFromDescription();

        group.MapGet("/internal/products/{productId:long}/uom-factor",
                async (long productId, long uomId, DateOnly date, IProductCatalog catalog, CancellationToken cancellationToken) =>
                {
                    var factor = await catalog.GetUomFactorAsync(productId, uomId, date, cancellationToken).ConfigureAwait(false);
                    return factor is null ? Results.NotFound() : Results.Ok(new { factor });
                })
            .WithName("InternalUomFactor")
            .ExcludeFromDescription();

        group.MapGet("/internal/products", async (string? ids, IProductCatalog catalog, CancellationToken cancellationToken) =>
                Results.Ok(await catalog.GetManyAsync(IdList.Parse(ids), cancellationToken).ConfigureAwait(false)))
            .WithName("InternalProducts")
            .ExcludeFromDescription();

        group.MapGet("/internal/locations", async (string? ids, ILocationCatalog catalog, CancellationToken cancellationToken) =>
                Results.Ok(await catalog.GetManyAsync(IdList.Parse(ids), cancellationToken).ConfigureAwait(false)))
            .WithName("InternalLocations")
            .ExcludeFromDescription();

        group.MapGet("/internal/reason-codes", async (string? ids, IReasonCodeCatalog catalog, CancellationToken cancellationToken) =>
                Results.Ok(await catalog.GetManyAsync(IdList.Parse(ids).Select(id => (ushort)id).ToArray(), cancellationToken).ConfigureAwait(false)))
            .WithName("InternalReasonCodes")
            .ExcludeFromDescription();

        group.MapGet("/internal/categories/products", async (string? ids, IProductCatalog catalog, CancellationToken cancellationToken) =>
                Results.Ok(await catalog.GetIdsByCategoryAsync(IdList.Parse(ids), cancellationToken).ConfigureAwait(false)))
            .WithName("InternalCategoryProducts")
            .ExcludeFromDescription();

        group.MapGet("/internal/uoms", async (string? ids, IUomCatalog catalog, CancellationToken cancellationToken) =>
                Results.Ok(await catalog.GetManyAsync(IdList.Parse(ids).Select(id => (ushort)id).ToArray(), cancellationToken).ConfigureAwait(false)))
            .WithName("InternalUoms")
            .ExcludeFromDescription();

        group.MapGet("/internal/suppliers", async (string? ids, ISupplierCatalog catalog, CancellationToken cancellationToken) =>
                Results.Ok(await catalog.GetManyAsync(IdList.Parse(ids), cancellationToken).ConfigureAwait(false)))
            .WithName("InternalSuppliers")
            .ExcludeFromDescription();

        group.MapGet("/internal/suppliers/{supplierId:long}", async (long supplierId, ISupplierCatalog catalog, CancellationToken cancellationToken) =>
            {
                var supplier = await catalog.GetAsync(supplierId, cancellationToken).ConfigureAwait(false);
                return supplier is null ? Results.NotFound() : Results.Ok(supplier);
            })
            .WithName("InternalSupplier")
            .ExcludeFromDescription();

        group.MapGet("/internal/locations/{locationId:long}", async (long locationId, ILocationCatalog catalog, CancellationToken cancellationToken) =>
            {
                var location = await catalog.GetAsync(locationId, cancellationToken).ConfigureAwait(false);
                return location is null ? Results.NotFound() : Results.Ok(location);
            })
            .WithName("InternalLocation")
            .ExcludeFromDescription();

        group.MapGet("/internal/locations/virtual/{locationType}", async (string locationType, ILocationCatalog catalog, CancellationToken cancellationToken) =>
            {
                var location = await catalog.GetVirtualAsync(locationType, cancellationToken).ConfigureAwait(false);
                return location is null ? Results.NotFound() : Results.Ok(location);
            })
            .WithName("InternalVirtualLocation")
            .ExcludeFromDescription();

        group.MapPost("/internal/number-sequences/{docType}/next",
                async (string docType, DateOnly docDate, INumberSequenceService sequences, CancellationToken cancellationToken) =>
                    Results.Ok(new { docNo = await sequences.NextAsync(docType, docDate, cancellationToken).ConfigureAwait(false) }))
            .WithName("InternalNextNumber")
            .ExcludeFromDescription();

        group.MapGet("/internal/currency/base", async (ICurrencyRateReader rates, CancellationToken cancellationToken) =>
                Results.Ok(new { currency = await rates.GetBaseCurrencyAsync(cancellationToken).ConfigureAwait(false) }))
            .WithName("InternalBaseCurrency")
            .ExcludeFromDescription();

        group.MapGet("/internal/currency/{currency}/rate", async (string currency, DateOnly date, ICurrencyRateReader rates, CancellationToken cancellationToken) =>
            {
                var rate = await rates.GetRateToBaseAsync(currency, date, cancellationToken).ConfigureAwait(false);
                return rate is null ? Results.NotFound() : Results.Ok(new { rate });
            })
            .WithName("InternalCurrencyRate")
            .ExcludeFromDescription();
    }
}

/// <summary>Parses the <c>?ids=1,2,3</c> query of the internal bulk endpoints.</summary>
internal static class IdList
{
    public static IReadOnlyCollection<uint> Parse(string? ids)
    {
        if (string.IsNullOrWhiteSpace(ids))
        {
            return [];
        }

        var parsed = new HashSet<uint>();
        foreach (var part in ids.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            if (uint.TryParse(part, System.Globalization.NumberStyles.None, System.Globalization.CultureInfo.InvariantCulture, out var id))
            {
                parsed.Add(id);
            }
        }

        return parsed;
    }
}

/// <summary>Query string of <c>GET /api/v1/masterdata/products</c>.</summary>
public sealed record ProductsRequest(string? Search, uint? CategoryId, bool? IsActive, int? Page, int? Size);
