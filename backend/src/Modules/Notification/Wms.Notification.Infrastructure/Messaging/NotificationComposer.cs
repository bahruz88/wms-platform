using System.Globalization;
using System.Text.Json;
using Wms.Notification.Domain.Entities;

namespace Wms.Notification.Infrastructure.Messaging;

/// <summary>What one integration event becomes in somebody's inbox.</summary>
public sealed record ComposedNotification(
    string Title,
    string Body,
    string? Link,
    string? EntityType,
    long? EntityId,
    uint? LocationId,
    NotificationSeverity DefaultSeverity);

/// <summary>
/// Turns an integration event's JSON into Azerbaijani inbox copy.
///
/// The text is written here rather than by the publishing module because the publisher speaks in
/// ids and quantities — it has no idea a person will read the result. An event this composer does
/// not know still produces a readable row: the reader learns something happened and where to look,
/// which beats an empty inbox or a crashed consumer.
/// </summary>
public static class NotificationComposer
{
    public static ComposedNotification Compose(string eventType, JsonElement payload)
    {
        var loc = OptionalUInt(payload, "locationId");

        return eventType switch
        {
            "GoodsReceiptPosted" => new(
                $"Qəbul post edildi: {Text(payload, "docNo")}",
                $"Qəbul sənədi anbara daxil oldu və qalıqlar yeniləndi.",
                Link("/inventory/goods-receipts", payload, "receiptId"),
                "goods_receipt", OptionalLong(payload, "receiptId"), loc,
                NotificationSeverity.Info),

            "ReceiptVarianceDetected" => new(
                $"Qəbulda fərq: {Text(payload, "docNo")}",
                "Sifariş olunan və qəbul edilən miqdar arasında fərq var — yoxlanılması lazımdır.",
                Link("/inventory/goods-receipts", payload, "receiptId"),
                "goods_receipt", OptionalLong(payload, "receiptId"), loc,
                NotificationSeverity.Warning),

            "StockBelowMinimum" => new(
                "Qalıq minimumdan aşağıdır",
                $"Məhsul {Number(payload, "productId")}: qalıq {Decimal(payload, "qtyOnHand")}, minimum {Decimal(payload, "minStock")}.",
                "/inventory/balances",
                "product", OptionalLong(payload, "productId"), loc,
                NotificationSeverity.Warning),

            "StockOverMaximum" => new(
                "Qalıq maksimumdan yuxarıdır",
                $"Məhsul {Number(payload, "productId")}: qalıq {Decimal(payload, "qtyOnHand")}, maksimum {Decimal(payload, "maxStock")}.",
                "/inventory/balances",
                "product", OptionalLong(payload, "productId"), loc,
                NotificationSeverity.Info),

            "BatchNearExpiry" => new(
                $"Partiya bitmək üzrədir: {Text(payload, "batchNo")}",
                $"{Number(payload, "daysLeft")} gün qalıb (son istifadə {Text(payload, "expiryDate")}).",
                "/inventory/batches",
                "batch", OptionalLong(payload, "batchId"), loc,
                Flag(payload, "isCritical") ? NotificationSeverity.Critical : NotificationSeverity.Warning),

            "BatchExpired" => new(
                $"Partiyanın vaxtı bitdi: {Text(payload, "batchNo")}",
                "Partiya istifadədən çıxarılmalıdır.",
                "/inventory/batches",
                "batch", OptionalLong(payload, "batchId"), loc,
                NotificationSeverity.Critical),

            "PurchaseOrderApproved" => new(
                $"Sifariş təsdiqləndi: {Text(payload, "docNo")}",
                "Satınalma sifarişi təsdiq zəncirindən keçdi və təchizatçıya göndərilə bilər.",
                Link("/procurement/purchase-orders", payload, "purchaseOrderId"),
                "purchase_order", OptionalLong(payload, "purchaseOrderId"), loc,
                NotificationSeverity.Info),

            "PriceChanged" => new(
                "Qiymət dəyişdi",
                $"Məhsul {Number(payload, "productId")} üçün təchizatçı qiyməti yeniləndi.",
                "/procurement/price-history",
                "product", OptionalLong(payload, "productId"), loc,
                NotificationSeverity.Info),

            "WastePosted" => new(
                "Tullantı post edildi",
                "Tullantı sənədi mühasibat kitabına yazıldı.",
                "/inventory/waste",
                "waste", OptionalLong(payload, "wasteId"), loc,
                NotificationSeverity.Info),

            "TransferCompleted" => new(
                "Transfer tamamlandı",
                "Göndərilən mal təyinat lokasiyasında qəbul edildi.",
                "/inventory/issues",
                "issue", OptionalLong(payload, "issueId"), loc,
                NotificationSeverity.Info),

            "CountVarianceApproved" => new(
                "Sayım fərqi təsdiqləndi",
                "Sayım fərqi düzəliş kimi mühasibat kitabına yazıldı.",
                "/inventory/counts",
                "count", OptionalLong(payload, "countId"), loc,
                NotificationSeverity.Info),

            "ConsumptionShortfallDetected" => new(
                "İstehlakda çatışmazlıq",
                "Nəzəri istehlak mövcud qalıqdan çox oldu — fərq çatışmazlıq kimi qeydə alındı.",
                "/consumption/variance",
                "consumption_run", OptionalLong(payload, "runId"), loc,
                NotificationSeverity.Warning),

            "SalesItemUnmapped" => new(
                "Satış məhsulu uyğunlaşdırılmayıb",
                "İmport edilmiş satış sətri heç bir menyu məhsuluna bağlı deyil.",
                "/consumption/sales-imports",
                "sales_import", OptionalLong(payload, "salesImportId"), loc,
                NotificationSeverity.Warning),

            _ => new(
                eventType,
                "Sistem hadisəsi qeydə alındı.",
                null, null, null, loc,
                NotificationSeverity.Info),
        };
    }

    private static string Text(JsonElement payload, string name) =>
        payload.TryGetProperty(name, out var v) && v.ValueKind is JsonValueKind.String
            ? v.GetString() ?? string.Empty
            : string.Empty;

    private static string Number(JsonElement payload, string name) =>
        payload.TryGetProperty(name, out var v) && v.ValueKind is JsonValueKind.Number
            ? v.ToString()
            : "—";

    /// <summary>Decimals travel as JSON strings (ADR-008); the comma is the Azerbaijani separator.</summary>
    private static string Decimal(JsonElement payload, string name)
    {
        if (!payload.TryGetProperty(name, out var v))
        {
            return "—";
        }

        var raw = v.ValueKind switch
        {
            JsonValueKind.String => v.GetString(),
            JsonValueKind.Number => v.ToString(),
            _ => null,
        };

        return raw is null || !decimal.TryParse(raw, NumberStyles.Number, CultureInfo.InvariantCulture, out var d)
            ? "—"
            : d.ToString("0.####", CultureInfo.InvariantCulture).Replace('.', ',');
    }

    private static bool Flag(JsonElement payload, string name) =>
        payload.TryGetProperty(name, out var v) && v.ValueKind is JsonValueKind.True;

    private static long? OptionalLong(JsonElement payload, string name) =>
        payload.TryGetProperty(name, out var v) && v.ValueKind is JsonValueKind.Number && v.TryGetInt64(out var id) ? id : null;

    private static uint? OptionalUInt(JsonElement payload, string name) =>
        payload.TryGetProperty(name, out var v) && v.ValueKind is JsonValueKind.Number && v.TryGetUInt32(out var id) ? id : null;

    private static string? Link(string prefix, JsonElement payload, string idName) =>
        OptionalLong(payload, idName) is { } id ? $"{prefix}/{id.ToString(CultureInfo.InvariantCulture)}" : prefix;
}
