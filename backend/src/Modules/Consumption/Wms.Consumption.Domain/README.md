# Wms.Consumption.Domain — filial istehlakı domeni

Qərar: [ADR-012](../../../../../docs/adr/ADR-012-branch-consumption-model.md) ·
Dizayn: [branch-operations.md](../../../../../docs/architecture/branch-operations.md) ·
Kontrakt: [consumption.v1.yaml](../../../../../contracts/openapi/consumption.v1.yaml)

Filial stoku indiyədək yalnız artırdı. Bu modul satılan menyu maddəsini reseptə vuraraq **nəzəri
məxaric** hesablayır və onu adi ikili yazılışlı sənəd kimi post edir: `RESTAURANT −qty` /
`V_CONSUMPTION +qty`, `doc_type = CONSUMPTION`. Layihə yalnız `Wms.Common.Domain`-ə bağlıdır —
nə EF Core, nə başqa modul.

## Aqreqatlar və cədvəllər

| Aqreqat / entity | Cədvəl | Açar | Nə saxlayır |
|---|---|---|---|
| `MenuItem` | `cons_menu_item` | `uint` | Satılan maddə və ya filialda hazırlanan yarımfabrikat (`is_sub_recipe`). `pos_code` importun uyğunlaşdırma açarıdır; `name_sort_key` Azərbaycan əlifba sırasıdır. |
| `Recipe` (aqreqat kökü) | `cons_recipe` | `uint` | Reseptin **bir versiyası**: `version_no`, `valid_from`/`valid_to`, `yield_portions`, `status`. `Activate(validFrom, previousActive)` əvvəlki versiyanı `valid_to = validFrom − 1` ilə bağlayır və `ARCHIVED` edir. |
| `RecipeLine` | `cons_recipe_line` | `uint` | Tərkib sətri: `FOOD_PRODUCT` (məhsul) **və ya** `SUB_RECIPE` (başqa menyu maddəsi), `qty_per_portion`, `uom_id`, `yield_pct`, `is_optional` + `attach_rate_pct`. |
| `SalesImport` (aqreqat kökü) | `cons_sales_import` | `long` | Bir filialın bir günlük satışı. Mənbə `POS` \| `CSV` \| `MANUAL` — aşağı axın eynidir. Vəziyyət: `DRAFT → SUBMITTED → CONSUMED` (və ya `CANCELLED`). |
| `SalesLine` | `cons_sales_line` | `long` | Satılan menyu maddəsi. Tanınmayan POS kodu `raw_pos_code`-da saxlanılır, atılmır. |
| `ConsumptionRun` (aqreqat kökü) | `cons_run` | `long` | Bir filial-günün nəzəri məxaric sənədi: `doc_no` (`CN-{YYYY}-{00000}`), `status`, `movement_group_id`, `shortfall_count`, `unmapped_count`. Vəziyyət: `DRAFT → CALCULATED → POSTED → REVERSED`, xəta halında `FAILED`. |
| `ConsumptionRunLine` | `cons_run_line` | `long` | Məhsul üzrə `theoretical_qty_base`, `posted_qty_base`, `shortfall_qty_base`, `base_uom_id`, `unit_cost`. |

Enum-lar (`Enums/ConsumptionEnums.cs`, MySQL-də `UPPER_SNAKE` ENUM): `RecipeStatus`, `ComponentType`,
`SalesSource`, `SalesImportStatus`, `ConsumptionRunStatus`.

## `BomExploder` — saf domen servisi

`Services/BomExploder.cs` bazasızdır: resept və məhsul məlumatını `IBomRecipeSource` /
`IBomProductSource` interfeysləri ilə alır (dictionary əsaslı implementasiyaları burada verilib), ona
görə `Wms.Consumption.UnitTests`-də tam yoxlanılır.

```
tələb_base = porsiya × qty_per_portion ÷ yield_portions × conversion_to_base ÷ (yield_pct ÷ 100)
```

- `yield_pct` emal itkisidir: kahının 8 %-i kəsilirsə 20 q resept 21,7391 q stok deməkdir.
- `yield_portions` bir hazırlanışdan çıxan porsiya sayıdır. Satılan maddə üçün 1-dir — buna görə
  dizayn sənədindəki düstur onu göstərmir — sous kimi yarımfabrikat üçün 1-dən böyükdür.
- `SUB_RECIPE` sətrində `qty_per_portion` alt-reseptin **porsiya sayıdır**; rekursiya həmin porsiya
  sayı ilə davam edir (`uom_id` orada çevrilmə üçün istifadə olunmur).
- Opsional tərkib `attach_rate_pct` ilə miqyaslanır.
- Dövr (`A → B → A`) `RECIPE_CYCLE`, 5-dən dərin yuvalanma `RECIPE_DEPTH_EXCEEDED`, çatışmayan
  vahid əmsalı `UOM_FACTOR_MISSING` ilə rədd edilir. Kök resept dərinlik 0-dır.
- Nəticə məhsul üzrə cəmlənir və base vahidin onluq sayına (maksimum `DECIMAL(18,4)`) yuvarlaqlaşır.

## İnvariantlar (hər biri üçün test var)

1. **Sıfır cəmi** — `CONSUMPTION` qrupu ikili yazılışdır; qrupu Inventory yaradır, `MovementGroup`
   sıfıra bərabər olmayan sətir dəstini onsuz da qəbul etmir.
2. **Bir gün, bir sənəd** — `(tenant_id, location_id, business_date)` həm `cons_sales_import`, həm
   `cons_run` üçün unikaldır (`DUPLICATE_BUSINESS_DATE`).
3. **Mənfi qalıq yaranmır** — `ConsumptionRunLine.Plan/Settle`: `posted = min(theoretical, available)`,
   qalan hissə `shortfall_qty_base`. Cəm həmişə `posted + shortfall = theoretical`.
4. **Keçmiş toxunulmazdır** — hesablama satış tarixinin resept versiyasını (`IsEffectiveOn`) və həmin
   tarixin `factor_to_base` dəyərini götürür; hər ikisi `inv_movement`-də dondurulur.
   Aktivləşdirmə post edilmiş günə toxuna bilmir (`PERIOD_CLOSED`).
5. **Tanınmayan satış itmir** — `SalesLine.RawPosCode` + `unmapped_count` + `SalesItemUnmapped`.
6. **Dövr rədd edilir** — `BomExploder` + `Recipe.ReplaceLines` (`RECIPE_CYCLE`, 422).
7. **Sayım dondurulmasına tabedir** — `409 LOCATION_FROZEN` (yoxlama Inventory-dədir).

## Sərhədlər

Domen **heç vaxt** `inv_*` cədvəllərinə toxunmur və qalıq/partiya bilmir. Post etmə tam olaraq
Inventory-nin tək tranzaksiyasındadır (`IStockPostingService`, ADR-002/ADR-012); bu layihə yalnız
«nə qədər lazımdır» sualını cavablandırır.
