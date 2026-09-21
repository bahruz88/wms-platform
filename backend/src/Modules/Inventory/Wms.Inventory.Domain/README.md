# Wms.Inventory.Domain

Nüvə modul (SPEC ADR-002: Inventory bölünmür). Şema prefiksi: `inv_`. Yalnız `Wms.Common.Domain`-dən asılıdır.

## Sahib olduğu aqreqatlar və cədvəllər (SPEC §9)

| Aqreqat / entity | Cədvəl | Status |
|---|---|---|
| `InventorySetting` | `inv_setting` | hazır (açarlar `InventorySettingKeys`-də, SPEC §9.1) |
| `Batch` | `inv_batch` | hazır (FEFO/FIFO indeksi, status maşını) |
| `MovementGroup` (aggregate root) + `Movement` | `inv_movement_group`, `inv_movement` | hazır — `MovementGroup.Create` ikili yazılış invariantını (`SUM(qty_base) = 0`) tətbiq edir (ADR-003, §12.3) |
| `StockBalance` (proyeksiya) | `inv_balance` | hazır — yalnız `Apply(Movement)` ilə dəyişir, public setter yoxdur (ADR-004, §12.2); mənfi qalıq rədd edilir (§12.1) |
| `GoodsReceipt` + `GoodsReceiptLine` | `inv_goods_receipt`, `inv_goods_receipt_line` | hazır (DRAFT → POSTED) |
| `StockRequest` | `inv_stock_request` | Faza 1 — planlaşdırılıb |
| `Issue` (BRANCH_ISSUE / WH_TRANSFER / BRANCH_TRANSFER) | `inv_issue` | Faza 1 — planlaşdırılıb (IN_TRANSIT mexanizmi) |
| `Count` + `CountLine` | `inv_count`, `inv_count_line` | Faza 1 — planlaşdırılıb (§12.6, §12.7 dondurma) |
| `Waste` | `inv_waste` | Faza 1 — planlaşdırılıb |
| `Sample` | `inv_sample` | Faza 1 — planlaşdırılıb |
| `ReturnToVendor` | `inv_return_to_vendor` | Faza 2 — planlaşdırılıb |

## Domen servisləri (SPEC §12, hər biri unit test ilə örtülür)

- `Quantity.Convert` (Common) — `qty_base = entered_qty × conversion_rate`, `MidpointRounding.AwayFromZero` (§12.1)
- `MovingAverageCost.Next` — hərəkətli orta maya dəyəri, xarici valyuta `unit_price × fx_rate` (§12.5)
- `BatchAllocator` / `BatchIssueComparer` — FEFO (expiry, sonra received_at) və FIFO sırası; BLOCKED/EXPIRED/QUARANTINE partiyalar ayrılmır (§12.4)
- `ReceiptTolerance.Evaluate` — PO ↔ qəbul toleransı (§12.8)

## Qaydalar

- `inv_movement` append-only: entity-də dəyişdirən metod yoxdur; səhv yalnız `REVERSAL` qrupu ilə düzəldilir.
- Bütün miqdar/məbləğ `decimal`; `double`/`float` analizator qaydası ilə qadağandır (`BannedSymbols.txt`).
- Biznes xətaları `Result` / `InventoryErrors` ilə qaytarılır, exception atılmır.
