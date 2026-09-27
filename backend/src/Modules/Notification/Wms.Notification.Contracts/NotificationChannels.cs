namespace Wms.Notification.Contracts;

/// <summary>Delivery channels of notifications.v1.yaml <c>Channel</c>.</summary>
public static class NotificationChannels
{
    public const string InApp = "IN_APP";
    public const string Email = "EMAIL";
    public const string Push = "PUSH";
}

public static class NotificationRoutes
{
    public const string ModuleName = "Notification";
    public const string Prefix = "/api/v1/notifications";
}
