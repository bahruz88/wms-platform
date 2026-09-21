# Wms.Notification.Domain

Şema prefiksi: `notif_`. Başqa moduldan asılılığı yoxdur — yalnız integration event-lərlə işləyir (SPEC §5).

## Sahib olduğu cədvəllər

| Entity | Cədvəl | Qeyd |
|---|---|---|
| `NotificationRule` | `notif_rule` | hansı event → hansı rola/kanala; `is_active` |
| `NotificationMessage` | `notif_message` | in-app bildiriş, `read_at`; consumer idempotentliyi üçün `event_id` unikal (SPEC §14.1) |

## Consume etdiyi event-lər (SPEC §14.2)

`GoodsReceiptPosted`, `ReceiptVarianceDetected`, `StockBelowMinimum`, `StockOverMaximum`,
`BatchNearExpiry`, `BatchExpired`, `PurchaseOrderApproved`, `PriceChanged`, `WastePosted`, `TransferCompleted`.
