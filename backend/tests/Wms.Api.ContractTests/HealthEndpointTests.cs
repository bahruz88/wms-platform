using System.Net;

namespace Wms.Api.ContractTests;

/// <summary>CONVENTIONS.md: <c>GET /health/live</c> must answer without any infrastructure dependency.</summary>
public sealed class HealthEndpointTests : IClassFixture<WmsApiFactory>
{
    private readonly WmsApiFactory _factory;

    public HealthEndpointTests(WmsApiFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Health_live_returns_200_with_every_module_loaded()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync(new Uri("/health/live", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("Healthy", await response.Content.ReadAsStringAsync(TestCancellation.Token));
    }

    [Fact]
    public async Task A_module_endpoint_requires_authentication()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync(new Uri("/api/v1/inventory/ping", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task An_unknown_route_returns_404()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync(new Uri("/api/v1/nope", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task The_openapi_document_is_served_in_development()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync(new Uri("/openapi/v1.json", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}

/// <summary>A per-module deployment (spec §4.1, §4.2) boots with only its own endpoints mapped.</summary>
public sealed class SingleModuleHostTests
{
    [Fact]
    public async Task An_inventory_only_host_serves_inventory_but_not_procurement()
    {
        // A split deployment reaches MasterData over HTTP, so ModuleTransport=Http is required (spec §4.2).
        await using var factory = new WmsApiFactory { Modules = "inventory", ModuleTransport = "Http" };
        using var client = factory.CreateClient();

        using var live = await client.GetAsync(new Uri("/health/live", UriKind.Relative), TestCancellation.Token);
        using var inventory = await client.GetAsync(new Uri("/api/v1/inventory/ping", UriKind.Relative), TestCancellation.Token);
        using var procurement = await client.GetAsync(new Uri("/api/v1/procurement/ping", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.OK, live.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, inventory.StatusCode); // mapped, but protected
        Assert.Equal(HttpStatusCode.NotFound, procurement.StatusCode);   // not mapped at all
    }

    [Fact]
    public async Task A_partial_deployment_with_in_process_transport_fails_fast()
    {
        // Inventory needs MasterData.Contracts; in-process that implementation simply does not exist.
        await using var factory = new WmsApiFactory { Modules = "inventory", ModuleTransport = "InProcess" };

        var exception = Assert.Throws<InvalidOperationException>(() => factory.CreateClient());

        Assert.Contains("masterdata", exception.Message, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("ModuleTransport=Http", exception.Message, StringComparison.Ordinal);
        await Task.CompletedTask;
    }

    [Fact]
    public async Task A_worker_deployment_loads_only_the_job_modules()
    {
        // The wms-worker container of CONVENTIONS.md: notification + integration, neither of which has dependencies.
        await using var factory = new WmsApiFactory { Modules = "notification,integration" };
        using var client = factory.CreateClient();

        using var live = await client.GetAsync(new Uri("/health/live", UriKind.Relative), TestCancellation.Token);
        using var notifications = await client.GetAsync(new Uri("/api/v1/notifications/ping", UriKind.Relative), TestCancellation.Token);
        using var inventory = await client.GetAsync(new Uri("/api/v1/inventory/ping", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.OK, live.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, notifications.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, inventory.StatusCode);
    }
}
