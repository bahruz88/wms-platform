# Wms.Procurement.Domain

Şema prefiksi: `proc_`. İcazəli asılılıqlar: `Wms.MasterData.Contracts`, `Wms.Inventory.Contracts` (SPEC §5).

## Sahib olduğu cədvəllər (SPEC §10)

| Entity | Cədvəl | Status |
|---|---|---|
| `Requisition` + `RequisitionLine` | `proc_requisition`, `proc_requisition_line` | hazır (DRAFT → SUBMITTED → … `converted_qty` qismən PO çevrilməsi, §12.8) |
| `PurchaseOrder` + `PurchaseOrderLine` | `proc_purchase_order`, `proc_purchase_order_line` | hazır (`total_amount_base` approval limiti ilə yoxlanılır) |
| `Rfq` | `proc_rfq` | Faza 2 — planlaşdırılıb |
| `Quotation` | `proc_quotation` | Faza 2 — planlaşdırılıb (ən ucuz seçilmədikdə `selection_note` MƏCBURİ) |
| `PriceHistory` | `proc_price_history` | Faza 2 — planlaşdırılıb (TOR §25, `PriceChanged` event) |
| `ApprovalRule` / `ApprovalInstance` / `ApprovalStep` | `proc_approval_rule`, `proc_approval_instance`, `proc_approval_step` | hazır: `ApprovalRuleSelector` məbləğ limitinə görə qaydanı seçir (§17.1) |
| `SplitCheckLog` | `proc_split_check_log` | Faza 2 — planlaşdırılıb (PR bölünməsinə qarşı SoD nəzarəti) |

## Qaydalar

- PR avtomatik PO-ya çevrilmir (TOR §9); bir PO bir neçə PR sətrindən yığıla bilər.
- `fx_rate` PO tarixindəki `master_currency_rate`-dən dondurulur; `total_amount_base` approval limiti üçün AZN-dədir.
