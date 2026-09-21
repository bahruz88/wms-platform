using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace Wms.Api.ContractTests;

/// <summary>
/// Boots the real host in memory. No infrastructure is contacted: <c>/health/live</c> has no dependencies and
/// DbContext registration is lazy, so MySQL, Redis and RabbitMQ are never opened by these tests.
/// </summary>
public sealed class WmsApiFactory : WebApplicationFactory<Program>
{
    /// <summary>Value of the <c>Modules</c> key; <c>*</c> loads every module (spec §4.1).</summary>
    public string Modules { get; init; } = "*";

    /// <summary><c>InProcess</c> or <c>Http</c> (spec §4.2).</summary>
    public string ModuleTransport { get; init; } = "InProcess";

    /// <summary>Shared secret of the <c>/internal/*</c> routes; empty to prove the host fails closed without it.</summary>
    public string InternalApiKey { get; init; } = "contract-test-internal-key";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.UseEnvironment(Environments.Development);
        builder.UseSetting("Modules", Modules);
        builder.UseSetting("ModuleTransport", ModuleTransport);
        builder.UseSetting("Jobs:Enabled", "false");
        builder.UseSetting("Seq:Url", string.Empty);
        builder.UseSetting("Otel:Endpoint", string.Empty);
        builder.UseSetting("Redis:ConnectionString", string.Empty);
        builder.UseSetting("Keycloak:Authority", "http://localhost:8080/realms/wms");
        builder.UseSetting("Keycloak:Audience", "wms-api");
        builder.UseSetting("Keycloak:RequireHttpsMetadata", "false");
        builder.UseSetting("InternalApi:Key", InternalApiKey);
        builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["ConnectionStrings:Wms"] = "Server=localhost;Port=3306;Database=wms_contract_tests;User=wms_app;Password=wms_app;",
            ["ConnectionStrings:WmsMigrator"] = "Server=localhost;Port=3306;Database=wms_contract_tests;User=wms_migrator;Password=wms_migrator;",
            // Used only when ModuleTransport=Http; nothing is called during these tests.
            ["ModuleEndpoints:Identity"] = "http://wms-identity:8080",
            ["ModuleEndpoints:MasterData"] = "http://wms-masterdata:8080",
            ["ModuleEndpoints:Inventory"] = "http://wms-inventory:8080",
            ["ModuleEndpoints:Procurement"] = "http://wms-procurement:8080",
            ["ModuleEndpoints:Documents"] = "http://wms-masterdata:8080",
            ["ModuleEndpoints:Notification"] = "http://wms-worker:8080",
            ["ModuleEndpoints:Reporting"] = "http://wms-reporting:8080",
            ["ModuleEndpoints:Integration"] = "http://wms-worker:8080",
        }));
    }
}
