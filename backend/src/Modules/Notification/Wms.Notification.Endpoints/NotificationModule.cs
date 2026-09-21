using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Notification.Application;
using Wms.Notification.Application.Queries;
using Wms.Notification.Contracts;
using Wms.Notification.Infrastructure;

namespace Wms.Notification.Endpoints;

/// <summary><c>--Modules=notification</c>. Route prefix <c>/api/v1/notifications</c>, table prefix <c>notif_</c>.</summary>
public sealed class NotificationModule : IModule
{
    public const string ModuleName = "notification";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddNotificationApplication();
        services.AddNotificationInfrastructure(configuration);
    }

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(NotificationRoutes.Prefix).WithTags("Notification").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("NotificationPing");

        group.MapGet("/", async ([AsParameters] NotificationsRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var query = new GetMyNotificationsQuery(request.UnreadOnly ?? false, new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(NotificationPermissions.NotificationView)
            .WithName("GetMyNotifications");
    }
}

public sealed record NotificationsRequest(bool? UnreadOnly, int? Page, int? Size);
