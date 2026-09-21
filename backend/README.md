# WMS Backend — .NET 10 modulyar monolit

Satınalma və Anbar İdarəetmə Platformasının backend-i. Mənbə sənədlər:
[`docs/SPEC-Satinalma-Anbar-Platformasi.md`](../docs/SPEC-Satinalma-Anbar-Platformasi.md) (texniki icra) və
[`docs/CONVENTIONS.md`](../docs/CONVENTIONS.md) (ortaq adlar).

**Bir solution, bir image, modul üzrə deployment** (ADR-001): eyni `Wms.Host.Api` həm tək konteynerdə
bütün modullarla (on-prem), həm də modul başına ayrıca konteynerlə (cloud) işləyir.

---

## 1. Tez başlanğıc

Lokal `dotnet` SDK tələb olunmur — hər şey Docker-də işləyə bilər.

```bash
# Build (Release, TreatWarningsAsErrors=true)
docker run --rm -v "$PWD":/src -w /src mcr.microsoft.com/dotnet/sdk:10.0 \
  dotnet build Wms.slnx -c Release

# Unit + arxitektura + contract testləri (integration testlər kənarda)
docker run --rm -v "$PWD":/src -w /src mcr.microsoft.com/dotnet/sdk:10.0 \
  dotnet test Wms.slnx -c Release --filter "Category!=Integration"

# Integration testlər (Testcontainers — real MySQL 8.4 konteyneri qaldırır)
docker run --rm -v "$PWD":/src -w /src \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e TESTCONTAINERS_RYUK_DISABLED=true \
  -e TESTCONTAINERS_HOST_OVERRIDE=host.docker.internal \
  --add-host=host.docker.internal:host-gateway \
  mcr.microsoft.com/dotnet/sdk:10.0 \
  dotnet test tests/Wms.Inventory.IntegrationTests -c Release
```

> `TESTCONTAINERS_HOST_OVERRIDE` yalnız testləri **SDK konteynerinin içindən** işlədəndə lazımdır:
> Testcontainers MySQL portunu **host-un** loopback-inə map edir, SDK konteynerinin `127.0.0.1`-i isə
> başqadır. Lokal SDK ilə (`dotnet test tests/Wms.Inventory.IntegrationTests`) bu dəyişənlər lazım deyil.

NuGet paketlərini təkrar yükləməmək üçün cache-i mount edin:
`-v "$HOME/.nuget/packages":/root/.nuget/packages`.

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

Nəticə: **49 biznes cədvəli + 10 history cədvəli + 12 `hangfire_*` = 71**.
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

## 6. Testlər

| Layihə | Nə yoxlayır | Sayı |
|---|---|---|
| `Wms.Inventory.UnitTests` | SPEC §12 invariantları: yuvarlaqlaşdırma, ikili yazılış, mənfi qalıq, FEFO/FIFO, hərəkətli orta, tolerans, approval qaydası, AZ əlifba sırası | 93 |
| `Wms.ArchitectureTests` | SPEC §17.4: modul sərhədləri, tenant query filter, unique index `tenant_id`-dən başlayır, `double`/`float` yoxdur, `inv_balance` public setter-siz, cədvəl prefiksləri, decimal precision | 170 |
| `Wms.Api.ContractTests` | Host qalxır, `/health/live`, auth tələbi, qismən deployment davranışı | 7 |
| `Wms.Inventory.IntegrationTests` | Testcontainers + real MySQL 8.4, sxem **real miqrasiyalardan** (`MigrateAsync`, §5.3): qəbul → balans → ledger sıfıra balanslaşır, idempotency key unikallığı, `inv_movement` partisiyalaşdırma DDL-i | 2 (`Category=Integration`) |
| `Wms.Consumption.UnitTests` | ADR-012: BOM partlaması (`yield_pct`, `yield_portions`, alt-resept, attach rate, yuvarlaqlaşdırma), dövr aşkarlanması, dərinlik limiti, resept versiyasının tarixə görə seçimi, `posted = min(theoretical, available)`, CSV parse (UTF-8 + Windows-1254 + pozuq sətirlər) | 69 |
| `Wms.Consumption.IntegrationTests` | Testcontainers + real MySQL 8.4 və üç modulun real DI qrafı: tam dövr (resept → satış → hesablama → post), qrupun sıfıra balanslaşması, filial qalığının düşməsi = `V_CONSUMPTION`-un artması, qəsdən yaradılmış çatışmazlıq mənfi qalıq yaratmır, `DUPLICATE_BUSINESS_DATE` | 3 (`Category=Integration`) |

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

Bunlar SPEC-də var, layihə strukturunda yeri hazırdır, amma məntiqi Faza 1/2-də yazılacaq:

- Inventory: `Issue`/`Transfer` (IN_TRANSIT), `Count` (dondurma, §12.7 — `LocationFreezeChecker` hazırda həmişə
  `false` qaytarır və TODO daşıyır), `Waste`, `Sample`, `ReturnToVendor` aqreqatları.
  **Nəticə:** Consumption `409 LOCATION_FROZEN` yolunu çağırır (`IStockPostingService.IsLocationFrozenAsync`
  həm sənəd açılanda, həm post edilən tranzaksiyanın içində), lakin `inv_count` aqreqatı olmadığı üçün
  bu şərt canlı sistemdə heç vaxt `true` olmur — yalnız unit səviyyəsində sübut olunub.
- Consumption: `GET /variance` və `GET /portion-compliance` ledger axınlarından (`IStockMovementReader`)
  hesablanır və işləkdir, lakin `COUNT_ADJUST` sənədi hələ yaradıla bilmədiyi üçün canlı datada fərq
  həmişə sıfır çıxır (SPEC-dəki Faza 3 işi).
- Procurement: `Rfq`, `Quotation`, `PriceHistory`, `SplitCheckLog`.
- `IdempotencyEndpointFilter` Redis cache-i işləkdir, lakin cavabın tam replay-i sadələşdirilmiş formadadır.
- `RolePermissionMap` — Identity `iam_role_permission` məlumatı oxunanadək istifadə olunan bootstrap xəritəsidir
  (TODO qeydi ilə). Endpoint-lərdəki `.RequirePermission(...)` artıq işləyir.
- Notification/Reporting/Integration consumer-ləri: cədvəllər və idempotentlik indeksləri hazırdır,
  RabbitMQ consumer-ləri Faza 2/3-də əlavə olunacaq.

---

## 9. Kod konvensiyaları (SPEC Əlavə A)

- File-scoped namespace, `Result<T>` (biznes xətaları üçün exception atılmır), `private set` + factory metodları.
- Hər async metodda `CancellationToken`; `DateTimeOffset` (UTC saxlama).
- Yalnız `decimal` — `double`/`float` `BannedSymbols.txt` ilə Domain və Application layihələrində analizator
  səviyyəsində qadağandır, bütün layihələrdə isə arxitektura testi ilə.
- Bütün read sorğularında `AsNoTracking()`.
- Kod və kod şərhləri ingilis dilində, sənədlər Azərbaycan dilində.

---

## 10. Consumption modulu (filial istehlakı)

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

### 10.1. Bir istehlak dövrünü əl ilə keçmək

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
