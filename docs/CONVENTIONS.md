# Layihə konvensiyaları (bütün komponentlər üçün ortaq)

Bu sənəd backend, frontend, deploy və docs arasında **ortaq adlar** və parametrləri təyin edir.
Əsas mənbə: `docs/SPEC-Satinalma-Anbar-Platformasi.md`. Ziddiyyət olarsa SPEC üstündür.

## Repo düzülüşü

```
SASS/
├── backend/            .NET 10 modulyar solution (Wms.slnx)
├── frontend/           Flutter pub-workspace monorepo (apps/ + packages/)
├── contracts/openapi/  OpenAPI 3.1 — modul başına bir fayl (API contract-first)
├── deploy/             docker-compose (dev, on-prem), Dockerfile-lar, k8s, keycloak realm, mysql init
├── docs/               SPEC, ADR-lər, arxitektura diaqramları, bu sənəd
├── scripts/            köməkçi shell skriptləri
└── .github/workflows/  CI
```

## Modullar (SPEC §5) və `--Modules=` adları

| Modul | `--Modules=` adı | Cədvəl prefiksi | Route prefiksi | Konteyner (cloud) | Konteyner portu |
|---|---|---|---|---|---|
| Identity | `identity` | `iam_` | `/api/v1/identity` | `wms-identity` | 8080 |
| MasterData | `masterdata` | `master_` | `/api/v1/masterdata` | `wms-masterdata` | 8080 |
| Inventory | `inventory` | `inv_` | `/api/v1/inventory` | `wms-inventory` | 8080 |
| Procurement | `procurement` | `proc_` | `/api/v1/procurement` | `wms-procurement` | 8080 |
| Documents | `documents` | `doc_` | `/api/v1/documents` | `wms-masterdata` ilə birgə | 8080 |
| Notification | `notification` | `notif_` | `/api/v1/notifications` | `wms-worker` ilə birgə | 8080 |
| Consumption | `consumption` | `cons_` | `/api/v1/consumption` | `wms-inventory` ilə birgə | 8080 |
| Reporting | `reporting` | `rpt_` | `/api/v1/reporting` | `wms-reporting` | 8080 |
| Integration | `integration` | `intg_` | `/api/v1/integration` | `wms-worker` ilə birgə | 8080 |

Ortaq cədvəllər: `common_outbox`, `common_audit_log`, `common_attachment` (SPEC §11).
MySQL-də "şema" = **tək database `wms` + cədvəl prefiksi** (on-prem sadəlik üçün). Modul başına
ayrıca DbContext və ayrıca `Migrations/` qovluğu.

## Backend layihə yolları (Dockerfile və CI bunlara istinad edir)

```
backend/Wms.slnx
backend/global.json                         (.NET 10 SDK)
backend/Directory.Build.props               (net10.0, nullable, TreatWarningsAsErrors)
backend/Directory.Packages.props            (central package management)
backend/src/Host/Wms.Host.Api/Wms.Host.Api.csproj           → API host, ModuleLoader, --Modules=
backend/src/Host/Wms.Host.Migrator/Wms.Host.Migrator.csproj → EF miqrasiyaları (startup-da avtomatik miqrasiya QADAĞANDIR)
backend/src/Gateway/Wms.Gateway/Wms.Gateway.csproj          → YARP
backend/src/BuildingBlocks/Wms.Common.{Domain,Application,Infrastructure,Contracts}/
backend/src/Modules/<Modul>/Wms.<Modul>.{Domain,Application,Infrastructure,Endpoints,Contracts}/
backend/tests/Wms.ArchitectureTests/
backend/tests/Wms.Inventory.UnitTests/
backend/tests/Wms.Inventory.IntegrationTests/
backend/tests/Wms.Api.ContractTests/
```

Host proseslər `dotnet Wms.Host.Api.dll` ilə başlayır, 8080 portunu dinləyir (`ASPNETCORE_URLS=http://+:8080`).
Health: `GET /health/live`, `GET /health/ready`. OpenAPI: `GET /openapi/v1.json` (yalnız Development).

## Backend konfiqurasiya açarları (env var formatı `A__B`)

| Açar | Dev dəyəri (docker-compose) |
|---|---|
| `Modules` | `*` \| `inventory` \| `masterdata,identity,documents` ... |
| `Jobs__Enabled` | `true` yalnız `wms-worker`-də |
| `ModuleTransport` | `InProcess` \| `Http` |
| `ConnectionStrings__Wms` | `Server=mysql;Port=3306;Database=wms;User=wms_app;Password=wms_app;` |
| `ConnectionStrings__WmsMigrator` | `Server=mysql;Port=3306;Database=wms;User=wms_migrator;Password=wms_migrator;` |
| `Redis__ConnectionString` | `redis:6379` |
| `RabbitMq__Host` / `__User` / `__Password` / `__Exchange` | `rabbitmq` / `wms` / `wms` / `wms.events` |
| `Minio__Endpoint` / `__AccessKey` / `__SecretKey` / `__Bucket` | `minio:9000` / `minioadmin` / `minioadmin` / `wms-attachments` |
| `Keycloak__Authority` | `http://keycloak:8080/realms/wms` |
| `Keycloak__Audience` | `wms-api` |
| `Seq__Url` | `http://seq:5341` |
| `Otel__Endpoint` | `http://otel-collector:4317` (opsional) |

## Host portları (docker-compose dev)

| Servis | Host port | Qeyd |
|---|---|---|
| Gateway (YARP) | 5000 | Flutter tətbiqlərinin `API_BASE_URL`-i |
| wms-identity | 5081 | |
| wms-masterdata | 5082 | (+ documents) |
| wms-inventory | 5083 | |
| wms-procurement | 5084 | |
| wms-reporting | 5085 | |
| wms-worker | — | Hangfire dashboard: 5086 |
| Flutter web (nginx) | 3000 | `flutter run -d chrome --web-port 3001` dev üçün |
| MySQL 8.4 | 3306 | db `wms`, root/`wms_root`, `wms_app`/`wms_app`, `wms_migrator`/`wms_migrator` |
| Redis 7 | 6379 | |
| RabbitMQ 4 | 5672 / 15672 | `wms`/`wms` |
| MinIO | 9000 / 9001 | `minioadmin`/`minioadmin`, bucket `wms-attachments` |
| Keycloak 26 | 8080 | admin/`admin`, realm `wms` |
| Seq | 5341 | auth söndürülüb (dev) |

> **Bu maşındakı faktiki portlar.** 5000, 8080 və 3306 portları başqa proseslər tərəfindən
> tutulduğu üçün `deploy/.env` onları əvəz edir: **Gateway 5001**, **Keycloak 8180**,
> **MySQL 3308**. `deploy/.env.example` standart dəyərləri saxlayır; `.env` yalnız bu maşına aiddir.
> Flutter üçün: `--dart-define=API_BASE_URL=http://localhost:5001`
> `--dart-define=KEYCLOAK_ISSUER=http://localhost:8180/realms/wms`.
> Yoxlanılıb (21.09.2026): `keeper` istifadəçisinin access token-i `tenant_id=1`,
> `aud=wms-api`, `realm_access.roles=[WAREHOUSE_KEEPER]` daşıyır.

On-prem profili (`docker-compose.onprem.yml`): tək `wms-api` (`Modules=*`, `Jobs__Enabled=true`) → 5000.

## Keycloak realm `wms`

- Client `wms-web` — public, PKCE, redirect `http://localhost:3000/*`, `http://localhost:3001/*`
- Client `wms-mobile` — public, PKCE, redirect `az.wms.mobile://callback`
- Client `wms-api` — bearer-only audience (access token `aud` = `wms-api`)
- Realm rolları: `ADMIN`, `PROCUREMENT_OFFICER`, `PROCUREMENT_MANAGER`, `WAREHOUSE_KEEPER`, `BRANCH_USER`, `AUDITOR`
- Token claim-ləri: `tenant_id` (user attribute → claim, **məcburi**), `preferred_username`, `realm_access.roles`
- Dev istifadəçiləri (parol = username): `admin`, `procurement`, `manager`, `keeper`, `branch1`, `auditor`; hamısı `tenant_id=1`

## API konvensiyaları (SPEC §13)

- `Idempotency-Key: <GUID>` header — bütün POST-larda məcburi
- Xəta: RFC 7807 `application/problem+json` + `code` sahəsi (`INSUFFICIENT_STOCK`, `LOCATION_FROZEN`, `STALE_VERSION`...)
- Səhifələmə: `{ items, page, size, total }`, max `size=200`
- Bütün miqdar/məbləğ sahələri JSON-da **string** kimi ötürülür (`"qty": "12.5000"`) — Dart-da `decimal` paketi ilə parse edilir, float işlənmir

## Flutter monorepo

```
frontend/pubspec.yaml            pub workspace kökü
frontend/melos.yaml              skriptlər (analyze/test/gen)
frontend/apps/wms_mobile         android+ios, org az.wms  (anbardar, filial)
frontend/apps/wms_web            web, org az.wms          (satınalma, menecer, admin, auditor)
frontend/packages/wms_core            saf Dart: Result/Failure, Quantity/Money (decimal), ProblemDetails
frontend/packages/wms_api_client      dio + interceptor-lar (auth, tenant, idempotency, problem+json), modul API-ləri
frontend/packages/wms_auth            OIDC abstraksiyası, token store, session state
frontend/packages/wms_design_system   tema, tokenlər, ortaq widget-lər, breakpoint-lər
frontend/packages/wms_l10n            az (default), en, ru ARB
frontend/packages/features/feature_{identity,master_data,inventory,procurement,reporting,notifications}
```

- State: Riverpod 3. Routing: go_router. HTTP: dio. Decimal: `decimal`. Codegen: freezed + json_serializable (build_runner).
- Hər feature: `lib/src/{data,domain,presentation}/`, `lib/src/routes.dart`, barrel `lib/<feature>.dart`.
- Env: `--dart-define=API_BASE_URL=http://localhost:5000 --dart-define=KEYCLOAK_ISSUER=http://localhost:8080/realms/wms --dart-define=KEYCLOAK_CLIENT_ID=wms-web|wms-mobile`
- Mobile deep link scheme: `az.wms.mobile`.

## Consumption modulu (filial istehlakı)

Qərar: [ADR-012](adr/ADR-012-branch-consumption-model.md) · Dizayn:
[architecture/branch-operations.md](architecture/branch-operations.md).

SPEC §20.1-dəki bloklayıcı açıq qərar həll olunub: filial istehlakı **resept əsaslı
nəzəri məxaric** ilə modelləşdirilir, satış məlumatı `POS` | `CSV` | `MANUAL`
mənbələrinin birindən gəlir.

- Modul `Consumption`, şema prefiksi `cons_`, `--Modules=consumption`.
  Cloud profilində ayrıca konteyner açılmır, `wms-inventory` ilə birgə deploy olunur
  (istehlak mühərriki Inventory-yə sıx bağlıdır və eyni gündəlik cədvəldə işləyir).
- Asılılıqlar: `Wms.MasterData.Contracts` (məhsul, lokasiya, vahid əmsalı, nömrə seriyası)
  və `Wms.Inventory.Contracts` (qalıq oxuma + sənəd post etmə). Birbaşa `inv_` cədvəllərinə
  müraciət **yoxdur**.
- Yeni ENUM dəyərləri: `master_location.location_type` → `V_CONSUMPTION`;
  `inv_movement_group.doc_type` → `CONSUMPTION`.
- Sənəd nömrəsi: `CN-{YYYY}-{00000}` (`master_number_sequence`, doc_type `CONSUMPTION`).
- İcazələr: `cons.recipe.manage`, `cons.recipe.view`, `cons.sales.import`,
  `cons.run.calculate`, `cons.run.post`, `cons.variance.view`.
- Hadisələr: `SalesImported`, `ConsumptionPosted`, `ConsumptionShortfallDetected`,
  `SalesItemUnmapped`.
- Job-lar: `ConsumptionRunner` (gündəlik 03:00, özünüyoxlama job-larından sonra),
  `SalesImportReminder` (gündəlik 11:00).
- Flutter feature paketi: `frontend/packages/features/feature_consumption`.

## Dizayn sistemi

İnterfeysin mənbəyi: **WMS Enterprise** dizayn sistemi (Claude Artifact, namespace `Wms`),
repoda `docs/design-system/` altında güzgülənib.

| Fayl | Nədir |
|---|---|
| `docs/design-system/tokens.json` | 28 rəng tokeni (light/dark), 11 mətn stili, spacing/radius/shadow/opacity |
| `docs/design-system/README.md` | Brend kitabı: dil, rəqəm formatı, rəng semantikası, əlçatanlıq |
| `docs/design-system/components/bundle.css` | Komponentlərin dəqiq ölçüləri (padding, min-height, sərhəd) |
| `docs/design-system/components/index.d.ts` | Komponent API-si (proplar) |
| `docs/design-system/components/<Ad>/README.md` | 14 komponent üzrə istifadə qaydaları |
| `docs/design-system/FLUTTER-MAPPING.md` | Bunların `wms_design_system` paketinə köçürülmə qaydası |

Qaydalar:

- Token dəyərləri **hərfi** köçürülür, təxmin edilmir. Dəyişiklik axını: artifact →
  `docs/design-system/` → Dart tokenləri.
- İnterfeys dili Azərbaycan dilidir; `toUpperCase()` interfeys mətnində **qadağandır**
  (`i` → `I` çevrilməsi səhvdir). Emoji işlədilmir.
- Rəqəm formatı: onluq ayırıcı vergül, min ayırıcı dar boşluq (U+202F), mənfi işarə
  U+2212. Bütün rəqəmlər mono ailə + tabular figures.
- Status yalnız `WmsDocStatusBadge` ilə, miqdar yalnız `WmsQtyUomInput` ilə, server xətası
  yalnız `WmsAlert` (RFC 7807) ilə göstərilir.
- `master.product.view_cost` icazəsi olmayan istifadəçiyə qiymət sütunu **render edilmir**
  (maskalanmır) — server sahəni JSON-dan çıxarır, interfeys sütunu qurmur.

## Ümumi qaydalar

- Git commit **edilmir** (istifadəçi özü commit edəcək).
- Müvəqqəti fayllar yalnız scratchpad-də.
- Sənədlər Azərbaycan dilində, kod və kod şərhləri ingilis dilində.
