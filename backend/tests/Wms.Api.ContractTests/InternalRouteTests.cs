using System.Net;
using System.Net.Http.Headers;
using Wms.Common.Infrastructure.Auth;

namespace Wms.Api.ContractTests;

/// <summary>
/// The module-to-module routes of spec §4.2 must not be usable by a client.
/// </summary>
/// <remarks>
/// All 24 <c>/api/v1/&lt;module&gt;/internal/*</c> routes were reachable through the gateway with nothing but
/// an ordinary user token — the YARP route table is a per-module catch-all, and the endpoints carried no
/// permission filter at all. Three of them write (ledger reversal, consumption posting, number sequence).
/// The gateway now refuses the <c>internal</c> path segment outright; these tests cover the second layer,
/// the API host itself, which is what protects a module container reached directly.
/// </remarks>
public sealed class InternalRouteTests : IClassFixture<WmsApiFactory>
{
    private static readonly string[] InternalRoutes =
    [
        "/api/v1/masterdata/internal/products?ids=1",
        "/api/v1/masterdata/internal/locations?ids=1",
        "/api/v1/masterdata/internal/suppliers?ids=1",
        "/api/v1/masterdata/internal/currency/base",
        "/api/v1/inventory/internal/stock-levels/1",
        "/api/v1/inventory/internal/period-flows",
        "/api/v1/identity/internal/tenants/1",
        "/api/v1/identity/internal/users/1/permissions",
        "/api/v1/documents/internal/attachments/1",
        "/api/v1/procurement/internal/purchase-orders/1",
    ];

    private readonly WmsApiFactory _factory;

    public InternalRouteTests(WmsApiFactory factory)
    {
        _factory = factory;
    }

    public static TheoryData<string> Routes()
    {
        var data = new TheoryData<string>();
        foreach (var route in InternalRoutes)
        {
            data.Add(route);
        }

        return data;
    }

    [Theory]
    [MemberData(nameof(Routes))]
    public async Task An_internal_route_is_refused_without_the_shared_secret(string route)
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync(new Uri(route, UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync(TestCancellation.Token);
        Assert.Contains("INTERNAL_ROUTE_FORBIDDEN", body, StringComparison.Ordinal);
    }

    [Fact]
    public async Task A_bearer_token_alone_does_not_open_an_internal_route()
    {
        // The refusal happens before authentication, so holding a valid user token changes nothing.
        using var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "any.jwt.value");

        using var response = await client.GetAsync(
            new Uri("/api/v1/masterdata/internal/products?ids=1", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task A_wrong_secret_is_refused()
    {
        using var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Add(InternalApi.HeaderName, "not-the-key");

        using var response = await client.GetAsync(
            new Uri("/api/v1/masterdata/internal/products?ids=1", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task The_shared_secret_gets_the_call_past_the_guard()
    {
        // With the secret the guard steps aside and the ordinary pipeline takes over; the route then answers
        // 401 because this request carries no bearer token. What matters is that it is no longer 403 from
        // the guard, i.e. module-to-module traffic still works.
        using var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Add(InternalApi.HeaderName, "contract-test-internal-key");

        using var response = await client.GetAsync(
            new Uri("/api/v1/masterdata/internal/products?ids=1", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task A_public_route_whose_path_merely_contains_internal_is_untouched()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync(
            new Uri("/api/v1/masterdata/products?search=internal", UriKind.Relative), TestCancellation.Token);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task A_host_configured_for_http_transport_without_the_secret_fails_fast()
    {
        // A deployment error must surface at startup, not as a 403 on the first inter-module call.
        await using var factory = new WmsApiFactory { Modules = "inventory", ModuleTransport = "Http", InternalApiKey = string.Empty };

        var exception = Assert.Throws<InvalidOperationException>(() => factory.CreateClient());

        Assert.Contains("InternalApi:Key", exception.Message, StringComparison.Ordinal);
        await Task.CompletedTask;
    }
}
