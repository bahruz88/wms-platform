using System.Globalization;
using System.Net;
using System.Net.Http.Json;
using Wms.Procurement.Application.Abstractions;
using Wms.Procurement.Contracts;

namespace Wms.Procurement.Infrastructure.Contracts;

/// <summary>In-process <see cref="IPurchaseOrderReader"/> so Inventory can pre-fill a goods receipt from a PO (spec §12.8).</summary>
public sealed class PurchaseOrderReader(IProcurementQueries queries) : IPurchaseOrderReader
{
    public Task<PurchaseOrderDto?> GetAsync(long purchaseOrderId, CancellationToken cancellationToken) =>
        queries.GetPurchaseOrderAsync(purchaseOrderId, cancellationToken);
}

/// <summary>HTTP implementation used when Procurement runs in another container (<c>ModuleTransport=Http</c>).</summary>
public sealed class HttpPurchaseOrderReader(HttpClient httpClient) : IPurchaseOrderReader
{
    public async Task<PurchaseOrderDto?> GetAsync(long purchaseOrderId, CancellationToken cancellationToken)
    {
        var url = ProcurementRoutes.InternalPurchaseOrder
            .Replace("{purchaseOrderId}", purchaseOrderId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<PurchaseOrderDto>(cancellationToken).ConfigureAwait(false);
    }
}
