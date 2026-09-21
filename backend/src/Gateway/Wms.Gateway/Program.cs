using Serilog;
using Serilog.Formatting.Compact;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, _, configuration) => configuration
    .ReadFrom.Configuration(context.Configuration)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("service", "wms-gateway")
    .WriteTo.Console(new CompactJsonFormatter()));

builder.WebHost.UseUrls(Environment.GetEnvironmentVariable("ASPNETCORE_URLS") ?? "http://+:8080");

// Routes and clusters come from the ReverseProxy section of appsettings (CONVENTIONS.md container names).
builder.Services.AddReverseProxy().LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));
builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseSerilogRequestLogging();

// Both probes are mandatory for every host (CONVENTIONS.md; deploy/k8s/base/deployment-gateway.yaml uses
// /health/live for startup+liveness and /health/ready for readiness). The gateway is a stateless reverse
// proxy: it owns no database, cache or broker connection, so readiness carries no infrastructure checks -
// the downstream services report their own MySQL/Redis/RabbitMQ state on their /health/ready.
app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready");

// Module-to-module routes are not part of the public API (spec §4.2). Every route table entry here is a
// `/api/v1/<module>/{**catch-all}` catch-all, so `/api/v1/masterdata/internal/products` was proxied straight
// through to MasterData, which answered 200 to any authenticated user - including the three writing routes
// (ledger reversal, consumption posting, number sequence). The gateway now refuses anything carrying an
// `internal` path segment with 404: as far as the outside world is concerned these routes do not exist.
// The API hosts additionally demand a shared secret header, so a caller that bypasses the gateway is refused
// too (Wms.Common.Infrastructure.Auth.InternalApi).
app.Use(async (context, next) =>
{
    if (IsInternalPath(context.Request.Path))
    {
        context.Response.StatusCode = StatusCodes.Status404NotFound;
        context.Response.ContentType = "application/problem+json";
        await context.Response.WriteAsync(
            """{"type":"https://wms/errors/not-found","title":"NOT_FOUND","status":404,"detail":"No such route.","code":"NOT_FOUND"}""",
            context.RequestAborted);
        return;
    }

    await next(context);
});

app.MapReverseProxy();

await app.RunAsync().ConfigureAwait(false);

// Whole-segment match, so a path such as /api/v1/masterdata/products/internal-code is unaffected.
static bool IsInternalPath(PathString path)
{
    if (!path.HasValue)
    {
        return false;
    }

    foreach (var segment in path.Value!.Split('/', StringSplitOptions.RemoveEmptyEntries))
    {
        if (string.Equals(segment, "internal", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }
    }

    return false;
}
