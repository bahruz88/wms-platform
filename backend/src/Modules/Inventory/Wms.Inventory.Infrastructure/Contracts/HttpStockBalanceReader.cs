using System.Globalization;
using System.Net;
using System.Net.Http.Json;
using Wms.Inventory.Contracts;

namespace Wms.Inventory.Infrastructure.Contracts;

/// <summary>HTTP implementation used by other containers when Inventory is deployed separately (<c>ModuleTransport=Http</c>).</summary>
public sealed class HttpStockBalanceReader(HttpClient httpClient) : IStockBalanceReader
{
    public async Task<StockLevelDto?> GetAsync(long productId, long locationId, CancellationToken cancellationToken)
    {
        var url = InventoryRoutes.InternalStockLevel
            .Replace("{productId}", productId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal)
            .Replace("{locationId}", locationId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);

        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<StockLevelDto>(cancellationToken).ConfigureAwait(false);
    }

    public async Task<IReadOnlyList<StockLevelDto>> GetByProductAsync(long productId, CancellationToken cancellationToken)
    {
        var url = InventoryRoutes.InternalStockLevelsByProduct
            .Replace("{productId}", productId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        var rows = await httpClient.GetFromJsonAsync<List<StockLevelDto>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        return rows ?? [];
    }
}

/// <summary>HTTP implementation of the write side, used when Consumption and Inventory are in different containers.</summary>
public sealed class HttpStockPostingService(HttpClient httpClient) : IStockPostingService
{
    public async Task<StockPostingOutcome> PostConsumptionAsync(ConsumptionPostingRequest request, CancellationToken cancellationToken)
    {
        using var response = await httpClient
            .PostAsJsonAsync(new Uri(InventoryRoutes.InternalConsumptionPosting, UriKind.Relative), request, cancellationToken)
            .ConfigureAwait(false);
        var outcome = await response.Content.ReadFromJsonAsync<StockPostingOutcome>(cancellationToken).ConfigureAwait(false);
        return outcome ?? StockPostingOutcome.Failure("POSTING_UNAVAILABLE", "Remote Inventory returned an empty posting outcome.", 502);
    }

    public async Task<StockReversalOutcome> ReverseAsync(StockReversalRequest request, CancellationToken cancellationToken)
    {
        using var response = await httpClient
            .PostAsJsonAsync(new Uri(InventoryRoutes.InternalReversal, UriKind.Relative), request, cancellationToken)
            .ConfigureAwait(false);
        var outcome = await response.Content.ReadFromJsonAsync<StockReversalOutcome>(cancellationToken).ConfigureAwait(false);
        return outcome ?? StockReversalOutcome.Failure("POSTING_UNAVAILABLE", "Remote Inventory returned an empty reversal outcome.", 502);
    }

    public async Task<bool> IsLocationFrozenAsync(uint locationId, CancellationToken cancellationToken)
    {
        var url = InventoryRoutes.InternalLocationFrozen
            .Replace("{locationId}", locationId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        var payload = await httpClient.GetFromJsonAsync<FrozenResponse>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        return payload?.Frozen ?? false;
    }

    private sealed record FrozenResponse(bool Frozen);
}

/// <summary>HTTP implementation of <see cref="IStockMovementReader"/> for the variance report.</summary>
public sealed class HttpStockMovementReader(HttpClient httpClient) : IStockMovementReader
{
    public async Task<IReadOnlyList<StockPeriodFlowDto>> GetPeriodFlowsAsync(
        uint? locationId,
        uint? productId,
        DateOnly periodFrom,
        DateOnly periodTo,
        CancellationToken cancellationToken)
    {
        var url = InventoryRoutes.InternalPeriodFlows
            + $"?periodFrom={periodFrom:yyyy-MM-dd}&periodTo={periodTo:yyyy-MM-dd}"
            + (locationId is { } l ? $"&locationId={l.ToString(CultureInfo.InvariantCulture)}" : string.Empty)
            + (productId is { } p ? $"&productId={p.ToString(CultureInfo.InvariantCulture)}" : string.Empty);

        var rows = await httpClient
            .GetFromJsonAsync<List<StockPeriodFlowDto>>(new Uri(url, UriKind.Relative), cancellationToken)
            .ConfigureAwait(false);
        return rows ?? [];
    }
}
