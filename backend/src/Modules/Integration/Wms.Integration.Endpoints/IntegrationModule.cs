using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Integration.Application;
using Wms.Integration.Application.Queries;
using Wms.Integration.Contracts;
using Wms.Integration.Infrastructure;

namespace Wms.Integration.Endpoints;

/// <summary><c>--Modules=integration</c>. Route prefix <c>/api/v1/integration</c>, table prefix <c>intg_</c>.</summary>
public sealed class IntegrationModule : IModule
{
    public const string ModuleName = "integration";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddIntegrationApplication();
        services.AddIntegrationInfrastructure(configuration);
    }

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(IntegrationRoutes.Prefix).WithTags("Integration").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("IntegrationPing");

        group.MapGet("/outbound", async ([AsParameters] OutboundRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var query = new GetOutboundMessagesQuery(request.Status, new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(IntegrationPermissions.OutboundView)
            .WithName("GetOutboundMessages");
    }
}

public sealed record OutboundRequest(string? Status, int? Page, int? Size);
