using System.Diagnostics;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using StackExchange.Redis;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Dispatching;
using Wms.Common.Infrastructure.Health;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Messaging;
using Wms.Common.Infrastructure.Persistence;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Common.Infrastructure.Time;

namespace Wms.Common.Infrastructure.DependencyInjection;

public static class WmsCommonServiceCollectionExtensions
{
    public const string RateLimitKey = "RateLimiting:PermitPerMinute";
    public const int DefaultPermitPerMinute = 100;

    private static readonly string[] ReadyTags = ["ready"];

    /// <summary>Context services shared by the API host and the migrator (no ASP.NET pipeline pieces).</summary>
    public static IServiceCollection AddWmsCore(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services.AddHttpContextAccessor();
        services.AddScoped<TenantContext>();
        services.AddScoped<ITenantContext>(sp => sp.GetRequiredService<TenantContext>());
        services.AddScoped<ITenantContextInitializer>(sp => sp.GetRequiredService<TenantContext>());
        services.AddScoped<PrincipalContext>();
        services.AddScoped<ICurrentUser, CurrentUser>();
        services.AddSingleton<IClock, SystemClock>();
        services.AddScoped<IDispatcher, Dispatcher>();

        var connectionString = configuration.GetConnectionString(WmsMySql.ConnectionStringName);
        services.AddDbContext<CommonDbContext>(options => options.UseWmsMySql(connectionString, CommonDbContext.MigrationsHistoryTable));

        return services;
    }

    /// <summary>Everything an API host needs: auth, problem details, JSON, rate limiting, telemetry, health, Redis, RabbitMQ, jobs.</summary>
    public static IServiceCollection AddWmsCommon(this IServiceCollection services, IConfiguration configuration, IHostEnvironment environment)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentNullException.ThrowIfNull(environment);

        services.AddWmsCore(configuration);

        services.Configure<InternalApiOptions>(configuration.GetSection(InternalApiOptions.SectionName));
        services.Configure<PrincipalCacheOptions>(configuration.GetSection(PrincipalCacheOptions.SectionName));

        AddAuthentication(services, configuration);
        services.AddAuthorization();

        services.AddProblemDetails(options => options.CustomizeProblemDetails = context =>
        {
            context.ProblemDetails.Extensions.TryAdd("traceId", Activity.Current?.Id ?? context.HttpContext.TraceIdentifier);
        });
        services.AddExceptionHandler<WmsExceptionHandler>();

        services.ConfigureHttpJsonOptions(options =>
        {
            options.SerializerOptions.Converters.Add(new DecimalStringJsonConverter());
            // Enums travel as UPPER_SNAKE on the wire, exactly as the OpenAPI contracts and the MySQL ENUM
            // columns spell them (UpperSnakeCaseEnum): FOOD_PRODUCT, COUNT_ADJUST, V_SUPPLIER ... Without the
            // policy System.Text.Json only matches the PascalCase member name case-insensitively, so a
            // multi-word value like FOOD_PRODUCT fails to bind.
            options.SerializerOptions.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.SnakeCaseUpper));
            options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
        });

        AddRateLimiting(services, configuration);
        AddTelemetry(services, configuration, environment);

        services.AddHealthChecks()
            .AddCheck<MySqlHealthCheck>("mysql", tags: ReadyTags)
            .AddCheck<RedisHealthCheck>("redis", tags: ReadyTags)
            .AddCheck<RabbitMqHealthCheck>("rabbitmq", tags: ReadyTags);

        var redisConnectionString = configuration["Redis:ConnectionString"];
        if (!string.IsNullOrWhiteSpace(redisConnectionString))
        {
            services.AddSingleton<IConnectionMultiplexer>(_ =>
            {
                var redisOptions = ConfigurationOptions.Parse(redisConnectionString);
                redisOptions.AbortOnConnectFail = false;
                redisOptions.ConnectTimeout = 3000;
                redisOptions.ClientName = "wms-api";
                return ConnectionMultiplexer.Connect(redisOptions);
            });
        }

        // Redis is shared by every container, so an iam change made in the Identity container is visible to
        // Inventory/MasterData/worker at once; the in-memory cache is the `dotnet run` and test fallback.
        services.AddMemoryCache();
        if (string.IsNullOrWhiteSpace(redisConnectionString))
        {
            services.AddSingleton<IPrincipalCache, MemoryPrincipalCache>();
        }
        else
        {
            services.AddSingleton<IPrincipalCache, RedisPrincipalCache>();
        }

        services.Configure<RabbitMqOptions>(configuration.GetSection(RabbitMqOptions.SectionName));
        services.AddSingleton<RabbitMqEventBus>();
        services.AddSingleton<IEventBus>(sp => sp.GetRequiredService<RabbitMqEventBus>());

        services.AddWmsJobs(configuration);
        return services;
    }

    /// <summary>Middleware order + health endpoints (<c>/health/live</c> has no dependencies, <c>/health/ready</c> checks MySQL, Redis, RabbitMQ).</summary>
    public static WebApplication UseWmsCommon(this WebApplication app)
    {
        ArgumentNullException.ThrowIfNull(app);

        app.UseExceptionHandler();
        app.UseStatusCodePages();

        // Before authentication: an unauthenticated probe of an /internal/ route must not even reach the
        // JWT handler, and the answer must not depend on whether the caller happens to hold a valid token.
        app.UseMiddleware<InternalRouteGuardMiddleware>();

        app.UseAuthentication();

        // The token carries no internal identifiers, so the iam_user row (id, permissions, locations) is
        // resolved here, once, before any endpoint filter reads ICurrentUser (spec §7, §16).
        app.UseMiddleware<PrincipalResolutionMiddleware>();

        app.UseRateLimiter();
        app.UseAuthorization();

        app.MapHealthChecks("/health/live", new HealthCheckOptions { Predicate = _ => false });
        app.MapHealthChecks("/health/ready", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains("ready"),
            ResponseWriter = WriteHealthReportAsync,
        });

        return app;
    }

    private static void AddAuthentication(IServiceCollection services, IConfiguration configuration)
    {
        var validIssuers = configuration.GetSection("Keycloak:ValidIssuers").Get<string[]>();
        services
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.Authority = configuration["Keycloak:Authority"];
                options.Audience = configuration["Keycloak:Audience"];
                options.RequireHttpsMetadata = configuration.GetValue("Keycloak:RequireHttpsMetadata", false);
                options.MapInboundClaims = false;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromSeconds(30),
                    NameClaimType = ClaimNames.PreferredUsername,
                    RoleClaimType = ClaimNames.Roles,
                    ValidIssuers = validIssuers is { Length: > 0 } ? validIssuers : null,
                };
            });
    }

    private static void AddRateLimiting(IServiceCollection services, IConfiguration configuration)
    {
        var permitLimit = configuration.GetValue(RateLimitKey, DefaultPermitPerMinute);
        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(httpContext =>
            {
                // Module-to-module calls (ModuleTransport=Http, the /internal/* routes of spec §4.2) carry the
                // caller's bearer token, so they land in the same partition as that user's own traffic. One user
                // action can fan out into several of them — decorating a page of documents with product, location,
                // UoM and supplier refs is four internal calls — so counting them against a per-user quota meant a
                // single busy screen could rate-limit itself, and the 429 surfaced as an opaque 500.
                if (IsInternalModuleCall(httpContext))
                {
                    return RateLimitPartition.GetNoLimiter("internal");
                }

                var partitionKey = httpContext.User.FindFirst(ClaimNames.Subject)?.Value
                    ?? httpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "anonymous";
                return RateLimitPartition.GetFixedWindowLimiter(partitionKey, _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = permitLimit,
                    Window = TimeSpan.FromMinutes(1),
                    QueueLimit = 0,
                    AutoReplenishment = true,
                });
            });
            options.OnRejected = async (context, cancellationToken) =>
            {
                context.HttpContext.Response.Headers.RetryAfter = "60";
                var problem = new Error("RATE_LIMITED", $"Too many requests: limit is {permitLimit} per minute per user.", StatusCodes.Status429TooManyRequests)
                    .ToProblemDetails();
                await context.HttpContext.Response.WriteAsJsonAsync(problem, options: null, contentType: "application/problem+json", cancellationToken)
                    .ConfigureAwait(false);
            };
        });
    }

    /// <summary>
    /// True for the <c>/api/v1/&lt;module&gt;/internal/...</c> routes. They are reachable only from inside the
    /// cluster: the gateway refuses the <c>internal</c> path segment outright and every host demands the shared
    /// module secret (<see cref="InternalApi"/>), so exempting them from the per-user quota cannot be abused
    /// from outside.
    /// </summary>
    private static bool IsInternalModuleCall(HttpContext httpContext) =>
        InternalApi.IsInternalPath(httpContext.Request.Path);

    private static void AddTelemetry(IServiceCollection services, IConfiguration configuration, IHostEnvironment environment)
    {
        var otlpEndpoint = configuration["Otel:Endpoint"];
        var serviceName = configuration["Otel:ServiceName"] ?? environment.ApplicationName;

        var telemetry = services.AddOpenTelemetry()
            .ConfigureResource(resource => resource.AddService(serviceName, serviceInstanceId: Environment.MachineName));

        telemetry.WithTracing(tracing =>
        {
            tracing.AddAspNetCoreInstrumentation(options =>
                options.Filter = httpContext => !httpContext.Request.Path.StartsWithSegments("/health"));
            tracing.AddHttpClientInstrumentation();
            if (!string.IsNullOrWhiteSpace(otlpEndpoint))
            {
                tracing.AddOtlpExporter(options => options.Endpoint = new Uri(otlpEndpoint));
            }
        });

        telemetry.WithMetrics(metrics =>
        {
            metrics.AddAspNetCoreInstrumentation();
            metrics.AddHttpClientInstrumentation();
            if (!string.IsNullOrWhiteSpace(otlpEndpoint))
            {
                metrics.AddOtlpExporter(options => options.Endpoint = new Uri(otlpEndpoint));
            }
        });
    }

    private static Task WriteHealthReportAsync(HttpContext context, HealthReport report)
    {
        var payload = new
        {
            status = report.Status.ToString(),
            totalDurationMs = report.TotalDuration.TotalMilliseconds,
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                durationMs = e.Value.Duration.TotalMilliseconds,
            }),
        };
        return context.Response.WriteAsJsonAsync(payload);
    }
}
