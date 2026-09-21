# WMS Flutter monorepo (frontend)

Satınalma və Anbar İdarəetmə Platformasının interfeys hissəsi: **pub workspace**
(Dart 3.13 / Flutter 3.47) daxilində iki tətbiq və on paylaşılan paket.

Əsas sənədlər: [`docs/SPEC-Satinalma-Anbar-Platformasi.md`](../docs/SPEC-Satinalma-Anbar-Platformasi.md),
[`docs/CONVENTIONS.md`](../docs/CONVENTIONS.md), [`docs/design-system/`](../docs/design-system/).

## Quruluş

```
frontend/
├── pubspec.yaml                  pub workspace kökü (+ melos konfiqurasiyası)
├── melos.yaml                    skriptlərin sənədləşməsi (melos 7 pubspec-dən oxuyur)
├── analysis_options.yaml         bütün paketlərin daxil etdiyi lint dəsti
├── apps/
│   ├── wms_mobile/               Android + iOS — anbardar və filial istifadəçisi
│   │                             (mobile_scanner barkod, image_picker foto)
│   └── wms_web/                  Web — satınalma, menecer, admin, auditor
│                                 (OIDC /callback, admin ekranları)
└── packages/
    ├── wms_core/                 saf Dart: Result/Failure, Quantity/Money (decimal),
    │                             ProblemDetails, Page, enum-lar, Permissions, AppEnv,
    │                             CrashReporter
    ├── wms_api_client/           dio + interceptor-lar, modul API-ləri (documents daxil),
    │                             freezed DTO-lar, AttachmentPolicy
    ├── wms_auth/                 Session, JwtParser, TokenStore, AuthGuard, provider-lər,
    │                             PKCE/callback/silent-refresh primitivləri
    ├── wms_design_system/        «WMS Enterprise» dizayn sistemi (token + 15 komponent)
    ├── wms_l10n/                 az (defolt), en, ru ARB + generasiya olunmuş sinif
    └── features/
        ├── feature_identity/     giriş, profil, RequirePermission, admin (istifadəçi/rol)
        ├── feature_master_data/  məhsul, təchizatçı, lokasiya, UoM
        ├── feature_inventory/    qalıq, qəbul, tələb, məxaric/transfer, sayım, tullantı,
        │                         nümunə, əlavələr, inv_setting
        ├── feature_procurement/  PR, RFQ, təklif müqayisəsi, PO təsdiqi, qiymət tarixçəsi
        ├── feature_reporting/    dashboard, hesabat siyahısı, export
        └── feature_notifications/ bildiriş siyahısı, oxunmamış sayğacı
```

Hər feature paketi eyni qatlara bölünür:

```
lib/feature_x.dart          barrel — yalnız bu fayl ixrac edir
lib/src/domain/             repository interfeysləri (saf, Flutter-siz məntiq)
lib/src/data/               API-yə bağlı implementasiyalar
lib/src/presentation/       ekranlar + Riverpod provider-ləri
lib/src/navigation.dart     route adları və yolları (sabitlər)
lib/src/routes.dart         `List<RouteBase> xRoutes()`
```

## İlkin quraşdırma

```sh
cd frontend
flutter pub get          # bütün workspace üzvlərini bir dəfəyə həll edir
dart pub global activate melos   # (opsional) melos skriptləri üçün
```

## Tətbiqlərin işə salınması

Dev mühiti `deploy/.env` ilə gəlir: gateway **5001**, Keycloak **8180**
(5000/8080 bu maşında məşğuldur). Dəyərlər `--dart-define` ilə override edilir.

Web (Chrome, **3001 portu məcburidir** — Keycloak redirect siyahısındadır):

```sh
cd apps/wms_web
flutter run -d chrome --web-port 3001 \
  --dart-define=API_BASE_URL=http://localhost:5001 \
  --dart-define=KEYCLOAK_ISSUER=http://localhost:8180/realms/wms \
  --dart-define=KEYCLOAK_CLIENT_ID=wms-web \
  --dart-define=FLAVOR=dev
```

> Veb tətbiq **path URL strategiyası** ilə işləyir (`#` yoxdur), çünki OAuth redirect
> URI-də fraqment ola bilməz. Redirect URI işlədiyi origin-dən hesablanır:
> `http://localhost:3001/callback`. Statik server naməlum yolları `index.html`-ə
> yönləndirməlidir (`deploy/docker/nginx.conf` → `try_files $uri $uri/ /index.html`).

Mobil (Android emulyator / iOS simulyator):

```sh
cd apps/wms_mobile
flutter run \
  --dart-define=API_BASE_URL=http://localhost:5001 \
  --dart-define=KEYCLOAK_ISSUER=http://localhost:8180/realms/wms \
  --dart-define=KEYCLOAK_CLIENT_ID=wms-mobile \
  --dart-define=FLAVOR=dev
```

> Android emulyatorundan host maşına `10.0.2.2` ilə müraciət edilir:
> `--dart-define=API_BASE_URL=http://10.0.2.2:5001`.

Release web build:

```sh
cd apps/wms_web
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.example.az \
  --dart-define=KEYCLOAK_ISSUER=https://auth.example.az/realms/wms \
  --dart-define=KEYCLOAK_CLIENT_ID=wms-web \
  --dart-define=FLAVOR=prod
```

Dev istifadəçiləri (parol = ad): `admin`, `procurement`, `manager`, `keeper`,
`branch1`, `auditor` — hamısı `tenant_id=1`.

Mobil deep link sxemi `az.wms.mobile`, redirect və **post-logout redirect**
`az.wms.mobile://callback` (`android/app/build.gradle.kts` → `manifestPlaceholders`,
`ios/Runner/Info.plist` → `CFBundleURLTypes`; realm tərəfi
`deploy/keycloak/*.json` → `post.logout.redirect.uris`).

Mobil tətbiq kamera icazəsi istəyir: Android `CAMERA` (`AndroidManifest.xml`),
iOS `NSCameraUsageDescription` (`Info.plist`). İcazə verilməsə skan ekranı səbəbi
`WmsAlert` ilə yazır və əl ilə daxiletmə açıq qalır.

## Kod generasiyası və lokalizasiya

```sh
# freezed + json_serializable (wms_api_client)
cd packages/wms_api_client && dart run build_runner build
# və ya kökdən:
dart run melos run gen

# ARB → AppLocalizations (nəticə lib/src/generated/ altında commit edilir)
cd packages/wms_l10n && flutter gen-l10n
# və ya kökdən:
dart run melos run l10n
```

Generasiya olunmuş fayllar (`*.g.dart`, `*.freezed.dart`, `app_localizations*.dart`)
repoda saxlanılır — `flutter analyze` əlavə addım tələb etmədən təmiz işləməlidir.

## Test və analiz

```sh
cd frontend
flutter analyze                 # workspace üzrə: "No issues found!"
dart run melos run test         # bütün paket və tətbiqlərin testləri
dart run melos run format       # dart format --set-exit-if-changed .
```

Ayrıca bir paketi yoxlamaq üçün:

```sh
cd packages/wms_core && dart test
cd packages/wms_design_system && flutter test
```

## Konvensiyalar

### 1. Decimal qaydası (pozulması buqdur)

Miqdar və məbləğ **heç vaxt `double` deyil**. `wms_core`-dakı `Quantity` və `Money`
`Decimal` üzərində qurulub; JSON-da string kimi gedir (`"12.5000"`), yuvarlaqlaşdırma
`AwayFromZero`-dur (backend ilə eyni). Qayda
`packages/wms_core/test/no_double_rule_test.dart` testi ilə tətbiq olunur: test
`wms_core`, `wms_api_client`, `wms_auth` və bütün feature paketlərinin `lib/`
qovluqlarını skan edir və `double` sözünə rast gələndə uğursuz olur.

### 2. Dizayn sistemi

Rənglər, tipoqrafiya, ölçülər `docs/design-system/tokens.json` və
`components/bundle.css` fayllarından **hərfi** köçürülüb; dəyərlərin uyğunluğu
`wms_design_system/test/tokens_test.dart` ilə yoxlanılır (JSON diskdən oxunur).

Ekranlarda Material widget-ləri deyil, sistem komponentləri işlədilir:

| Nə lazımdır | Komponent |
|---|---|
| Miqdar daxiletməsi | `WmsQtyUomInput` (base UoM ekvivalenti + mənfi qadağası) |
| Fayl/foto əlavəsi | `AttachmentUploadField` (presign → PUT → complete, progress) |
| Sənəd/partiya statusu | `WmsDocStatusBadge` (öz badge-ini yazmaq qadağandır) |
| Cədvəl | `WmsDataTable` (`permission` verilmiş sütun render edilmir) |
| Server xətası (RFC 7807) | `WmsAlert.fromProblem` / `WmsAlert.fromFailure` |
| Ledger sətirləri | `WmsLedgerTable` (işarə + sıfır cəmi yoxlanışı) |
| Sayım fərqi | `WmsVarianceIndicator` |
| Partiya seçimi | `WmsBatchPicker` (FEFO təklifi nişanlanır) |
| Təsdiq zənciri | `WmsApprovalChain` |
| Dashboard göstəricisi | `WmsKpiCard` |
| Modal | `WmsDialog` / `WmsConfirmDialog` |

Dəyişməz qaydalar: interfeys mətni Azərbaycan dilindədir və **böyük hərfə
çevrilmir** (`i` → `I` səhvdir), emoji işlədilmir, rəng tək başına məna daşımır,
balans heç bir ekranda input deyil, qiymət sütunları `master.product.view_cost`
icazəsinə bağlıdır (maskalamaq yox — sütun ümumiyyətlə render edilmir).

### 3. Rəqəm formatı

`WmsFormat`: onluq ayırıcı vergül, min ayırıcı dar boşluq (U+202F), mənfi işarə
U+2212, tarix `dd.MM.yyyy`, vaxt `dd.MM.yyyy HH:mm`. Onluq sayı məhsulun
`base_uom.decimals` dəyərindən gəlir, sabit yazılmır.

### 4. API

Bütün sorğular `WmsApiClient` üzərindən gedir: `AuthInterceptor` (bearer + 401-də
bir dəfə refresh), `IdempotencyInterceptor` (POST-lara `Idempotency-Key`),
`ProblemDetailsInterceptor` (`application/problem+json` → `ProblemDetails` →
`Failure`), `LoggingInterceptor` (yalnız debug). Repository-lər `Result<T>`
qaytarır — biznes xətası üçün exception atılmır.

**Fayl əlavələri** (`documents.v1.yaml`) API-dən keçmir: `DocumentsApi.presign` →
`uploadBytes` (birbaşa MinIO-ya `PUT`, `onProgress` ilə) → `complete`. Presigned
sorğu üçün ayrıca, interceptor-suz `storageClient` işlədilir ki, bearer token və
`Idempotency-Key` obyekt saxlancına düşməsin. Client tərəfdə `AttachmentPolicy`
25 MB limitini və icazəli MIME siyahısını yoxlayır; ekranlarda
`AttachmentUploadField` + `attachmentUploadProvider` işlənir.

### 4.1. Autentifikasiya

| Platforma | Axın |
|---|---|
| Web | `KeycloakAuthWeb` — Authorization Code + PKCE (S256). `state` və code verifier `sessionStorage`-də saxlanılır, `/callback` route-u mübadiləni tamamlayır, sessiya `SecureTokenStore`-a yazılır (səhifə yenilənəndə itmir), `SilentRefreshScheduler` token bitməzdən 1 dəqiqə əvvəl yeniləyir. |
| Mobil | `KeycloakAuthMobile` — `flutter_appauth` ilə Authorization Code + PKCE; çıxış RP-initiated logout-dur (`id_token_hint`, yoxdursa `client_id`). |

Brauzerə toxunan yeganə fayl `apps/wms_web/lib/auth/window_browser.dart`-dır;
qalan məntiq `Browser` interfeysinin arxasındadır və VM testləri ilə örtülüb.

### 4.2. Xəta bildirişi

`FlutterError.onError`, `PlatformDispatcher.onError` və mühafizə olunan zona tək bir
`CrashReporter` (wms_core) interfeysinə yönləndirilib. Defolt `LoggingCrashReporter`-dir;
Sentry/Crashlytics əlavə etmək üçün yalnız `bootstrap()`-da başqa implementasiya
verilir — çağırış yerləri dəyişmir.

### 5. Yeni ekran necə əlavə olunur

1. Lazımdırsa `wms_api_client`-ə DTO və metod əlavə et, `build_runner` işlət.
2. Feature paketində `domain/` interfeysini genişləndir, `data/`-da tətbiq et.
3. `presentation/` altında ekranı və provider-i yaz (yalnız dizayn sistemi widget-ləri).
4. `navigation.dart`-a route adı/yolu, `routes.dart`-a `GoRoute` əlavə et.
5. Ekran naviqasiyada görünməlidirsə uyğun app-ın `router/app_router.dart`
   faylındakı shell branch-inə əlavə et.
6. Test yaz: icazə davranışı, məcburi sahələr və format ən azı bir testlə örtülməlidir.

### 6. Ümumi

- Sənədlər Azərbaycan dilində, kod və kod şərhləri ingilis dilində.
- Git commit avtomatik edilmir.
- Müvəqqəti fayllar repoya düşmür.
