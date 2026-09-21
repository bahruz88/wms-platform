using System.Globalization;
using System.Net;
using System.Net.Http.Json;
using Wms.MasterData.Contracts;

namespace Wms.MasterData.Infrastructure.Contracts;

/// <summary>HTTP implementations used when MasterData runs in another container (<c>ModuleTransport=Http</c>).</summary>
public sealed class HttpProductCatalog(HttpClient httpClient) : IProductCatalog
{
    public async Task<ProductDto?> GetAsync(long productId, CancellationToken cancellationToken)
    {
        var url = MasterDataRoutes.InternalProduct
            .Replace("{productId}", productId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<ProductDto>(cancellationToken).ConfigureAwait(false);
    }

    public async Task<IReadOnlyList<ProductDto>> GetManyAsync(IReadOnlyCollection<uint> productIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(productIds);
        if (productIds.Count == 0)
        {
            return [];
        }

        var url = MasterDataRoutes.InternalProducts + "?ids=" + HttpRefs.Join(productIds);
        return await httpClient.GetFromJsonAsync<List<ProductDto>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false) ?? [];
    }

    public async Task<IReadOnlyList<uint>> GetIdsByCategoryAsync(IReadOnlyCollection<uint> categoryIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(categoryIds);
        if (categoryIds.Count == 0)
        {
            return [];
        }

        var url = MasterDataRoutes.InternalCategoryProducts + "?ids=" + HttpRefs.Join(categoryIds);
        return await httpClient.GetFromJsonAsync<List<uint>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false) ?? [];
    }

    public async Task<decimal?> GetUomFactorAsync(long productId, long uomId, DateOnly date, CancellationToken cancellationToken)
    {
        var url = MasterDataRoutes.InternalUomFactor
            .Replace("{productId}", productId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal)
            + $"?uomId={uomId.ToString(CultureInfo.InvariantCulture)}&date={date:yyyy-MM-dd}";
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        var payload = await response.Content.ReadFromJsonAsync<FactorResponse>(cancellationToken).ConfigureAwait(false);
        return payload?.Factor;
    }

    private sealed record FactorResponse(decimal? Factor);
}

public sealed class HttpLocationCatalog(HttpClient httpClient) : ILocationCatalog
{
    public Task<LocationDto?> GetAsync(long locationId, CancellationToken cancellationToken)
    {
        var url = MasterDataRoutes.InternalLocation
            .Replace("{locationId}", locationId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        return GetLocationAsync(url, cancellationToken);
    }

    public async Task<IReadOnlyList<LocationDto>> GetManyAsync(IReadOnlyCollection<uint> locationIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(locationIds);
        if (locationIds.Count == 0)
        {
            return [];
        }

        var url = MasterDataRoutes.InternalLocations + "?ids=" + HttpRefs.Join(locationIds);
        return await httpClient.GetFromJsonAsync<List<LocationDto>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false) ?? [];
    }

    public Task<LocationDto?> GetVirtualAsync(string locationType, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(locationType);
        var url = MasterDataRoutes.InternalVirtualLocation
            .Replace("{locationType}", Uri.EscapeDataString(locationType), StringComparison.Ordinal);
        return GetLocationAsync(url, cancellationToken);
    }

    private async Task<LocationDto?> GetLocationAsync(string url, CancellationToken cancellationToken)
    {
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<LocationDto>(cancellationToken).ConfigureAwait(false);
    }
}

public sealed class HttpSupplierCatalog(HttpClient httpClient) : ISupplierCatalog
{
    public async Task<SupplierRefDto?> GetAsync(long supplierId, CancellationToken cancellationToken)
    {
        var url = MasterDataRoutes.InternalSupplier
            .Replace("{supplierId}", supplierId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<SupplierRefDto>(cancellationToken).ConfigureAwait(false);
    }

    public async Task<IReadOnlyList<SupplierRefDto>> GetManyAsync(IReadOnlyCollection<uint> supplierIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(supplierIds);
        if (supplierIds.Count == 0)
        {
            return [];
        }

        var url = MasterDataRoutes.InternalSuppliers + "?ids=" + HttpRefs.Join(supplierIds);
        return await httpClient.GetFromJsonAsync<List<SupplierRefDto>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false) ?? [];
    }
}

public sealed class HttpUomCatalog(HttpClient httpClient) : IUomCatalog
{
    public async Task<UomRefDto?> GetAsync(long uomId, CancellationToken cancellationToken)
    {
        var uoms = await GetManyAsync([(ushort)Math.Clamp(uomId, 0, ushort.MaxValue)], cancellationToken).ConfigureAwait(false);
        return uoms.Count == 0 ? null : uoms[0];
    }

    public async Task<IReadOnlyList<UomRefDto>> GetManyAsync(IReadOnlyCollection<ushort> uomIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(uomIds);
        if (uomIds.Count == 0)
        {
            return [];
        }

        var url = MasterDataRoutes.InternalUoms + "?ids=" + HttpRefs.Join(uomIds.Select(id => (uint)id));
        return await httpClient.GetFromJsonAsync<List<UomRefDto>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false) ?? [];
    }
}

public sealed class HttpReasonCodeCatalog(HttpClient httpClient) : IReasonCodeCatalog
{
    public async Task<ReasonCodeRefDto?> GetAsync(long reasonCodeId, CancellationToken cancellationToken)
    {
        var codes = await GetManyAsync([(ushort)Math.Clamp(reasonCodeId, 0, ushort.MaxValue)], cancellationToken).ConfigureAwait(false);
        return codes.Count == 0 ? null : codes[0];
    }

    public async Task<IReadOnlyList<ReasonCodeRefDto>> GetManyAsync(IReadOnlyCollection<ushort> reasonCodeIds, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(reasonCodeIds);
        if (reasonCodeIds.Count == 0)
        {
            return [];
        }

        var url = MasterDataRoutes.InternalReasonCodes + "?ids=" + HttpRefs.Join(reasonCodeIds.Select(id => (uint)id));
        return await httpClient.GetFromJsonAsync<List<ReasonCodeRefDto>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false) ?? [];
    }
}

/// <summary>Shared helper for the bulk <c>?ids=</c> query of the internal MasterData endpoints.</summary>
internal static class HttpRefs
{
    public static string Join(IEnumerable<uint> ids) =>
        string.Join(',', ids.Distinct().Select(id => id.ToString(CultureInfo.InvariantCulture)));
}

public sealed class HttpNumberSequenceService(HttpClient httpClient) : INumberSequenceService
{
    public async Task<string> NextAsync(string docType, DateOnly docDate, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(docType);
        var url = MasterDataRoutes.InternalNextNumber
            .Replace("{docType}", Uri.EscapeDataString(docType), StringComparison.Ordinal)
            + $"?docDate={docDate:yyyy-MM-dd}";
        using var response = await httpClient.PostAsync(new Uri(url, UriKind.Relative), content: null, cancellationToken).ConfigureAwait(false);
        response.EnsureSuccessStatusCode();
        var payload = await response.Content.ReadFromJsonAsync<NumberResponse>(cancellationToken).ConfigureAwait(false);
        return payload?.DocNo ?? throw new InvalidOperationException($"Remote MasterData returned no document number for '{docType}'.");
    }

    private sealed record NumberResponse(string DocNo);
}

public sealed class HttpCurrencyRateReader(HttpClient httpClient) : ICurrencyRateReader
{
    public async Task<string> GetBaseCurrencyAsync(CancellationToken cancellationToken)
    {
        var payload = await httpClient
            .GetFromJsonAsync<CurrencyResponse>(new Uri(MasterDataRoutes.InternalBaseCurrency, UriKind.Relative), cancellationToken)
            .ConfigureAwait(false);
        return payload?.Currency ?? "AZN";
    }

    public async Task<decimal?> GetRateToBaseAsync(string currency, DateOnly date, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(currency);
        var url = MasterDataRoutes.InternalRate
            .Replace("{currency}", Uri.EscapeDataString(currency), StringComparison.Ordinal)
            + $"?date={date:yyyy-MM-dd}";
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        var payload = await response.Content.ReadFromJsonAsync<RateResponse>(cancellationToken).ConfigureAwait(false);
        return payload?.Rate;
    }

    private sealed record CurrencyResponse(string Currency);

    private sealed record RateResponse(decimal? Rate);
}
