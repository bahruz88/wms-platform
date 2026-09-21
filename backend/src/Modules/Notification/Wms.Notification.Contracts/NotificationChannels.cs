namespace Wms.Notification.Contracts;

/// <summary>Notification consumes integration events only (spec §5); it exposes no synchronous contract yet.</summary>
public static class NotificationChannels
{
    public const string InApp = "IN_APP";
    public const string Email = "EMAIL";
}

public static class NotificationRoutes
{
    public const string ModuleName = "Notification";
    public const string Prefix = "/api/v1/notifications";
}
