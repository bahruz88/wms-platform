# WMS Backend — .NET 10 modulyar monolit

Satınalma və Anbar İdarəetmə Platformasının backend-i. Mənbə sənədlər:
[`docs/SPEC-Satinalma-Anbar-Platformasi.md`](../docs/SPEC-Satinalma-Anbar-Platformasi.md) (texniki icra) və
[`docs/CONVENTIONS.md`](../docs/CONVENTIONS.md) (ortaq adlar).

**Bir solution, bir image, modul üzrə deployment** (ADR-001): eyni `Wms.Host.Api` həm tək konteynerdə
bütün modullarla (on-prem), həm də modul başına ayrıca konteynerlə (cloud) işləyir.

---

## 1. Tez başlanğıc

Lokal `dotnet` SDK tələb olunmur — hər şey Docker-də işləyə bilər.

> ⚠️ **Repo kökünü mount edin, yalnız `backend/`-i yox.** `.editorconfig` repo kökündədir və
> `EnforceCodeStyleInBuild` sayəsində build-in bir hissəsidir. Yalnız `backend/` mount edilsə o fayl
> konteynerdə olmur, kod stili qaydaları heç işləmir və build lokalda yaşıl, CI-da qırmızı görünür —
> backend workflow-unun heç vaxt keçməməsinin səbəbi məhz bu idi (§8.19).

```bash
cd "$(git rev-parse --show-toplevel)"

# Build (Release, TreatWarningsAsErrors=true) — CI-dakı əmrin eynisi
docker run --rm -v "$PWD":/repo -w /repo/backend mcr.microsoft.com/dotnet/sdk:10.0 \
  dotnet build Wms.slnx -c Release -warnaserror

# Unit + arxitektura + contract testləri (integration testlər kənarda)
docker run --rm -v "$PWD":/repo -w /repo/backend mcr.microsoft.com/dotnet/sdk:10.0 \
  dotnet test Wms.slnx -c Release --filter "FullyQualifiedName!~IntegrationTests"

# Integration testlər (Testcontainers — real MySQL 8.4 konteyneri qaldırır)
docker run --rm -v "$PWD":/repo \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e TESTCONTAINERS_RYUK_DISABLED=true \
  -e TESTCONTAINERS_HOST_OVERRIDE=host.docker.internal \
  --add-host=host.docker.internal:host-gateway \
  -w /repo/backend mcr.microsoft.com/dotnet/sdk:10.0 \
  dotnet test Wms.slnx -c Release --filter "FullyQualifiedName~IntegrationTests"
```

> `TESTCONTAINERS_HOST_OVERRIDE` yalnız testləri **SDK konteynerinin içindən** işlədəndə lazımdır:
> Testcontainers MySQL portunu **host-un** loopback-inə map edir, SDK konteynerinin `127.0.0.1`-i isə
> başqadır. Lokal SDK ilə (`dotnet test tests/Wms.Inventory.IntegrationTests`) bu dəyişənlər lazım deyil.

NuGet paketlərini təkrar yükləməmək üçün cache-i mount edin:
`-v "$HOME/.nuget/packages":/root/.nuget/packages`. Eyni iş qovluğunda paralel build-lər `obj/`-də
toqquşur — hər birinə `-p:ArtifactsPath=/artifacts` verib ayrı qovluq mount edin.

Lokal SDK varsa eyni əmrlər birbaşa işləyir:

```bash
dotnet build Wms.slnx -c Release
dotnet test  Wms.slnx -c Release --filter "Category!=Integration"
dotnet run --project src/Host/Wms.Host.Api
```

### Bütün stack-i konteynerdə qaldırmaq

```bash
scripts/dev-up.sh                 # infra: mysql, redis, rabbitmq, minio, keycloak, seq
scripts/db-migrate.sh             # migrator image-ini build edir, miqrasiyaları tətbiq edir, ledger grant-larını verir
# backend servisləri (web olmadan; web web/ (React) tərəfindən build olunur):
docker compose --project-directory deploy -f deploy/docker-compose.yml \
  --profile infra --profile app up -d --build \
  gateway wms-identity wms-masterdata wms-inventory wms-procurement wms-reporting wms-worker
# hər şey birlikdə (web daxil):
scripts/dev-up.sh --app
```

Yoxlama:

```bash
curl -s localhost:5001/health/live                      # gateway  (bu maşında 5001, default 5000)
curl -s localhost:5083/health/ready | jq                # mysql + redis + rabbitmq vəziyyəti
TOKEN=$(scripts/keycloak-token.sh keeper)
curl -s -H "Authorization: Bearer $TOKEN" localhost:5001/api/v1/inventory/balances | jq
```

Portlar və parollar `deploy/.env`-dədir (`deploy/README.md` §1). Bu maşında gateway **5001**,
Keycloak **8180**, MySQL **3308**.

---

## 2. Solution strukturu

```
backend/
├── Wms.slnx                       XML solution formatı (.NET 10)
├── global.json                    SDK 10.0.x, rollForward=latestFeature
├── Directory.Build.props          net10.0, nullable, TreatWarningsAsErrors, BannedApiAnalyzers
├── Directory.Packages.props       central package management
├── BannedSymbols.txt              System.Double və System.Single qadağandır (SPEC Əlavə A)
├── src/
│   ├── BuildingBlocks/            Wms.Common.{Domain,Application,Infrastructure,Contracts}
│   ├── Modules/<Modul>/           Wms.<Modul>.{Domain,Application,Infrastructure,Endpoints,Contracts}
│   ├── Host/Wms.Host.Api          API host, ModuleLoader/ModuleRegistry
│   ├── Host/Wms.Host.Migrator     EF miqrasiyaları (startup-da avtomatik miqrasiya YOXDUR)
│   └── Gateway/Wms.Gateway        YARP
└── tests/                         ArchitectureTests, Inventory.{Unit,Integration}Tests,
                                   Consumption.{Unit,Integration}Tests, Api.ContractTests
```

`.editorconfig` repo kökündədir və burada təkrarlanmır.

---

## 3. Modul yükləmə

`Modules` konfiqurasiya açarı hansı modulların qalxacağını təyin edir (SPEC §4.1):

```bash
dotnet run --project src/Host/Wms.Host.Api --Modules=inventory --ModuleTransport=Http
dotnet run --project src/Host/Wms.Host.Api --Modules=masterdata,identity
dotnet run --project src/Host/Wms.Host.Api --Modules='*'          # on-prem: tək konteyner
```

| Modul | `--Modules=` | Cədvəl prefiksi | Route | DbContext |
|---|---|---|---|---|
| Identity | `identity` | `iam_` | `/api/v1/identity` | `IdentityDbContext` |
| MasterData | `masterdata` | `master_` | `/api/v1/masterdata` | `MasterDataDbContext` |
| Inventory | `inventory` | `inv_` | `/api/v1/inventory` | `InventoryDbContext` |
| Consumption | `consumption` | `cons_` | `/api/v1/consumption` | `ConsumptionDbContext` |
| Procurement | `procurement` | `proc_` | `/api/v1/procurement` | `ProcurementDbContext` |
| Documents | `documents` | `doc_` | `/api/v1/documents` | `DocumentsDbContext` |
| Notification | `notification` | `notif_` | `/api/v1/notifications` | `NotificationDbContext` |
| Reporting | `reporting` | `rpt_` | `/api/v1/reporting` | `ReportingDbContext` |
| Integration | `integration` | `intg_` | `/api/v1/integration` | `IntegrationDbContext` |

- Naməlum modul adı → proses **dərhal dayanır** (fail fast).
- Hər modul ən azı bir real GET endpoint verir (`/ping`) və bütün route qrupu `RequireAuthorization()` altındadır.

### Modullararası çağırış (`ModuleTransport`)

`*.Contracts` interfeyslərinin **iki** implementasiyası var (SPEC §4.2):

| `ModuleTransport` | Davranış |
|---|---|
| `InProcess` (default) | Contracts eyni prosesdəki modulun Infrastructure-dan həll olunur |
| `Http` | Yüklənməmiş modulların contracts-ları `ModuleEndpoints:<Modul>` ünvanına typed `HttpClient` ilə bağlanır; çağıranın bearer token-i ötürülür |

**Vacib:** qismən deployment (`Modules=inventory`) `ModuleTransport=Http` tələb edir, çünki Inventory
`MasterData.Contracts`-a bağlıdır. `InProcess` ilə belə konfiqurasiya startup-da **aydın mesajla** dayanır
(anlaşılmaz DI xətası əvəzinə) — `ModuleRegistry.MissingDependencies` bunu yoxlayır.

İcazəli asılılıqlar (SPEC §5 + ADR-012, arxitektura testi ilə qorunur):
`MasterData → Identity.Contracts`, `Inventory → MasterData.Contracts`,
`Consumption → MasterData.Contracts + Inventory.Contracts`,
`Procurement → MasterData.Contracts + Inventory.Contracts`, qalanları — heç nə.

`Consumption` cloud profilində ayrıca konteyner almır: `wms-inventory` onu `Modules=inventory,consumption`
ilə birgə qaldırır (ADR-012), gateway isə `/api/v1/consumption` route-unu həmin konteynerə yönəldir.

---

## 4. Konfiqurasiya

Açarlar CONVENTIONS.md-dəki adlarla eynidir (env var formatı `A__B`):

| Açar | Təyinat |
|---|---|
| `Modules` | `*` \| `inventory` \| `masterdata,identity` … |
| `ModuleTransport` | `InProcess` \| `Http` |
| `ModuleEndpoints__<Modul>` | `Http` transport üçün uzaq modulun ünvanı |
| `Jobs__Enabled` | Hangfire server + `/hangfire` dashboard (yalnız `wms-worker`) |
| `Jobs__Storage` | `MySql` (default) \| `InMemory` (dev) |
| `ConnectionStrings__Wms` | runtime istifadəçisi (`wms_app`) |
| `ConnectionStrings__WmsMigrator` | miqrasiya istifadəçisi (`wms_migrator`) |
| `Redis__ConnectionString`, `RabbitMq__*`, `Minio__*` | infrastruktur |
| `Keycloak__Authority`, `Keycloak__Audience` | JWT bearer |
| `Keycloak__ValidIssuers__0…` | yalnız lazım olduqda: discovery sənədindəki `issuer` token-dəki `iss`-dən fərqlənirsə |
| `InternalApi__Key` | **məcburi** — modullararası `/internal/*` marşrutlarının ortaq sirri (§8.15). Hər konteynerdə eyni dəyər; `ModuleTransport=Http` ilə host bu açar olmadan **qalxmır** |
| `PrincipalCache__TtlSeconds` | default `30` — `iam_user` + icazə + lokasiya snapshot-unun yaşı (§8.16). Identity-dəki yazılar entry-ni dərhal invalidasiya edir |
| `Minio__PublicEndpoint` | brauzerin gördüyü MinIO ünvanı; presigned URL məhz bu host üçün imzalanır (default: `Minio__Endpoint`) |
| `Antivirus__Enabled` / `__Host` / `__Port` / `__TimeoutSeconds` | ClamAV (SPEC §11). Dev-də `false`; `true` olduqda əlçatmaz clamd yükləməni **fail-closed** dayandırır (`503 VIRUS_SCAN_UNAVAILABLE`) |
| `Seq__Url`, `Otel__Endpoint` | log və telemetriya |
| `RateLimiting__PermitPerMinute` | default `100` req/dəq/istifadəçi |

`appsettings.Development.json` bütün host adlarını `localhost`-a yönəldir.
`appsettings.json`-da sirr saxlanılmır (SPEC §16) — dəyərlər boşdur, env var ilə verilir.

> ⚠️ Konteynerdə də `ASPNETCORE_ENVIRONMENT=Development` işlədilir (OpenAPI, `RequireHttpsMetadata=false`),
> ona görə `appsettings.Development.json`-dakı `localhost` ünvanları **env var ilə üzərinə yazılmalıdır**.
> `deploy/docker-compose.yml` bunu edir: `ModuleEndpoints__*` (API host-ları) və
> `ReverseProxy__Clusters__*__Destinations__d1__Address` (gateway). Əks halda modullararası HTTP çağırışları
> və bütün gateway route-ları konteyner daxilində `localhost:508x`-ə gedib 502 verir.

> ⚠️ Env var ilə üzərinə yazıla bilən **hər konfiqurasiya açarı yalnız `[A-Za-z0-9_]` simvollarından**
> ibarət olmalıdır: image entrypoint-i `/bin/sh` (dash) skriptidir və dash uşaq prosesin mühitini öz
> dəyişən cədvəlindən qurur — adı düzgün shell identifikatoru olmayan dəyişənləri **səssizcə atır**.
> Bax §8.7.

**Keycloak issuer (yoxlanılıb, xüsusi hal lazım deyil).** Dev-də `KC_HOSTNAME=http://localhost:${KEYCLOAK_PORT}`
+ `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true` verilib. Nəticədə `http://keycloak:8080/realms/wms/.well-known/openid-configuration`
sənədi `issuer: http://localhost:8180/realms/wms` (frontend URL — token-dəki `iss` ilə eyni), amma
`jwks_uri: http://keycloak:8080/...` (konteyner şəbəkəsindən əlçatan) qaytarır. `JwtBearerHandler`
`ValidIssuer`-i məhz discovery sənədindən götürdüyü üçün `Keycloak__Authority=http://keycloak:8080/realms/wms`
ilə issuer uyğunsuzluğu **yaranmır** (21.09.2026-da real token ilə yoxlanılıb: 200).
Əgər gələcəkdə Keycloak konfiqurasiyası dəyişib uyğunsuzluq yaranarsa, `ValidateIssuer`-i söndürmək
əvəzinə `Keycloak__ValidIssuers__0=<public issuer>` verilməlidir (`AddAuthentication` bunu dəstəkləyir).

### Endpoint-lər

- `GET /health/live` — heç bir infrastrukturdan asılı deyil
- `GET /health/ready` — MySQL, Redis, RabbitMQ yoxlanılır; biri düşəndə **503** + JSON hesabat
  (Gateway-də hər iki endpoint var, amma o, stateless proxy olduğu üçün `ready` infrastruktur yoxlaması
  daşımır — `deploy/k8s/base/deployment-gateway.yaml` readinessProbe-u məhz `/health/ready`-yə vurur)
- `GET /openapi/v1.json` — yalnız Development
- `GET /hangfire` — yalnız `Jobs__Enabled=true`
- `ASPNETCORE_URLS` default `http://+:8080`

---

## 5. Miqrasiyalar

Startup-da avtomatik miqrasiya **qadağandır** (SPEC §18.3) — ayrıca `wms-migrator` job-u var.
Hər DbContext-in **öz `Persistence/Migrations/` qovluğu və öz history cədvəli** var, ona görə doqquz
kontekst eyni `wms` bazasını paylaşa bilir:

| DbContext | Miqrasiya qovluğu | History cədvəli |
|---|---|---|
| `CommonDbContext` | `src/BuildingBlocks/Wms.Common.Infrastructure/Persistence/Migrations` | `__ef_migrations_common` |
| `IdentityDbContext` | `src/Modules/Identity/…/Persistence/Migrations` | `__ef_migrations_identity` |
| `MasterDataDbContext` | `src/Modules/MasterData/…/Persistence/Migrations` | `__ef_migrations_masterdata` |
| `InventoryDbContext` | `src/Modules/Inventory/…/Persistence/Migrations` | `__ef_migrations_inventory` |
| `ConsumptionDbContext` | `src/Modules/Consumption/…/Persistence/Migrations` | `__ef_migrations_consumption` |
| `ProcurementDbContext` | `src/Modules/Procurement/…/Persistence/Migrations` | `__ef_migrations_procurement` |
| `DocumentsDbContext` | `src/Modules/Documents/…/Persistence/Migrations` | `__ef_migrations_documents` |
| `NotificationDbContext` | `src/Modules/Notification/…/Persistence/Migrations` | `__ef_migrations_notification` |
| `ReportingDbContext` | `src/Modules/Reporting/…/Persistence/Migrations` | `__ef_migrations_reporting` |
| `IntegrationDbContext` | `src/Modules/Integration/…/Persistence/Migrations` | `__ef_migrations_integration` |

History cədvəlinin adı `<Context>.MigrationsHistoryTable` sabitindədir və həm design-time factory-yə,
həm `WmsMySql.UseWmsMySql(...)`-ə ötürülür — yeni modul əlavə edəndə hər ikisini vermək lazımdır.

### 5.1. Miqrasiyanın tətbiqi

```bash
scripts/db-migrate.sh                 # migrator image build + run, sonra ledger grant-ları
scripts/db-migrate.sh --no-build      # mövcud image ilə
scripts/db-ledger-grants.sh           # yalnız grant-ları yenidən ver
```

`Wms.Host.Migrator` bütün DbContext-ləri sıra ilə `Database.MigrateAsync()` edir
(əvvəl `CommonDbContext` — outbox/audit, sonra modullar), **sonda Hangfire sxemini** (`hangfire_*`)
`wms_migrator` ilə yaradır və xəta olarsa **sıfırdan fərqli kodla** çıxır.
Miqrasiyadan sonra `scripts/db-ledger-grants.sh` **hökmən** işləməlidir: yeni cədvəllərə `wms_app`
üçün UPDATE/DELETE yalnız orada verilir (fail-closed, `deploy/README.md` §1).

Konteynersiz (və ya CI-də) birbaşa:

```bash
ConnectionStrings__WmsMigrator='Server=...;Database=wms;User=wms_migrator;Password=...;' \
  dotnet run --project src/Host/Wms.Host.Migrator
```

### 5.2. Yeni miqrasiya yaratmaq

Miqrasiya adı: `YYYYMMDD_ModuleName_Description` (SPEC Əlavə A). Lokal SDK yoxdursa SDK
konteynerində `dotnet-ef` quraşdırılır (EF Core 9 stack-i — versiya **9.0.20** olmalıdır):

```bash
SCRATCH=/tmp/wms                 # NuGet cache üçün istənilən qovluq
docker run -d --name wms-sdk --network wms_default \
  -v "$PWD":/src -v "$SCRATCH/nuget":/root/.nuget/packages -w /src \
  -e PATH=/root/.dotnet/tools:/usr/local/bin:/usr/bin:/bin \
  mcr.microsoft.com/dotnet/sdk:10.0 sleep infinity
docker exec wms-sdk dotnet tool install --global dotnet-ef --version 9.0.20

docker exec wms-sdk dotnet-ef migrations add 20260921_Inventory_Initial \
  -p src/Modules/Inventory/Wms.Inventory.Infrastructure \
  -s src/Host/Wms.Host.Migrator \
  -c InventoryDbContext \
  -o Persistence/Migrations
```

`-p` (miqrasiyanın yazılacağı layihə) və `-c` (kontekst) hər modul üçün dəyişir; `-s` həmişə
`Wms.Host.Migrator`-dur. Bazaya qoşulmaq lazım deyil — hər kontekstin
`IDesignTimeDbContextFactory`-si var (`DesignTimeConnection.Resolve()` yalnız connection string-i
formalaşdırır, açmır).

Geri qaytarma / təkrar tətbiq (konteyner `wms_default` şəbəkəsində olmalıdır):

```bash
docker exec -e ConnectionStrings__WmsMigrator='Server=mysql;Port=3306;Database=wms;User=wms_migrator;Password=wms_migrator;' \
  wms-sdk dotnet-ef database update 0 \
  -p src/Modules/Inventory/Wms.Inventory.Infrastructure -s src/Host/Wms.Host.Migrator -c InventoryDbContext
```

### 5.3. Mövcud miqrasiyalar

21.09.2026-da doqquz ilkin miqrasiya generasiya olunub və canlı MySQL 8.4-ə tətbiq edilib:

`20260921_Common_Initial`, `20260921_Identity_Initial`, `20260921_MasterData_Initial`,
`20260921_Inventory_Initial`, `20260921_Procurement_Initial`, `20260921_Documents_Initial`,
`20260921_Notification_Initial`, `20260921_Reporting_Initial`, `20260921_Integration_Initial`.

Consumption modulu (ADR-012) üç miqrasiya əlavə etdi:

| Miqrasiya | Kontekst | Nə edir |
|---|---|---|
| `20260921_Consumption_Initial` | `ConsumptionDbContext` | 7 `cons_*` cədvəli + `__ef_migrations_consumption` |
| `20260921_MasterData_ConsumptionLocationType` | `MasterDataDbContext` | `master_location.location_type` ENUM-una `V_CONSUMPTION` |
| `20260921_Inventory_ConsumptionDocType` | `InventoryDbContext` | `inv_movement_group.doc_type` ENUM-una `CONSUMPTION` |

Son ikisi yalnız ENUM genişlənməsidir (`ALTER COLUMN`, mövcud dəyərlərə toxunmur); EF onları
"may result in the loss of data" kimi işarələyir, çünki hər `AlterColumn` üçün belə edir.

Anbar sənədləri (bu buraxılış) iki miqrasiya əlavə etdi:

| Miqrasiya | Kontekst | Nə edir |
|---|---|---|
| `20260921_Inventory_Count` | `InventoryDbContext` | `inv_count`, `inv_count_line` (SPEC §9.6, §12.7) |
| `20260921_Inventory_WarehouseDocuments` | `InventoryDbContext` | `inv_stock_request(_line)`, `inv_issue(_line)`, `inv_waste(_line)`, `inv_sample(_line)`, `inv_return_to_vendor(_line)` |

Bu buraxılış (Faza 1) iki miqrasiya əlavə etdi:

| Miqrasiya | Kontekst | Nə edir |
|---|---|---|
| `20260922_MasterData_ContractAlignment` | `MasterDataDbContext` | `master_product_category`-yə `is_active`, `row_version`, `default_issue_strategy`, `ix_cat_path`; `master_location` və `master_reason_code`-a `row_version`; `ix_reason_group`. Hamısı additiv — kontrakt bu üç cədvəlin update əməliyyatında `rowVersion` + `409 STALE_VERSION` tələb edir, SPEC §8 DDL-ində isə sütun yox idi |
| `20260922_Documents_AttachmentUpload` | `DocumentsDbContext` | `common_attachment`-ə `status ENUM('PENDING','SCANNING','READY','REJECTED') DEFAULT 'READY'`, `scan_result`, `ix_att_status`. Presign/complete axını üçün (§8.18) |

Nəticə: **61 biznes cədvəli + 10 history cədvəli + 12 `hangfire_*` = 83**.
Miqrasiyadan sonra `scripts/db-ledger-grants.sh` yenidən işlədilib: prosedur cədvəlləri
`information_schema`-dan oxuduğu üçün yeddi `cons_*` cədvəli avtomatik `UPDATE/DELETE` aldı,
`inv_movement` və `common_audit_log` isə yenə yalnız `SELECT+INSERT`-dədir.

`Wms.Inventory.IntegrationTests` fixture-u artıq `EnsureCreated()` deyil, **real miqrasiyaları**
işlədir — ona görə `inv_movement` partisiyalaşdırması (§8.3) hər test qaçışında yoxlanılır.

### 5.4. Sxemin SPEC-ə uyğunluğu (21.09.2026-da canlı MySQL 8.4-də yoxlanılıb)

| SPEC qaydası | Nəticə |
|---|---|
| §6.3 miqdar/məbləğ `DECIMAL(18,4)` | ✅ 28 sütun, hamısı `decimal(18,4)` |
| §6.3 conversion əmsalı / məzənnə `DECIMAL(18,8)` | ✅ 5 sütun (`conversion_rate`, `fx_rate`, `rate_to_base`, `factor_to_base`, `proc_purchase_order.fx_rate`) |
| §6.3 faiz `DECIMAL(9,4)` | ✅ `master_product.vat_rate`, `proc_purchase_order_line.vat_rate` |
| §6.3 `FLOAT`/`DOUBLE` qadağandır | ✅ 0 WMS sütunu (yeganə `float` — `hangfire_Set.Score`, §8.2) |
| §6.3 vaxt damğası `DATETIME(3)` | ✅ 32/32 datetime sütunu `datetime(3)` |
| §6.4 `utf8mb4` / `utf8mb4_0900_ai_ci` | ✅ baza + 51 cədvəlin (42 biznes + 9 history) hamısı; 3 `char(36)` GUID sütunu `ascii_general_ci` (§8.6) |
| §6.5 hər unikal indeks `tenant_id` ilə başlayır | ✅ 29/31 — istisnalar `iam_tenant.uq_tenant_code`, `iam_permission.uq_perm_code` (§8.4). PK-lar `id`-dir (§6.1) |
| §6.2 `tenant_id INT UNSIGNED NOT NULL` | ✅ hamısı; tenant_id-siz cədvəllər SPEC-də də tenant-siz (`iam_tenant`, `iam_permission`, 3 junction, `proc_approval_step`) |
| CONVENTIONS cədvəl prefiksləri | ✅ `iam_` 8, `master_` 10, `inv_` 7, `proc_` 7, `notif_` 2, `rpt_` 2, `intg_` 3, `common_` 3 (+9 history, +12 `hangfire_`) |
| §9.4 `PARTITION BY RANGE (YEAR(posted_at))` | ✅ p2026 / p2027 / pmax — iki güzəştlə (§8.3) |
| §9.4/§16 ledger append-only | ✅ `wms_app` `inv_movement` və `common_audit_log`-da SELECT+INSERT, UPDATE/DELETE → MySQL 1142 |
| SPEC DDL-dəki sütun `DEFAULT` dəyərləri | ⚠️ 14/51 (§8.5) |
| SPEC DDL-dəki `BIGINT UNSIGNED` id | ⚠️ 17 cədvəldə işarəli `bigint` (§8.6) |

Cədvəldəki saylar **yalnız WMS cədvəllərinə** aiddir. `hangfire_*` cədvəllərini Hangfire-ın öz
installer-i yaradır və onlar SPEC §6-ya tabe deyil — bax §8.2.

Təkrar yoxlamaq üçün (`mysql` konteynerində, root ilə):

```sql
-- FLOAT/DOUBLE yoxdur
SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA='wms' AND DATA_TYPE IN ('float','double','real');
-- hər unikal indeks tenant_id ilə başlayır (PRIMARY istisna)
SELECT TABLE_NAME, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) cols
  FROM information_schema.STATISTICS
 WHERE TABLE_SCHEMA='wms' AND NON_UNIQUE=0 AND INDEX_NAME<>'PRIMARY'
 GROUP BY TABLE_NAME, INDEX_NAME HAVING SUBSTRING_INDEX(cols,',',1)<>'tenant_id';
```

---

### 5.5. `iam` kataloqu (həmişə) və demo datası (`--seed`)

`Wms.Host.Migrator` miqrasiyalardan sonra **hər dəfə** `iam` kataloqunu yazır (`IamSeeder.SeedCatalogueAsync`):
tenant, altı sistem rolu, `iam_permission` kataloqu (**101 kod**) və sistem rollarının
`iam_role_permission` sətirləri. Bu, demo datası deyil — onsuz heç bir sorğu avtorizasiya oluna bilmir
və hər audit sütununun göstərəcəyi sətir yoxdur, ona görə `--seed` bayrağından asılı deyil.

- **Mənbə:** `Wms.Identity.Domain/PermissionCatalog.cs`. Kod siyahısı ilə endpoint-lərdəki
  `.RequirePermission(...)` arasındakı uyğunluğu arxitektura testi saxlayır
  (`PermissionCatalogConsistencyTests`).
- **Dəqiq uzlaşdırma:** sistem rolları platformanındır — buraxılış bir rolu **daraltdıqda** (məsələn
  `doc.attachment.*` → `view/upload/delete`, §8.15) köhnə sətirlər silinir, genişləndikdə yenisi əlavə olunur.
  Kataloqdan çıxarılan icazə kodu (`inv.return.*` → `inv.rtv.*`) `iam_permission`-dan da silinir.
  **Nəticə:** sistem rolunun icazə dəstini `PUT /identity/roles/{id}/permissions` ilə dəyişmək **davamlı
  deyil** — növbəti migrator qaçışı onu geri qaytarır. Fərqli dəst lazımdırsa custom rol yaradın;
  custom rollara seeder heç vaxt toxunmur.

`--seed` bayrağı ilə əlavə olaraq anbar ekranlarını doldurmaq üçün təkrarlana bilən demo datası yazılır. Hər addım təbii açar (kod / SKU / sənəd nömrəsi) üzrə **upsert**-dir: ikinci dəfə işlətmək heç
nə dəyişmir, yarımçıq bazanı isə tamamlayır.

```bash
# konteynerdə (wms_default şəbəkəsində)
docker exec -w /src -e ConnectionStrings__WmsMigrator='Server=mysql;Port=3306;Database=wms;User=wms_migrator;Password=wms_migrator;' \
  wms-sdk dotnet run --project src/Host/Wms.Host.Migrator -c Release -- --seed

# lokal SDK ilə
ConnectionStrings__WmsMigrator='Server=localhost;Port=3308;Database=wms;User=wms_migrator;Password=wms_migrator;' \
  dotnet run --project src/Host/Wms.Host.Migrator -- --seed
```

Nə yaranır:

| Data | Say / detal |
|---|---|
| Ölçü vahidləri | 6 (`G`, `KG`, `PRT`, `PCS`, `L`, `BOX`) |
| Kateqoriyalar | 7 (qida və qeyri-qida) |
| Məhsullar | 25, SKU + min/maks ehtiyat + raf ömrü ilə; `G` bazalı olanlara `KG` (×1000), `PCS` bazalı olanlara `BOX` (×24) alış vahidi |
| Lokasiyalar | 2 anbar + **15 filial** + 6 virtual (`V-SUP`, `V-CONS`, `V-ADJ`, `V-WASTE`, `V-SAMPLE`, `V-TRANSIT`) |
| Təchizatçılar | 6 (4-ü qida üçün təsdiqli) |
| Səbəb kodları | 14 — hər qrupdan (`ADJUSTMENT`, `WASTE`, `RETURN`, `SAMPLE`, `TRANSFER`) |
| Məzənnələr | USD / EUR / TRY üçün 30 günlük tarixçə (deterministik, təsadüfi deyil) |
| Partiyalar | Hər partiyalı məhsul üçün 3 tranş: **vaxtı keçmiş**, **bu həftə bitən**, **təzə** — FEFO-nun seçəcəyi bir şey olsun |
| Başlanğıc qalıq | `OPENING` ikili yazılışlı sənədi ilə (504 ledger sətri) 2 anbar + 4 filialda |
| Sayım | `WH-02`-də dondurulmuş sayım, 42 sətir, **18-i fərqli** — lokasiya bloklanmış vəziyyətdə |
| Məxaric | 2 sənəd `DISPATCHED` statusunda, filial təsdiqini gözləyir |
| Tələblər | 3 ədəd (2 `SUBMITTED`, 1 `DRAFT`) |
| `iam_user` | CONVENTIONS.md-dəki altı dev istifadəçisi, rolları və **lokasiya icazələri** ilə: `keeper` → WH-01 + WH-02, `branch1` → BR-NIZ, qalanları məhdudiyyətsiz (`iam.location.view_all`) |

Dev istifadəçiləri `external_id = pending:<username>` ilə yazılır: Keycloak subject-ini seeder bilmir.
Həmin istifadəçinin **ilk real token-i** sətri "sahiblənir" (`preferred_username` üzrə tapılır və
`external_id` real `sub` ilə əvəzlənir), ona görə rollar və lokasiya icazələri o istifadəçinin ilk
sorğusundan etibarən qüvvədədir. Bax §8.16.

**Qalıq heç vaxt birbaşa `inv_balance`-a yazılmır** — başlanğıc qalıq da real `OPENING` qrupundan keçir
(ADR-004), ona görə seed datası canlı data ilə eyni invariantları ödəyir:
`SELECT group_id, SUM(qty_base) … HAVING SUM(qty_base) <> 0` boş qalır və fiziki lokasiyalarda mənfi qalıq olmur.

Seeder `SeedContext` ilə işləyir (`tenant_id = 1`, `created_by = 1`): design-time stub `HasTenant = false`
verdiyi üçün query filter-lər `tenant_id = 0`-a baxar və idempotentlik yoxlamaları heç nə tapmazdı.

---

## 6. Testlər

| Layihə | Nə yoxlayır | Sayı |
|---|---|---|
| `Wms.Inventory.UnitTests` | SPEC §12 invariantları: yuvarlaqlaşdırma, ikili yazılış, mənfi qalıq, FEFO/FIFO, hərəkətli orta, tolerans, approval qaydası, AZ əlifba sırası; **sayım aqreqatı** (dondurma, fərq faizi, səbəb kodu məcburiliyi, approval həddi, statuslar), **məxaric/transfer** (IN_TRANSIT, fərqli qəbul, partiya override), **tullantı/nümunə/qaytarma/tələb** status axınları; **§12.6 öz-özünü təsdiq** (sayım və tullantı, həm handler səviyyəsində, həm fail-closed halı), **`LocationScope`** (§16 fail-closed semantikası), **`inv_setting` tip validasiyası** | 194 |
| `Wms.Identity.UnitTests` | SPEC §7: icazə kataloqu və default rol qrantları, §7.1 SoD (rol icazəsi + rol kombinasiyası), `iam_user` rol/lokasiya dəstləri, pre-provisioning sahiblənməsi, delegasiya qaydaları | 27 |
| `Wms.MasterData.UnitTests` | Dəyişməzlik qaydaları (`sku`, `base_uom_id`, `location_type`, `reason_group`), `factor_to_base` versiyalanması, unikallıq 409-ları, kateqoriya yolu və dövr, AZ sıralama, maya sahəsinin JSON-dan çıxarılması | 69 |
| `Wms.Documents.UnitTests` | 25 MB limiti (presign + complete), beş icazəli tip, content-type uyğunsuzluğu, checksum, virus skanı (yoluxmuş + əlçatmaz), storage key forması, tenant izolyasiyası | 140 |
| `Wms.ArchitectureTests` | SPEC §17.4: modul sərhədləri, tenant query filter, unique index `tenant_id`-dən başlayır, `double`/`float` yoxdur, `inv_balance` public setter-siz, cədvəl prefiksləri, decimal precision; **`RolePermissionMap`** — hər rol üzrə icazə matrisi və wildcard matcher (§8.12); **icazə kataloqunun uzlaşması** (hər `.RequirePermission(...)` kodu kataloqdadır, bootstrap xəritəsi `PermissionCatalog` ilə eynidir) **`/internal/*` yol/sirr uyğunlaşdırması** və **lokasiya scope-unun filtrlərdə mövcudluğu** | 391 |
| `Wms.Api.ContractTests` | Host qalxır, `/health/live`, auth tələbi, qismən deployment davranışı; **`/internal/*` qorunması** (10 marşrut sirrsiz 403, yanlış sirr 403, düz sirr keçir, `ModuleTransport=Http` sirrsiz startup-da fail edir) | 22 |
| `Wms.Inventory.IntegrationTests` | Testcontainers + real MySQL 8.4, sxem **real miqrasiyalardan** (`MigrateAsync`, §5.3): qəbul → balans → ledger sıfıra balanslaşır, idempotency key unikallığı, `inv_movement` partisiyalaşdırma DDL-i; **sayım**: `FOR UPDATE` snapshot → dondurma → `COUNT_ADJUST` qrupu sıfıra balanslaşır → lokasiya açılır | 4 (`Category=Integration`) |
| `Wms.Consumption.UnitTests` | ADR-012: BOM partlaması (`yield_pct`, `yield_portions`, alt-resept, attach rate, yuvarlaqlaşdırma), dövr aşkarlanması, dərinlik limiti, resept versiyasının tarixə görə seçimi, `posted = min(theoretical, available)`, CSV parse (UTF-8 + Windows-1254 + pozuq sətirlər) | 69 |
| `Wms.Consumption.IntegrationTests` | Testcontainers + real MySQL 8.4 və üç modulun real DI qrafı: tam dövr (resept → satış → hesablama → post), qrupun sıfıra balanslaşması, filial qalığının düşməsi = `V_CONSUMPTION`-un artması, qəsdən yaradılmış çatışmazlıq mənfi qalıq yaratmır, `DUPLICATE_BUSINESS_DATE` | 3 (`Category=Integration`) |

**Cəmi 919 test** (912 sürətli + 7 Testcontainers), 0 xəbərdarlıq.

Integration testlər `[Trait("Category","Integration")]` ilə işarələnib və
`--filter "Category!=Integration"` ilə kənarlaşdırılır.

---

## 7. Paket versiyaları

Bütün versiyalar `Directory.Packages.props`-da mərkəzləşdirilib.

| Paket | Versiya |
|---|---|
| .NET SDK / TargetFramework | `10.0.x` / `net10.0` |
| Microsoft.EntityFrameworkCore(.Relational/.Design) | **9.0.20** |
| Pomelo.EntityFrameworkCore.MySql | **9.0.0** |
| EFCore.NamingConventions | 9.0.0 |
| MySqlConnector | 2.4.0 |
| ASP.NET Core paketləri (JwtBearer, OpenApi, Mvc.Testing) | 10.0.12 |
| FluentValidation | 12.1.1 |
| Hangfire.Core / .AspNetCore | 1.8.25 |
| Hangfire.MySqlStorage | 2.0.3 |
| Hangfire.InMemory | 1.0.0 |
| RabbitMQ.Client | 7.2.2 |
| StackExchange.Redis | 2.13.17 |
| Serilog.AspNetCore / Sinks.Seq | 10.0.0 / 9.1.0 |
| OpenTelemetry.* | 1.19.0 |
| Yarp.ReverseProxy | 2.3.0 |
| Dapper | 2.1.86 |
| xunit / Microsoft.NET.Test.Sdk | 2.9.3 / 17.14.1 |
| NetArchTest.Rules | 1.3.2 |
| Testcontainers.MySql | 4.15.0 |
| Microsoft.CodeAnalysis.BannedApiAnalyzers | 5.6.0 |

---

## 8. Spesifikasiyadan kənarlaşmalar

### 8.1. 🔴 EF Core 10 əvəzinə EF Core 9 (Pomelo səbəbilə)

SPEC §3 **EF Core 10 + Pomelo** tələb edir və özü də xəbərdarlıq edir:
*"⚠️ Layihəyə başlamazdan əvvəl Pomelo-nun EF Core 10 dəstəyini yoxlayın"*.

**Vəziyyət (21.09.2026):** `Pomelo.EntityFrameworkCore.MySql` üçün NuGet-də **heç bir 10.x buraxılışı yoxdur**
(son stabil: `9.0.0`, EF Core `[9.0.0, 9.0.999]` tələb edir).

**Qərar:** brifinqdəki fallback tətbiq edilib — **EF Core 9.0.20 + Pomelo 9.0.0 + EFCore.NamingConventions 9.0.0**.
Runtime və ASP.NET Core paketləri **net10.0 / 10.0.12**-dir; yalnız EF Core stack-i 9.x-dədir (dəstəklənən kombinasiyadır).

**Nə vaxt qaytarılmalıdır:** Pomelo 10.x çıxan kimi `Directory.Packages.props`-da üç EF Core paketini və
Pomelo-nu 10.x-ə qaldırmaq kifayətdir — kodda dəyişiklik gözlənilmir.

### 8.2. Hangfire.MySqlStorage lisenziyası (LGPL-3.0)

SPEC §3 Hangfire (Core) seçib, lakin MySQL storage rəsmi deyil. `Hangfire.MySqlStorage` 2.0.3 istifadə olunur —
lisenziyası **LGPL-3.0**-dır. Bu, dəyişiklik edilmədən NuGet paketi kimi istifadədə SaaS üçün qəbul edilə bilər,
amma SPEC §3-dəki "bütün NuGet asılılıqlarının lisenziyasını yoxlayın" tələbi baxımından **hüquqi təsdiq lazımdır**.
Alternativ: `Jobs__Storage=InMemory` (yalnız dev) və ya PostgreSQL/Redis storage-a keçid.

**Sxem sahibliyi (21.09.2026-da düzəldildi).** `MySqlStorage` default olaraq `hangfire_*` cədvəllərini
konstruktorda özü yaradır. Bu iki qaydanı pozurdu: SPEC §18.3 (startup-da DDL yoxdur) və SPEC §16
(`wms_app`-in CREATE hüququ yoxdur) — `wms-worker` `CREATE command denied to user 'wms_app'` ilə
crash edirdi. İndi host-da `PrepareSchemaIfNecessary=false`-dur, sxemi isə `Wms.Host.Migrator`
`WmsJobsExtensions.EnsureJobStorageSchema(...)` ilə `wms_migrator` hesabı altında yaradır.

**Sxemin keyfiyyəti (SPEC §6-ya tabe deyil).** Hangfire-ın installer-i öz DDL-ini yazır və o, SPEC §6
qaydalarının bir neçəsini pozur: cədvəllər `utf8mb3_general_ci` (§6.4 `utf8mb4_0900_ai_ci` tələb edir),
`hangfire_Set.Score` **`FLOAT`**-dur (§6.3 qadağan edir), `datetime`/`datetime(6)` sütunları `DATETIME(3)`
deyil, adlar PascalCase-dir (§6.1 snake_case), unikal indekslər `tenant_id` ilə başlamır (§6.5).
Bunlar **biznes datası deyil** — icra olunan job-ların əməliyyat vəziyyətidir, `hangfire_` prefiksi ilə
təcrid olunub və kitabxananı fork etmədən dəyişdirilə bilməz. Buna baxmayaraq `utf8mb3` MySQL 8.4-də
deprecated-dir və gələcək versiyada silinəcək — bu, §8.2-nin başındakı lisenziya sualı ilə birlikdə
job storage seçiminin yenidən nəzərdən keçirilməsi üçün ikinci arqumentdir.

### 8.3. `inv_movement` partisiyalaşdırması — tətbiq edilib, iki güzəştlə

SPEC §9.4 `PARTITION BY RANGE (YEAR(posted_at))` (p2026 / p2027 / pmax) tələb edir. EF Core bunu model
səviyyəsində ifadə edə bilmir, ona görə `20260921_Inventory_Initial` miqrasiyasının sonunda
`PartitionMovementLedger(...)` metodunda `migrationBuilder.Sql(...)` ilə verilib. **Partisiyalar
tətbiq olunub** (`SHOW CREATE TABLE inv_movement` üç partisiyanı göstərir) — amma MySQL/InnoDB-nin iki
sərt məhdudiyyəti EF-in yaratdığı cədvəli olduğu kimi qəbul etmir, ona görə əvvəlcə iki dəyişiklik edilir:

| Məhdudiyyət | Nə edilib | Güzəşt |
|---|---|---|
| **Hər unikal açar (PK daxil) partisiya sütununu saxlamalıdır** | `PRIMARY KEY (id)` → `PRIMARY KEY (id, posted_at)`; `uq_mv_line (tenant_id, group_id, line_no)` → `(tenant_id, group_id, line_no, posted_at)` | Unikallıq artıq `posted_at`-a da bağlıdır: eyni `(tenant_id, group_id, line_no)` fərqli `posted_at` ilə DB səviyyəsində bloklanmır. Praktikada bütün sətirlər qrupun `posted_at`-ını daşıyır (`MovementGroup` aqreqatı onu bir dəfə təyin edir), ona görə invariant qorunur — amma indi **tətbiq səviyyəsində**, DB səviyyəsində deyil. `id` PK-də birinci qalır: InnoDB AUTO_INCREMENT sütunundan bunu tələb edir. |
| **InnoDB partisiyalı cədvəldə (və ona) foreign key dəstəkləmir** | EF-in yaratdığı `fk_inv_movement_inv_movement_group_group_id` və artıq lazımsız `ix_inv_movement_group_id` indeksi silinir | `group_id` üçün DB səviyyəsində referensial bütövlük yoxdur. SPEC §9.4-ün öz DDL-ində də bu cədvəldə FK **yoxdur**; yeganə yazıcı `MovementGroup` aqreqatıdır (`inv_movement`-ə birbaşa insert yalnız append-only ledger axını ilə olur) və `inv_balance`-dan `inv_movement`-ə heç bir FK yoxdur, ona görə əks istiqamətdə problem yaranmır. |

EF model-i (`MovementConfiguration`) dəyişmir — snapshot orijinal PK/FK-ni saxlayır, DDL fərqi yalnız
miqrasiyadadır. Bu, EF-in ifadə edə bilmədiyi sxem elementləri üçün standart yanaşmadır; `inv_movement`
append-only olduğu üçün EF heç vaxt bu cədvələ UPDATE/DELETE göndərmir və fərq davranışa təsir etmir.

`Down()` əvvəlcə `ALTER TABLE inv_movement REMOVE PARTITIONING` edir, sonra EF cədvəlləri silir —
`dotnet-ef database update 0` → `database update` dövrü real MySQL-də yoxlanılıb.

**Saxlama siyasəti:** `pmax` 2028+ illəri yığır. 2027-nin sonundan əvvəl yeni miqrasiya ilə
`ALTER TABLE inv_movement REORGANIZE PARTITION pmax INTO (PARTITION p2028 VALUES LESS THAN (2029), PARTITION pmax VALUES LESS THAN MAXVALUE)`
verilməlidir, əks halda bütün yeni illər bir partisiyada toplanacaq.

### 8.4. `uq_mv_line` və digər unikal indekslərə `tenant_id` əlavəsi

SPEC §9.4-də `UNIQUE KEY uq_mv_line (group_id, line_no)`, §9.6-da `uq_grl (receipt_id, line_no)`,
§10-da `uq_prl`/`uq_pol` `tenant_id`-siz verilib, lakin §6.5 **hər unikal indeksin birinci sütunu `tenant_id`
olmalıdır** deyir və bunu arxitektura testi ilə tələb edir. §6.5 üstün tutulub: bu indekslərin hamısına
`tenant_id` prefiksi əlavə edilib.

İstisnalar (arxitektura testində sənədləşdirilib): `iam_tenant.uq_tenant_code` (tenant cədvəlinin özü),
`iam_permission.uq_perm_code` (qlobal kataloq), `iam_user_role` / `iam_role_permission` / `iam_user_location`
junction cədvəllərinin PK-ları (valideynləri artıq tenant-scoped-dur).

### 8.5. Sütun `DEFAULT` dəyərləri — 37-si hələ DDL-də yoxdur

SPEC-in DDL blokları 51 sütun üçün `DEFAULT` elan edir. Generasiya olunmuş sxemdə **14-ü var**, 37-si
yoxdur. Mövcud olanlar: SPEC §6.2-nin məcburi sütunları (`row_version DEFAULT 1`, `is_deleted DEFAULT 0` —
`ModuleDbContext.ApplyMandatoryColumnDefaults` mərkəzi olaraq verir), `common_outbox.attempt_count DEFAULT 0`
və `inv_balance`-ın dörd sütunu.

Çatışmayanlar biznes defaultlarıdır (`master_product.vat_rate 18.0000`, `master_supplier.currency 'AZN'`,
`inv_batch.status 'ACTIVE'`, `proc_requisition.priority 'NORMAL'`, bütün `is_active 1` sütunları və s.).
**Runtime-da problem yaratmır** — bu dəyərləri domen factory metodları təyin edir (`Product.Create(...)`
və s.), yəni tətbiq heç vaxt DB default-una güvənmir. Əhəmiyyəti Faza 0-ın **data migration** skriptləri
üçündür: birbaşa `INSERT` edən skript bu sütunları açıq verməlidir, yoxsa `STRICT_TRANS_TABLES`
`NOT NULL` sütunu üçün xəta verəcək.

Bağlamaq üçün: hər `IEntityTypeConfiguration`-da `.HasDefaultValue(x).ValueGeneratedNever()`
(`ValueGeneratedNever()` olmadan EF INSERT-dən sonra dəyəri geri oxumaq üçün əlavə round-trip edir).

### 8.6. `BIGINT` id-lər işarəlidir, `CHAR(36)` GUID sütunları `ascii_general_ci`-dir

- SPEC §7–§10 `BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT` yazır; domen entity-ləri `long` işlətdiyi üçün
  EF 17 cədvəldə işarəli `bigint` yaradır (müsbət diapazon 9.2×10¹⁸ — heç bir praktiki risk yoxdur).
  `int unsigned` / `smallint unsigned` id-lər (`uint` / `ushort` sahələr) SPEC ilə tam uyğundur.
  Dəyişmək domen tiplərini `ulong`-a keçirmək deməkdir — .NET-də əlverişsizdir, contracts və 270 testə
  toxunur, ona görə edilməyib.
- `inv_movement_group.idempotency_key`, `notif_message.event_id`, `intg_outbound_message.event_id`
  sütunları `char(36) COLLATE ascii_general_ci`-dir: Pomelo `Guid` → `char(36)` üçün bunu avtomatik verir.
  Cədvəl və baza default-u SPEC §6.4-dəki `utf8mb4_0900_ai_ci`-dir; GUID mətnində qeyri-ASCII simvol ola
  bilməz, ona görə bu, saxlanılan şüurlu optimizasiyadır.

### 8.7. Env var ilə verilən konfiqurasiya açarlarında `-` işlənə bilməz

`deploy/docker/backend.Dockerfile`-ın entrypoint-i `/bin/sh` (dash) skriptidir. Dash uşaq prosesin
mühitini öz dəyişən cədvəlindən yenidən qurur və **adı düzgün shell identifikatoru olmayan
(`[A-Za-z0-9_]`-dən kənar) dəyişənləri səssizcə atır** — `docker inspect` onları göstərsə də .NET-ə
çatmır. Buna görə YARP cluster id-ləri `wms-identity` deyil, **`identity`** adlanır
(`ReverseProxy__Clusters__identity__Destinations__d1__Address` işləyir,
`ReverseProxy__Clusters__wms-identity__...` heç vaxt işləməzdi). Yeni konfiqurasiya açarı əlavə edəndə
bu qaydaya riayət edin.

### 8.11. Anbar sənədlərinin sxemində SPEC DDL-indən kənarlaşmalar

SPEC §9.6 bu sənədlərin yalnız **başlıq** cədvəllərini verir; sətir cədvəlləri kontraktdan (inventory.v1.yaml)
törədilib. Aşağıdakılar şüurlu əlavələrdir:

| Cədvəl / sütun | Səbəb |
|---|---|
| `inv_stock_request_line`, `inv_issue_line`, `inv_waste_line`, `inv_sample_line`, `inv_return_to_vendor_line` | SPEC §9.6 yalnız başlıqları verir, lakin kontraktda hər sənədin `lines[]` massivi var |
| `inv_count.scope_category_ids`, `inv_count.scope_product_ids` (`VARCHAR(2000)`, vergüllə ayrılmış) | `CYCLE`/`SPOT` sayımın əhatəsi **yaratma** anında verilir, sətirlər isə **dondurma** anında yaranır (kontrakt: "Sətirlər dondurma anında yaradılır"), ona görə əhatə arada saxlanmalıdır. Ayrıca `inv_count_scope` cədvəli əvəzinə iki sütun seçilib: əhatə bir dəfə yazılır, heç vaxt sorğulanmır |
| `inv_count.requires_approval` | Kontraktdakı `Count.requiresApproval` sahəsi; `submit` anında hesablanıb dondurulur, çünki `count_variance_approval_threshold_pct` sonradan dəyişə bilər |
| `inv_count_line.counted_by`, `counted_at` | Kontraktda var (`CountLine.countedBy/countedAt`), SPEC DDL-ində yox idi — SoD yoxlaması üçün lazımdır |
| `inv_count_line.avg_unit_cost` | Fərqin manat dəyəri dondurma anındakı maya dəyəri ilə hesablanır (kontrakt: `varianceValue`); post anında balansı ikinci dəfə oxumamaq üçün snapshot-da saxlanılır |
| `inv_issue_line.suggested_batch_id` | SPEC §12.4 FEFO/FIFO təklifindən fərqli partiya seçimini `reason_code` ilə tələb edir; təklifin özü saxlanılmasa, sonradan yoxlanıla bilməz |
| `inv_return_to_vendor.location_id` | SPEC DDL-ində yoxdur, lakin malın **haradan** çıxdığı bilinmədən ikili yazılış qurula bilmir (ADR-003) |
| `inv_waste.approval_comment`, `inv_return_to_vendor.outcome`/`outcome_note` | Kontraktda var |

`inv_count_line`-ın `uq_cl_line (tenant_id, count_id, product_id, batch_id)` unikal indeksi partiyasız sətirlər
üçün tam zəmanət vermir: MySQL unikal indeksdə çoxlu `NULL`-a icazə verir. Təkrar sətirin qarşısını aqreqat özü
alır (`StockCount.CountLine` upsert edir) — indeks partiyalı sətirlər üçün əlavə qoruyucudur.

### 8.12. `RolePermissionMap` wildcard semantikası dəyişdi (buq düzəlişi)

Əvvəlki matcher pattern və icazənin **seqment sayının eyni olmasını** tələb edirdi. Nəticədə `AUDITOR` rolunun
`*.view` şablonu yalnız iki seqmentli kodlara uyurdu: `audit.view` ✅, `inv.balance.view` ❌. Auditor canlı
sistemdə `/inventory/balances`-də **403** alırdı — bu, ekran xəritəsindəki "auditor ledger, audit log, hesabat və
export görür" tələbinə ziddir.

İndi `*` **bir və ya bir neçə** bütöv seqmenti əvəz edir:

| Pattern | Uyur | Uymur |
|---|---|---|
| `*.view` | `audit.view`, `inv.balance.view`, `inv.receipt.line.view` | `inv.receipt.post`, `master.product.view_cost` |
| `inv.*.view` | `inv.balance.view`, `inv.receipt.line.view` | `proc.po.view` |
| `master.product.view` | `master.product.view` | `master.product.view_cost` |

Seqment bütöv müqayisə olunur, ona görə `view` heç vaxt `view_cost`-a uymur — SPEC §7.1-in anbardarı maya
dəyərindən kənarda saxlayan qaydası qorunur. `tests/Wms.ArchitectureTests/RolePermissionMapTests.cs` hər rol üçün
həm verilən, həm verilməyən icazələri yoxlayır.

### 8.13. Minimal API parametr bind xətası 500 əvəzinə 400 verir

`Microsoft.AspNetCore.Http.BadHttpRequestException` (məcburi query/route parametri verilməyib və ya parse
olunmur) `WmsExceptionHandler`-də xəritələnməmişdi və `INTERNAL_ERROR` 500 kimi çıxırdı. Üç endpoint bu səbəbdən
500 verirdi: `GET /consumption/variance`, `GET /consumption/portion-compliance` (`periodFrom`/`periodTo` məcburidir),
`GET /documents/attachments` (`entityType`/`entityId` məcburidir). İndi `400 BAD_REQUEST` + RFC 7807 qaytarılır.

---

### 8.14. Modullararası `/internal/*` çağırışları rate limit-dən kənardır

`RateLimiting:PermitPerMinute` (default 100) partisiyanı JWT `sub` claim-i üzrə qurur. `ModuleTransport=Http`
rejimində modullararası çağırışlar **çağıranın token-ini** daşıyır (SPEC §4.2), ona görə onlar istifadəçinin öz
trafiki ilə eyni partisiyaya düşürdü. Bir səhifə açmaq bir neçə daxili çağırışa çevrilir — sənəd siyahısını
məhsul, lokasiya, vahid və təchizatçı referansları ilə bəzəmək dörd daxili çağırışdır — nəticədə bir aktiv
ekran özü-özünü rate limit edə bilirdi və `429` çağıran modulda **500** kimi görünürdü.

İki düzəliş:

1. `/api/v1/<modul>/internal/...` yolları `RateLimitPartition.GetNoLimiter` alır.

> ⚠️ Bu bəndin ilkin əsaslandırması **səhv idi**: "bu route-lar gateway-dən proxy olunmur" yazılmışdı,
> halbuki gateway-in route cədvəli modul başına `{**catch-all}`-dur və hamısını olduğu kimi ötürürdü.
> Rate limit-dən azad etmək ona görə real risk idi. İndi marşrutlar həqiqətən bağlıdır (§8.15), ona görə
> istisna təhlükəsizdir.
2. `HttpRequestException` artıq `502 UPSTREAM_MODULE_UNAVAILABLE` kimi xəritələnir — qonşu modulun nasazlığı
   bu modulun `INTERNAL_ERROR`-u kimi görünmür.

`InProcess` transportda (on-prem, `Modules=*`) daxili çağırış HTTP-dən keçmir, ona görə bu problem yaranmırdı.

---

### 8.15. `/internal/*` marşrutları: gateway rədd edir + ortaq sirr (təhlükəsizlik düzəlişi)

**Nə səhv idi.** 24 modullararası marşrutun hamısı gateway-dən adi istifadəçi token-i ilə çağırıla bilirdi
(`branch1` tokeni ilə `GET /api/v1/masterdata/internal/products?ids=1` → **200**), üzərlərində heç bir
`.RequirePermission(...)` yox idi və üçü yazma əməliyyatıdır: ledger storno-su
(`/inventory/internal/reversals`), istehlak post-u (`/inventory/internal/consumption-postings`) və nömrə
seriyası (`/masterdata/internal/number-sequences/{docType}/next`). `ExcludeFromDescription()` yalnız OpenAPI
sənədindən gizlədir, marşrutu bağlamır.

**Nə edilib — iki müstəqil qat, hər ikisi fail-closed:**

1. **Gateway** (`Wms.Gateway/Program.cs`): yolunda bütöv `internal` seqmenti olan hər sorğu `MapReverseProxy`-dən
   əvvəl **404** alır. Kənar dünya üçün bu marşrutlar mövcud deyil. Seqment bütöv müqayisə olunur, ona görə
   `/masterdata/products/internal-code` kimi real resurs zədələnmir.
2. **Hər API host** (`InternalRouteGuardMiddleware`, `UseAuthentication`-dan **əvvəl**): `X-Wms-Internal-Key`
   header-i `InternalApi:Key` ilə üst-üstə düşməlidir (`CryptographicOperations.FixedTimeEquals`), əks halda
   **403 `INTERNAL_ROUTE_FORBIDDEN`**. Beləliklə gateway-i yan keçib modul konteynerinə birbaşa çıxan çağırış
   da rədd olunur. Açar konfiqurasiya olunmayıbsa **heç nə qəbul edilmir**.

`ModuleTransport=Http` rejimində `AddModuleHttpClient<>` həmin header-i `InternalApiKeyHandler` ilə əlavə edir
və açar yoxdursa host **startup-da** `InvalidOperationException` ilə dayanır — səhv konfiqurasiya ilk
modullararası çağırışda 403 kimi deyil, dərhal görünür. `InProcess` (on-prem, `Modules=*`) rejimində
modullararası çağırış HTTP-dən keçmir, ona görə bu qat sadəcə xaricdən gələni bağlayır.

**Əlaqəli daraltma:** `doc.attachment.*` wildcard-ı `doc.attachment.manage` kodu kataloqa əlavə olunan
kimi onu da verməyə başlamışdı — nəticədə filial istifadəçisi anbarın əlavəsini silə bilirdi.
`WAREHOUSE_KEEPER` və `BRANCH_USER` indi açıq şəkildə `doc.attachment.view|upload|delete` alır; silmək
yalnız öz yüklədiyinə şamildir.

### 8.16. Token-dəki identifikatorlar əvəzinə `iam_user`-in server tərəfində həlli

**Nə səhv idi.** Keycloak token-i daxili identifikator daşımır, `iam_*` cədvəlləri isə boş idi. Nəticə:
`ICurrentUser.UserId` həmişə **0**, yəni hər `created_by` / `posted_by` / `approved_by` / `uploaded_by` və
hər `common_audit_log.user_id` sıfır; SPEC §12.6-dakı öz-özünü təsdiq qadağası `userId != 0` şərti ilə
qorunduğu üçün **səssizcə söndürülmüşdü**; avtorizasiya `iam_role_permission`-dan deyil, kompilyasiya olunmuş
xəritədən işləyirdi.

**Niyə Keycloak mapper-i yox, server tərəfində həll.** Mapper daxili id-ni token-ə yazmalı olardı: bunun üçün
Keycloak-a WMS bazasına yazma hüququ və ya xüsusi SPI lazımdır, id token-in ömrü boyu donur, və mapper hər
mühitdə eyni qurulmasa audit jurnalı **səssizcə** yenidən sıfıra qayıdır. İndiki model: Keycloak
**autentifikasiyanın**, WMS bazası isə **identikliyin** yeganə mənbəyidir.

- `PrincipalResolutionMiddleware` (`UseAuthentication`-dan sonra) sorğu başına bir dəfə `IPrincipalDirectory`
  ilə `iam_user` sətrini tapır; ilk görüşdə sətri yaradır və realm rollarını `iam_user_role`-a köçürür.
- Seeder və ya operator tərəfindən **əvvəlcədən hazırlanmış** sətir (`external_id = pending:<username>`)
  eyni `preferred_username` ilə gələn ilk real token tərəfindən sahiblənilir — rol və lokasiya icazələri
  istifadəçinin ilk sorğusundan qüvvədədir.
- Nəticə `IPrincipalCache`-də saxlanılır: Redis varsa **bütün konteynerlər arasında** (default TTL 30 s),
  yoxdursa yaddaşda. Identity-nin yazma endpoint-ləri entry-ni dərhal invalidasiya edir, ona görə rol və ya
  lokasiya dəyişikliyi növbəti sorğuda qüvvəyə minir — yenidən login lazım deyil.
- `ICurrentUser.HasPermission` artıq **yalnız** `iam_role_permission`-dan oxunan dəstə baxır.
  `RolePermissionMap` bootstrap mənbəyi kimi qalır: seeder onu `iam_role_permission`-a açır və sətirləri
  hələ yazılmamış sistem rolu üçün fallback olur (loglanır) — boş bazada məhsul yenə qalxır.
- Identity əlçatmazdırsa `HttpRequestException` → **502 `UPSTREAM_MODULE_UNAVAILABLE`**; icazə səssizcə
  verilmir. Deaktiv istifadəçi **403 `USER_DISABLED`** alır.

### 8.17. Lokasiya filtri fail-open idi — `LocationScope` ilə fail-closed oldu

**Nə səhv idi.** Filtr `IReadOnlyCollection<uint>` daşıyırdı və **boş = məhdudiyyət yoxdur** demək idi.
`iam_user_location` bütün istifadəçilər üçün boş olduğundan filtr heç vaxt tətbiq olunmurdu: `branch1`
tokeni ilə `GET /inventory/balances?size=200` hər iki mərkəzi anbarı və başqa filialı qaytarırdı.

**Nə edilib.** `Wms.Common.Application/Security/LocationScope.cs` iki vəziyyəti açıq ayırır:

| Scope | Nə deməkdir |
|---|---|
| `LocationScope.Unrestricted` | filtr yoxdur — **yalnız** `iam.location.view_all` icazəsi ilə |
| `LocationScope.RestrictedTo([...])` | yalnız sadalanan lokasiyalar |
| `LocationScope.Nothing` (boş restricted) | **heç bir fiziki lokasiya** — heç vaxt "hamısı" kimi oxunmur |

`iam.location.view_all` ADMIN, AUDITOR, PROCUREMENT_MANAGER, PROCUREMENT_OFFICER və WAREHOUSE_KEEPER
rollarına verilir, BRANCH_USER-ə **verilmir**. Yeni rol heç bir icazə ilə başladığı üçün defolt
məhdudiyyətlidir — fail-closed. Filtr bütün lokasiyaya bağlı oxumalara şamildir: balanslar, hərəkətlər,
partiyalar, qəbullar, məxariclər, sayımlar, tullantı, nümunə, qaytarma, tələblər, istehlak satış/qaçışları
və fərq hesabatı. Məxaric və tələb sənədləri **hər iki ucu** ilə görünür (mənbə və ya hədəf filialdırsa),
əks halda filial ona gələn məxarici görə bilməzdi.

> **Kontraktla fərq:** `identity.v1.yaml` `Me.locationIds` üçün "boş = məhdudiyyət yoxdur" yazır. Bu, mərkəzi
> rollar üçün **doğru qalır** (onlarda `iam.location.view_all` var). Filial istifadəçisi üçün boş siyahı indi
> "heç nə" deməkdir. Kontraktın mətni yenilənməlidir; JSON forması dəyişmir.

### 8.18. `common_attachment`-ə `status` və `scan_result` sütunları

SPEC §11-in DDL-ində əlavələr tək addımda yazılır, halbuki presign → yükləmə → complete axınında sətir
obyektdən **əvvəl** yaranır. `status ENUM('PENDING','SCANNING','READY','REJECTED')` və `scan_result`
əlavə edilib; `PENDING` sətir siyahıda və `GET /attachments/{id}`-də görünmür, `download-url` isə
`409 ATTACHMENT_NOT_READY` verir. `entity_id = 0` kontraktdakı `entityId: null` üçün sentineldir
(sütun `NOT NULL` qalır).

Tamamlama zamanı iki fərqli uyğunsuzluq ayrılır: **presign anında imzalanmış** checksum ilə saxlanan
baytlar uyuşmursa sənəd `REJECTED` olur və obyekt silinir (icazə verilən məzmun deyil), amma
`complete` gövdəsində client-in **təkrar yazdığı** checksum/ETag səhvdirsə cavab `422`-dir və sətir
`PENDING` qalır — bir yazı səhvi düzgün yükləməni məhv etməməlidir.

### 8.19. Backend CI-ın heç vaxt keçməməsi: repo kökündəki `.editorconfig`

`.editorconfig` repo kökündədir və `csharp_style_namespace_declarations = file_scoped:warning` qoyur;
`Directory.Build.props`-dakı `TreatWarningsAsErrors` + `EnforceCodeStyleInBuild` ilə birlikdə EF-in
generasiya etdiyi hər miqrasiya (blok namespace) **`error IDE0161`** verirdi. CI tam checkout edir, ona görə
qırmızı idi; README-dəki lokal əmr isə yalnız `backend/`-i mount edirdi, yəni o fayl konteynerdə yox idi və
build yaşıl görünürdü — nasazlıq lokalda **görünməz** idi.

Düzəliş: `backend/.editorconfig` (root **deyil**, kökün üstünə qatlanır) `src/**/Persistence/Migrations/*.cs`
üçün `generated_code = true` və IDE stil qaydalarını söndürür. Bunlar generasiya olunmuş kod-dur; əl ilə
yazılmış koda heç nə dəyişmir. §1-dəki əmr indi repo kökünü mount edir, yəni lokal build CI ilə eynidir.

### 8.10. JSON-da enum-lar UPPER_SNAKE-dir (platforma səviyyəsində dəyişiklik)

`ConfigureHttpJsonOptions`-da `JsonStringEnumConverter` indi `JsonNamingPolicy.SnakeCaseUpper` ilə
qurulur. Səbəb: kontraktlar və MySQL ENUM sütunları `FOOD_PRODUCT` / `COUNT_ADJUST` / `V_SUPPLIER`
yazır, `System.Text.Json` isə policy olmadan yalnız PascalCase üzvün adını (`FoodProduct`) — üstəlik
yalnız hərf registrindən asılı olmayaraq — tanıyır. Nəticədə `"componentType":"FOOD_PRODUCT"`
**500** verirdi. Tək sözdən ibarət dəyərlər (`ACCEPTED`, `MANUAL`, `SUBMITTED`) hər iki halda işləyir,
ona görə mövcud endpoint-lərdə davranış dəyişmir.

### 8.9. Consumption modulunda dizayn sənədindən kənarlaşmalar

`docs/architecture/branch-operations.md` §4-dəki DDL bloku ilə generasiya olunan sxem arasındakı
fərqlər — hər biri şüurlu və səbəbi ilə:

| Fərq | Səbəb |
|---|---|
| `cons_recipe_line.uq_rline`, `cons_sales_line.uq_sline`, `cons_run_line.uq_rl` indekslərinə `tenant_id` prefiksi əlavə olunub | SPEC §6.5 hər unikal indeksin `tenant_id` ilə başlamasını tələb edir və arxitektura testi bunu yoxlayır — §8.4-dəki eyni qərar |
| `cons_run`-a `failure_reason VARCHAR(500) NULL` sütunu əlavə olunub | Kontraktdakı `ConsumptionRun.failureReason` sahəsi `status = FAILED` üçün məcburidir; DDL-də qarşılığı yox idi |
| `cons_menu_item`-də `updated_at`/`updated_by` var | `AuditableEntity` (SPEC §6.2 məcburi audit sütunları); DDL-də onsuz da vardı |
| `cons_recipe`, `cons_sales_import`, `cons_run` `IAuditable` **deyil** | DDL onlar üçün `created_at`/`created_by` (resept) və `imported_at`/`imported_by` (satış) verir; `IAuditable` ikinci dəst sütun yaradardı. `row_version` (`IVersioned`) hər üçündə var |

Dizayn sənədinin açıq buraxdığı və burada həll olunan məsələlər:

- **`yield_portions` düsturda görünmür.** Satılan maddə üçün o, 1-dir, ona görə sənəddəki düstur
  düzdür. Alt-resept üçün («sous kimi yarımfabrikatlarda 1-dən böyük olur») tərkib sətirləri bir
  **hazırlanışı** təsvir edir, ona görə `÷ yield_portions` tətbiq olunur. `yield_portions = 1`-də
  düstur hərfi mənada sənəddəki düsturdur.
- **`SUB_RECIPE` sətrində `qty_per_portion` nəyi ölçür.** Alt-reseptin **porsiya sayını**; `uom_id`
  orada çevrilmə üçün istifadə olunmur (alt-resept stokda saxlanılan məhsul deyil).
- **Storno-dan sonra eyni gün.** `uq_run_day` bir filial-gün üçün bir sətir buraxır, ona görə
  `REVERSED` sənəd yenidən hesablanıb (`POST /runs/{id}/calculate`) yenidən post edilir; ikinci sətir
  yaradılmır. Ledger-də həm orijinal, həm `REVERSAL`, həm də yeni qrup görünür.
- **`PERIOD_CLOSED` nə qədər genişdir.** Yoxlama tenant üzrə deyil, **menyu maddəsi** üzrədir (maddənin
  özü + onu alt-resept kimi istifadə edən maddələr): əks halda ilk post edilmiş gündən sonra yeni
  menyu maddəsinə resept bağlamaq mümkün olmazdı.
- **Çatışmazlıq rəqəmini kim təyin edir.** Hesablama zamanı `posted = min(theoretical, available)`
  planlaşdırılır, lakin **son söz Inventory-nindir**: o, balansları `FOR UPDATE` ilə kilidlədikdən
  sonra real ayırmanı qaytarır və `cons_run_line` həmin rəqəmlə yenilənir (`Settle`). Beləliklə
  plan ilə post arasındakı yarış (məsələn araya düşən tullantı sənədi) mənfi qalıq yarada bilmir.
- **Bütün gün çatışmazlıq olduqda.** Post ediləcək heç nə qalmırsa ikili yazılışlı qrup yaranmır
  (`MovementGroup` ən azı iki sətir tələb edir); sənəd `POSTED` olur, `movement_group_id` isə `NULL`
  qalır — kontraktda bu sahə nullable-dır.
- **İki tranzaksiya.** Inventory-nin post etməsi öz tranzaksiyasında commit olunur, sonra Consumption
  `run.status = POSTED` yazır — dizayn sənədinin ardıcıllıq diaqramı da belədir. Aradakı çökmə
  `CALCULATED` sənəd + post edilmiş qrup buraxır; təkrar post `uq_mg_idem` sayəsində yeni qrup
  yaratmır, eyni `movement_group_id`-ni qaytarır.

### 8.8. Hələ tam icra olunmamış hissələr (skeleton)

Bunlar SPEC-də var, layihə strukturunda yeri hazırdır, amma məntiqi növbəti mərhələdə yazılacaq:

- **Procurement yazı endpoint-ləri** — `Requisition`, `Rfq`, `Quotation`, `PurchaseOrder` yaratma/təsdiq axınları,
  `PriceHistory`, `SplitCheckLog`. Oxu tərəfi (`GET /purchase-orders`) işləkdir. (Faza 2)
- `GET /inventory/goods-receipts/{id}` cavabındakı `attachmentIds` həmişə boşdur: `common_attachment` Documents
  modulunundur və Inventory → Documents asılılığı ADR-001-də icazəli deyil. İnterfeys əlavələri
  `GET /documents/attachments?entityType=GOODS_RECEIPT&entityId=…` ilə oxuyur.
- `GoodsReceiptSummary.poDocNo` / `IssueSummary.requestDocNo` siyahı cavablarında `null`-dır (detal cavabında
  doludur) — siyahı üçün əlavə join hələ yazılmayıb; kontraktda hər ikisi nullable-dır.
- Notification/Reporting/Integration consumer-ləri: cədvəllər və idempotentlik indeksləri hazırdır,
  RabbitMQ consumer-ləri Faza 3-də əlavə olunacaq.
- `IdempotencyEndpointFilter` Redis cache-i işləkdir, lakin cavabın tam replay-i sadələşdirilmiş formadadır.
- **Əlavələr:** `AttachmentOrphanCleaner` (SPEC §15) job-u yoxdur — silinmə və rədd anında obyekt onsuz da
  best-effort silinir; `thumbnailAvailable` həmişə `false`; POSTED sənədə bağlı əlavənin silinməsində
  `409 INVALID_STATE_TRANSITION` yoxdur, çünki Documents modulu sahib sənədin statusunu görə bilmir
  (spec §5 ona heç bir modul kontraktı vermir) — sahib tərəfdə yoxlama və ya hadisə lazımdır.
- **Identity:** `setUserLocations` virtual lokasiyanı rədd etmir (kontrakt `422` istəyir): Identity-nin
  MasterData-ya kontrakt asılılığı yoxdur və `masterdata → identity` istiqaməti onsuz da mövcud olduğu üçün
  əks asılılıq dövrə yaradardı. Yoxlama ya MasterData tərəfdən, ya da hadisə ilə əlavə edilməlidir.

**Bu buraxılışda bağlananlar** (əvvəl bu siyahıda idi): Identity yazı endpoint-ləri (15 əməliyyat) və
`iam` sxeminin doldurulması, MasterData-nın 27 əməliyyatı, fayl əlavələri (MinIO presign/complete/download),
`GET /inventory/settings` + `PUT /inventory/settings/{key}`, `GET /identity/me`-nin kontrakt forması,
`RolePermissionMap`-in avtorizasiya mənbəyi olmaqdan çıxıb yalnız bootstrap qalması.
Əvvəlki buraxılışdan: `inv_count` aqreqatı və `LOCATION_FROZEN`, `Issue`/`Transfer` (IN_TRANSIT),
`StockRequest`, `Waste`, `Sample`, `ReturnToVendor`, partiya status dəyişikliyi və hərəkət qrupunun storno-su.

---

## 9. Anbar sənədləri (inventory yazı endpoint-ləri)

Kontrakt: [inventory.v1.yaml](../contracts/openapi/inventory.v1.yaml). Bütün POST-lar `Idempotency-Key`
tələb edir, bütün dəyişdirici çağırışlar `rowVersion` ilə optimistik kilid yoxlayır və cavabda **bütöv sənədi**
qaytarır ki, client-in əlində həmişə təzə `rowVersion` olsun.

| Endpoint | İcazə | Ledger təsiri |
|---|---|---|
| `GET/POST /stock-requests`, `PUT /{id}`, `POST /{id}/submit\|cancel` | `inv.request.view` / `.create` | yoxdur (tələb sənədi) |
| `GET/POST /issues`, `POST /{id}/dispatch` | `inv.issue.view` / `.create` / `.dispatch` | mənbə −qty / `IN_TRANSIT` +qty |
| `POST /issues/{id}/confirm-receipt` | `inv.issue.confirm` | `IN_TRANSIT` −qty / hədəf +qty |
| `GET/POST /counts`, `POST /{id}/freeze\|lines\|submit\|approve\|post\|cancel` | `inv.count.*`, `inv.adjustment.approve` | post: `COUNT_ADJUST` — `V_ADJUSTMENT` ↔ lokasiya |
| `GET/POST /waste`, `POST /{id}/submit\|approve\|post` | `inv.waste.*` | post: lokasiya −qty / `V_WASTE` +qty |
| `GET/POST /samples`, `POST /{id}/post` | `inv.sample.view` / `.create` / `.post` | post: lokasiya −qty / `V_SAMPLE` +qty |
| `GET/POST /return-to-vendor`, `POST /{id}/send\|close` | `inv.rtv.view` / `.create` / `.post` | send: lokasiya −qty / `V_SUPPLIER` +qty |
| `GET /batches`, `GET /batches/{id}`, `POST /batches/{id}/status` | `inv.batch.view` / `.manage` | yoxdur |
| `GET /movements`, `GET /movement-groups/{id}`, `POST /{id}/reverse` | `inv.movement.view` / `.reverse` | reverse: `REVERSAL` qrupu (əks işarələr) |
| `GET /goods-receipts` (siyahı) | `inv.receipt.view` | yoxdur |
| `GET /settings`, `PUT /settings/{key}` | `inv.settings.view` / `.manage` | yoxdur (§12.4) |

### 9.1. Sayım (`inv_count`) — SPEC §12.6, §12.7

```
DRAFT ──freeze──▶ FROZEN ──lines──▶ COUNTING ──submit──▶ REVIEW ──approve──▶ APPROVED ──post──▶ POSTED
  └──────────────────────── cancel ────────────────────────────────────────────┘
```

- **`freeze`** lokasiyanın bütün balans sətirlərini `SELECT … FOR UPDATE` ilə kilidləyir və `book_qty`-ni
  **həmin an** yazır. Kilid bütün lokasiyanı əhatə edir (əhatə filtri yaddaşda tətbiq olunur), ona görə
  snapshot ilə blok arasında heç bir post araya girə bilmir.
- **Blok**: `FROZEN`, `COUNTING`, `REVIEW`, `APPROVED` statuslarında həmin lokasiyada
  RECEIPT / ISSUE / TRANSFER / WASTE / SAMPLE / CONSUMPTION post-u `409 LOCATION_FROZEN` verir.
  `inv_setting.block_transactions_during_count = false` ilə söndürülə bilər (TOR §36).
- **Fərq**: `varianceQty = counted − book`, `variancePct = variance ÷ |book| × 100` (`DECIMAL(9,4)`).
  `book = 0` halında fərq ±100 % sayılır.
- **Səbəb kodu**: sıfırdan fərqli hər sətirdə `reasonCodeId` (qrup `ADJUSTMENT`) **məcburidir** — həm sətir
  daxil ediləndə, həm post anında yoxlanılır (`422 REASON_CODE_REQUIRED`). Excel-dəki izahsız `+510` bu
  modeldə mümkün deyil.
- **Approval**: `|variancePct| > count_variance_approval_threshold_pct` olan sətir varsa `requiresApproval`
  qalxır; təsdiq `inv.adjustment.approve` tələb edir. Sayımı aparan şəxs onu təsdiqləyə bilmir (SoD).
- **Post**: hər fərqli sətir üçün artıqlıq → `V_ADJUSTMENT` −/lokasiya +, kəsir → lokasiya −/`V_ADJUSTMENT` +,
  `unitCost` = dondurma anındakı `avg_unit_cost`. Fərq yoxdursa qrup yaranmır (`adjustGroupId = null`) —
  ikili yazılış ən azı iki sətir tələb edir, boş sənəd isə səs-küydür. Hər iki halda lokasiya açılır və
  `CountVarianceApproved` outbox-a düşür.

### 9.2. Məxaric və transfer (`inv_issue`) — iki addım

`dispatch` malı `IN_TRANSIT`-ə köçürür, `confirm-receipt` isə oradan hədəfə. Filial göndərilləndən az qəbul
edərsə fərq **`IN_TRANSIT`-də qalır** və sənəd `DISCREPANCY` statusuna düşür: itki görünən qalır və kimsə onu
düzəliş sənədi ilə bağlamalıdır — iki lokasiya arasında səssizcə yox olmur. Fərqli sətir `reasonCodeId` **və**
`note` tələb edir (`422 DISCREPANCY_REASON_REQUIRED`).

FEFO/FIFO təklifindən fərqli partiya seçilərsə `batchOverrideReasonCodeId` məcburidir
(`422 BATCH_OVERRIDE_REASON_REQUIRED`, SPEC §12.4); təklifin özü `inv_issue_line.suggested_batch_id`-də
saxlanılır ki, sonradan yoxlana bilsin.

### 9.3. Ortaq post mühərriki

`IDocumentPostingEngine` (Inventory.Application) hər anbar sənədinin ledger-ə çevrilmə yeridir: mənbə
balanslarını `FOR UPDATE` ilə kilidləyir, FEFO/FIFO ayırmasını işlədir (`BLOCKED`/`EXPIRED`/`QUARANTINE`
partiyaları buraxır), `−qty` / `+qty` cütünü yazır və balans proyeksiyasını yeniləyir. Consumption yolundan
fərqi: **miqdarı kəsmir** — çatışmazlıq burada xətadır (`409 INSUFFICIENT_STOCK`), çünki insan "bu qədər
göndərirəm" deyib. Mühərrik çağıranın tranzaksiyasının içində işləyir, ona görə sənəd statusu və hərəkətlər
birlikdə commit olunur.

---

## 10. Kod konvensiyaları (SPEC Əlavə A)

- File-scoped namespace, `Result<T>` (biznes xətaları üçün exception atılmır), `private set` + factory metodları.
- Hər async metodda `CancellationToken`; `DateTimeOffset` (UTC saxlama).
- Yalnız `decimal` — `double`/`float` `BannedSymbols.txt` ilə Domain və Application layihələrində analizator
  səviyyəsində qadağandır, bütün layihələrdə isə arxitektura testi ilə.
- Bütün read sorğularında `AsNoTracking()`.
- Kod və kod şərhləri ingilis dilində, sənədlər Azərbaycan dilində.

---

## 11. Consumption modulu (filial istehlakı)

Qərar: [ADR-012](../docs/adr/ADR-012-branch-consumption-model.md) · Dizayn:
[branch-operations.md](../docs/architecture/branch-operations.md) · Kontrakt:
[consumption.v1.yaml](../contracts/openapi/consumption.v1.yaml) · Domen:
[`Wms.Consumption.Domain/README.md`](src/Modules/Consumption/Wms.Consumption.Domain/README.md).

Filial stoku indiyədək yalnız artırdı. Modul satılan **menyu maddəsini** reseptə vurub **nəzəri
məxaric** hesablayır və onu adi ikili yazılışlı sənəd kimi post edir:
`RESTAURANT −qty` / `V_CONSUMPTION +qty`, `doc_type = CONSUMPTION`.

```
satış (POS | CSV | MANUAL) → cons_sales_import
        → BOM partlaması (satış tarixinin resept versiyası, dərinlik ≤ 5)
        → cons_run + cons_run_line   (theoretical / posted / shortfall)
        → Inventory: tək tranzaksiyada FOR UPDATE → FEFO/FIFO → inv_movement → inv_balance
```

- **Sərhəd:** modul `inv_*` cədvəllərinə heç vaxt toxunmur. Post etmə `Wms.Inventory.Contracts`-dakı
  `IStockPostingService.PostConsumptionAsync(...)` ilə Inventory-yə verilir; kilid, partiya ayırması
  (`BLOCKED`/`EXPIRED`/`QUARANTINE` xaric), hərəkət sətirləri, balans və audit hamısı Inventory-nin
  **bir** tranzaksiyasındadır. Fərq hesabatı üçün `IStockMovementReader.GetPeriodFlowsAsync(...)` var.
- **Job-lar** (`Jobs__Enabled=true`, yəni `wms-worker`): `consumption-runner` (gündəlik 03:00, balans
  özünüyoxlamalarından sonra) dünənin `SUBMITTED` satışlarını hesablayıb post edir;
  `consumption-sales-import-reminder` (gündəlik 11:00) satışı yüklənməmiş filialları xəbərdarlıq kimi loglayır.
- **Hadisələr** (`common_outbox`): `SalesImported`, `ConsumptionPosted`, `ConsumptionShortfallDetected`,
  `SalesItemUnmapped`.
- **İcazələr:** `cons.recipe.manage`, `cons.recipe.view`, `cons.sales.import`, `cons.run.calculate`,
  `cons.run.post`, `cons.variance.view`. Storno `inv.movement.reverse` tələb edir.
  `unitCost`/`costAmount` sahələri `master.product.view_cost` olmayan istifadəçiyə **göndərilmir**.

### 11.1. Bir istehlak dövrünü əl ilə keçmək

Tələb: `master_uom`, `master_product` (+ `master_product_uom` əmsalları), `RESTAURANT` tipli lokasiya,
**`V_CONSUMPTION` tipli virtual lokasiya** və filialda başlanğıc qalıq. `V_CONSUMPTION` yoxdursa post
`422 VIRTUAL_LOCATION_MISSING` verir.

```bash
GW=http://localhost:5001/api/v1/consumption
TOKEN=$(scripts/keycloak-token.sh admin)
H=(-H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json')
idem() { printf -- '-H'; printf 'Idempotency-Key: %s' "$(uuidgen)"; }   # hər POST üçün yeni GUID

# 1. Menyu maddəsi (satılan) və yarımfabrikat
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/menu-items   -d '{"code":"SW-BMT","posCode":"PLU-1001","name":"Italian BMT 15 sm","category":"Sandwich"}'
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/menu-items   -d '{"code":"SAUCE-CHI","posCode":"PLU-9001","name":"Chipotle sousu","isSubRecipe":true}'

# 2. Alt-reseptin versiyası: 1 hazırlanış = 10 porsiya, 500 q yağ
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/menu-items/2/recipes   -d '{"validFrom":"2026-01-01","yieldPortions":"10.0000",
       "lines":[{"lineNo":1,"componentType":"FOOD_PRODUCT","productId":3,"qtyPerPortion":"500.0000","uomId":1}]}'
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/recipes/1/activate   -d '{"validFrom":"2026-01-01","rowVersion":1}'

# 3. Əsas resept: 20 q kahı (itki 8 % → yieldPct 92), 0,15 kq toyuq, 2 porsiya sous
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/menu-items/1/recipes   -d '{"validFrom":"2026-01-01","yieldPortions":"1.0000","lines":[
        {"lineNo":1,"componentType":"FOOD_PRODUCT","productId":1,"qtyPerPortion":"20.0000","uomId":1,"yieldPct":"92.0000"},
        {"lineNo":2,"componentType":"FOOD_PRODUCT","productId":2,"qtyPerPortion":"0.1500","uomId":2},
        {"lineNo":3,"componentType":"SUB_RECIPE","subMenuItemId":2,"qtyPerPortion":"2.0000","uomId":3}]}'
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/recipes/2/activate   -d '{"validFrom":"2026-01-01","rowVersion":1}'

# BOM önizləməsi (stokdan heç nə çıxmır)
curl -s "${H[@]}" "$GW/recipes/2/explosion?portions=100"

# 4. Günün satışı → təsdiq
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/sales-imports   -d '{"locationId":11,"businessDate":"2026-09-20","source":"MANUAL",
       "lines":[{"menuItemId":1,"qtySold":"100.0000","grossAmount":"1200.0000"}]}'
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/sales-imports/1/submit -d '{}'

# CSV ilə (UTF-8 və ya Windows-1254, ayırıcı avtomatik, maks 5 MB):
# curl -s -H "Authorization: Bearer $TOKEN" -H "Idempotency-Key: $(uuidgen)" -X POST \
#   $GW/sales-imports/upload-csv -F locationId=11 -F businessDate=2026-09-20 -F file=@sales.csv

# 5. Hesablama (DRAFT → CALCULATED); postImmediately=true dərhal post edir
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/runs -d '{"salesImportId":1}'

# 6. Post (CALCULATED → POSTED) və nəticə
curl -s "${H[@]}" -H "Idempotency-Key: $(uuidgen)" -X POST $GW/runs/1/post -d '{}'
curl -s "${H[@]}" $GW/runs/1
```

Ledger-i yoxlamaq:

```sql
SELECT g.doc_no, g.doc_type, SUM(m.qty_base) AS zero_sum
  FROM inv_movement m JOIN inv_movement_group g ON g.id = m.group_id
 WHERE g.doc_type = 'CONSUMPTION' GROUP BY g.id;          -- hər qrup 0 verməlidir

SELECT product_id, location_id, qty_on_hand FROM inv_balance ORDER BY location_id, product_id;
SELECT doc_no, status, shortfall_count, unmapped_count, movement_group_id FROM cons_run;
SELECT product_id, theoretical_qty_base, posted_qty_base, shortfall_qty_base FROM cons_run_line;
```

Düzəliş yalnız storno ilə: `POST /runs/{id}/reverse` (`reasonCodeId` məcburidir) sənədi `REVERSED`
edir və Inventory-də `REVERSAL` qrupu yaradır; həmin gün `POST /runs/{id}/calculate` + `/post` ilə
yenidən hesablanır.

---

## 12. Identity, MasterData, əlavələr və parametrlər (Faza 1)

Bu dörd sahə birlikdə "sistemin real tenant üçün qurula bilməsi" deməkdir: rol və icazə olmadan heç nə
avtorizasiya olunmur, səbəb kodu olmadan heç bir ləğv/tullantı/düzəliş sənədi yazıla bilmir.

### 12.1. Identity (`/api/v1/identity`) — 17/17 əməliyyat

| Endpoint | İcazə | Qeyd |
|---|---|---|
| `GET /me` | `iam.me.view` | kontraktdakı `Me`: `user`, `tenant`, `roles`, **`permissions`**, `locationIds`, `canViewCost`, `activeDelegations` |
| `GET /tenant` | `iam.me.view` | valyuta, timezone, locale — client formatlaşdırmanı buradan alır |
| `GET /users` | `iam.user.view` | `q`, `isActive`, `roleCode`, `locationId` filtrləri + səhifələmə |
| `POST /users` · `GET/PUT /users/{id}` | `iam.user.manage` / `.view` | `PUT` `rowVersion` tələb edir |
| `PUT /users/{id}/roles` · `PUT /users/{id}/locations` | `iam.user.manage` | tam əvəzləmə; cache dərhal invalidasiya olunur |
| `GET /roles` · `POST /roles` · `GET /roles/{id}` | `iam.role.view` / `.manage` | sistem rolları `isSystem=true` |
| `PUT /roles/{id}/permissions` | `iam.role.manage` | naməlum kod → `422 UNKNOWN_PERMISSION` |
| `GET /permissions` | `iam.role.view` | 101 kodluq kataloq, `module` filtri, `isCritical` bayrağı |
| `GET/POST /delegations`, `GET/DELETE /delegations/{id}` | `iam.delegation.view` / `.create` | `DELETE` sətri silmir, `validTo`-nu bu günə çəkir |

**SoD (SPEC §7.1)** iki yerdə də tətbiq olunur və hər ikisi `422 SEGREGATION_OF_DUTIES` verir:
`WAREHOUSE_KEEPER` roluna `master.product.view_cost` əlavə etmək, **və** həmin rolu maya dəyərini verən
başqa rolla eyni istifadəçidə birləşdirmək (`createUser`, `setUserRoles`).

### 12.2. MasterData (`/api/v1/masterdata`) — 29/29 əməliyyat

`GET /reason-codes` artıq işləyir — bu, bütün ləğv/tullantı/düzəliş gövdələrinin bloklayıcısı idi.

Dəyişməzlik qaydaları (yaradıldıqdan sonra dəyişmir, hər biri öz kodu ilə **422**):
`sku` → `SKU_IMMUTABLE`, `base_uom_id` → `BASE_UOM_IMMUTABLE`, `location_type` →
`LOCATION_TYPE_IMMUTABLE`, `reason_group` → `REASON_GROUP_IMMUTABLE`, kateqoriyanın `product_type` →
`PRODUCT_TYPE_IMMUTABLE`. Qayda **domen entity-sindədir**, endpoint-də deyil.

`master_product_uom.factor_to_base` **heç vaxt UPDATE edilmir** (SPEC §12.1): yeni əmsal köhnə sətri
`valid_to = validFrom − 1` ilə bağlayır və yeni sətir açır; üst-üstə düşən interval
`422 UOM_VALIDITY_OVERLAP` verir.

Unikallıq pozuntuları DB constraint-inə çatmadan **409** olur (`SKU_ALREADY_EXISTS`,
`REASON_CODE_ALREADY_EXISTS`, …). Silmə yoxdur — `isActive` ilə deaktivasiya.

> ⚠️ Seeder-in yaratdığı səbəb kodları defis daşıyır (`WST-EXP`), kontraktdakı `ReasonCodeCreate.code`
> nümunəsi isə `^[A-Z0-9_]{1,32}$`-dir. Mövcud sətirlər işləyir, amma API vasitəsilə eyni formada yenisini
> yaratmaq olmur. Ya seeder alt-xəttə keçməli, ya kontrakt defisi qəbul etməlidir.

### 12.3. Fayl əlavələri (`/api/v1/documents`) — 6/6 əməliyyat

```
POST /attachments/presign  → PENDING sətir + presigned PUT URL (25 MB, 5 tip)
      ↓ client birbaşa MinIO-ya PUT edir (uploadHeaders ilə)
POST /attachments/{id}/complete → StatObject (ölçü + content-type) → SHA-256 → ClamAV → READY
GET  /attachments/{id}/download-url → qısa ömürlü presigned GET
```

- **25 MB** həm presign-da (elan edilən ölçü), həm complete-də (MinIO-nun bildirdiyi real ölçü) yoxlanılır.
- **Beş tip:** PDF, JPEG, PNG, XLSX, DOCX. Complete-də saxlanan content-type presign-dakı ilə tutuşdurulur —
  presigned PUT yalnız `host`-u imzalayır, ona görə client başqa tiplə yükləyə bilər; bu yoxlama onu bağlayır.
- **Virus skanı** `Antivirus__Enabled=true` olduqda ClamAV INSTREAM ilə; yoluxmuş fayl silinir və
  `422 ATTACHMENT_INFECTED`, clamd əlçatmazsa `503 VIRUS_SCAN_UNAVAILABLE` (fail-closed).
- **Storage key** həmişə serverdə qurulur: `{tenantId}/{entityType}/{entityId}/{guid}/{təmizlənmiş ad}`.
- Brauzerdən yükləmə üçün MinIO CORS lazımdır (`MINIO_API_CORS_ALLOW_ORIGIN`, dev-də `*`) və presigned URL
  `Minio__PublicEndpoint` üçün imzalanır.

### 12.4. `inv_setting` (`/api/v1/inventory/settings`)

`GET` doqquz açarı tipi, defoltu və `ENUM` üçün icazəli dəyərləri ilə qaytarır (sətir hələ yoxdursa
default görünür). `PUT /settings/{key}` dəyəri **açarın tipinə görə** yoxlayır: `INT` (diapazonla),
`DECIMAL` (0–100 %, min ayırıcı qəbul edilmir — `2,5` `2.5`-in yazı səhvidir), `BOOL`
(`true/1/yes` → `true`), `ENUM` (`MOVING_AVERAGE` | `FIFO`). Səhv dəyər `422 INVALID_SETTING_VALUE`,
naməlum açar `404 SETTING_NOT_FOUND`. Dəyişiklik `common_audit_log`-a köhnə/yeni dəyərlə düşür.
`inv.settings.manage` kritik icazədir: defolt qrantlarda yalnız ADMIN-dədir.
