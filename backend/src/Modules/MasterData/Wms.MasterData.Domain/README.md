# Wms.MasterData.Domain

Şema prefiksi: `master_`. İcazəli asılılıq: `Wms.Identity.Contracts` (SPEC §5).

## Sahib olduğu cədvəllər (SPEC §8)

| Entity | Cədvəl | Qeyd |
|---|---|---|
| `Uom` | `master_uom` | `MASS`/`VOLUME`/`COUNT`, `decimals` (yuvarlaqlaşdırma dəqiqliyi, §12.1) |
| `ProductCategory` | `master_product_category` | iyerarxiya + `path`, `FOOD`/`NON_FOOD` |
| `Product` | `master_product` | `sku` MƏCBURİ + unikal, `name` TRIM, `name_sort_key` (AZ əlifba sırası, §6.4), `base_uom_id`, `issue_strategy` |
| `ProductUom` | `master_product_uom` | `factor_to_base DECIMAL(18,8)`, `valid_from`/`valid_to` — əmsal dəyişəndə köhnə sətir bağlanır, UPDATE qadağandır (§12.1) |
| `Supplier` | `master_supplier` | VÖEN, `is_approved_food_supplier` (TOR §7) |
| `SupplierCertificate` | `master_supplier_certificate` | bitmə tarixi üzrə həftəlik alert job-u (§15) |
| `Location` | `master_location` | fiziki VƏ virtual lokasiyalar — ikili yazılışın əsası (ADR-003) |
| `CurrencyRate` | `master_currency_rate` | CBAR məzənnəsi, `rate_to_base DECIMAL(18,8)`; məzənnə yoxdursa qəbul bloklanır (§12.5) |
| `ReasonCode` | `master_reason_code` | `WASTE`/`ADJUSTMENT`/`RETURN`/`SAMPLE`/`TRANSFER`, `requires_approval`, `requires_photo` |
| `NumberSequence` | `master_number_sequence` | `PR-2026-00001` (Əlavə B), `SELECT ... FOR UPDATE` ilə artırılır |

## Domen servisləri

- `AzerbaijaniSortKey.Create` — `name_sort_key` hesablanması (`a b c ç d e ə f g ğ h x ı i j k q l m n o ö p r s ş t u ü v y z`), MySQL-də `az` collation olmadığı üçün (§6.4).
