# Satınalma və Anbar İdarəetmə Platforması

Restoran şəbəkələri üçün **multi-tenant SaaS** satınalma və anbar platforması.
İlk müştəri — **Subway Azərbaycan (15 filial)**; hazırda proses Excel faylları üzərində
aparılır və platforma onu əvəz edir.

Sistemin texniki mövqeyi üç qərarla müəyyən olunur:

- **Balans heç vaxt birbaşa yazılmır.** Hər qalıq ikili yazılışlı ledger-dən törəyir —
  Excel-dəki izahsız `+510` sabiti bu modeldə mümkün deyil ([ADR-003](docs/adr/ADR-003-double-entry-ledger.md), [ADR-004](docs/adr/ADR-004-balance-as-projection.md)).
- **Float qadağandır.** Miqdar və məbləğ DB-də `DECIMAL`, JSON-da **string**, web-də
  `decimal.js`, mobildə `decimal` paketi ([ADR-008](docs/adr/ADR-008-decimal-on-client.md)).
- **Modulyar monolit, modul üzrə deployment.** Eyni image cloud-da 7 konteyner, on-prem-də
  tək konteyner kimi işləyir ([ADR-001](docs/adr/ADR-001-modular-monolith-per-module-deployment.md)).

**Stack:** .NET 10 · MySQL 8.4 · Redis · RabbitMQ · MinIO · Keycloak · YARP · React 18 + Vite (web) · Flutter 3.47 (mobil)

---

## Repo düzülüşü

| Qovluq | Nədir | Sənəd |
|---|---|---|
| [`backend/`](backend) | .NET 10 modulyar solution (`Wms.slnx`), 8 modul, Minimal API | — |
| [`web/`](web) | Vite + React 18 + TypeScript — satınalma, menecer, admin, auditor | — |
| [`mobile/`](mobile) | Flutter pub-workspace monorepo — `apps/wms_mobile` + `packages/` (anbardar, filial) | — |
| [`contracts/`](contracts) | **OpenAPI 3.1 kontraktları** — API-nin həqiqət mənbəyi | [contracts/README.md](contracts/README.md) |
| [`deploy/`](deploy) | docker-compose (dev, on-prem), Dockerfile-lar, k8s, Keycloak realm, MySQL init | [deploy/README.md](deploy/README.md) |
| [`docs/`](docs) | SPEC, konvensiyalar, ADR-lər, arxitektura, UX, dizayn sistemi | aşağıda |
| [`docs/design-system/`](docs/design-system) | **WMS Enterprise** dizayn sistemi — tokenlər, 14 komponent, brend kitabı | [design-system/README.md](docs/design-system/README.md) |
| [`docs/adr/`](docs/adr) | 13 arxitektura qərarı | [adr/README.md](docs/adr/README.md) |
| [`docs/architecture/`](docs/architecture) | C4, ardıcıllıq, vəziyyət və ER diaqramları (Mermaid) | [overview.md](docs/architecture/overview.md) · [data-model.md](docs/architecture/data-model.md) |
| [`docs/ux/`](docs/ux) | Rol × platforma ekran xəritəsi | [screen-map.md](docs/ux/screen-map.md) |
| [`scripts/`](scripts) | `dev-up` · `dev-down` · `dev-logs` · `db-migrate` · `keycloak-token` · `gen-client` | — |
| [`.github/workflows/`](.github/workflows) | CI: backend · web · mobile · contracts · deploy | — |

---

## Tələblər

| Alət | Versiya | Məcburi? |
|---|---|---|
| **Docker** (Compose v2.24+) | 24+ | **Bəli** — bütün infrastruktur, həmçinin lint və backend build burada işləyə bilər |
| **Node.js** | 22 LTS (npm 10+) | **Bəli** — `web/` (Vite + React) üzərində işləyirsinizsə |
| **Flutter** | 3.47.x (Dart 3.13.x) | `mobile/` (Flutter) üzərində işləyirsinizsə |
| .NET SDK | 10.0.100+ | **Opsional** — yoxdursa `make` avtomatik `mcr.microsoft.com/dotnet/sdk:10.0` konteynerinə keçir |
| `bash`, `curl` | — | Bəli (skriptlər üçün) |
| `jq` | — | Tövsiyə (`keycloak-token.sh --decode` üçün) |

Yoxlamaq üçün: `make doctor`

---

## Quick start — 5 addım

```bash
# 1. Port/parol konfiqurasiyası (bir dəfə)
cp deploy/.env.example deploy/.env

# 2. İnfrastruktur: MySQL, Redis, RabbitMQ, MinIO, Keycloak, Seq
make up                       # = scripts/dev-up.sh

# 3. Verilənlər bazası sxemi (EF miqrasiyaları + ledger qoruması)
make migrate                  # = scripts/db-migrate.sh

# 4. Backend
make backend-run MODULES=*    # lokal dotnet varsa host-da, yoxsa konteynerdə
#   və ya bir modul:  make backend-run MODULES=inventory

# 5a. Web (React) — satınalma, menecer, admin, auditor
make web-install              # npm ci (bir dəfə)
make gen-client-web           # OpenAPI → TypeScript client (kod gitignore-dadır)
make web-dev                  # Vite dev server, port 3001

# 5b. Mobil (Flutter) — anbardar, filial
make mobile-get               # pub workspace (bir dəfə)
make gen-client               # OpenAPI → Dart client (məcburi, kod gitignore-dadır)
make mobile-run               # qoşulmuş cihaz / emulyator
```

Web və mobil müstəqildir — yalnız biri üzərində işləyirsinizsə digərinin alətlərinə
ehtiyac yoxdur ([ADR-013](docs/adr/ADR-013-web-react-mobile-flutter.md)).

**Login:** dev istifadəçiləri — `admin`, `procurement`, `manager`, `keeper`, `branch1`, `auditor`.
**Parol = istifadəçi adı**, hamısı `tenant_id=1`.

Token-i birbaşa yoxlamaq üçün:

```bash
scripts/keycloak-token.sh keeper --decode
# aud=wms-api, tenant_id=1, realm_access.roles=[WAREHOUSE_KEEPER]
```

Dayandırmaq: `make down` (data qalır) · tam təmizləmə: `scripts/dev-down.sh --volumes`

---

## Servis ünvanları

Portlar `deploy/.env` faylından gəlir. **`deploy/.env.example` standart dəyərləri saxlayır;
`deploy/.env` (git-ignored) isə konkret maşına aid override-dır** — `scripts/dev-up.sh`
başlamazdan əvvəl tutulmuş portları xəbərdarlıq edir.

| Servis | Standart (`.env.example`) | Bu maşında (`.env`) | Qeyd |
|---|---|---|---|
| **Gateway (YARP)** | 5000 | **5001** | web `VITE_API_BASE_URL`, mobil `API_BASE_URL` |
| wms-identity | 5081 | 5081 | |
| wms-masterdata (+ documents) | 5082 | 5082 | |
| wms-inventory | 5083 | 5083 | |
| wms-procurement | 5084 | 5084 | |
| wms-reporting | 5085 | 5085 | |
| wms-worker (Hangfire dashboard) | 5086 | 5086 | `/hangfire` |
| Web (React → nginx) | 3000 | 3000 | dev: Vite `make web-dev` → 3001 |
| MySQL 8.4 | 3306 | **3308** | db `wms`; `wms_app`/`wms_app`, `wms_migrator`/`wms_migrator` |
| Redis 7 | 6379 | 6379 | |
| RabbitMQ 4 | 5672 / 15672 | 5672 / 15672 | `wms`/`wms` |
| MinIO | 9000 / 9001 | 9000 / 9001 | `minioadmin`/`minioadmin`, bucket `wms-attachments` |
| **Keycloak 26** | 8080 | **8180** | admin/`admin`, realm `wms` |
| Seq | 5341 | 5341 | auth söndürülüb (dev) |

> **Niyə fərq var:** bu maşında 5000 (macOS AirPlay), 8080 (başqa layihənin konteyneri) və
> 3306 (host `mysqld`) tutulub. Başqa maşında `.env`-i silmək kifayətdir — standart portlar işləyəcək.
> Dəyişdirdikdə `API_BASE_URL` və `KEYCLOAK_ISSUER` sətirlərini də yeniləyin.

**Web (Vite env)** və **mobil (dart-define)** dəyərləri (hazırkı konfiqurasiya):

```
# web/  — Vite build/dev zamanı mühit dəyişəni
VITE_API_BASE_URL=http://localhost:5001
VITE_KEYCLOAK_ISSUER=http://localhost:8180/realms/wms
VITE_KEYCLOAK_CLIENT_ID=wms-web

# mobile/  — flutter run/build arqumenti
--dart-define=API_BASE_URL=http://localhost:5001
--dart-define=KEYCLOAK_ISSUER=http://localhost:8180/realms/wms
--dart-define=KEYCLOAK_CLIENT_ID=wms-mobile
```

`make web-dev` / `make web-build` / `make mobile-run` və `.vscode/launch.json`
bunları özü ötürür.

---

## `make` target-ləri

```
make help              bütün target-lər + hazırkı toolchain
make doctor            docker / dotnet / flutter / node / .env yoxlaması

make up | down | logs  dev stack (logs: make logs SERVICES="keycloak mysql")
make migrate           EF miqrasiyaları (ayrıca migrator — startup-da YOX)

make backend-build     dotnet build, xəbərdarlıqlar xətadır
make backend-test      unit + arxitektura + integration (Testcontainers)
make backend-run       MODULES=inventory | masterdata | procurement | reporting | *

make mobile-get        pub workspace asılılıqları
make mobile-analyze    flutter analyze
make mobile-test       melos run test
make mobile-run        cihaz / emulyator

make web-install       npm ci
make web-dev           Vite dev server :3001
make web-build         produksiya bundle-ı (web/dist)
make web-test          web testləri
make web-lint          eslint + typecheck

make gen-client        OpenAPI → Dart client + build_runner (mobil)
make gen-client-web    OpenAPI → TypeScript client (web)
make lint-contracts    redocly lint + openapi-generator validate
make k8s-build         kustomize render (OVERLAY=dev|prod)
```

Lokal .NET SDK yoxdursa `backend-build` və `backend-test` avtomatik
`mcr.microsoft.com/dotnet/sdk:10.0` konteynerində işləyir — `make help` hansı rejimin
aktiv olduğunu göstərir.

---

## İş qaydaları (qısa)

Tam siyahı: [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md) · [`SPEC Əlavə A`](docs/SPEC-Satinalma-Anbar-Platformasi.md#əlavə-a--kod-konvensiyaları)

**Ümumi**

- Sənədlər **Azərbaycan dilində**, kod və kod şərhləri **ingilis dilində**.
- Git commit avtomatik edilmir — istifadəçi özü commit edir.
- Müvəqqəti fayllar repoya yazılmır.

**API (contract-first)**

- Dəyişiklik **əvvəl** `contracts/openapi/<modul>.v1.yaml`-da edilir, sonra kodda ([ADR-007](docs/adr/ADR-007-contract-first-openapi.md)).
- Hər `POST` `Idempotency-Key` (GUID) tələb edir.
- Xəta: RFC 7807 `application/problem+json` + `code` sahəsi.
- Səhifələmə `{items, page, size, total}`, `size` ≤ 200.
- **Miqdar/məbləğ JSON-da string** (`"qty": "12.5000"`) — `double` heç bir qatda yoxdur.

**Backend**

- `Result<T>` pattern; biznes xətası üçün exception atılmır.
- `decimal` məcburi, `double`/`float` analizator qaydası ilə qadağandır.
- Nullable aktiv, `TreatWarningsAsErrors=true`.
- Modul yalnız başqa modulun `*.Contracts` layihəsini görür — arxitektura testi ilə qorunur.
- Hər unikal indeksin birinci sütunu `tenant_id`.
- Miqrasiya adı: `YYYYMMDD_ModuleName_Description`; startup-da avtomatik miqrasiya **qadağandır**.

**Web (`web/`, React)**

- Vite · React 18 · TypeScript · React Router 6 · TanStack Query · React Hook Form + Zod.
- Miqdar/məbləğ `decimal.js` (JSON-da string); miqdar üçün `number` tipi **qadağandır**.
- Dizayn sistemi `docs/design-system/` fayllarından gəlir — tokenlər CSS dəyişəni,
  `bundle.js` tipli ESM React modulları ([ADR-011](docs/adr/ADR-011-design-system.md)).
- Generasiya olunan TypeScript client commit edilmir (`make gen-client-web`).

**Mobil (`mobile/`, Flutter)**

- Riverpod 3 · go_router · dio · `decimal` · freezed + json_serializable.
- Hər feature paketi: `lib/src/{data,domain,presentation}/` + `routes.dart` + barrel.
- UI komponentləri `wms_design_system`-dən götürülür — öz badge/cədvəl yazılmır ([ADR-011](docs/adr/ADR-011-design-system.md)).
- Generasiya olunan Dart client commit edilmir (`make gen-client`).

---

## Sənədlər

| Sənəd | Nə üçün |
|---|---|
| [**SPEC**](docs/SPEC-Satinalma-Anbar-Platformasi.md) | Texniki spesifikasiya — data modeli, domen invariantları, API qaydaları. **Ziddiyyətdə üstündür.** |
| [**CONVENTIONS**](docs/CONVENTIONS.md) | Komponentlər arası ortaq adlar, portlar, konfiqurasiya açarları |
| [**ADR-lər**](docs/adr/README.md) | 11 arxitektura qərarı (kontekst → qərar → nəticə) |
| [**Arxitektura**](docs/architecture/overview.md) | C4 kontekst/konteyner, deployment, 5 ardıcıllıq diaqramı, PO və sayım vəziyyət maşınları |
| [**Data modeli**](docs/architecture/data-model.md) | `inv` və `proc` ER diaqramları, ikili yazılış cədvəli |
| [**Ekran xəritəsi**](docs/ux/screen-map.md) | Rol × platforma matrisi, ekran-ekran sahələr və validasiyalar |
| [**Dizayn sistemi**](docs/design-system/README.md) | Tokenlər, komponent qaydaları, [Flutter köçürməsi](docs/design-system/FLUTTER-MAPPING.md) |
| [**API kontraktları**](contracts/README.md) | Contract-first axın, generasiya, versiyalaşdırma |
| [**Deploy**](deploy/README.md) | Compose profilləri, k8s, Keycloak realm, backup |

---

## Mərhələlər

[SPEC §19](docs/SPEC-Satinalma-Anbar-Platformasi.md#19-mərhələlər)

| Faza | Əhatə | Çıxış meyarı |
|---|---|---|
| **0 — Data migration hazırlığı** (2–4 həftə) | SKU təyini, adların təmizlənməsi, **base UoM və conversion əmsalları**, açılış qalıqlarının **partiya səviyyəsində** toplanması, supplier bazası, açılış qiymətləri | Miqrasiya dataseti hazırdır |
| **1 — Nüvə** | Identity, MasterData, Inventory (ledger, balans, batch, qəbul, məxaric, transfer, sayım, tullantı, nümunə), Documents | **Mərkəzi anbar və 15 filialın stoku sistemdədir, Excel dayandırılır** |
| **2 — Satınalma** | Procurement (PR → RFQ → Quotation → Comparison → PO → Approval), Notification, RTV, qiymət tarixçəsi | Satınalma axını sistemdədir |
| **3 — Analitika** | Reporting read-model, TOR §29-dakı 24 hesabat, dashboard, Excel import/export | Hesabatlar Excel-i əvəz edir |
| **4 — İnteqrasiya** | 1C adapteri (master data, PO, qəbul), Import Shipment Tracking | 1C ilə ikitərəfli axın |

---

## Açıq qərarlar

[SPEC §20](docs/SPEC-Satinalma-Anbar-Platformasi.md#20-açıq-qərarlar) — bunlar həll olunmadan
müvafiq modul tam layihələndirilə bilməz.

| # | Məsələ | Təsir |
|---|---|---|
| **20.1** 🔴 | **Filial istehlakı modeli — BLOKLAYICI.** Sendviç hazırlanarkən işlənən xammalın necə çıxacağı təyin edilməyib. Variantlar: (a) Recipe/BOM + POS inteqrasiyası, (b) filial günlük istehlak qeydiyyatı, (c) yalnız inventarizasiya fərqi | (a) seçilərsə yeni bounded context və xarici inteqrasiya əlavə olunur; TOR §24 analitikasının işləməsi bundan asılıdır |
| **20.2** | **1C-də master data sahibliyi** — məhsul və supplier kartının "system of record"-u hansı sistemdir? | İnteqrasiya istiqaməti və dublikat kod riski |
| **20.3** | **Həcm göstəriciləri** — rol üzrə istifadəçi sayı, SKU sayı, aylıq hərəkət sətri, attachment həcmi | Sizing və qiymətləndirmə |
| **20.4** | **Costing metodunun 1C ilə uzlaşması** — default `MOVING_AVERAGE`; 1C fərqli metod işlədirsə anbar dəyəri iki sistemdə fərqlənəcək | Maliyyə ilə təsdiqlənməlidir |

Əlavə olaraq interfeys tərəfində həll gözləyən məsələlər (offline rejimi, barkod skan axını,
mobil toxunma hədəfləri, çap şablonları) [`docs/ux/screen-map.md` §8](docs/ux/screen-map.md)-də sadalanıb.

## Filial istehlakı — SPEC §20.1 həll olundu

Spesifikasiyanın yeganə bloklayıcı açıq qərarı 21.09.2026-da bağlandı: filial istehlakı
**resept əsaslı nəzəri məxaric** ilə modelləşdirilir və fiziki sayımla tutuşdurulur.
Satış məlumatı `POS`, `CSV` və ya `MANUAL` mənbəyindən gəlir — POS inteqrasiyası bloklayıcı deyil.

- Qərar: [docs/adr/ADR-012-branch-consumption-model.md](docs/adr/ADR-012-branch-consumption-model.md)
- Dizayn: [docs/architecture/branch-operations.md](docs/architecture/branch-operations.md)
- Kontrakt: [contracts/openapi/consumption.v1.yaml](contracts/openapi/consumption.v1.yaml)
- Modul: `Consumption` (`cons_`, `--Modules=consumption`)

## Vəziyyət və yol xəritəsi

Repo boyunca aparılmış auditin nəticəsi, fazalar üzrə: [docs/ROADMAP.md](docs/ROADMAP.md).
Orada kontrakt əhatəsi (184 əməliyyatın 81-i işləyir), bağlanmalı təhlükəsizlik boşluqları,
beş faza və miqyas tavanları göstərilib.
