using Wms.Notification.Domain.Entities;

namespace Wms.Notification.UnitTests;

/// <summary>A handset registers once per user; its push token is expected to rotate.</summary>
public sealed class NotificationDeviceTests
{
    private static readonly DateTimeOffset Now = new(2026, 9, 28, 8, 0, 0, TimeSpan.Zero);

    private static NotificationDevice New() => NotificationDevice.Register(
        1, 4, "handset-1", DevicePlatform.Android, "fcm-first", "1.0.0", Now).Value;

    [Fact]
    public void Refresh_replaces_the_token_in_place()
    {
        var device = New();

        var refreshed = device.Refresh(DevicePlatform.Android, "fcm-second", "1.0.1", Now.AddDays(1));

        Assert.True(refreshed.IsSuccess);
        Assert.Equal("fcm-second", device.PushToken);
        Assert.Equal("1.0.1", device.AppVersion);
        Assert.Equal(Now.AddDays(1), device.RegisteredAt);
        Assert.Equal("handset-1", device.DeviceId);
    }

    [Fact]
    public void An_empty_push_token_is_refused()
    {
        var result = NotificationDevice.Register(1, 4, "handset-1", DevicePlatform.Ios, "   ", null, Now);

        Assert.True(result.IsFailure);
    }

    [Fact]
    public void A_push_token_over_the_column_width_is_refused()
    {
        var result = NotificationDevice.Register(
            1, 4, "handset-1", DevicePlatform.Ios, new string('t', NotificationDevice.PushTokenMaxLength + 1), null, Now);

        Assert.True(result.IsFailure);
    }
}
