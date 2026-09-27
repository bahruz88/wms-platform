using Wms.Notification.Domain.Entities;

namespace Wms.Notification.UnitTests;

/// <summary>TOR §36: the delivery matrix is the tenant's to configure, within limits.</summary>
public sealed class NotificationRuleTests
{
    private static NotificationRule System() => NotificationRule.Create(
        1, "BatchExpired", NotificationSeverity.Critical, ["IN_APP", "EMAIL"],
        targetRoleCode: "WAREHOUSE_KEEPER", isSystem: true).Value;

    private static NotificationRule Tenant() => NotificationRule.Create(
        1, "StockBelowMinimum", NotificationSeverity.Warning, ["IN_APP"],
        targetRoleCode: "PROCUREMENT_OFFICER").Value;

    [Fact]
    public void Channels_round_trip_through_the_stored_string()
    {
        var rule = System();

        Assert.Equal(["IN_APP", "EMAIL"], rule.ChannelList);
    }

    [Fact]
    public void Target_user_ids_round_trip_and_drop_junk()
    {
        var rule = NotificationRule.Create(
            1, "WastePosted", NotificationSeverity.Info, ["IN_APP"], targetUserIds: [4u, 7u]).Value;

        Assert.Equal([4u, 7u], rule.TargetUserIdList);
    }

    [Fact]
    public void A_rule_needs_at_least_one_channel()
    {
        var result = NotificationRule.Create(1, "WastePosted", NotificationSeverity.Info, [], targetRoleCode: "ADMIN");

        Assert.True(result.IsFailure);
    }

    [Fact]
    public void An_unknown_channel_is_refused()
    {
        var result = NotificationRule.Create(1, "WastePosted", NotificationSeverity.Info, ["SMS"], targetRoleCode: "ADMIN");

        Assert.True(result.IsFailure);
    }

    [Fact]
    public void A_system_rule_may_be_switched_off_but_not_deleted()
    {
        var rule = System();

        var deleted = rule.Delete();

        Assert.True(deleted.IsFailure);
        Assert.True(rule.IsActive);
    }

    [Fact]
    public void A_system_rule_may_be_retargeted_but_not_pointed_at_another_event()
    {
        var rule = System();

        var retarget = rule.Update(
            "BatchExpired", NotificationSeverity.Warning, ["IN_APP"], "ADMIN", null, false,
            NotificationDigest.Daily, isActive: false);
        var rewired = rule.Update(
            "GoodsReceiptPosted", NotificationSeverity.Warning, ["IN_APP"], "ADMIN", null, false,
            NotificationDigest.Daily, isActive: true);

        Assert.True(retarget.IsSuccess);
        Assert.Equal("ADMIN", rule.TargetRoleCode);
        Assert.False(rule.IsActive);
        Assert.True(rewired.IsFailure);
        Assert.Equal("BatchExpired", rule.EventType);
    }

    [Fact]
    public void A_tenant_rule_is_deactivated_rather_than_removed()
    {
        var rule = Tenant();

        Assert.True(rule.Delete().IsSuccess);
        Assert.False(rule.IsActive);
    }
}
