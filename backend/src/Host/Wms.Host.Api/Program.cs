using Serilog;
using Serilog.Events;
using Serilog.Formatting.Compact;
using Wms.Common.Infrastructure.DependencyInjection;
using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Modules;
using Wms.Host.Api;

var builder = WebApplication.CreateBuilder(args);

// Structured JSON logging to stdout plus Seq when configured (spec §3, CONVENTIONS Seq__Url).
builder.Host.UseSerilog((context, _, configuration) =>
{
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .Enrich.WithProperty("service", context.HostingEnvironment.ApplicationName)
        .Enrich.WithProperty("modules", context.Configuration[ModuleRegistry.ConfigurationKey] ?? ModuleRegistry.All)
        .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
        .MinimumLevel.Override("Microsoft.EntityFrameworkCore.Database.Command", LogEventLevel.Warning)
        .WriteTo.Console(new CompactJsonFormatter());

    var seqUrl = context.Configuration["Seq:Url"];
    if (!string.IsNullOrWhiteSpace(seqUrl))
    {
        configuration.WriteTo.Seq(seqUrl, apiKey: context.Configuration["Seq:ApiKey"]);
    }
});

// CONVENTIONS.md: every host listens on 8080 inside its container.
builder.WebHost.UseUrls(Environment.GetEnvironmentVariable("ASPNETCORE_URLS") ?? "http://+:8080");

builder.Services.AddWmsCommon(builder.Configuration, builder.Environment);
builder.Services.AddOpenApi();

var modules = builder.LoadModules();

var app = builder.Build();

app.UseSerilogRequestLogging(options => options.GetLevel = (httpContext, _, exception) =>
    exception is not null ? LogEventLevel.Error
    : httpContext.Request.Path.StartsWithSegments("/health") ? LogEventLevel.Verbose
    : LogEventLevel.Information);

app.UseWmsCommon();

if (app.Environment.IsDevelopment())
{
    // GET /openapi/v1.json (CONVENTIONS.md) — Development only.
    app.MapOpenApi();
}

app.MapModuleEndpoints();

// Hangfire server + /hangfire dashboard only where Jobs:Enabled=true (the wms-worker container).
app.MapWmsJobs();

// NOTE: no automatic migration on startup (spec §18.3) — that is the job of Wms.Host.Migrator.
app.Logger.LogInformation(
    "WMS API started. Modules: {Modules}. Jobs: {JobsEnabled}. Transport: {Transport}",
    string.Join(", ", modules.Select(m => m.Name)),
    app.Configuration.AreJobsEnabled(),
    ModuleTransportConfiguration.Resolve(app.Configuration));

await app.RunAsync().ConfigureAwait(false);

/// <summary>Exposed so <c>WebApplicationFactory&lt;Program&gt;</c> can boot the host in contract tests.</summary>
public partial class Program;
