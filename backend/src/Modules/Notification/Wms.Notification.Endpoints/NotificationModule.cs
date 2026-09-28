using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Notification.Application;
using Wms.Notification.Application.Commands;
using Wms.Notification.Application.Queries;
using Wms.Notification.Contracts;
using Wms.Notification.Domain.Entities;
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
        ArgumentNullException.ThrowIfNull(app);
        var group = app.MapGroup(NotificationRoutes.Prefix).WithTags("Notification").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("NotificationPing");

        // ---------------------------------------------------------------- inbox

        group.MapGet("/inbox", async ([AsParameters] InboxRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                var query = new GetMyNotificationsQuery(request.UnreadOnly ?? false, new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, ct).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(NotificationPermissions.InboxView)
            .WithName("listNotifications");

        group.MapGet("/inbox/unread-count", async (IDispatcher dispatcher, CancellationToken ct) =>
            {
                var result = await dispatcher.QueryAsync(new GetUnreadCountQuery(), ct).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(NotificationPermissions.InboxView)
            .WithName("getUnreadCount");

        group.MapGet("/inbox/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken ct) =>
            {
                var result = await dispatcher.QueryAsync(new GetNotificationQuery(id), ct).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(NotificationPermissions.InboxView)
            .WithName("getNotification");

        group.MapPost("/inbox/{id:long}/read", async Task<IResult> (long id, IDispatcher dispatcher, CancellationToken ct) =>
            {
                var marked = await dispatcher.SendAsync(new MarkNotificationReadCommand(id), ct).ConfigureAwait(false);
                if (marked.IsFailure)
                {
                    return marked.Error.ToProblem();
                }

                var reloaded = await dispatcher.QueryAsync(new GetNotificationQuery(id), ct).ConfigureAwait(false);
                return reloaded.ToOk();
            })
            .RequirePermission(NotificationPermissions.InboxView)
            .WithName("markNotificationRead");

        group.MapPost("/inbox/read-all", async Task<IResult> (ReadAllRequest? request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                var result = await dispatcher
                    .SendAsync(new MarkAllNotificationsReadCommand(request?.Before), ct)
                    .ConfigureAwait(false);
                return result.IsFailure
                    ? result.Error.ToProblem()
                    : TypedResults.Ok(new MarkedReadResponse(result.Value));
            })
            .RequirePermission(NotificationPermissions.InboxView)
            .WithName("markAllNotificationsRead");

        // ---------------------------------------------------------------- rules

        group.MapGet("/rules", async ([AsParameters] RulesRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                var result = await dispatcher.QueryAsync(new ListNotificationRulesQuery(request.IsActive), ct).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(NotificationPermissions.RuleView)
            .WithName("listNotificationRules");

        group.MapPost("/rules", async Task<IResult> (NotificationRuleCreateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var result = await dispatcher.SendAsync(request.ToCommand(), ct).ConfigureAwait(false);
                return result.IsFailure
                    ? result.Error.ToProblem()
                    : TypedResults.Created($"{NotificationRoutes.Prefix}/rules/{result.Value}", new CreatedRuleResponse(result.Value));
            })
            .RequirePermission(NotificationPermissions.RuleManage)
            .RequireIdempotencyKey()
            .WithName("createNotificationRule");

        group.MapPut("/rules/{id:int}", async Task<IResult> (uint id, NotificationRuleUpdateRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var updated = await dispatcher.SendAsync(request.ToCommand(id), ct).ConfigureAwait(false);
                if (updated.IsFailure)
                {
                    return updated.Error.ToProblem();
                }

                var reloaded = await dispatcher.QueryAsync(new ListNotificationRulesQuery(null), ct).ConfigureAwait(false);
                return reloaded.IsFailure
                    ? reloaded.Error.ToProblem()
                    : TypedResults.Ok(reloaded.Value.First(r => r.Id == id));
            })
            .RequirePermission(NotificationPermissions.RuleManage)
            .WithName("updateNotificationRule");

        group.MapDelete("/rules/{id:int}", async Task<IResult> (uint id, IDispatcher dispatcher, CancellationToken ct) =>
            {
                var result = await dispatcher.SendAsync(new DeleteNotificationRuleCommand(id), ct).ConfigureAwait(false);
                return result.IsFailure ? result.Error.ToProblem() : TypedResults.NoContent();
            })
            .RequirePermission(NotificationPermissions.RuleManage)
            .WithName("deleteNotificationRule");

        // ---------------------------------------------------------------- devices

        group.MapPost("/devices", async Task<IResult> (DeviceRegistrationRequest request, IDispatcher dispatcher, CancellationToken ct) =>
            {
                ArgumentNullException.ThrowIfNull(request);
                var command = request.ToCommand();
                if (command.IsFailure)
                {
                    return command.Error.ToProblem();
                }

                var result = await dispatcher.SendAsync(command.Value, ct).ConfigureAwait(false);
                return result.IsFailure
                    ? result.Error.ToProblem()
                    : TypedResults.Ok(new RegisteredDeviceResponse(request.DeviceId));
            })
            .RequirePermission(NotificationPermissions.InboxView)
            .RequireIdempotencyKey()
            .WithName("registerDevice");

        group.MapDelete("/devices/{deviceId}", async Task<IResult> (string deviceId, IDispatcher dispatcher, CancellationToken ct) =>
            {
                var result = await dispatcher.SendAsync(new UnregisterDeviceCommand(deviceId), ct).ConfigureAwait(false);
                return result.IsFailure ? result.Error.ToProblem() : TypedResults.NoContent();
            })
            .RequirePermission(NotificationPermissions.InboxView)
            .WithName("unregisterDevice");
    }
}

public sealed record InboxRequest(bool? UnreadOnly, int? Page, int? Size);

public sealed record RulesRequest(bool? IsActive);

/// <summary>Body of <c>markAllNotificationsRead</c>; absent means "everything unread".</summary>
public sealed record ReadAllRequest(DateTimeOffset? Before);

public sealed record MarkedReadResponse(int MarkedCount);

public sealed record CreatedRuleResponse(uint Id);

public sealed record RegisteredDeviceResponse(string DeviceId);

/// <summary><c>NotificationRuleCreate</c>.</summary>
public sealed record NotificationRuleCreateRequest(
    string EventType,
    string Severity,
    List<string>? Channels,
    string? TargetRoleCode,
    List<uint>? TargetUserIds,
    bool? TargetLocationScoped,
    string? Digest)
{
    public CreateNotificationRuleCommand ToCommand() => new(
        EventType,
        NotificationEnums.Severity(Severity),
        Channels ?? [],
        TargetRoleCode,
        TargetUserIds ?? [],
        TargetLocationScoped ?? true,
        NotificationEnums.Digest(Digest));
}

/// <summary><c>NotificationRuleUpdate</c>.</summary>
public sealed record NotificationRuleUpdateRequest(
    uint RowVersion,
    string EventType,
    string Severity,
    List<string>? Channels,
    string? TargetRoleCode,
    List<uint>? TargetUserIds,
    bool? TargetLocationScoped,
    string? Digest,
    bool IsActive)
{
    public UpdateNotificationRuleCommand ToCommand(uint id) => new(
        id,
        RowVersion,
        EventType,
        NotificationEnums.Severity(Severity),
        Channels ?? [],
        TargetRoleCode,
        TargetUserIds ?? [],
        TargetLocationScoped ?? true,
        NotificationEnums.Digest(Digest),
        IsActive);
}

/// <summary><c>DeviceRegistration</c>.</summary>
public sealed record DeviceRegistrationRequest(string DeviceId, string Platform, string PushToken, string? AppVersion)
{
    public Wms.Common.Domain.Result<RegisterDeviceCommand> ToCommand()
    {
        var platform = Platform?.ToUpperInvariant() switch
        {
            "ANDROID" => DevicePlatform.Android,
            "IOS" => DevicePlatform.Ios,
            _ => (DevicePlatform?)null,
        };

        return platform is null
            ? NotificationErrors.InvalidDevice("platform must be ANDROID or IOS.")
            : new RegisterDeviceCommand(DeviceId, platform.Value, PushToken, AppVersion);
    }
}

internal static class NotificationEnums
{
    public static NotificationSeverity Severity(string? value) => value?.ToUpperInvariant() switch
    {
        "WARNING" => NotificationSeverity.Warning,
        "CRITICAL" => NotificationSeverity.Critical,
        _ => NotificationSeverity.Info,
    };

    public static NotificationDigest Digest(string? value) =>
        string.Equals(value, "DAILY", StringComparison.OrdinalIgnoreCase)
            ? NotificationDigest.Daily
            : NotificationDigest.Immediate;
}
