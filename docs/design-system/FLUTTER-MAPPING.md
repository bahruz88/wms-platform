# WMS Enterprise dizayn sistemi → Flutter tətbiqi

Mənbə: `docs/design-system/` (Claude Artifact "WMS Enterprise" design system, namespace `Wms`).
Hədəf: `mobile/packages/wms_design_system` (yalnız mobil — web tətbiqi dizayn sistemini
öz doğma React formatında işlədir, [ADR-013](../adr/ADR-013-web-react-mobile-flutter.md)).

Bu sənəd dizayn sistemini Flutter-ə **necə köçürəcəyini** deyir. Dəyərlərin özü
`tokens.json` və `components/bundle.css` fayllarındadır — onlar mənbədir, təxmin etmə.

## 1. Token qatı

`lib/src/tokens/` altında, hamısı `tokens.json`-dan **hərfi** köçürülür:

| Fayl | Məzmun |
|---|---|
| `wms_colors.dart` | 28 rəng tokeni, `light`/`dark` cütü ilə. `ledger-in`/`ledger-out` aliasdır (`success`/`danger`). |
| `wms_typography.dart` | `display`, `title-lg`, `title`, `body`, `body-strong`, `caption`, `label` (sans) + `figure-lg`, `figure`, `figure-sm`, `doc-no` (mono). |
| `wms_spacing.dart` | `space1..space7` = 4, 8, 12, 16, 24, 32, 48. |
| `wms_radius.dart` | `sm` 4, `md` 6, `lg` 10, `pill` 999. |
| `wms_shadows.dart` | `shadowSm`, `shadowMd`, `shadowOverlay` — hər tema üçün ayrı. |
| `wms_opacity.dart` | `disabled` 0.45, `pending` 0.7. |

Qaydalar:

- Rənglər `ThemeExtension<WmsColors>` ilə verilir, `Theme.of(context).extension<WmsColors>()!`
  ilə oxunur. `ColorScheme`-ə sığmayan tokenlər (`ledgerIn`, `virtualLocation`, `rowHover`,
  `surfaceSunken`, `inkMuted`...) məhz buna görə extension-dadır.
- `WmsTheme.light()` / `WmsTheme.dark()` Material 3 `ThemeData` qaytarır; `ColorScheme`
  aşağıdakı kimi bağlanır: `primary`=`accent`, `onPrimary`=`on-accent`,
  `surface`=`surface`, `onSurface`=`ink`, `error`=`danger`, `onError`=`on-danger`,
  `outline`=`border-control`, `outlineVariant`=`border`, `surfaceContainerLowest`=`surface-canvas`,
  `surfaceContainerLow`=`surface-sunken`, `surfaceContainerHigh`=`surface-raised`.
- Mono ailə: `ui-monospace` Flutter-də yoxdur. `fontFamilyFallback` işlət:
  `['SF Mono', 'Menlo', 'Consolas', 'Roboto Mono', 'monospace']`.
  **Rəqəmlərdə `fontFeatures: [FontFeature.tabularFigures()]` məcburidir** — sütun
  boyu onluqların düzülməsi bu sistemin əsas tələbidir.
- `letterSpacing` dəyərləri `em`-dədir (`-0.01em`, `0.02em`); Flutter piksel istəyir:
  `letterSpacing = fontSize * emValue`.

## 2. Formatlama (`lib/src/format/`)

`index.d.ts`-dəki `format` obyektinin Dart qarşılığı — `intl` ilə, `Decimal` üzərində:

- `WmsFormat.number(Decimal, decimals)` → `1 284,5000`. Onluq ayırıcı **vergül**,
  min ayırıcı **dar boşluq** (U+202F). `NumberFormat` ilə `az` locale qur, ayırıcıları
  bu iki simvola məcbur et.
- `WmsFormat.signed(Decimal, decimals)` → `+12,0000` / `−12,0000`.
  **Mənfi işarə U+2212 (`−`), ASCII defis deyil.**
- `WmsFormat.date` → `dd.MM.yyyy`, `WmsFormat.dateTime` → `dd.MM.yyyy HH:mm`.
  Saxlama UTC, göstərmə `tenant.timezone`.
- Rəqəm heç vaxt kəsilmir: `decimals` məhsulun `base_uom.decimals` dəyərindən gəlir.

## 3. Komponentlər (`lib/src/components/`)

CSS-dəki hər sinif üçün bir widget. Ölçülər `bundle.css`-dən **hərfi** götürülür
(`min-height: 34px` → `minimumSize: Size(0, 34)` və s.).

| Widget | CSS mənbəyi | Kritik davranış |
|---|---|---|
| `WmsButton` | `.wms-btn*` | 4 variant: primary/secondary/ghost/danger, `size` md(34px)/sm(28px). `loading` → `disabled` + eni sabit qalır (spinner mətnin yerinə, düymə sıçramır). `disabled` olduqda səbəb `tooltip` ilə verilir. |
| `WmsBadge` | `.wms-badge*` | 6 ton + `soft`/`solid`/`outline`. **Mətn məcburidir**, `dot` yalnız müşayiətçi. |
| `WmsDocStatusBadge` | — | ENUM → (Azərbaycanca ad, ton) xəritəsi komponentin daxilində. Naməlum status neytral tonda olduğu kimi göstərilir. Orijinal ENUM `tooltip`-də. Status üçün başqa badge yazmaq qadağandır. |
| `WmsAlert` | `.wms-alert*` | RFC 7807 cavabı olduğu kimi köçürülür: `title`→başlıq, `detail`→gövdə, `code` və `traceId` `ink-muted` ilə kiçik. `danger` → `Semantics(liveRegion: true)`. |
| `WmsField` | `.wms-field*` | Etiket + hint/error qabığı. `error` verildikdə `hint` gizlənir, sərhəd `danger`. |
| `WmsTextField` | `.wms-input` | `mono` bayrağı SKU/barkod/sənəd nömrəsi üçün. Yalnız oxunan dəyər `readOnly`, `disabled` deyil. |
| `WmsSelect` | `.wms-select*` | Seçilə bilməyən variant siyahıdan çıxarılmır, `disabled` edilir və səbəb etiketə yazılır. |
| `WmsQtyUomInput` | `.wms-qty*` | **Miqdar daxil edilən hər yerdə bu işlənir.** Rəqəm sağa düzlənir + mono. Vahid base-dən fərqlidirsə altında `= <miqdar> <base kod> · əmsal <n>`. Vahid dəyişəndə **rəqəm dəyişmir**, yalnız base ekvivalenti yenilənir. Mənfi dəyər qəbul edilmir. |
| `WmsDataTable` | `.wms-table*` | Sticky başlıq, `dense` defolt. `numeric` sütun sağa + mono + tabular. **`permission` verilmiş sütun icazə yoxdursa ümumiyyətlə render edilmir** (boş xana və ya `***` yox). `empty` mətni səbəb + növbəti addım. |
| `WmsLedgerTable` | `.wms-ledger*` | İşarə (`+`/`−`) həmişə görünür, rəng ikinci dərəcəlidir. Virtual lokasiyalar `virtual` tonlu badge alır. Cəm sıfır yoxlaması sətri həmişə göstərilir; sıfır deyilsə `danger` və sənəd post edilə bilməz. Redaktə düyməsi yoxdur. |
| `WmsBatchPicker` | `.wms-batch*` | FEFO/FIFO təklifi nişanlanır. `ACTIVE` olmayan partiyalar görünür amma seçilmir. Expiry iki pilləli: `criticalDays`→danger, `warningDays`→warning. Sıra: ACTIVE, QUARANTINE, BLOCKED, EXPIRED; hər qrupda expiry üzrə. Təklifdən kənar seçim → səbəb sahəsi açılır. |
| `WmsApprovalChain` | `.wms-chain*` | Bütün addımlar göstərilir, gözlənilənlər `opacity-pending`. Cari addım warning tonlu saat ikonu. Delegasiya açıq yazılır. Təsdiq/rədd düymələri komponentin **daxilində deyil**. |
| `WmsVarianceIndicator` | `.wms-variance*` | Fərq işarəli, faiz yanında `figure-sm`. Həddən yuxarı → «Təsdiq tələb edir». Fərq var, səbəb kodu yox → «Səbəb kodu yoxdur». Sıfır fərq **neytral**, yaşıl deyil. |
| `WmsKpiCard` | `.wms-kpi*` | Rəqəm `figure-lg` mono. `delta` verilirsə `hint` də məcburi. `deltaTone` ilə yön əl ilə verilə bilər (tullantının azalması yaxşıdır). Pul göstəricisi `view_cost` icazəsinə bağlı — icazə yoxdursa kart render edilmir. |
| `WmsDialog` | `.wms-scrim`, `.wms-dialog*` | Footer: sağda təsdiq, solda imtina. Destruktiv təsdiq `danger` və məcburi sahə dolana qədər `disabled`. Modal üstündə modal yoxdur. |
| `WmsEmptyState` | `.wms-table__empty` | Səbəb + növbəti addım. «Məlumat yoxdur» yazmaq qadağandır. |

İkonlar: sistemin öz kitabxanası yoxdur. Konturlu, 1.5px, 16px şəbəkəli dəst
(`Icons.*_outlined` və ya `lucide_icons`) + `currentColor` qaydası — ikon mətn rəngini
miras alır. Tək başına əməliyyat bildirən ikona `Semantics(label:)` məcburidir.

## 4. Dəyişməz qaydalar (tətbiqdə pozulmamalıdır)

Bunlar `docs/design-system/README.md` və spesifikasiyanın invariantlarından gəlir:

1. **`text-transform: uppercase` qadağandır** — Azərbaycan əlifbasında `i`→`I` səhvdir.
   Flutter-də `.toUpperCase()` interfeys mətnində çağırılmır.
2. **Balans heç bir ekranda input deyil.** Qalıq sahəsi yalnız oxunur.
3. **Qiymət sütunları icazəyə bağlıdır** (`master.product.view_cost`). Server sahəni
   JSON-dan çıxarır, interfeys sütunu render etmir. Maskalamaq (`***`) qadağandır.
4. **Rəng tək başına məna daşımır** — hər status söz və ya işarə ilə müşayiət olunur.
5. **Fokus halqası həmişə var**: 2px `focus-ring`, 2px offset. `outline: none` ekvivalenti
   (Flutter-də `focusNode` görüntüsünün söndürülməsi) qadağandır.
6. **Emoji işlədilmir.**
7. Sıralama `name_sort_key` sütununa görə — Dart-ın `compareTo`-su `ə` hərfini düzgün
   yerləşdirmir, serverin verdiyi sıra saxlanılır.
8. `prefers-reduced-motion` → `MediaQuery.disableAnimations` yoxlanılır, keçidlər söndürülür.

## 5. Yoxlama

- `wms_design_system/test/` altında: token dəyərlərinin `tokens.json` ilə üst-üstə
  düşməsi (faylı test-də oxu və müqayisə et), `WmsFormat` testləri (vergül, dar boşluq,
  U+2212 işarəsi, `decimals` kəsilməməsi), hər komponent üçün golden və ya widget testi.
- Kontrast: hər mətn cütü öz fonunda hər iki temada ≥ 4.5:1 (24px+ və sərhədlər ≥ 3:1).
  Bunu bir dəfə test ilə yoxla — `tokens.json`-dakı `usage` sahəsi hansı fonun
  nəzərdə tutulduğunu deyir.
