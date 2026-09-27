namespace Wms.Notification.Application;

/// <summary>
/// The permission codes of notifications.v1.yaml's <c>x-permission</c>. They are the contract's
/// spelling, not a convenient shorthand: the gateway enforces what the contract publishes.
/// </summary>
public static class NotificationPermissions
{
    public const string InboxView = "notif.inbox.view";

    public const string RuleView = "notif.rule.view";

    public const string RuleManage = "notif.rule.manage";
}
