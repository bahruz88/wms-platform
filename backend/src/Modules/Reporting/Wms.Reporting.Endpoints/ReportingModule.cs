using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Reporting.Application;
using Wms.Reporting.Application.Queries;
using Wms.Reporting.Contracts;
using Wms.Reporting.Infrastructure;

namespace Wms.Reporting.Endpoints;

/// <summary><c>--Modules=reporting</c>. Route prefix <c>/api/v1/reporting</c>, table prefix <c>rpt_</c>.</summary>
public sealed class ReportingModule : IModule
{
    public const string ModuleName = "reporting";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddReportingApplication();
        services.AddReportingInfrastructure(configuration);
    }

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(ReportingRoutes.Prefix).WithTags("Reporting").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("ReportingPing");

        group.MapGet("/reports", async ([AsParameters] PagingRequest paging, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetReportsQuery(paging.ToPageRequest()), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(ReportingPermissions.ReportView)
            .WithName("GetReports");
    }
}
