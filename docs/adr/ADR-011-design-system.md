# ADR-011: Dizayn sistemi artifact-dan gəlir, Flutter paketi onun tətbiqidir

**Status:** Qəbul edilib
**Əlaqəli:** [docs/design-system/README.md](../design-system/README.md), [docs/design-system/FLUTTER-MAPPING.md](../design-system/FLUTTER-MAPPING.md), [ADR-006](ADR-006-flutter-monorepo-two-shells.md)

## Kontekst

İki tətbiq qabığı (mobil, veb) və altı rol eyni domen məlumatını göstərir. Rəqəm formatı,
status nişanları, ledger işarələri, partiya seçicisi və təsdiq zənciri hər iki qabıqda
**eyni** görünməli və eyni davranmalıdır — əks halda "qəbul ekranındakı miqdar" ilə
"sayım ekranındakı miqdar" fərqli oxunur və bu, məhz sistemin aradan qaldırmağa çalışdığı
səhv növüdür.

Dizaynı kod içində, ekran-ekran qurmaq bu uyğunluğu təmin etmir: hər developer öz badge-ini,
öz rəqəm formatını yazır. Digər tərəfdən, ənənəvi "UI/UX sənədi" (PDF/Figma) kodla
sinxronlaşmır və tez köhnəlir.

Müştəri tərəfindən **WMS Enterprise** adlı dizayn sistemi Claude Artifact kimi hazırlanıb:
28 rəng tokeni (işıqlı/tünd cütü ilə), 11 mətn stili, məsafə/radius/kölgə/şəffaflıq tokenləri,
14 komponent təlimatı, `bundle.css` və `index.d.ts`.

## Qərar

1. **Mənbə — Claude Artifact "WMS Enterprise"** (namespace `Wms`). Dizayn dəyişikliyi orada edilir.
2. **Repoda güzgü — `docs/design-system/`**: `tokens.json`, `README.md` (brend kitabı),
   `components/` (14 komponent təlimatı + `bundle.css` + `index.d.ts`), `FLUTTER-MAPPING.md`.
   Bu qovluq **oxunur, əl ilə redaktə edilmir** — artifact-dan yenilənir.
3. **Tətbiq — `mobile/packages/wms_design_system`** (mobil) və `web/` (React, komponentləri
   birbaşa işlədir — [ADR-013](ADR-013-web-react-mobile-flutter.md)): tokenlər `tokens.json`-dan **hərfi**
   köçürülür (`ThemeExtension<WmsColors>`, `WmsTypography`, `WmsSpacing`, `WmsRadius`,
   `WmsShadows`), komponentlər `bundle.css`-dəki ölçülərlə birə-bir qurulur
   (`min-height: 34px` → `minimumSize: Size(0, 34)`).
4. **Dəyişiklik axını tək istiqamətlidir:**

   ```
   Claude Artifact "WMS Enterprise"
        ↓  (export / sync)
   docs/design-system/        ← repoda həqiqət nüsxəsi
        ↓  (hərfi köçürmə + test)
   mobile/packages/wms_design_system/lib/src/tokens/*.dart
        ↓
   feature paketləri və qabıqlar
   ```

   Əks istiqamət yoxdur: Dart-da rəng/ölçü **uydurulmur**. Yeni token lazımdırsa əvvəl
   artifact-da yaradılır.

## Nəticələr

- `wms_design_system/test/` altında token dəyərlərinin `docs/design-system/tokens.json` ilə
  üst-üstə düşməsini yoxlayan test var: test faylı **JSON-u oxuyur** və Dart sabitləri ilə
  tutuşdurur. Artifact yenilənəndə test qırmızı olur — sinxronizasiya unudulmur.
- Komponent adları kontrakt kimidir: `WmsDataTable`, `WmsQtyUomInput`, `WmsBatchPicker`,
  `WmsDocStatusBadge`, `WmsLedgerTable`, `WmsVarianceIndicator`, `WmsApprovalChain`,
  `WmsKpiCard`, `WmsAlert`, `WmsDialog`, `WmsButton`, `WmsBadge`, `WmsField`, `WmsTextField`,
  `WmsSelect`, `WmsEmptyState`. Ekran bu siyahıdan kənar öz badge-ini və ya öz cədvəlini yazmır.
- Sistem **brenddən asılı deyil**: yeni müştəriyə satışda yalnız `accent` ailəsi dəyişir,
  qalan tokenlər neytraldır. Bu, multi-tenant SaaS mövqeyinin dizayn tərəfidir.
- Dizayn sistemi domen invariantlarını daşıyır (balans input deyil, qiymət icazəyə bağlıdır,
  FEFO təklifi görünür, storno redaktə deyil) — yəni UI qaydası spesifikasiya ilə eyni mənbədən gəlir.
- `text-transform: uppercase` qadağandır (Azərbaycan əlifbasında `i`→`I` səhvdir); bütün
  rəqəmlər mono + tabular; onluq ayırıcı vergül, mənfi işarə U+2212.
- Qarşılığında: dizayn dəyişikliyi iki addımlıdır (artifact → repo → Dart) və bir manual
  sinxronizasiya nöqtəsi var. Token testi bu nöqtəni görünən edir, lakin avtomatlaşdırmır.
- Bu ADR `docs/ux/screen-map.md`-dəki "başlanğıc nöqtəsi" statusunu da dəyişir: brend, tokenlər,
  ikonoqrafiya, boş/xəta vəziyyətləri və əlçatanlıq artıq **həll olunub**; qalan boşluqlar
  ekran-spesifik mobil layout, offline davranış, skan axını, çap/export şablonları və onboarding-dir.
