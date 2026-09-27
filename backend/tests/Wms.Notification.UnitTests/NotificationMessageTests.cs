using Wms.Notification.Domain.Entities;

namespace Wms.Notification.UnitTests;

public sealed class NotificationMessageTests
{
    private static readonly DateTimeOffset Now = new(2026, 9, 28, 8, 0, 0, TimeSpan.Zero);

    [Fact]
    public void A_message_needs_a_recipient()
    {
        var result = NotificationMessage.Create(1, Guid.NewGuid(), "WastePosted", "Başlıq", "Mətn", Now);

        Assert.True(result.IsFailure);
    }

    [Fact]
    public void MarkRead_keeps_the_first_timestamp()
    {
        var message = NotificationMessage.Create(
            1, Guid.NewGuid(), "WastePosted", "Başlıq", "Mətn", Now, recipientUserId: 4).Value;

        message.MarkRead(Now.AddHours(1));
        message.MarkRead(Now.AddHours(5));

        Assert.Equal(Now.AddHours(1), message.ReadAt);
    }

    [Fact]
    public void A_title_over_two_hundred_characters_is_refused()
    {
        var result = NotificationMessage.Create(
            1, Guid.NewGuid(), "WastePosted", new string('a', 201), "Mətn", Now, recipientUserId: 4);

        Assert.True(result.IsFailure);
    }
}
