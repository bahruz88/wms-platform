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
app.MapReverseProxy();

await app.RunAsync().ConfigureAwait(false);
