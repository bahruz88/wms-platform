using System.Net.Http.Json;
using Wms.Inventory.Contracts;

namespace Wms.Inventory.Infrastructure.Contracts;

/// <summary>
/// HTTP implementation of <see cref="IInventoryReportingSource"/> used by the <c>wms-reporting</c> container,
/// where Inventory is not loaded (<c>ModuleTransport=Http</c>, spec §4.2). Every call POSTs its filter as a
/// body: report filters carry a dozen values and query-string identifiers already overflow at scale
/// (ROADMAP §4).
/// </summary>
public sealed class HttpInventoryReportingSource(HttpClient httpClient) : IInventoryReportingSource
{
    public Task<InventoryDashboardDto> GetDashboardAsync(InventoryDashboardRequest request, CancellationToken cancellationToken) =>
        PostAsync<InventoryDashboardRequest, InventoryDashboardDto>(InventoryRoutes.InternalReportDashboard, request, cancellationToken);

    public Task<ReportRowSet<StockBalanceReportRow>> GetStockBalancesAsync(StockBalanceReportRequest request, CancellationToken cancellationToken) =>
        PostSetAsync<StockBalanceReportRequest, StockBalanceReportRow>(InventoryRoutes.InternalReportStockBalances, request, cancellationToken);

    public Task<ReportRowSet<BatchStockReportRow>> GetBatchStockAsync(BatchStockReportRequest request, CancellationToken cancellationToken) =>
        PostSetAsync<BatchStockReportRequest, BatchStockReportRow>(InventoryRoutes.InternalReportBatchStock, request, cancellationToken);

    public Task<ReportRowSet<MovementLedgerReportRow>> GetMovementsAsync(MovementReportRequest request, CancellationToken cancellationToken) =>
        PostSetAsync<MovementReportRequest, MovementLedgerReportRow>(InventoryRoutes.InternalReportMovements, request, cancellationToken);

    public Task<ReportRowSet<MovementAggregateReportRow>> GetMovementAggregateAsync(MovementAggregateReportRequest request, CancellationToken cancellationToken) =>
        PostSetAsync<MovementAggregateReportRequest, MovementAggregateReportRow>(InventoryRoutes.InternalReportMovementAggregate, request, cancellationToken);

    public Task<ReportRowSet<CountVarianceReportRow>> GetCountVariancesAsync(CountVarianceReportRequest request, CancellationToken cancellationToken) =>
        PostSetAsync<CountVarianceReportRequest, CountVarianceReportRow>(InventoryRoutes.InternalReportCountVariances, request, cancellationToken);

    public Task<ReportRowSet<ReceiptVarianceReportRow>> GetReceiptVariancesAsync(ReceiptVarianceReportRequest request, CancellationToken cancellationToken) =>
        PostSetAsync<ReceiptVarianceReportRequest, ReceiptVarianceReportRow>(InventoryRoutes.InternalReportReceiptVariances, request, cancellationToken);

    public Task<ReportRowSet<StockCoverageReportRow>> GetStockCoverageAsync(StockCoverageReportRequest request, CancellationToken cancellationToken) =>
        PostSetAsync<StockCoverageReportRequest, StockCoverageReportRow>(InventoryRoutes.InternalReportStockCoverage, request, cancellationToken);

    private async Task<TResponse> PostAsync<TRequest, TResponse>(string url, TRequest request, CancellationToken cancellationToken)
        where TResponse : class
    {
        using var response = await httpClient
            .PostAsJsonAsync(new Uri(url, UriKind.Relative), request, cancellationToken)
            .ConfigureAwait(false);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<TResponse>(cancellationToken).ConfigureAwait(false)
            ?? throw new HttpRequestException($"Remote Inventory returned an empty body for {url}.");
    }

    private async Task<ReportRowSet<TRow>> PostSetAsync<TRequest, TRow>(string url, TRequest request, CancellationToken cancellationToken)
    {
        using var response = await httpClient
            .PostAsJsonAsync(new Uri(url, UriKind.Relative), request, cancellationToken)
            .ConfigureAwait(false);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<ReportRowSet<TRow>>(cancellationToken).ConfigureAwait(false)
            ?? ReportRowSet<TRow>.Empty;
    }
}
