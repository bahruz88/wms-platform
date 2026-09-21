# ADR-006: Flutter monorepo — iki tətbiq qabığı, ortaq feature paketləri

> **⚠️ ƏVƏZ EDİLİB — 21.09.2026.** Bu qərar [ADR-013](ADR-013-web-react-mobile-flutter.md)
> ilə əvəz olunub: web React + TypeScript-ə keçdi, mobil Flutter olaraq qaldı.
> Aşağıdakı mətn tarixi qeyd kimi saxlanılır.

**Status:** Əvəz edilib (ADR-013)
**Əlaqəli:** [CONVENTIONS → Frontend: iki stack, bir kontrakt](../CONVENTIONS.md), [ADR-007](ADR-007-contract-first-openapi.md), [ADR-011](ADR-011-design-system.md)

## Kontekst

Platformanın iki tamamilə fərqli istifadə profili var:

- **Mobil** — anbardar və filial işçisi. Ayaq üstə, bir əllə, anbar işığında, barkod skan
  edərək işləyir. Ekranda bir anda bir sənəd olur; əsas əməliyyatlar qəbul, filial təsdiqi,
  sayım, tullantı (fotolu).
- **Veb** — satınalma mütəxəssisi, menecer, admin, auditor. Masaüstü, klaviatura, geniş ekran.
  Əsas iş çoxsütunlu cədvəllər (təkliflərin müqayisəsi, ledger, hesabatlar), paralel pəncərələr,
  Excel export.

Bu iki profil eyni domenlə işləyir (eyni API, eyni model, eyni invariantlar), lakin naviqasiya,
ekran tərkibi və hətta hansı sahələrin göstərildiyi fərqlidir (anbardar qiymət görmür).
Sual: bir responsiv tətbiq, iki ayrı repo, yoxsa bir monorepo + iki qabıq?

## Qərar

**Bir Flutter pub-workspace monorepo, iki tətbiq qabığı (`apps/wms_mobile`, `apps/wms_web`),
ortaq feature paketləri.**

```
frontend/
├── pubspec.yaml                  pub workspace kökü (Melos 7 scripts)
├── apps/wms_mobile               android + ios qabığı  → anbardar, filial
├── apps/wms_web                  web qabığı            → satınalma, menecer, admin, auditor
└── packages/
    ├── wms_core                  saf Dart: Result/Failure, Quantity/Money (decimal), ProblemDetails
    ├── wms_api_client            dio + interceptor-lar, generasiya olunmuş client-in fasadı
    ├── wms_auth                  OIDC abstraksiyası, token store, sessiya
    ├── wms_design_system         tema, tokenlər, ortaq widget-lər (ADR-011)
    ├── wms_l10n                  az (default), en, ru ARB
    └── features/feature_*        domen məntiqi + ekranlar, platformadan asılı olmayan
```

Qabıq **nazikdir**: `main.dart`, `go_router` konfiqurasiyası, platforma icazələri
(kamera, bildiriş), tema seçimi və hansı feature route-larının qeydiyyata alınması.
Bütün data/domen qatı və ekranların özəyi feature paketlərindədir. Platforma fərqi olan
ekran üçün feature paketi `presentation/mobile/` və `presentation/web/` alt qovluqları
saxlayır və qabıq hansının bağlanacağını seçir — `if (kIsWeb)` şaxələnməsi ekran kodunun
içində yazılmır.

Stack: **Riverpod 3** (state), **go_router** (routing), **dio** (HTTP), **decimal** (rəqəm),
freezed + json_serializable (codegen).

## Nəzərdən keçirilən alternativlər

**(a) Bir responsiv tətbiq (tək `MaterialApp`, breakpoint-lərlə).**
Rədd edildi. Fərq yalnız ekran enində deyil: naviqasiya modeli (mobil — tapşırıq axını,
bottom nav; veb — sidebar + çoxsəviyyəli cədvəllər), giriş üsulu (skan vs klaviatura),
platforma asılılıqları (kamera, push, deep link `az.wms.mobile://` vs brauzer redirect) və
rol dəsti ayrıdır. Bir tətbiqdə bu `if (isMobile)` şaxələnmələrinə çevrilir; veb build-inə
kamera/push paketləri, mobil build-ə isə heç vaxt açılmayan cədvəl ekranları daxil olur.
Bundan əlavə mobil tətbiq mağazaya ayrıca göndərilir və öz release ritmi olmalıdır.

**(b) İki ayrı repo.**
Rədd edildi. Ortaq kod (domen modelləri, `Decimal` çevirməsi, API client, dizayn sistemi,
lokalizasiya) hər iki tərəfdə lazımdır. Ayrı repo bunu ya kopyalamağa, ya da erkən mərhələdə
private pub registry qurmağa məcbur edir. 1–3 nəfərlik komanda üçün ikisi də əlavə yükdür:
kontrakt dəyişəndə iki repo, iki PR, iki CI, versiya uyğunsuzluğu riski. Monorepoda
`make gen-client` bir dəfə işləyir və hər iki qabıq eyni anda yenilənir.

## Nəticələr

- Bir `flutter pub get` (workspace kökündə) bütün paketləri bağlayır; `melos run analyze`
  və `melos run test` hamısını əhatə edir.
- CI iki build artefaktı verir: `flutter build web` (wms_web) və `flutter build apk` (wms_mobile).
- Feature paketi **qabıqdan asılı ola bilməz** (yalnız əks istiqamət) — bu qayda review-də
  yoxlanılır; pozuntu dairəvi asılılıq kimi özünü göstərir.
- Rol → qabıq bölgüsü sərt deyil: menecer mobil tətbiqdə təsdiq verə bilir (`listPendingApprovals`),
  anbardar vebdə cədvələ baxa bilir. Bölgü **optimallaşdırmadır**, məhdudiyyət deyil;
  icazə yoxlaması həmişə serverdədir.
- Qarşılığında: iki qabıq iki `main.dart`, iki icon/splash dəsti, iki dart-define dəsti deməkdir —
  bu təkrar şüurlu qəbul edilir və `README.md`-də sənədləşdirilir.
