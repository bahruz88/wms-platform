using System.Text.Json;
using Wms.Notification.Domain.Entities;
using Wms.Notification.Infrastructure.Messaging;

namespace Wms.Notification.UnitTests;

/// <summary>
/// The composer is what a person actually reads, so it is tested against the shape the publishing
/// modules really emit — including the decimals-as-strings rule of ADR-008.
/// </summary>
public sealed class NotificationComposerTests
{
    private static JsonElement Payload(string json) => JsonDocument.Parse(json).RootElement;

    [Fact]
    public void A_posted_receipt_names_the_document_and_links_to_it()
    {
        var result = NotificationComposer.Compose(
            "GoodsReceiptPosted",
            Payload("""{"tenantId":1,"receiptId":311,"docNo":"GR-2026-00311","locationId":7}"""));

        Assert.Contains("GR-2026-00311", result.Title, StringComparison.Ordinal);
        Assert.Equal("/inventory/goods-receipts/311", result.Link);
        Assert.Equal("goods_receipt", result.EntityType);
        Assert.Equal(311, result.EntityId);
        Assert.Equal(7u, result.LocationId);
    }

    [Fact]
    public void A_string_decimal_is_rendered_with_the_azerbaijani_comma()
    {
        var result = NotificationComposer.Compose(
            "StockBelowMinimum",
            Payload("""{"tenantId":1,"productId":5,"locationId":1,"qtyOnHand":"12.5000","minStock":"40.0000"}"""));

        Assert.Contains("12,5", result.Body, StringComparison.Ordinal);
        Assert.Contains("40", result.Body, StringComparison.Ordinal);
    }

    [Fact]
    public void Expiry_severity_follows_the_events_own_critical_flag()
    {
        var warning = NotificationComposer.Compose(
            "BatchNearExpiry",
            Payload("""{"tenantId":1,"batchId":9,"batchNo":"B-9","daysLeft":10,"isCritical":false}"""));
        var critical = NotificationComposer.Compose(
            "BatchNearExpiry",
            Payload("""{"tenantId":1,"batchId":9,"batchNo":"B-9","daysLeft":2,"isCritical":true}"""));

        Assert.Equal(NotificationSeverity.Warning, warning.DefaultSeverity);
        Assert.Equal(NotificationSeverity.Critical, critical.DefaultSeverity);
    }

    [Fact]
    public void An_unknown_event_still_produces_a_readable_row()
    {
        var result = NotificationComposer.Compose("SomethingNobodyMappedYet", Payload("""{"tenantId":1}"""));

        Assert.Equal("SomethingNobodyMappedYet", result.Title);
        Assert.False(string.IsNullOrWhiteSpace(result.Body));
        Assert.Equal(NotificationSeverity.Info, result.DefaultSeverity);
    }

    [Fact]
    public void A_missing_field_renders_as_a_dash_rather_than_throwing()
    {
        var result = NotificationComposer.Compose(
            "StockBelowMinimum",
            Payload("""{"tenantId":1}"""));

        Assert.Contains("—", result.Body, StringComparison.Ordinal);
    }
}
