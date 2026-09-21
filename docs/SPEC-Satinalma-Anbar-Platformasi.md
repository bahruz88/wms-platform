# Satınalma və Anbar İdarəetmə Platforması — Texniki Spesifikasiya

**Versiya:** 1.0
**Tarix:** 20.09.2026
**Status:** Development-ə hazır
**Əsas sənəd:** Satınalma və Anbar İdarəetmə Sistemi — Texniki Tapşırıq (TOR) v1.0

> Bu sənəd developer və ya coding agent üçün nəzərdə tutulub. TOR biznes tələblərini,
> bu sənəd isə **necə qurulacağını** təyin edir. Ziddiyyət olarsa TOR biznes məntiqi
> üzrə, bu sənəd texniki icra üzrə üstünlük təşkil edir.

---

## Mündəricat

1. [Layihə konteksti](#1-layihə-konteksti)
2. [Arxitektura qərarları (ADR)](#2-arxitektura-qərarları-adr)
3. [Texnologiya stack](#3-texnologiya-stack)
4. [Solution strukturu](#4-solution-strukturu)
5. [Modul sərhədləri](#5-modul-sərhədləri)
6. [Data modeli — ümumi qaydalar](#6-data-modeli--ümumi-qaydalar)
7. [Şema: `iam`](#7-şema-iam)
8. [Şema: `master`](#8-şema-master)
9. [Şema: `inv` — nüvə](#9-şema-inv--nüvə)
10. [Şema: `proc`](#10-şema-proc)
11. [Şema: `common`](#11-şema-common)
12. [Domen invariantları](#12-domen-invariantları)
13. [API konvensiyaları](#13-api-konvensiyaları)
14. [Messaging və Outbox](#14-messaging-və-outbox)
15. [Background job-lar](#15-background-job-lar)
16. [Təhlükəsizlik](#16-təhlükəsizlik)
17. [Test strategiyası](#17-test-strategiyası)
18. [Deployment](#18-deployment)
19. [Mərhələlər](#19-mərhələlər)
20. [Açıq qərarlar](#20-açıq-qərarlar)

---

## 1. Layihə konteksti

### 1.1. Biznes

Subway restoran şəbəkəsi (15 filial) üçün satınalma və anbar idarəetmə platforması.
Hazırda proses Excel faylları üzərində aparılır.

### 1.2. Məhsul mövqeyi

**Multi-tenant SaaS.** Subway ilk müştəridir; platforma başqa şəbəkələrə də satılacaq.
`tenant_id` ilk gündən data modelinin bir hissəsidir.

### 1.3. Komanda və məhdudiyyətlər

| Amil | Vəziyyət | Nəticə |
|---|---|---|
| Komanda | 1–3 developer | Operativ mürəkkəblik minimuma endirilməlidir |
| DevOps | Ayrıca yoxdur | Bir repo, bir pipeline, bir miqrasiya seti |
| Deployment | Hibrid (cloud + on-prem) | Eyni image həm çox-konteyner, həm tək-konteyner işləməlidir |
| Arxitektura | Mikroservis (tender tələbi) | Modulyar kod + modul üzrə deployment profili |

### 1.4. Mövcud vəziyyətdən çıxarılan dərslər

İndiki Excel prosesinin təhlili aşağıdakı konkret nasazlıqları aşkar etdi.
**Data modeli bunların təkrarlanmasını struktur səviyyəsində qadağan etməlidir.**

| Mövcud problem | Spesifikasiyada həlli |
|---|---|
| Düstur içində izahsız `+510` sabiti | Hər düzəliş `reason_code_id` + approval tələb edən sənəddir (§12.6) |
| 4 sətirdə düstur əl ilə rəqəmlə əvəzlənib | Balans yalnız ledger-dən törəyir, birbaşa yazılmır (§12.2) |
| Tullantı və AQTA fərq düsturundan kənarda | İkili yazılış: hər sənəd sıfıra balanslaşır (§12.3) |
| Qalıq artımları = qeydə alınmamış mədaxil | Balans dəyişikliyi yalnız `stock_movement` vasitəsilə mümkündür |
| `−23.50999999999999` (float artefaktı) | Bütün miqdar/məbləğ `DECIMAL`, `FLOAT` qadağandır (§6.3) |
| Bir sətirdə iki partiya qarışıb | Partiya (batch) birinci dərəcəli obyektdir (§9.2) |
| Vaxtı keçmiş 121 000 ədəd siqnalsız qalıb | Expiry job + avtomatik blok (§15) |
| 15 filialdan yalnız 6-sı hesablamada | Reconciliation bütün lokasiyaları əhatə edir (§15) |
| Vahid qarışıqlığı, conversion tətbiq olunmur | Base UoM məcburi, əmsal hərəkətdə dondurulur (§12.1) |
| SKU yoxdur, adların sonunda boşluq | `sku` məcburi + unikal, `name` trim edilir (§8) |
| Qiymət yoxdur, itki manatla ölçülmür | Hər hərəkətdə `unit_cost` (§12.5) |

---

## 2. Arxitektura qərarları (ADR)

### ADR-001: Modulyar kod bazası, modul üzrə deployment

**Qərar.** Bir solution, bounded context başına bir .NET layihəsi, hər modul öz DB
şeması ilə. Deployment profili konfiqurasiya ilə seçilir:

```bash
dotnet run --Modules=inventory                    # Inventory Service
dotnet run --Modules=procurement                  # Procurement Service
dotnet run --Modules=masterdata,identity          # Master Data Service
dotnet run --Modules=*                            # on-prem: tək konteyner
```

**Səbəb.** Tender mikroservis tələb edir (modullar müstəqil deploy və scale olunur),
komanda isə 3 nəfərdir (bir repo, bir build). Hibrid deployment eyni image ilə həll olunur.

**Nəticə.** Modullar bir-birinin daxili tiplərinə birbaşa müraciət edə bilməz —
yalnız `*.Contracts` layihəsi vasitəsilə. Bu qayda **arxitektura testi ilə** qorunur (§17.4).

### ADR-002: Inventory bölünmür

**Qərar.** Receiving, Issue, Transfer, Waste, Sample, Count, Batch, Balance —
hamısı **tək servis, tək şema, tək ACID tranzaksiya**.

**Səbəb.** Bunların hamısı eyni balans və partiya cədvəllərinə toxunur. Ayrılma halında
sadə məxaric saga + kompensasiya tələb edən paylanmış tranzaksiyaya çevrilir;
kompensasiya uğursuz olduqda balans yanlış qalır.

**Nəticə.** Bu, tender müzakirəsində müdafiə olunmalı texniki mövqedir.

### ADR-003: İkili yazılışlı (double-entry) stok ledger-i

**Qərar.** Hər sənəd bir `movement_group` yaradır; hər hərəkət sətri işarəli `qty_base`
daşıyır; **hər qrupun cəmi sıfıra bərabər olmalıdır**. Supplier, Waste, Sample,
In-Transit və Adjustment virtual lokasiyalar kimi modelləşdirilir.

**Səbəb.** Mühasibatlıqdan gələn bu prinsip ledger-i özü-özünü yoxlayan edir.
Excel-in əsas problemi məhz balansın mənbəyinin olmaması idi.

**Nəticə.** `SUM(qty_base) GROUP BY movement_group_id` həmişə `0` — bu, DB-səviyyəli
yoxlama job-u və test invariantıdır.

### ADR-004: Balans yalnız proyeksiyadır

**Qərar.** `stock_balance` cədvəli `stock_movement`-dən törəyir və eyni tranzaksiyada
`SELECT ... FOR UPDATE` ilə yenilənir. Heç bir kod balansı birbaşa təyin edə bilməz.

**Nəticə.** Gecə işləyən reconciliation job `SUM(stock_movement.qty_base)` ilə
`stock_balance.qty_on_hand`-i tutuşdurur; fərq → kritik alert.

### ADR-005: Shared database + `tenant_id`

**Qərar.** Bütün tenant-lar eyni şemada, `tenant_id` sütunu ilə. EF Core global query
filter məcburidir. On-prem müştəri eyni build-in tək-tenant konfiqurasiyasıdır.

**Səbəb.** 3 nəfərlik komanda üçün schema-per-tenant miqrasiya yükü daşınmazdır.

---

## 3. Texnologiya stack

| Sahə | Seçim | Qeyd |
|---|---|---|
| Runtime | **.NET 10 (LTS)** | |
| API | ASP.NET Core Minimal API + `TypedResults` | Controller istifadə edilmir |
| ORM | **EF Core 10 + Pomelo.EntityFrameworkCore.MySql** | ⚠️ Layihəyə başlamazdan əvvəl Pomelo-nun EF Core 10 dəstəyini yoxlayın |
| Hesabat sorğuları | Dapper | EF Core ilə hesabat yazılmır |
| DB | **MySQL 8.4 LTS**, InnoDB | 9.x innovation branch istifadə edilmir |
| Validasiya | FluentValidation | |
| Mapping | Mapperly (source generator) | AutoMapper istifadə edilmir — lisenziya |
| Mediator | Sadə handler interfeysi və ya `Mediator` (MIT) | MediatR istifadə edilmir — lisenziya |
| Messaging | RabbitMQ (`RabbitMQ.Client` + nazik abstraksiya) | MassTransit v9 kommersiyadır |
| Background jobs | Hangfire (Core) | |
| Cache / distributed lock | Redis | |
| Fayl saxlama | MinIO (S3 uyğun) | Fayllar **heç vaxt** MySQL BLOB-da saxlanmır |
| Auth | Keycloak (OIDC) | Öz IdentityServer-i yazılmır |
| Gateway | YARP | |
| Log | Serilog (structured, JSON) | |
| Trace/metrics | OpenTelemetry → Seq / Grafana | |
| Test | xUnit + Testcontainers (real MySQL) | In-memory DB stok məntiqi üçün yaramır |
| Miqrasiya | EF Core Migrations, modul başına ayrı | |

> **Lisenziya xəbərdarlığı.** MediatR, AutoMapper və MassTransit-in son major
> versiyaları kommersiya lisenziyasına keçib. SaaS məhsul üçün bu, təkrarlanan
> xərcdir. Yuxarıdakı alternativlər seçilib. Layihəyə başlamazdan əvvəl bütün
> NuGet asılılıqlarının lisenziyasını yoxlayın.

---

## 4. Solution strukturu

```
src/
├── Host/
│   └── Wms.Host.Api/                    # tək giriş nöqtəsi, modulları yükləyir
│       ├── Program.cs
│       ├── ModuleLoader.cs              # --Modules= parametri
│       └── appsettings.json
│
├── BuildingBlocks/
│   ├── Wms.Common.Domain/               # Entity, AggregateRoot, DomainEvent, Result
│   ├── Wms.Common.Application/          # ICommand, IQuery, pipeline behaviors
│   ├── Wms.Common.Infrastructure/       # DbContext base, Outbox, Audit, Tenant
│   └── Wms.Common.Contracts/            # integration event-lər
│
├── Modules/
│   ├── Identity/
│   │   ├── Wms.Identity.Domain/
│   │   ├── Wms.Identity.Application/
│   │   ├── Wms.Identity.Infrastructure/
│   │   ├── Wms.Identity.Endpoints/
│   │   └── Wms.Identity.Contracts/      # YALNIZ bunu başqa modullar görür
│   │
│   ├── MasterData/                       # eyni struktur
│   ├── Inventory/
│   ├── Procurement/
│   ├── Documents/
│   ├── Notification/
│   ├── Reporting/
│   └── Integration/
│
tests/
├── Wms.ArchitectureTests/               # modul sərhədləri, tenant filter
├── Wms.Inventory.UnitTests/
├── Wms.Inventory.IntegrationTests/      # Testcontainers + real MySQL
└── Wms.Api.ContractTests/

deploy/
├── docker-compose.yml                   # lokal dev
├── docker-compose.onprem.yml            # tək konteyner
└── k8s/                                 # cloud
```

### 4.1. Modul yükləmə

```csharp
// ModuleLoader.cs
public interface IModule
{
    string Name { get; }
    void RegisterServices(IServiceCollection services, IConfiguration config);
    void MapEndpoints(IEndpointRouteBuilder app);
}

// Program.cs
var enabled = builder.Configuration["Modules"] ?? "*";
var modules = ModuleRegistry.Resolve(enabled);   // "*" → hamısı
foreach (var m in modules) m.RegisterServices(builder.Services, builder.Configuration);
...
foreach (var m in modules) m.MapEndpoints(app);
```

### 4.2. Modullararası çağırış

```csharp
// Contracts-da təyin olunur
public interface IProductCatalog
{
    Task<ProductDto?> GetAsync(long productId, CancellationToken ct);
}

// In-process implementasiya (default)
// HTTP implementasiya (modullar ayrı deploy olunanda)
// Seçim appsettings ilə: "ModuleTransport": "InProcess" | "Http"
```

Bu, ADR-001-in praktik nəticəsidir: kod dəyişmədən həqiqi mikroservisə keçid mümkündür.

---

## 5. Modul sərhədləri

| Modul | Məsuliyyət | Şema | Başqa moduldan asılılıq |
|---|---|---|---|
| **Identity** | Tenant, istifadəçi, rol, icazə, lokasiya girişi | `iam` | — |
| **MasterData** | Məhsul, kateqoriya, UoM, supplier, lokasiya, valyuta, nömrə seriyası, səbəb kodları | `master` | Identity |
| **Inventory** | Partiya, ledger, balans, qəbul, məxaric, transfer, sayım, tullantı, nümunə, qaytarma | `inv` | MasterData |
| **Procurement** | PR, RFQ, Quotation, Comparison, PO, Approval | `proc` | MasterData, Inventory (PO qalığı) |
| **Documents** | Attachment metadata, MinIO əlaqəsi | `doc` | — |
| **Notification** | Bildiriş qaydaları, in-app bildiriş | `notif` | — (event-lə işləyir) |
| **Reporting** | Read-model, hesabat, Excel export | `rpt` | — (read replica) |
| **Integration** | 1C adapteri, outbox consumer | `intg` | Contracts |

**Qadağalar:**

- Şemalararası `FOREIGN KEY` yoxdur.
- Şemalararası `JOIN` yoxdur (hesabat read-model-i istisna).
- Bir modul başqa modulun `DbContext`-inə müraciət edə bilməz.

---

## 6. Data modeli — ümumi qaydalar

### 6.1. Adlandırma

- Cədvəl və sütun: `snake_case`, tək halda (`purchase_order`, `not purchase_orders`).
- PK: `id`.
- FK: `<referenced_table>_id`.
- Boolean: `is_` prefiksi (`is_active`).
- Tarix: `_at` (datetime), `_date` (date).

### 6.2. Hər cədvəldə məcburi sütunlar

```sql
tenant_id     INT UNSIGNED NOT NULL,
created_at    DATETIME(3) NOT NULL,
created_by    INT UNSIGNED NOT NULL,
updated_at    DATETIME(3) NULL,
updated_by    INT UNSIGNED NULL,
row_version   INT UNSIGNED NOT NULL DEFAULT 1,   -- optimistic concurrency
is_deleted    TINYINT(1) NOT NULL DEFAULT 0      -- soft delete (ledger-də YOXDUR)
```

### 6.3. Tip qaydaları — məcburi

| Məqsəd | Tip | Qeyd |
|---|---|---|
| Miqdar | `DECIMAL(18,4)` | `FLOAT`/`DOUBLE` **qadağandır** |
| Məbləğ | `DECIMAL(18,4)` | |
| Conversion əmsalı | `DECIMAL(18,8)` | |
| Məzənnə | `DECIMAL(18,8)` | |
| Faiz | `DECIMAL(9,4)` | |
| Valyuta kodu | `CHAR(3)` | ISO 4217 |
| Vaxt damğası | `DATETIME(3)` | UTC-də saxlanılır |

### 6.4. Charset və collation

```sql
DEFAULT CHARSET = utf8mb4
DEFAULT COLLATE = utf8mb4_0900_ai_ci
```

⚠️ **Azərbaycan əlifbası:** MySQL-də `az` collation yoxdur, türk collation-u (`utf8mb4_tr_0900_ai_ci`)
`ə` hərfini düzgün emal etmir. Əlifba sırası tələb olunan siyahılarda ayrıca
`name_sort_key VARCHAR(255)` sütunu saxlanılır və sıralama tətbiq səviyyəsində
Azərbaycan əlifba sırası (`a b c ç d e ə f g ğ h x ı i j k q l m n o ö p r s ş t u ü v y z`)
ilə hesablanır.

### 6.5. Unikal indekslər

**Hər unikal indeksin birinci sütunu `tenant_id` olmalıdır.**

```sql
-- SƏHV
UNIQUE KEY uq_sku (sku)
-- DÜZGÜN
UNIQUE KEY uq_sku (tenant_id, sku)
```

Bu qayda arxitektura testi ilə yoxlanılır (§17.4).

---

## 7. Şema: `iam`

```sql
CREATE TABLE iam_tenant (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code          VARCHAR(32)  NOT NULL,
  name          VARCHAR(200) NOT NULL,
  default_currency CHAR(3)   NOT NULL DEFAULT 'AZN',
  timezone      VARCHAR(64)  NOT NULL DEFAULT 'Asia/Baku',
  locale        VARCHAR(10)  NOT NULL DEFAULT 'az-AZ',
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME(3)  NOT NULL,
  UNIQUE KEY uq_tenant_code (code)
) ENGINE=InnoDB;

CREATE TABLE iam_user (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  external_id   VARCHAR(64)  NOT NULL,        -- Keycloak subject
  username      VARCHAR(100) NOT NULL,
  full_name     VARCHAR(200) NOT NULL,
  email         VARCHAR(200) NULL,
  phone         VARCHAR(32)  NULL,
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME(3)  NOT NULL,
  created_by    INT UNSIGNED NOT NULL,
  updated_at    DATETIME(3)  NULL,
  updated_by    INT UNSIGNED NULL,
  row_version   INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_user_username (tenant_id, username),
  UNIQUE KEY uq_user_external (tenant_id, external_id)
) ENGINE=InnoDB;

CREATE TABLE iam_role (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  code          VARCHAR(48)  NOT NULL,   -- PROCUREMENT_OFFICER, PROCUREMENT_MANAGER,
                                         -- WAREHOUSE_KEEPER, BRANCH_USER, ADMIN, AUDITOR
  name          VARCHAR(120) NOT NULL,
  is_system     TINYINT(1)   NOT NULL DEFAULT 0,
  UNIQUE KEY uq_role_code (tenant_id, code)
) ENGINE=InnoDB;

CREATE TABLE iam_permission (
  id            SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code          VARCHAR(80)  NOT NULL,   -- inv.receipt.create, proc.po.approve,
                                         -- master.product.view_cost ...
  module        VARCHAR(32)  NOT NULL,
  UNIQUE KEY uq_perm_code (code)
) ENGINE=InnoDB;

CREATE TABLE iam_role_permission (
  role_id       INT UNSIGNED NOT NULL,
  permission_id SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (role_id, permission_id)
) ENGINE=InnoDB;

CREATE TABLE iam_user_role (
  user_id       INT UNSIGNED NOT NULL,
  role_id       INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, role_id)
) ENGINE=InnoDB;

-- Filial məhdudiyyəti: istifadəçi hansı lokasiyaları görür
CREATE TABLE iam_user_location (
  user_id       INT UNSIGNED NOT NULL,
  location_id   INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, location_id)
) ENGINE=InnoDB;

-- Approval delegasiyası (TOR-da yox idi, əlavə edildi)
CREATE TABLE iam_delegation (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  from_user_id  INT UNSIGNED NOT NULL,
  to_user_id    INT UNSIGNED NOT NULL,
  valid_from    DATE NOT NULL,
  valid_to      DATE NOT NULL,
  reason        VARCHAR(300) NULL,
  created_at    DATETIME(3) NOT NULL,
  created_by    INT UNSIGNED NOT NULL,
  KEY ix_deleg (tenant_id, from_user_id, valid_from, valid_to)
) ENGINE=InnoDB;
```

### 7.1. Kritik icazələr

| Kod | Təsir |
|---|---|
| `master.product.view_cost` | Anbardar bu icazəyə malik **olmamalıdır** (TOR §3.1, §40) |
| `inv.adjustment.approve` | Sayım fərqinin təsdiqi |
| `inv.waste.approve` | Tullantının təsdiqi |
| `proc.po.approve` | PO təsdiqi |
| `inv.movement.reverse` | Storno |

---

## 8. Şema: `master`

```sql
CREATE TABLE master_uom (
  id            SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  code          VARCHAR(12)  NOT NULL,      -- KG, G, L, ML, PCS, CASE, BOX
  name          VARCHAR(60)  NOT NULL,
  uom_class     ENUM('MASS','VOLUME','COUNT') NOT NULL,
  decimals      TINYINT UNSIGNED NOT NULL DEFAULT 3,
  UNIQUE KEY uq_uom (tenant_id, code)
) ENGINE=InnoDB;

CREATE TABLE master_product_category (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  parent_id     INT UNSIGNED NULL,
  code          VARCHAR(32)  NOT NULL,
  name          VARCHAR(150) NOT NULL,
  product_type  ENUM('FOOD','NON_FOOD') NOT NULL,
  path          VARCHAR(500) NOT NULL,        -- /NON_FOOD/CHEMICAL
  UNIQUE KEY uq_cat (tenant_id, code)
) ENGINE=InnoDB;

CREATE TABLE master_product (
  id                 INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id          INT UNSIGNED NOT NULL,
  sku                VARCHAR(48)  NOT NULL,        -- MƏCBURİ
  name               VARCHAR(250) NOT NULL,        -- TRIM edilir
  name_sort_key      VARCHAR(250) NOT NULL,        -- AZ əlifba sırası
  barcode            VARCHAR(64)  NULL,            -- optional (TOR §4)
  category_id        INT UNSIGNED NOT NULL,
  brand              VARCHAR(120) NULL,
  base_uom_id        SMALLINT UNSIGNED NOT NULL,   -- BÜTÜN balans bu vahiddədir
  default_supplier_id INT UNSIGNED NULL,
  min_stock          DECIMAL(18,4) NULL,
  max_stock          DECIMAL(18,4) NULL,
  reorder_point      DECIMAL(18,4) NULL,
  vat_rate           DECIMAL(9,4) NOT NULL DEFAULT 18.0000,
  requires_batch     TINYINT(1) NOT NULL DEFAULT 0,
  requires_expiry    TINYINT(1) NOT NULL DEFAULT 0,
  issue_strategy     ENUM('FEFO','FIFO') NOT NULL DEFAULT 'FEFO',
  shelf_life_days    SMALLINT UNSIGNED NULL,
  image_key          VARCHAR(300) NULL,            -- MinIO key
  is_active          TINYINT(1) NOT NULL DEFAULT 1,
  created_at         DATETIME(3) NOT NULL,
  created_by         INT UNSIGNED NOT NULL,
  updated_at         DATETIME(3) NULL,
  updated_by         INT UNSIGNED NULL,
  row_version        INT UNSIGNED NOT NULL DEFAULT 1,
  is_deleted         TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_product_sku (tenant_id, sku),
  KEY ix_product_cat (tenant_id, category_id),
  KEY ix_product_name (tenant_id, name_sort_key)
) ENGINE=InnoDB;

-- Məhsul üzrə alternativ vahidlər. Base UoM üçün də sətir olmalıdır (factor = 1).
CREATE TABLE master_product_uom (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  product_id    INT UNSIGNED NOT NULL,
  uom_id        SMALLINT UNSIGNED NOT NULL,
  factor_to_base DECIMAL(18,8) NOT NULL,     -- 1 CASE = 12 PCS → 12.00000000
  is_purchase_default TINYINT(1) NOT NULL DEFAULT 0,
  is_issue_default    TINYINT(1) NOT NULL DEFAULT 0,
  valid_from    DATE NOT NULL,
  valid_to      DATE NULL,                    -- əmsal dəyişəndə köhnə sətir bağlanır
  UNIQUE KEY uq_puom (tenant_id, product_id, uom_id, valid_from)
) ENGINE=InnoDB;

CREATE TABLE master_supplier (
  id              INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  code            VARCHAR(32)  NOT NULL,
  name            VARCHAR(250) NOT NULL,
  tax_id          VARCHAR(32)  NULL,          -- VÖEN
  contact_person  VARCHAR(150) NULL,
  phone           VARCHAR(64)  NULL,
  email           VARCHAR(200) NULL,
  address         VARCHAR(500) NULL,
  bank_details    VARCHAR(500) NULL,
  currency        CHAR(3) NOT NULL DEFAULT 'AZN',
  payment_terms   VARCHAR(200) NULL,
  delivery_terms  VARCHAR(200) NULL,
  incoterms       VARCHAR(16)  NULL,
  is_approved_food_supplier TINYINT(1) NOT NULL DEFAULT 0,   -- TOR §7
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      DATETIME(3) NOT NULL,
  created_by      INT UNSIGNED NOT NULL,
  row_version     INT UNSIGNED NOT NULL DEFAULT 1,
  is_deleted      TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_supplier_code (tenant_id, code)
) ENGINE=InnoDB;

-- Supplier sertifikatları + bitmə tarixi üzrə alert (TOR-da yox idi)
CREATE TABLE master_supplier_certificate (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  supplier_id   INT UNSIGNED NOT NULL,
  cert_type     VARCHAR(80)  NOT NULL,
  cert_number   VARCHAR(80)  NULL,
  issued_date   DATE NULL,
  expiry_date   DATE NULL,
  attachment_id BIGINT UNSIGNED NULL,
  KEY ix_cert_exp (tenant_id, expiry_date)
) ENGINE=InnoDB;

-- Lokasiya: fiziki VƏ virtual. Double-entry ledger-in əsasıdır.
CREATE TABLE master_location (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  parent_id     INT UNSIGNED NULL,
  code          VARCHAR(32)  NOT NULL,
  name          VARCHAR(200) NOT NULL,
  location_type ENUM(
      'CENTRAL_WAREHOUSE',   -- Food WH, Non-Food WH
      'SUB_LOCATION',        -- Freezer, Cooler, Dry Store, Equipment...
      'SHELF',               -- optional (TOR §11)
      'RESTAURANT',          -- 15 filial
      'IN_TRANSIT',          -- virtual: yolda olan mal
      'V_SUPPLIER',          -- virtual: mədaxil mənbəyi
      'V_WASTE',             -- virtual: tullantı
      'V_SAMPLE',            -- virtual: AQTA nümunəsi
      'V_ADJUSTMENT'         -- virtual: sayım düzəlişi
  ) NOT NULL,
  is_virtual    TINYINT(1) NOT NULL,
  allows_food   TINYINT(1) NOT NULL DEFAULT 1,
  allows_non_food TINYINT(1) NOT NULL DEFAULT 1,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_loc_code (tenant_id, code),
  KEY ix_loc_parent (tenant_id, parent_id)
) ENGINE=InnoDB;

CREATE TABLE master_currency_rate (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  currency      CHAR(3) NOT NULL,
  rate_date     DATE NOT NULL,
  rate_to_base  DECIMAL(18,8) NOT NULL,       -- 1 <currency> = X AZN
  source        VARCHAR(32) NOT NULL DEFAULT 'CBAR',
  UNIQUE KEY uq_rate (tenant_id, currency, rate_date)
) ENGINE=InnoDB;

CREATE TABLE master_reason_code (
  id            SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  code          VARCHAR(32) NOT NULL,
  name          VARCHAR(200) NOT NULL,
  reason_group  ENUM('WASTE','ADJUSTMENT','RETURN','SAMPLE','TRANSFER') NOT NULL,
  requires_approval TINYINT(1) NOT NULL DEFAULT 1,
  requires_photo    TINYINT(1) NOT NULL DEFAULT 0,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_reason (tenant_id, code)
) ENGINE=InnoDB;

-- Sənəd nömrələmə: PR-2026-00001
CREATE TABLE master_number_sequence (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_type      VARCHAR(24) NOT NULL,
  prefix        VARCHAR(12) NOT NULL,
  period        VARCHAR(8)  NOT NULL,          -- '2026' və ya '2026-09'
  last_number   INT UNSIGNED NOT NULL DEFAULT 0,
  padding       TINYINT UNSIGNED NOT NULL DEFAULT 5,
  UNIQUE KEY uq_seq (tenant_id, doc_type, period)
) ENGINE=InnoDB;
```

---

## 9. Şema: `inv` — nüvə

### 9.1. Konfiqurasiya parametrləri

```sql
CREATE TABLE inv_setting (
  tenant_id     INT UNSIGNED NOT NULL,
  setting_key   VARCHAR(64) NOT NULL,
  setting_value VARCHAR(500) NOT NULL,
  PRIMARY KEY (tenant_id, setting_key)
) ENGINE=InnoDB;
```

Məcburi parametrlər (TOR §36 — hard-coded olmamalıdır):

| Açar | Default | Təsvir |
|---|---|---|
| `expiry_warning_days` | `30` | Expiry alert müddəti |
| `expiry_critical_days` | `7` | Kritik alert |
| `receipt_over_tolerance_pct` | `0` | PO-dan artıq qəbulun icazəli faizi |
| `receipt_under_tolerance_pct` | `0` | Çatışmazlıq toleransı |
| `costing_method` | `MOVING_AVERAGE` | `MOVING_AVERAGE` \| `FIFO` |
| `count_variance_approval_threshold_pct` | `2` | Bundan yuxarı variance approval tələb edir |
| `block_transactions_during_count` | `true` | Sayım zamanı əməliyyat bloku |
| `require_branch_receipt_confirmation` | `true` | In-transit mexanizmi |

### 9.2. Partiya (batch)

```sql
CREATE TABLE inv_batch (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  product_id      INT UNSIGNED NOT NULL,
  batch_no        VARCHAR(64) NOT NULL,
  production_date DATE NULL,
  expiry_date     DATE NULL,
  supplier_id     INT UNSIGNED NULL,
  received_at     DATETIME(3) NOT NULL,          -- FIFO üçün
  status          ENUM('ACTIVE','BLOCKED','EXPIRED','QUARANTINE') NOT NULL DEFAULT 'ACTIVE',
  created_at      DATETIME(3) NOT NULL,
  created_by      INT UNSIGNED NOT NULL,
  row_version     INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_batch (tenant_id, product_id, batch_no, expiry_date),
  KEY ix_batch_fefo (tenant_id, product_id, status, expiry_date, received_at)
) ENGINE=InnoDB;
```

> Excel-də `Bread Stick Black` sətrində köhnə (15.09.2026) və yeni (fevral) partiyalar
> qarışmışdı. Bu modeldə onlar iki ayrı `inv_batch` sətridir və FEFO avtomatik
> köhnəni əvvəl çıxarır.

### 9.3. Hərəkət qrupu (sənəd başlığı)

```sql
CREATE TABLE inv_movement_group (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  doc_type        ENUM('RECEIPT','ISSUE','TRANSFER','COUNT_ADJUST',
                       'WASTE','SAMPLE','RETURN','OPENING','REVERSAL') NOT NULL,
  doc_no          VARCHAR(32) NOT NULL,
  doc_date        DATE NOT NULL,
  source_doc_type VARCHAR(24) NULL,              -- PO, STOCK_REQUEST, COUNT...
  source_doc_id   BIGINT UNSIGNED NULL,
  reason_code_id  SMALLINT UNSIGNED NULL,
  note            VARCHAR(1000) NULL,
  reverses_group_id BIGINT UNSIGNED NULL,        -- storno
  posted_at       DATETIME(3) NOT NULL,
  posted_by       INT UNSIGNED NOT NULL,
  idempotency_key CHAR(36) NOT NULL,
  UNIQUE KEY uq_mg_doc (tenant_id, doc_type, doc_no),
  UNIQUE KEY uq_mg_idem (tenant_id, idempotency_key),
  KEY ix_mg_src (tenant_id, source_doc_type, source_doc_id)
) ENGINE=InnoDB;
```

### 9.4. Ledger — append-only

```sql
CREATE TABLE inv_movement (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  group_id        BIGINT UNSIGNED NOT NULL,
  line_no         SMALLINT UNSIGNED NOT NULL,
  product_id      INT UNSIGNED NOT NULL,
  batch_id        BIGINT UNSIGNED NULL,
  location_id     INT UNSIGNED NOT NULL,
  qty_base        DECIMAL(18,4) NOT NULL,        -- işarəli: + mədaxil / − məxaric
  base_uom_id     SMALLINT UNSIGNED NOT NULL,
  entered_qty     DECIMAL(18,4) NOT NULL,        -- istifadəçinin daxil etdiyi
  entered_uom_id  SMALLINT UNSIGNED NOT NULL,
  conversion_rate DECIMAL(18,8) NOT NULL,        -- hərəkət anında DONDURULUR
  unit_cost       DECIMAL(18,4) NULL,            -- base UoM üzrə, tenant valyutasında
  currency        CHAR(3) NULL,
  fx_rate         DECIMAL(18,8) NULL,
  posted_at       DATETIME(3) NOT NULL,
  posted_by       INT UNSIGNED NOT NULL,
  UNIQUE KEY uq_mv_line (group_id, line_no),
  KEY ix_mv_balance (tenant_id, product_id, location_id, batch_id, id),
  KEY ix_mv_posted (tenant_id, posted_at)
) ENGINE=InnoDB
  PARTITION BY RANGE (YEAR(posted_at)) (
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
  );
```

**Qaydalar:**

- `UPDATE` və `DELETE` **qadağandır**. Səhv → `REVERSAL` qrupu ilə storno.
- Bu qadağa DB istifadəçisinin hüquqları ilə də tətbiq edilməlidir (`GRANT SELECT, INSERT ONLY`).
- `SUM(qty_base) WHERE group_id = X` **həmişə 0** olmalıdır (ADR-003).

### 9.5. Balans — proyeksiya

```sql
CREATE TABLE inv_balance (
  tenant_id       INT UNSIGNED NOT NULL,
  product_id      INT UNSIGNED NOT NULL,
  location_id     INT UNSIGNED NOT NULL,
  batch_id        BIGINT UNSIGNED NOT NULL DEFAULT 0,   -- 0 = batch-siz
  qty_on_hand     DECIMAL(18,4) NOT NULL DEFAULT 0,
  qty_reserved    DECIMAL(18,4) NOT NULL DEFAULT 0,
  avg_unit_cost   DECIMAL(18,4) NOT NULL DEFAULT 0,
  last_movement_id BIGINT UNSIGNED NULL,
  updated_at      DATETIME(3) NOT NULL,
  PRIMARY KEY (tenant_id, product_id, location_id, batch_id),
  KEY ix_bal_loc (tenant_id, location_id, product_id)
) ENGINE=InnoDB;
```

`qty_available = qty_on_hand - qty_reserved`

### 9.6. Əməliyyat sənədləri

```sql
-- Anbara qəbul (TOR §12)
CREATE TABLE inv_goods_receipt (
  id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id         INT UNSIGNED NOT NULL,
  doc_no            VARCHAR(32) NOT NULL,
  doc_date          DATE NOT NULL,
  po_id             BIGINT UNSIGNED NULL,
  supplier_id       INT UNSIGNED NOT NULL,
  location_id       INT UNSIGNED NOT NULL,
  temperature_c     DECIMAL(6,2) NULL,
  quality_status    ENUM('ACCEPTED','PARTIALLY_ACCEPTED','REJECTED') NOT NULL,
  packaging_note    VARCHAR(500) NULL,
  status            ENUM('DRAFT','POSTED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  movement_group_id BIGINT UNSIGNED NULL,
  created_at        DATETIME(3) NOT NULL,
  created_by        INT UNSIGNED NOT NULL,
  row_version       INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_gr (tenant_id, doc_no)
) ENGINE=InnoDB;

CREATE TABLE inv_goods_receipt_line (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  receipt_id      BIGINT UNSIGNED NOT NULL,
  line_no         SMALLINT UNSIGNED NOT NULL,
  product_id      INT UNSIGNED NOT NULL,
  po_line_id      BIGINT UNSIGNED NULL,
  ordered_qty     DECIMAL(18,4) NULL,            -- PO-dan
  received_qty    DECIMAL(18,4) NOT NULL,        -- faktiki
  rejected_qty    DECIMAL(18,4) NOT NULL DEFAULT 0,
  uom_id          SMALLINT UNSIGNED NOT NULL,
  batch_no        VARCHAR(64) NULL,
  production_date DATE NULL,
  expiry_date     DATE NULL,
  unit_price      DECIMAL(18,4) NULL,
  currency        CHAR(3) NULL,
  variance_note   VARCHAR(500) NULL,             -- fərq olduqda MƏCBURİ
  UNIQUE KEY uq_grl (receipt_id, line_no)
) ENGINE=InnoDB;

-- Filial qida tələbi (TOR §16)
CREATE TABLE inv_stock_request (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_no        VARCHAR(32) NOT NULL,
  doc_date      DATE NOT NULL,
  from_location_id INT UNSIGNED NOT NULL,        -- mərkəzi anbar
  to_location_id   INT UNSIGNED NOT NULL,        -- filial
  required_date DATE NULL,
  status        ENUM('DRAFT','SUBMITTED','PICKING','PARTIALLY_ISSUED',
                     'ISSUED','CANCELLED','CLOSED') NOT NULL DEFAULT 'DRAFT',
  note          VARCHAR(1000) NULL,
  created_at    DATETIME(3) NOT NULL,
  created_by    INT UNSIGNED NOT NULL,
  row_version   INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_sr (tenant_id, doc_no)
) ENGINE=InnoDB;

-- Məxaric / transfer (eyni struktur, doc_type fərqlənir)
CREATE TABLE inv_issue (
  id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id         INT UNSIGNED NOT NULL,
  doc_no            VARCHAR(32) NOT NULL,
  doc_date          DATE NOT NULL,
  issue_type        ENUM('BRANCH_ISSUE','WH_TRANSFER','BRANCH_TRANSFER') NOT NULL,
  from_location_id  INT UNSIGNED NOT NULL,
  to_location_id    INT UNSIGNED NOT NULL,
  request_id        BIGINT UNSIGNED NULL,
  status            ENUM('DRAFT','DISPATCHED','RECEIVED',
                         'DISCREPANCY','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  dispatch_group_id BIGINT UNSIGNED NULL,        -- → IN_TRANSIT
  receipt_group_id  BIGINT UNSIGNED NULL,        -- IN_TRANSIT → hədəf
  dispatched_at     DATETIME(3) NULL,
  received_at       DATETIME(3) NULL,
  received_by       INT UNSIGNED NULL,
  UNIQUE KEY uq_issue (tenant_id, doc_no)
) ENGINE=InnoDB;

-- Sayım (TOR §21)
CREATE TABLE inv_count (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_no        VARCHAR(32) NOT NULL,
  location_id   INT UNSIGNED NOT NULL,
  count_type    ENUM('FULL','CYCLE','SPOT') NOT NULL,
  status        ENUM('DRAFT','FROZEN','COUNTING','REVIEW',
                     'APPROVED','POSTED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  frozen_at     DATETIME(3) NULL,                -- bu andan əməliyyat bloklanır
  approved_by   INT UNSIGNED NULL,
  approved_at   DATETIME(3) NULL,
  adjust_group_id BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_count (tenant_id, doc_no)
) ENGINE=InnoDB;

CREATE TABLE inv_count_line (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  count_id      BIGINT UNSIGNED NOT NULL,
  product_id    INT UNSIGNED NOT NULL,
  batch_id      BIGINT UNSIGNED NULL,
  book_qty      DECIMAL(18,4) NOT NULL,          -- dondurulma anındakı sistem qalığı
  counted_qty   DECIMAL(18,4) NULL,
  variance_qty  DECIMAL(18,4) NULL,              -- counted − book
  variance_pct  DECIMAL(9,4) NULL,
  reason_code_id SMALLINT UNSIGNED NULL,         -- variance ≠ 0 olduqda MƏCBURİ
  note          VARCHAR(500) NULL,
  KEY ix_cl (count_id, product_id)
) ENGINE=InnoDB;

-- Tullantı və nümunə: ayrı cədvəllər, ayrı virtual lokasiyalar (TOR §22, §23)
CREATE TABLE inv_waste (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_no        VARCHAR(32) NOT NULL,
  doc_date      DATE NOT NULL,
  location_id   INT UNSIGNED NOT NULL,
  reason_code_id SMALLINT UNSIGNED NOT NULL,
  status        ENUM('DRAFT','PENDING_APPROVAL','APPROVED',
                     'POSTED','REJECTED') NOT NULL DEFAULT 'DRAFT',
  approved_by   INT UNSIGNED NULL,
  approved_at   DATETIME(3) NULL,
  movement_group_id BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_waste (tenant_id, doc_no)
) ENGINE=InnoDB;

CREATE TABLE inv_sample (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_no        VARCHAR(32) NOT NULL,
  doc_date      DATE NOT NULL,
  location_id   INT UNSIGNED NOT NULL,
  authority     VARCHAR(150) NOT NULL DEFAULT 'AQTA',
  purpose       VARCHAR(500) NULL,
  movement_group_id BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_sample (tenant_id, doc_no)
) ENGINE=InnoDB;

-- Supplier-ə qaytarma (TOR-da yox idi — əlavə edildi)
CREATE TABLE inv_return_to_vendor (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_no        VARCHAR(32) NOT NULL,
  doc_date      DATE NOT NULL,
  supplier_id   INT UNSIGNED NOT NULL,
  receipt_id    BIGINT UNSIGNED NULL,
  reason_code_id SMALLINT UNSIGNED NOT NULL,
  claim_amount  DECIMAL(18,4) NULL,
  status        ENUM('DRAFT','SENT','ACCEPTED','REJECTED','CLOSED') NOT NULL,
  movement_group_id BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_rtv (tenant_id, doc_no)
) ENGINE=InnoDB;
```

---

## 10. Şema: `proc`

```sql
CREATE TABLE proc_requisition (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  doc_no          VARCHAR(32) NOT NULL,
  doc_date        DATE NOT NULL,
  requester_location_id INT UNSIGNED NOT NULL,
  product_type    ENUM('FOOD','NON_FOOD') NOT NULL,
  priority        ENUM('LOW','NORMAL','HIGH','URGENT') NOT NULL DEFAULT 'NORMAL',
  required_date   DATE NULL,
  status          ENUM('DRAFT','SUBMITTED','IN_PROCUREMENT','CONVERTED_TO_PO',
                       'REJECTED','CANCELLED','CLOSED') NOT NULL DEFAULT 'DRAFT',
  note            VARCHAR(1000) NULL,
  created_at      DATETIME(3) NOT NULL,
  created_by      INT UNSIGNED NOT NULL,
  row_version     INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_pr (tenant_id, doc_no)
) ENGINE=InnoDB;

CREATE TABLE proc_requisition_line (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  requisition_id  BIGINT UNSIGNED NOT NULL,
  line_no         SMALLINT UNSIGNED NOT NULL,
  product_id      INT UNSIGNED NOT NULL,
  qty             DECIMAL(18,4) NOT NULL,
  uom_id          SMALLINT UNSIGNED NOT NULL,
  converted_qty   DECIMAL(18,4) NOT NULL DEFAULT 0,   -- PO-ya çevrilmiş hissə
  note            VARCHAR(500) NULL,
  UNIQUE KEY uq_prl (requisition_id, line_no)
) ENGINE=InnoDB;

CREATE TABLE proc_rfq (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_no        VARCHAR(32) NOT NULL,
  doc_date      DATE NOT NULL,
  due_date      DATE NULL,
  status        ENUM('DRAFT','SENT','CLOSED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  UNIQUE KEY uq_rfq (tenant_id, doc_no)
) ENGINE=InnoDB;

CREATE TABLE proc_quotation (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  rfq_id        BIGINT UNSIGNED NULL,
  supplier_id   INT UNSIGNED NOT NULL,
  quote_no      VARCHAR(64) NULL,
  quote_date    DATE NOT NULL,
  valid_until   DATE NULL,
  currency      CHAR(3) NOT NULL,
  delivery_days SMALLINT UNSIGNED NULL,
  payment_terms VARCHAR(200) NULL,
  total_amount  DECIMAL(18,4) NULL,
  is_selected   TINYINT(1) NOT NULL DEFAULT 0,
  selection_note VARCHAR(500) NULL,             -- ən ucuz seçilmədikdə MƏCBURİ
  KEY ix_quote (tenant_id, rfq_id, supplier_id)
) ENGINE=InnoDB;

CREATE TABLE proc_purchase_order (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  doc_no          VARCHAR(32) NOT NULL,
  doc_date        DATE NOT NULL,
  supplier_id     INT UNSIGNED NOT NULL,
  currency        CHAR(3) NOT NULL,
  fx_rate         DECIMAL(18,8) NOT NULL,        -- PO tarixindəki məzənnə
  subtotal        DECIMAL(18,4) NOT NULL,
  vat_amount      DECIMAL(18,4) NOT NULL,
  total_amount    DECIMAL(18,4) NOT NULL,
  total_amount_base DECIMAL(18,4) NOT NULL,      -- AZN — approval limiti bununla yoxlanılır
  delivery_location_id INT UNSIGNED NOT NULL,
  expected_date   DATE NULL,
  incoterms       VARCHAR(16) NULL,
  status          ENUM('DRAFT','PENDING_APPROVAL','APPROVED','REJECTED',
                       'SENT_TO_SUPPLIER','PARTIALLY_RECEIVED','FULLY_RECEIVED',
                       'CLOSED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  sent_at         DATETIME(3) NULL,
  created_at      DATETIME(3) NOT NULL,
  created_by      INT UNSIGNED NOT NULL,
  row_version     INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_po (tenant_id, doc_no)
) ENGINE=InnoDB;

CREATE TABLE proc_purchase_order_line (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id       INT UNSIGNED NOT NULL,
  po_id           BIGINT UNSIGNED NOT NULL,
  line_no         SMALLINT UNSIGNED NOT NULL,
  requisition_line_id BIGINT UNSIGNED NULL,
  product_id      INT UNSIGNED NOT NULL,
  qty             DECIMAL(18,4) NOT NULL,
  uom_id          SMALLINT UNSIGNED NOT NULL,
  unit_price      DECIMAL(18,4) NOT NULL,
  vat_rate        DECIMAL(9,4) NOT NULL,
  line_total      DECIMAL(18,4) NOT NULL,
  received_qty    DECIMAL(18,4) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_pol (po_id, line_no)
) ENGINE=InnoDB;

-- Qiymət tarixçəsi (TOR §25)
CREATE TABLE proc_price_history (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  product_id    INT UNSIGNED NOT NULL,
  supplier_id   INT UNSIGNED NOT NULL,
  po_id         BIGINT UNSIGNED NULL,
  price_date    DATE NOT NULL,
  unit_price    DECIMAL(18,4) NOT NULL,
  currency      CHAR(3) NOT NULL,
  unit_price_base DECIMAL(18,4) NOT NULL,        -- AZN-ə çevrilmiş
  prev_price_base DECIMAL(18,4) NULL,
  diff_amount   DECIMAL(18,4) NULL,
  diff_pct      DECIMAL(9,4) NULL,
  KEY ix_ph (tenant_id, product_id, supplier_id, price_date)
) ENGINE=InnoDB;

-- Approval: parametrik (TOR §10, §36)
CREATE TABLE proc_approval_rule (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_type      VARCHAR(24) NOT NULL,            -- PO, WASTE, COUNT_ADJUST
  product_type  ENUM('FOOD','NON_FOOD','ANY') NOT NULL DEFAULT 'ANY',
  min_amount_base DECIMAL(18,4) NOT NULL DEFAULT 0,
  max_amount_base DECIMAL(18,4) NULL,            -- NULL = limitsiz
  step_no       TINYINT UNSIGNED NOT NULL,
  approver_role_id INT UNSIGNED NOT NULL,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  KEY ix_rule (tenant_id, doc_type, product_type, min_amount_base)
) ENGINE=InnoDB;

CREATE TABLE proc_approval_instance (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  doc_type      VARCHAR(24) NOT NULL,
  doc_id        BIGINT UNSIGNED NOT NULL,
  current_step  TINYINT UNSIGNED NOT NULL DEFAULT 1,
  status        ENUM('PENDING','APPROVED','REJECTED','CANCELLED') NOT NULL,
  KEY ix_ai (tenant_id, doc_type, doc_id)
) ENGINE=InnoDB;

CREATE TABLE proc_approval_step (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  instance_id   BIGINT UNSIGNED NOT NULL,
  step_no       TINYINT UNSIGNED NOT NULL,
  approver_user_id INT UNSIGNED NULL,
  delegated_from_user_id INT UNSIGNED NULL,
  decision      ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  decided_at    DATETIME(3) NULL,
  comment       VARCHAR(1000) NULL,
  KEY ix_as (instance_id, step_no)
) ENGINE=InnoDB;

-- PR bölünməsinə qarşı nəzarət (TOR-da yox idi — SoD riski)
CREATE TABLE proc_split_check_log (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  supplier_id   INT UNSIGNED NOT NULL,
  window_start  DATE NOT NULL,
  cumulative_amount_base DECIMAL(18,4) NOT NULL,
  triggered_po_id BIGINT UNSIGNED NULL,
  KEY ix_split (tenant_id, supplier_id, window_start)
) ENGINE=InnoDB;
```

---

## 11. Şema: `common`

```sql
CREATE TABLE common_outbox (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  event_type    VARCHAR(120) NOT NULL,
  payload       JSON NOT NULL,
  occurred_at   DATETIME(3) NOT NULL,
  processed_at  DATETIME(3) NULL,
  attempt_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  last_error    TEXT NULL,
  KEY ix_outbox_pending (processed_at, id)
) ENGINE=InnoDB;

CREATE TABLE common_audit_log (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  entity_type   VARCHAR(80) NOT NULL,
  entity_id     BIGINT UNSIGNED NOT NULL,
  action        ENUM('CREATE','UPDATE','DELETE','APPROVE','REJECT',
                     'POST','REVERSE','EXPORT') NOT NULL,
  changes       JSON NULL,                       -- {"field":{"old":..,"new":..}}
  user_id       INT UNSIGNED NOT NULL,
  ip_address    VARCHAR(45) NULL,
  occurred_at   DATETIME(3) NOT NULL,
  KEY ix_audit (tenant_id, entity_type, entity_id, occurred_at)
) ENGINE=InnoDB;

CREATE TABLE common_attachment (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tenant_id     INT UNSIGNED NOT NULL,
  entity_type   VARCHAR(80) NOT NULL,
  entity_id     BIGINT UNSIGNED NOT NULL,
  attachment_type VARCHAR(48) NOT NULL,          -- QUOTATION, TEMP_PHOTO, INVOICE...
  file_name     VARCHAR(300) NOT NULL,
  content_type  VARCHAR(120) NOT NULL,
  size_bytes    BIGINT UNSIGNED NOT NULL,
  storage_key   VARCHAR(500) NOT NULL,           -- MinIO obyekt açarı
  checksum_sha256 CHAR(64) NOT NULL,
  uploaded_by   INT UNSIGNED NOT NULL,
  uploaded_at   DATETIME(3) NOT NULL,
  KEY ix_att (tenant_id, entity_type, entity_id)
) ENGINE=InnoDB;
```

**Attachment məhdudiyyətləri:** maksimum 25 MB/fayl; icazəli tiplər PDF, JPEG, PNG,
XLSX, DOCX; yükləmədə virus skan (ClamAV) — bunlar `inv_setting` deyil, tətbiq
konfiqurasiyasındadır.

---

## 12. Domen invariantları

> Bu bölmə spesifikasiyanın nüvəsidir. Hər bənd üçün ayrıca unit test olmalıdır.

### 12.1. Vahid çevirmə

```
qty_base = entered_qty × conversion_rate
```

- `conversion_rate` hərəkət anında `master_product_uom`-dan oxunur və `inv_movement`-də
  **dondurulur**. Sonradan əmsal dəyişərsə keçmiş hərəkətlər toxunulmaz qalır.
- `master_product_uom`-da əmsal dəyişməsi → köhnə sətir `valid_to` ilə bağlanır,
  yeni sətir açılır. `UPDATE factor_to_base` **qadağandır**.
- Yuvarlaqlaşdırma: `qty_base` `base_uom.decimals` qədər, `MidpointRounding.AwayFromZero`.
- Balansda mənfi qalıq **qadağandır** (`inv_setting.allow_negative_stock = false`).

### 12.2. Balans yalnız ledger-dən törəyir

```csharp
// TƏK icazəli yol
await using var tx = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted, ct);

var balance = await db.Balances
    .FromSqlInterpolated($@"
        SELECT * FROM inv_balance
        WHERE tenant_id = {tenantId} AND product_id = {productId}
          AND location_id = {locationId} AND batch_id = {batchId}
        FOR UPDATE")
    .FirstOrDefaultAsync(ct);

// 1. movement sətri INSERT
// 2. balance.qty_on_hand += qty_base
// 3. outbox event INSERT
// hamısı EYNİ tranzaksiyada

await tx.CommitAsync(ct);
```

`inv_balance`-a birbaşa `UPDATE` edən hər hansı başqa kod yolu **buq sayılır**.

### 12.3. İkili yazılış — hər sənəd sıfıra balanslaşır

| Əməliyyat | Sətir 1 | Sətir 2 |
|---|---|---|
| Qəbul | `V_SUPPLIER` −100 | `Food WH` +100 |
| Filiala məxaric | `Food WH` −50 | `IN_TRANSIT` +50 |
| Filial təsdiqi | `IN_TRANSIT` −50 | `Elmlər` +50 |
| Filiallararası transfer | `Elmlər` −10 | `IN_TRANSIT` +10 |
| Tullantı | `Elmlər` −5 | `V_WASTE` +5 |
| AQTA nümunəsi | `Food WH` −2 | `V_SAMPLE` +2 |
| Sayım artıqlığı | `V_ADJUSTMENT` −3 | `Food WH` +3 |
| Qaytarma | `Food WH` −8 | `V_SUPPLIER` +8 |

**İnvariant:** `SELECT group_id, SUM(qty_base) FROM inv_movement GROUP BY group_id
HAVING SUM(qty_base) <> 0` → **həmişə boş nəticə**.

Bu, Excel-in ən böyük nasazlığını (tullantı və AQTA-nın hesablamadan kənarda qalması)
struktur səviyyəsində aradan qaldırır: tullantı ledger-in bir hissəsidir, ayrıca
sütun deyil.

### 12.4. FEFO / FIFO ayırması

```sql
SELECT b.id, bal.qty_on_hand - bal.qty_reserved AS available
FROM inv_balance bal
JOIN inv_batch b ON b.id = bal.batch_id
WHERE bal.tenant_id = ? AND bal.product_id = ? AND bal.location_id = ?
  AND b.status = 'ACTIVE'
  AND (bal.qty_on_hand - bal.qty_reserved) > 0
ORDER BY
  CASE WHEN ? = 'FEFO' THEN b.expiry_date END ASC,
  b.received_at ASC
FOR UPDATE SKIP LOCKED;
```

- Strategiya `master_product.issue_strategy`-dən gəlir (kateqoriya səviyyəsində
  default, məhsul səviyyəsində override).
- `SKIP LOCKED` paralel məxariclərdə eyni partiyanın iki dəfə ayrılmasının qarşısını alır.
- İstifadəçiyə təklif olunan partiya göstərilir; başqa partiya seçilərsə
  `reason_code_id` + `note` **məcburidir** və audit-ə düşür (TOR §14).
- `status IN ('BLOCKED','EXPIRED','QUARANTINE')` partiyalar ayrılmaya daxil edilmir.

### 12.5. Maya dəyəri (costing)

Default: **Moving Average**, base UoM üzrə, tenant valyutasında.

```
Mədaxildə:
  new_avg = (qty_on_hand × avg_unit_cost + receipt_qty × receipt_unit_cost)
            / (qty_on_hand + receipt_qty)

Məxaricdə:
  unit_cost = cari avg_unit_cost   (avg dəyişmir)
```

- Xarici valyutada qəbul: `unit_cost_base = unit_price × fx_rate`,
  `fx_rate` PO tarixindəki `master_currency_rate`-dən (mənbə: CBAR).
- Məzənnə mövcud deyilsə qəbul **bloklanır** — avtomatik köhnə məzənnə götürülmür.
- Bu, Excel-də ümumiyyətlə olmayan imkanı verir: tullantı və kəsirin manatla dəyəri.

### 12.6. Düzəliş yalnız sənədlə

Sayım fərqi, storno və hər hansı manual korreksiya üçün:

1. `inv_count` və ya `REVERSAL` qrupu yaradılır;
2. `reason_code_id` **məcburidir**;
3. `inv_setting.count_variance_approval_threshold_pct`-dən yuxarı fərq approval tələb edir;
4. `common_audit_log`-a yazılır.

> Excel-dəki `+510` sabiti bu modeldə mümkün deyil — o, səbəb kodu, təsdiqləyən və
> tarix daşıyan sənədə çevrilir.

### 12.7. Sayım zamanı dondurma

`inv_count.status = 'FROZEN'` olduqda həmin `location_id` üzrə bütün
`RECEIPT / ISSUE / TRANSFER / WASTE / SAMPLE` əməliyyatları rədd edilir
(`409 Conflict`, kod `LOCATION_FROZEN`). `book_qty` dondurma anında yazılır.

### 12.8. PO ↔ qəbul toleransı

```
if received_qty > ordered_qty × (1 + over_tolerance_pct/100)  → warning + approval
if received_qty < ordered_qty × (1 - under_tolerance_pct/100) → variance_note MƏCBURİ
```

PR avtomatik PO-ya çevrilmir (TOR §9). Bir PO bir neçə PR sətrindən yığıla bilər;
`proc_requisition_line.converted_qty` qismən çevrilməni izləyir.

### 12.9. Tenant izolyasiyası

```csharp
// DbContext-də refleksiya ilə avtomatik
foreach (var et in modelBuilder.Model.GetEntityTypes()
             .Where(e => typeof(ITenantEntity).IsAssignableFrom(e.ClrType)))
{
    modelBuilder.Entity(et.ClrType).AddQueryFilter<ITenantEntity>(
        e => e.TenantId == _tenantContext.TenantId);
}
```

- `TenantId` **yalnız** JWT claim-dən gəlir, heç vaxt request body/query-dən.
- Raw SQL (Dapper hesabatları) üçün `tenant_id` parametri məcburidir — bu,
  arxitektura testi ilə yoxlanılır.
- `IgnoreQueryFilters()` istifadəsi yalnız `[AllowCrossTenant]` atributu ilə
  işarələnmiş admin əməliyyatlarında.

---

## 13. API konvensiyaları

### 13.1. Marşrutlar

```
/api/v1/{module}/{resource}
POST   /api/v1/inventory/goods-receipts
GET    /api/v1/inventory/goods-receipts/{id}
POST   /api/v1/inventory/goods-receipts/{id}/post
GET    /api/v1/inventory/balances?locationId=&productId=&page=1&size=50
POST   /api/v1/procurement/purchase-orders/{id}/approve
```

### 13.2. Idempotentlik

Bütün `POST` əməliyyatları `Idempotency-Key` header-i tələb edir (GUID).
Təkrar açar → əvvəlki nəticə qaytarılır, yeni sənəd yaradılmır.

### 13.3. Xəta formatı — RFC 7807

```json
{
  "type": "https://wms/errors/insufficient-stock",
  "title": "Kifayət qədər stok yoxdur",
  "status": 409,
  "code": "INSUFFICIENT_STOCK",
  "detail": "Chicken Strips: mövcud 45.0000 KG, tələb olunan 60.0000 KG",
  "traceId": "00-abc...",
  "errors": { "lines[2].qty": ["Mövcud qalıqdan çoxdur"] }
}
```

### 13.4. Səhifələmə

```json
{ "items": [...], "page": 1, "size": 50, "total": 1284 }
```

Maksimum `size = 200`. Hesabat export-u ayrıca async endpoint-dir.

### 13.5. Concurrency

`row_version` optimistic locking. Uyğunsuzluq → `409 Conflict`, kod `STALE_VERSION`.

### 13.6. Versiyalaşdırma

URL-də (`/v1/`). Breaking change → `/v2/`, köhnə versiya minimum 6 ay saxlanılır.

---

## 14. Messaging və Outbox

### 14.1. Outbox axını

```
Biznes tranzaksiyası (MySQL)
  ├── domain cədvəlləri INSERT/UPDATE
  ├── inv_movement INSERT
  ├── inv_balance UPDATE
  └── common_outbox INSERT          ← eyni tranzaksiya
COMMIT
     ↓
OutboxPublisher (Hangfire, hər 5 san)
     ↓
RabbitMQ (topic exchange: wms.events)
     ↓
Notification / Reporting / Integration consumer-ləri
```

Consumer-lər **idempotent** olmalıdır (`event_id` üzrə dedup).

### 14.2. Integration event-ləri

| Event | Nə vaxt | Consumer |
|---|---|---|
| `GoodsReceiptPosted` | Qəbul post edildikdə | Notification, Reporting, Integration(1C) |
| `ReceiptVarianceDetected` | PO ≠ faktiki | Notification |
| `StockBelowMinimum` | Balans min-dən aşağı | Notification |
| `StockOverMaximum` | Balans max-dan yuxarı | Notification |
| `BatchNearExpiry` | Expiry job | Notification |
| `BatchExpired` | Expiry job | Notification, Inventory (blok) |
| `PurchaseOrderApproved` | Approval tamamlandıqda | Notification, Integration |
| `PriceChanged` | Yeni qiymət əvvəlkindən fərqli | Notification, Reporting |
| `WastePosted` | Tullantı post edildikdə | Notification, Reporting |
| `TransferCompleted` | Filial təsdiqi | Notification |
| `CountVarianceApproved` | Sayım təsdiqi | Reporting, Integration |

---

## 15. Background job-lar

| Job | Cədvəl | İş |
|---|---|---|
| `OutboxPublisher` | hər 5 san | Outbox → RabbitMQ |
| `ExpiryScanner` | gündəlik 06:00 | `expiry_warning_days` və `expiry_critical_days` üzrə alert; vaxtı keçmiş partiyaları `EXPIRED` statusuna keçir və ayrılmadan çıxar |
| `StockLevelScanner` | gündəlik 06:15 | min/max/reorder point yoxlaması, `stock_coverage_days` hesablanması |
| `BalanceReconciliation` | gecə 02:00 | `SUM(inv_movement.qty_base)` ↔ `inv_balance.qty_on_hand`; fərq → **kritik alert** |
| `DoubleEntryCheck` | gecə 02:10 | `SUM(qty_base) GROUP BY group_id <> 0` → kritik alert |
| `CertificateExpiryScanner` | həftəlik | Supplier sertifikatlarının bitmə tarixi |
| `PriceVarianceCalculator` | qəbul sonrası | `proc_price_history` doldurulması |
| `ReportingProjector` | hər 1 dəq | Read-model yenilənməsi |
| `AttachmentOrphanCleaner` | həftəlik | MinIO-da sahibsiz obyektlər |

`BalanceReconciliation` və `DoubleEntryCheck` — bu iki job sistemin özünü yoxlama
mexanizmidir. Onlar alert verərsə, **kod səviyyəsində tranzaksiya buqu var** deməkdir.

---

## 16. Təhlükəsizlik

- **Authentication:** Keycloak OIDC, access token 15 dəq, refresh 8 saat.
- **Authorization:** permission-based (`iam_permission`), rol → icazə toplusu.
  Endpoint səviyyəsində `.RequirePermission("inv.receipt.create")`.
- **Lokasiya filtri:** filial istifadəçisi yalnız `iam_user_location`-dakı
  lokasiyaları görür. Query filter səviyyəsində tətbiq olunur, endpoint-də deyil.
- **Qiymət gizlətmə:** `master.product.view_cost` icazəsi olmayan istifadəçiyə
  `unit_cost`, `avg_unit_cost`, `total_value` sahələri DTO səviyyəsində `null`
  qaytarılır — JSON-da mövcud olmamalıdır (TOR §3.1, §40).
- **Transport:** yalnız HTTPS, HSTS.
- **Rate limiting:** `AddRateLimiter`, istifadəçi başına 100 req/dəq.
- **Audit qorunması:** `common_audit_log` və `inv_movement` üçün DB istifadəçisinə
  yalnız `SELECT, INSERT` hüququ verilir.
- **Sirr idarəetməsi:** connection string-lər environment variable / secret store-da,
  `appsettings.json`-da deyil.
- **Fərdi məlumatlar:** istifadəçi məlumatları üzrə Azərbaycan Respublikasının
  "Fərdi məlumatlar haqqında" qanununa uyğunluq — data retention siyasəti
  müqavilədə təsbit olunmalıdır.

---

## 17. Test strategiyası

### 17.1. Unit testlər — məcburi əhatə

Hər §12 invariantı üçün ayrıca test:

- Vahid çevirmə və yuvarlaqlaşdırma
- Mənfi qalığın qarşısının alınması
- FEFO sırası (expiry bərabər olduqda `received_at`)
- Bloklanmış/expired partiyanın ayrılmaması
- Moving average hesablanması (xarici valyuta daxil)
- Approval qaydasının məbləğ limitinə görə seçilməsi
- Delegasiyanın tətbiqi

### 17.2. Integration testlər — Testcontainers + real MySQL

- Qəbul → balans artımı → ledger sıfıra balanslaşması
- Məxaric → IN_TRANSIT → filial təsdiqi → hər iki balans
- Paralel iki məxaric eyni partiyadan (`SKIP LOCKED` yoxlaması)
- Sayım dondurma → əməliyyatın rədd edilməsi
- Idempotency key təkrarı → yeni sənəd yaranmaması
- Storno → balansın ilkin vəziyyətə qayıtması

### 17.3. Yük testi

Minimum ssenari: 100 eyni vaxtlı istifadəçi, 2 000 hərəkət/saat,
1 000 000 mövcud `inv_movement` sətri ilə. Hədəf: p95 < 2 san.

### 17.4. Arxitektura testləri (NetArchTest və ya analoq)

```csharp
// 1. Modul sərhədləri
Types.InAssembly(inventoryAssembly)
     .ShouldNot().HaveDependencyOn("Wms.Procurement.Domain");

// 2. Bütün tenant entity-lərinin query filter-i var
// 3. Bütün unique index-lərin birinci sütunu tenant_id
// 4. Heç bir entity-də float/double miqdar sahəsi yoxdur
// 5. inv_balance-a birbaşa SaveChanges yolu yoxdur
```

---

## 18. Deployment

### 18.1. Cloud profili

| Konteyner | Modullar | Replika |
|---|---|---|
| `wms-gateway` | YARP | 2 |
| `wms-identity` | identity | 2 |
| `wms-masterdata` | masterdata | 2 |
| `wms-inventory` | inventory | 3 |
| `wms-procurement` | procurement | 2 |
| `wms-worker` | hangfire job-lar | 1 |
| `wms-reporting` | reporting | 2 |

### 18.2. On-prem profili

Tək konteyner (`--Modules=*`) + MySQL + Redis + RabbitMQ + MinIO.
`docker-compose.onprem.yml` ilə bir əmrlə qalxır.

### 18.3. Miqrasiya

Modul başına ayrı `DbContext` və ayrı migration qovluğu.
Startup-da avtomatik miqrasiya **qadağandır** — ayrıca `wms-migrator` job-u.

### 18.4. Backup / DR

- MySQL: gündəlik tam + binlog (point-in-time recovery).
- **RPO ≤ 15 dəqiqə, RTO ≤ 4 saat** (müqavilədə təsbit olunmalıdır).
- MinIO: versiyalaşdırma aktiv + gündəlik replikasiya.
- Bərpa proseduru rüblük test edilir.

---

## 19. Mərhələlər

### Faza 0 — Data migration hazırlığı (2–4 həftə)

Bu mərhələ layihə planlarında ən çox unudulan hissədir və mövcud Excel-lər
nəzərə alınarsa qaçılmazdır:

- Məhsul master-inin təmizlənməsi: **SKU təyini** (hazırda yoxdur), adların
  `TRIM` edilməsi, dublikatların birləşdirilməsi.
- **Base UoM və conversion əmsallarının** hər məhsul üçün təsbiti
  (`1 QUTUDA` sütunu hazırda heç bir hesablamada istifadə olunmur).
- Açılış qalıqlarının **partiya səviyyəsində** toplanması — bir sətirdə qarışmış
  partiyaların ayrılması.
- Supplier bazasının qurulması, approved food supplier işarələnməsi.
- Açılış qiymətləri (maya dəyəri üçün).

### Faza 1 — Nüvə (Excel-i əvəz edir)

Identity, MasterData, Inventory (ledger, balans, batch, qəbul, məxaric,
transfer, sayım, tullantı, nümunə), Documents.

**Çıxış meyarı:** mərkəzi anbar və 15 filialın stoku sistemdə aparılır, Excel dayandırılır.

### Faza 2 — Satınalma

Procurement (PR → RFQ → Quotation → Comparison → PO → Approval), Notification,
qaytarma (RTV), qiymət tarixçəsi.

### Faza 3 — Analitika

Reporting read-model, TOR §29-dakı 24 hesabat, dashboard, Excel import/export.

### Faza 4 — İnteqrasiya

1C adapteri (master data sinxronizasiyası, PO və qəbulun ötürülməsi),
Import Shipment Tracking.

---

## 20. Açıq qərarlar

Bunlar həll olunmadan müvafiq modul tam layihələndirilə bilməz.

### 20.1. 🔴 Filial istehlakı modeli — BLOKLAYICI

Hazırda filial stoku yalnız artır (məxaric, transfer) və tullantı/transferdən başqa
heç nə onu azaltmır. Sendviç hazırlanarkən işlənən xammalın necə çıxacağı təyin
edilməyib. Üç variant:

| Variant | Əlavə iş | Dəqiqlik |
|---|---|---|
| **(a)** Recipe/BOM + POS inteqrasiyası | Yeni `Recipe` konteksti + POS adapteri | Yüksək |
| **(b)** Filial günlük istehlak qeydiyyatı | Sadə forma | Orta |
| **(c)** Yalnız inventarizasiya fərqi | Minimal | Aşağı |

**Təsir:** (a) seçilərsə arxitekturaya yeni bounded context və xarici inteqrasiya əlavə olunur.
Bu qərar TOR §24-dəki həftəlik/aylıq istifadə analitikasının işləyib-işləməyəcəyini də müəyyən edir.

### 20.2. 1C-də master data sahibliyi

Məhsul və supplier kartının "system of record"-u hansı sistemdir — WMS, yoxsa 1C?
Qərar verilmədən inteqrasiya istiqaməti və dublikat kod riski həll olunmur.

### 20.3. Həcm göstəriciləri

Rol üzrə istifadəçi sayı, SKU sayı, aylıq hərəkət sətri, attachment həcmi və
saxlanma müddəti — sizing və qiymətləndirmə üçün lazımdır.

### 20.4. Costing metodunun 1C ilə uzlaşması

Default `MOVING_AVERAGE` seçilib. 1C-də fərqli metod istifadə olunursa iki sistemdə
anbar dəyəri fərqlənəcək. Maliyyə ilə təsdiqlənməlidir.

---

## Əlavə A — Kod konvensiyaları

- `Result<T>` pattern; biznes xətaları üçün exception atılmır.
- Domain entity-ləri `private set` + factory metodları; anemik model qadağandır.
- `CancellationToken` hər async metodda.
- `DateTime` yerinə `DateTimeOffset`; saxlama UTC, göstərmə `tenant.timezone`.
- `decimal` — pul və miqdar üçün; `double` istifadəsi analizator qaydası ilə qadağan.
- Nullable reference types aktiv, `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`.
- EF Core: `AsNoTracking()` bütün read sorğularında; `Include` zəncirləri 2 səviyyədən dərin olmamalıdır.
- Migration adı: `YYYYMMDD_ModuleName_Description`.

## Əlavə B — Sənəd nömrələmə formatı

| Sənəd | Format | Nümunə |
|---|---|---|
| Purchase Requisition | `PR-{YYYY}-{00000}` | `PR-2026-00142` |
| Purchase Order | `PO-{YYYY}-{00000}` | `PO-2026-00087` |
| Goods Receipt | `GR-{YYYY}-{00000}` | `GR-2026-00311` |
| Stock Request | `SR-{YYYY}-{00000}` | `SR-2026-01204` |
| Issue / Transfer | `IS-{YYYY}-{00000}` | `IS-2026-00998` |
| Inventory Count | `IC-{YYYY}-{00000}` | `IC-2026-00012` |
| Waste | `WS-{YYYY}-{00000}` | `WS-2026-00067` |
| Sample | `SM-{YYYY}-{00000}` | `SM-2026-00009` |
| Return to Vendor | `RV-{YYYY}-{00000}` | `RV-2026-00004` |

Nömrə `master_number_sequence` üzərindən `SELECT ... FOR UPDATE` ilə alınır.
Boşluqlar (gap) qəbul edilir — tranzaksiya geri alınarsa nömrə itə bilər.
