using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Modules;
using Wms.Reporting.Contracts;
using Wms.Reporting.Infrastructure;
using Wms.Reporting.Application;

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

        ReportingEndpoints.Map(group);
    }
}
