# ADR-013 — Web React + TypeScript, mobil Flutter

**Status:** Qəbul edildi — 21.09.2026
**Əvəz edir:** [ADR-006](ADR-006-flutter-monorepo-two-shells.md) (Flutter monorepo, iki shell)
**Əlaqəli:** [ADR-007](ADR-007-contract-first-openapi.md), [ADR-008](ADR-008-decimal-on-client.md), [ADR-011](ADR-011-design-system.md)

## Kontekst

ADR-006 hər iki tətbiqi — web və mobil — bir Flutter pub workspace-də qururdu.
Bu qərar yenidən nəzərdən keçirildi və üç səbəbə görə dəyişdirildi.

**Birincisi, dizayn sistemi React-dir.** `docs/design-system/` altındakı "WMS Enterprise"
sistemi `react@18` və `react-dom@18` kitabxanalarına söykənir; `components/bundle.js`
`window.Wms` qlobalını təyin edən React komponent kitabxanasıdır və `index.d.ts`
React tiplərini (`ReactNode`, `JSX.Element`) elan edir. Flutter tətbiqində bu komponentlər
əl ilə tərcümə olunurdu. React web app onları **birbaşa** işlədir — tərcümə qatı,
onunla birlikdə isə tərcümə xətaları aradan qalxır.

**İkincisi, Flutter web enterprise admin paneli üçün zəif seçimdir.** Release bundle-ı
41 MB-dir, ilk yüklənmə uzundur, mətn seçimi və brauzer axtarışı Material canvas
rendering ilə tam işləmir, SEO isə ümumiyyətlə yoxdur. Satınalma və menecer ekranları
gün ərzində saatlarla açıq qalan masaüstü interfeysdir; burada DOM əsaslı web app
daha uyğundur.

**Üçüncüsü, komanda paralel işləyəcək.** Web və mobil ayrı adamlar tərəfindən
aparılacaq. Ayrı stack-lər hər komandaya öz ekosistemini verir; ortaq nöqtə isə
kod deyil, **OpenAPI kontraktıdır**.

## Qərar

**Web:** Vite + React 18 + TypeScript, `web/` qovluğunda. Dizayn sistemi
`docs/design-system/` faylarından gəlir: `tokens.json` → CSS dəyişənləri,
`components/bundle.css` olduğu kimi, `components/bundle.js` isə tipli ESM React
modullarına köçürülür (`window.Wms` qlobalı işlədilmir).

**Mobil:** Flutter olaraq qalır, `mobile/` qovluğunda (`frontend/`-dən adı dəyişdirilib).
Anbardar və filial işçisi üçün barkod skaneri, kamera, oflayn davranış və bir əllə
istifadə artıq qurulub və işləyir; onu atmaq üçün səbəb yoxdur.

**Ortaq nöqtə:** `contracts/openapi/`. Dart client oradan generasiya olunurdu,
TypeScript client də eyni spesifikasiyalardan generasiya olunur. Kontrakt dəyişəndə
hər iki tərəf eyni mənbədən yenilənir.

## Nəticələr

**Müsbət.**

- Dizayn sistemi öz doğma formatında işlənir; tərcümə qatı yox olur.
- Web tətbiqi sürətli yüklənir, brauzerin öz davranışını (mətn seçimi, `Ctrl+F`,
  çap, açıqlıq alətləri) qoruyur.
- İki komanda bir-birini bloklamadan işləyir.
- Mobil tərəfdəki 301 test və hazır barkod/auth işi saxlanılır.

**Mənfi və risklər.**

- **İki stack saxlanılır.** Dart və TypeScript, iki dəst asılılıq, iki CI axını.
  3 nəfərlik komanda üçün bu real yükdür. Qarşılığı: hər platformada doğma alətlər.
- **Biznes məntiqi iki dəfə yazılır.** Miqdar formatlaşdırması, icazə yoxlamaları,
  sənəd vəziyyət maşınları hər iki tərəfdə təkrarlanır. Bunun qarşısı kontraktın
  sərt saxlanması və hər iki tərəfdə eyni invariant testlərinin yazılması ilə alınır.
- **Atılan iş.** `apps/wms_web` (2 192 sətir) və `packages/features` daxilindəki web
  ekranları yenidən yazılır. Backend, kontraktlar, deploy və sənədlər toxunulmur.
- Flutter `wms_design_system` paketi yalnız mobil üçün qalır; artıq iki platformaya
  deyil, birinə xidmət edir.

## Dəyişməyən qaydalar

Hər iki tətbiqdə eyni qalır və hər ikisində test ilə qorunur:

- Miqdar və məbləğ JSON-da **string**-dir; `double` istifadəsi qadağandır
  (web tərəfdə `decimal.js`, mobil tərəfdə `decimal` paketi) — [ADR-008](ADR-008-decimal-on-client.md).
- İnterfeys dili Azərbaycan dilidir; `toUpperCase()` interfeys mətnində qadağandır.
- `master.product.view_cost` icazəsi olmayan istifadəçiyə qiymət sütunu **render edilmir**,
  maskalanmır.
- Server xətası RFC 7807 formatında, `code` sahəsi görünən şəkildə göstərilir.
- Keycloak OIDC, Authorization Code + PKCE, public client — [ADR-009](ADR-009-keycloak-oidc-pkce.md).
