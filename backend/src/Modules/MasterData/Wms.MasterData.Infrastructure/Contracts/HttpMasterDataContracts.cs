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
