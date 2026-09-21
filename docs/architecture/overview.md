# Arxitektura — ümumi baxış

Bu sənəd sistemin **strukturunu və axınlarını** göstərir. Qərarların səbəbi
[ADR-lərdə](../adr/README.md), data modeli [`data-model.md`](data-model.md)-də,
davranış qaydaları isə [SPEC](../SPEC-Satinalma-Anbar-Platformasi.md)-dədir.
Ziddiyyət olarsa SPEC üstündür.

Diaqramlar Mermaid ilədir və GitHub-da birbaşa render olunur.

---

## 1. Sistem konteksti (C4 — Level 1)

Platformanın kimlərlə və hansı xarici sistemlərlə işlədiyi.

```mermaid
flowchart TB
    subgraph users["İstifadəçilər"]
        keeper["Anbardar<br/>WAREHOUSE_KEEPER<br/>mobil"]
        branch["Filial işçisi<br/>BRANCH_USER<br/>mobil"]
        officer["Satınalma mütəxəssisi<br/>PROCUREMENT_OFFICER<br/>veb"]
        manager["Menecer<br/>PROCUREMENT_MANAGER<br/>veb + mobil təsdiq"]
        admin["Administrator<br/>ADMIN<br/>veb"]
        auditor["Auditor<br/>AUDITOR<br/>veb, yalnız oxuma"]
    end

    wms["<b>WMS platforması</b><br/>Satınalma və Anbar İdarəetmə<br/>multi-tenant SaaS"]

    subgraph ext["Xarici sistemlər"]
        kc["Keycloak<br/>OIDC identity provider<br/>realm wms"]
        onec["1C<br/>mühasibat<br/>master data + sənəd ötürülməsi"]
        cbar["CBAR<br/>Mərkəzi Bank<br/>gündəlik məzənnə"]
        minio["MinIO / S3<br/>fayl saxlama<br/>qaimə, sertifikat, foto"]
        smtp["SMTP / Push<br/>bildiriş çatdırılması"]
    end

    keeper -->|"qəbul, məxaric, sayım,<br/>tullantı, skan"| wms
    branch -->|"tələb, qəbul təsdiqi,<br/>tullantı"| wms
    officer -->|"PR, RFQ, təklif,<br/>PO"| wms
    manager -->|"təsdiq, dashboard"| wms
    admin -->|"master data, istifadəçi,<br/>parametrlər"| wms
    auditor -->|"ledger, audit log,<br/>hesabat"| wms

    wms -->|"OIDC / PKCE,<br/>tenant_id claim"| kc
    wms <-->|"master data sinxronu,<br/>PO və qəbul"| onec
    wms -->|"gündəlik məzənnə<br/>HTTP"| cbar
    wms -->|"presigned PUT / GET,<br/>S3 API"| minio
    wms -->|"e-mail, push"| smtp

    classDef person fill:#e8f0fe,stroke:#1a5fd0,color:#16191c
    classDef system fill:#1a5fd0,stroke:#164fb0,color:#ffffff
    classDef external fill:#f1f3f5,stroke:#7f878f,color:#16191c
    class keeper,branch,officer,manager,admin,auditor person
    class wms system
    class kc,onec,cbar,minio,smtp external
```

Qeyd: 1C inteqrasiyası Faza 4-dədir və master data sahibliyi hələ həll olunmayıb
([SPEC §20.2](../SPEC-Satinalma-Anbar-Platformasi.md#202-1c-də-master-data-sahibliyi)).

---

> **Filial əməliyyatları ayrıca sənəddədir.** Filial istehlakı modeli, resept/BOM,
> satış importu və fərq analizi üçün bax: [branch-operations.md](branch-operations.md)
> (qərar: [ADR-012](../adr/ADR-012-branch-consumption-model.md)).

## 2. Konteyner diaqramı (C4 — Level 2)

Cloud profili ([SPEC §18.1](../SPEC-Satinalma-Anbar-Platformasi.md#181-cloud-profili)).
Bütün modul konteynerləri **eyni image-dən** qalxır, yalnız `Modules` dəyişəni fərqlidir (ADR-001).

```mermaid
flowchart TB
    web["Flutter Web<br/>wms_web<br/>nginx, port 3000"]
    mob["Flutter Mobile<br/>wms_mobile<br/>Android / iOS"]

    gw["wms-gateway<br/>YARP<br/>route → modul"]

    subgraph modules["Modul konteynerləri — eyni image, fərqli --Modules="]
        id["wms-identity<br/>Modules=identity<br/>2 replika"]
        md["wms-masterdata<br/>Modules=masterdata,documents<br/>2 replika"]
        inv["wms-inventory<br/>Modules=inventory<br/>3 replika"]
        proc["wms-procurement<br/>Modules=procurement<br/>2 replika"]
        rpt["wms-reporting<br/>Modules=reporting<br/>2 replika"]
        wrk["wms-worker<br/>Modules=notification,integration<br/>Jobs__Enabled=true<br/>1 replika"]
    end

    mig["wms-migrator<br/>Job, ayrıca işləyir<br/>startup-da miqrasiya YOXDUR"]

    subgraph infra["İnfrastruktur"]
        my[("MySQL 8.4<br/>database wms<br/>cədvəl prefiksləri")]
        rd[("Redis 7<br/>keş, distributed lock")]
        mq{{"RabbitMQ 4<br/>topic exchange wms.events"}}
        mn[("MinIO<br/>bucket wms-attachments")]
        kc["Keycloak 26<br/>realm wms"]
        seq["Seq<br/>structured log + trace"]
    end

    web -->|"HTTPS /api/v1/**"| gw
    mob -->|"HTTPS /api/v1/**"| gw
    web -.->|"OIDC PKCE"| kc
    mob -.->|"OIDC PKCE"| kc
    gw -->|"JWT bearer"| id
    gw --> md
    gw --> inv
    gw --> proc
    gw --> rpt
    gw --> wrk

    id --> my
    md --> my
    inv --> my
    proc --> my
    rpt --> my
    wrk --> my
    mig --> my

    inv --> rd
    proc --> rd
    rpt --> rd

    wrk -->|"OutboxPublisher<br/>hər 5 san"| mq
    mq -->|"consumer"| wrk
    mq -->|"consumer"| rpt

    md --> mn
    inv --> mn
    wrk --> mn

    id -.->|"token validasiyası<br/>JWKS"| kc
    inv -.-> seq
    proc -.-> seq
    wrk -.-> seq

    classDef client fill:#e8f0fe,stroke:#1a5fd0,color:#16191c
    classDef svc fill:#ffffff,stroke:#1a5fd0,color:#16191c
    classDef store fill:#f1f3f5,stroke:#7f878f,color:#16191c
    class web,mob client
    class gw,id,md,inv,proc,rpt,wrk,mig svc
    class my,rd,mq,mn,kc,seq store
```

`Documents` modulu `wms-masterdata` ilə, `Notification` və `Integration` isə `wms-worker`
ilə birgə deploy olunur (CONVENTIONS). `Jobs__Enabled=true` yalnız worker-dədir — Hangfire
job-ları bir dəfə işləməlidir.

---

## 3. Deployment: cloud vs on-prem

Eyni image, iki profil ([SPEC §18](../SPEC-Satinalma-Anbar-Platformasi.md#18-deployment)).

```mermaid
flowchart LR
    subgraph cloud["Cloud profili — Kubernetes"]
        direction TB
        ing["Ingress / TLS"]
        cgw["wms-gateway × 2"]
        cmod["modul pod-ları<br/>identity 2, masterdata 2,<br/>inventory 3, procurement 2,<br/>reporting 2, worker 1"]
        cweb["wms-web × 2<br/>nginx"]
        cjob["wms-migrator<br/>Job, релиз öncəsi"]
        cinfra[("Managed / StatefulSet<br/>MySQL, Redis, RabbitMQ,<br/>MinIO, Keycloak, Seq")]
        ing --> cgw
        ing --> cweb
        cgw --> cmod
        cmod --> cinfra
        cjob --> cinfra
    end

    subgraph onprem["On-prem profili — docker-compose.onprem.yml"]
        direction TB
        oapi["wms-api<br/>Modules=*<br/>Jobs__Enabled=true<br/>TƏK konteyner"]
        oweb["wms-web<br/>nginx"]
        oinfra[("MySQL + Redis +<br/>RabbitMQ + MinIO +<br/>Keycloak<br/>eyni host")]
        obak["backup.sh<br/>gündəlik dump + binlog"]
        oweb --> oapi
        oapi --> oinfra
        oinfra --> obak
    end

    img["Eyni Docker image<br/>ghcr.io/.../wms-api:TAG"]
    img --> cmod
    img --> oapi
    img --> cjob

    classDef box fill:#ffffff,stroke:#1a5fd0,color:#16191c
    classDef store fill:#f1f3f5,stroke:#7f878f,color:#16191c
    class ing,cgw,cmod,cweb,cjob,oapi,oweb,obak,img box
    class cinfra,oinfra store
```

| | Cloud | On-prem |
|---|---|---|
| Konteyner sayı | 7 tətbiq + infra | 2 tətbiq + infra |
| `Modules` | modul başına bir dəyər | `*` |
| Miqrasiya | `Job` (релиз öncəsi) | `scripts/db-migrate.sh` |
| Scale | HPA, inventory 3 replika | şaquli (host resursu) |
| Backup | managed MySQL + MinIO replikasiyası | `deploy/onprem/backup.sh` |
| RPO / RTO | ≤ 15 dəq / ≤ 4 saat | müqavilə ilə |

---

## 4. Modul asılılıqları

[SPEC §5](../SPEC-Satinalma-Anbar-Platformasi.md#5-modul-sərhədləri). Ox = "asılıdır"
(yalnız `*.Contracts` interfeysləri üzərindən). Şemalararası FK və JOIN yoxdur.

```mermaid
flowchart TB
    identity["Identity<br/>iam_<br/>tenant, user, role,<br/>permission, delegation"]
    masterdata["MasterData<br/>master_<br/>product, uom, supplier,<br/>location, rate, reason"]
    inventory["Inventory<br/>inv_<br/>batch, ledger, balance,<br/>receipt, issue, count, waste"]
    procurement["Procurement<br/>proc_<br/>PR, RFQ, quotation,<br/>PO, approval"]
    documents["Documents<br/>doc_ / common_attachment<br/>MinIO metadata"]
    notification["Notification<br/>notif_<br/>qayda, inbox"]
    reporting["Reporting<br/>rpt_<br/>read-model, export"]
    integration["Integration<br/>intg_<br/>1C adapteri, outbox consumer"]
    contracts(["Wms.Common.Contracts<br/>integration event-ləri"])

    masterdata --> identity
    inventory --> masterdata
    procurement --> masterdata
    procurement -->|"PO qalığı,<br/>qəbul edilmiş miqdar"| inventory
    integration --> contracts

    inventory -.->|"event"| contracts
    procurement -.->|"event"| contracts
    contracts -.-> notification
    contracts -.-> reporting
    contracts -.-> integration

    classDef core fill:#ffffff,stroke:#1a5fd0,color:#16191c
    classDef evt fill:#e8f0fe,stroke:#1a5fd0,color:#16191c
    class identity,masterdata,inventory,procurement,documents,notification,reporting,integration core
    class contracts evt
```

- **Düz ox** — sinxron asılılıq (`IProductCatalog` və s., `ModuleTransport` ilə in-process və ya HTTP).
- **Punktir ox** — asinxron, outbox → RabbitMQ. Notification, Reporting və Integration heç bir
  modula **sinxron** asılı deyil; onlar yalnız event oxuyur.
- `Documents` heç kimdən asılı deyil; başqa modullar ona `attachmentId` ilə istinad edir.

---

## 5. Ardıcıllıq diaqramları

### (a) Qəbulun post edilməsi — `postGoodsReceipt`

Tək tranzaksiya: partiya → ledger → balans → outbox. Sonra asinxron bildiriş.
([SPEC §12.2](../SPEC-Satinalma-Anbar-Platformasi.md#122-balans-yalnız-ledger-dən-törəyir), §12.3, §14.1)

```mermaid
sequenceDiagram
    autonumber
    actor K as Anbardar (mobil)
    participant GW as Gateway (YARP)
    participant INV as wms-inventory
    participant DB as MySQL
    participant WRK as wms-worker
    participant MQ as RabbitMQ
    participant NOTIF as Notification

    K->>GW: POST /inventory/goods-receipts/311/post<br/>Idempotency-Key, rowVersion
    GW->>INV: JWT bearer (tenant_id=1)
    INV->>DB: BEGIN

    INV->>DB: SELECT ... FOR UPDATE<br/>idempotency açarı yoxlanışı
    alt açar artıq mövcuddur
        DB-->>INV: əvvəlki nəticə
        INV-->>K: 200 + Idempotent-Replayed: true
    else yeni sorğu
        INV->>DB: SELECT inv_count WHERE location FROZEN
        alt lokasiya dondurulub
            INV->>DB: ROLLBACK
            INV-->>K: 409 LOCATION_FROZEN
        else lokasiya açıqdır
            INV->>DB: SELECT master_currency_rate (xarici valyuta)
            alt məzənnə yoxdur
                INV->>DB: ROLLBACK
                INV-->>K: 409 FX_RATE_MISSING
            else məzənnə var
                INV->>DB: INSERT/SELECT inv_batch (partiya)
                INV->>DB: INSERT inv_movement_group (RECEIPT)
                INV->>DB: SELECT inv_balance FOR UPDATE
                Note over INV,DB: sətir kilidi — paralel post gözləyir
                INV->>DB: INSERT inv_movement<br/>V_SUPPLIER −qty / anbar +qty<br/>SUM(qty_base) = 0
                INV->>DB: UPDATE inv_balance<br/>qty_on_hand, moving average
                INV->>DB: INSERT common_outbox<br/>GoodsReceiptPosted (+ ReceiptVarianceDetected)
                INV->>DB: UPDATE inv_goods_receipt SET status=POSTED
                INV->>DB: COMMIT
                INV-->>K: 200 GoodsReceipt (movementGroupId)
            end
        end
    end

    Note over WRK: OutboxPublisher — hər 5 saniyə
    WRK->>DB: SELECT common_outbox WHERE processed_at IS NULL
    WRK->>MQ: publish wms.events
    WRK->>DB: UPDATE processed_at
    MQ-->>NOTIF: GoodsReceiptPosted
    NOTIF->>DB: INSERT notif_notification (qaydalara görə)
    NOTIF-->>K: push / in-app badge
```

### (b) Məxaric → IN_TRANSIT → filial təsdiqi

İki ayrı hərəkət qrupu, iki ayrı tranzaksiya; aralıqda mal `IN_TRANSIT` virtual
lokasiyasındadır ([SPEC §12.3](../SPEC-Satinalma-Anbar-Platformasi.md#123-i̇kili-yazılış--hər-sənəd-sıfıra-balanslaşır)).

```mermaid
sequenceDiagram
    autonumber
    actor K as Anbardar
    actor B as Filial işçisi
    participant INV as wms-inventory
    participant DB as MySQL
    participant MQ as RabbitMQ

    K->>INV: POST /issues (DRAFT)<br/>sətirlər, FEFO təklifi
    INV->>DB: SELECT batch FEFO<br/>FOR UPDATE SKIP LOCKED
    DB-->>INV: təklif olunan partiya
    INV-->>K: 201 Issue (suggestedBatch)

    K->>INV: POST /issues/998/dispatch
    INV->>DB: BEGIN
    INV->>DB: SELECT inv_balance FOR UPDATE (mənbə)
    alt qtyAvailable < tələb
        INV->>DB: ROLLBACK
        INV-->>K: 409 INSUFFICIENT_STOCK
    else partiya BLOCKED / EXPIRED
        INV-->>K: 409 BATCH_BLOCKED
    else uğurlu
        INV->>DB: INSERT movement_group (ISSUE)<br/>Food WH −50 / IN_TRANSIT +50
        INV->>DB: UPDATE balance (mənbə, IN_TRANSIT)
        INV->>DB: INSERT outbox (IssueDispatched)
        INV->>DB: COMMIT
        INV-->>K: 200 Issue status=DISPATCHED
    end

    Note over B: mal filiala çatır
    B->>INV: POST /issues/998/confirm-receipt<br/>lines[].receivedQty
    INV->>DB: BEGIN
    alt receivedQty = dispatchedQty
        INV->>DB: INSERT movement_group (TRANSFER)<br/>IN_TRANSIT −50 / Filial +50
        INV->>DB: UPDATE issue SET status=RECEIVED
    else fərq var
        Note over B,INV: reasonCodeId + note MƏCBURİ<br/>yoxdursa 422 REASON_CODE_REQUIRED
        INV->>DB: INSERT movement_group (TRANSFER)<br/>IN_TRANSIT −48 / Filial +48
        Note over DB: qalan 2 vahid IN_TRANSIT-də qalır<br/>ayrıca sənədlə bağlanır
        INV->>DB: UPDATE issue SET status=DISCREPANCY
    end
    INV->>DB: INSERT outbox (TransferCompleted)
    INV->>DB: COMMIT
    INV-->>B: 200 Issue
    INV->>MQ: TransferCompleted → Notification (anbardara)
```

### (c) Sayım: dondurma → fərq → təsdiq → COUNT_ADJUST

([SPEC §12.6](../SPEC-Satinalma-Anbar-Platformasi.md#126-düzəliş-yalnız-sənədlə), §12.7)

```mermaid
sequenceDiagram
    autonumber
    actor K as Anbardar
    actor M as Menecer
    participant INV as wms-inventory
    participant DB as MySQL

    K->>INV: POST /counts (FULL, locationId)
    INV-->>K: 201 Count status=DRAFT

    K->>INV: POST /counts/12/freeze
    INV->>DB: BEGIN
    INV->>DB: UPDATE inv_count SET status=FROZEN, frozen_at=now()
    INV->>DB: INSERT inv_count_line<br/>book_qty = cari qty_on_hand (snapshot)
    INV->>DB: COMMIT
    INV-->>K: 200 status=FROZEN
    Note over INV: bu andan həmin lokasiyada<br/>RECEIPT/ISSUE/WASTE/SAMPLE → 409 LOCATION_FROZEN

    loop rəf-rəf sayım (mobil)
        K->>INV: POST /counts/12/lines<br/>countedQuantity + uomId
        INV->>DB: UPSERT count_line<br/>variance_qty = counted − book<br/>variance_pct
        Note over INV: variance ≠ 0 və reasonCodeId yoxdursa<br/>422 REASON_CODE_REQUIRED
        INV-->>K: 200 Count (yenilənmiş sətirlər)
    end

    K->>INV: POST /counts/12/submit
    INV->>DB: UPDATE status=REVIEW
    alt |variance_pct| > count_variance_approval_threshold_pct
        INV->>DB: INSERT proc_approval_instance (COUNT_ADJUST)
        INV-->>M: bildiriş — təsdiq gözlənilir
        M->>INV: POST /counts/12/approve (decision=APPROVED)
        Note over M,INV: inv.adjustment.approve icazəsi<br/>sayımı aparan özü təsdiqləyə bilməz
        INV->>DB: UPDATE status=APPROVED, approved_by
    else fərq həddin altındadır
        INV->>DB: UPDATE status=APPROVED (avtomatik)
    end

    M->>INV: POST /counts/12/post
    INV->>DB: BEGIN
    INV->>DB: INSERT movement_group (COUNT_ADJUST)
    Note over INV,DB: artıqlıq: V_ADJUSTMENT −3 / lokasiya +3<br/>kəsir: lokasiya −5 / V_ADJUSTMENT +5<br/>cəm = 0
    INV->>DB: UPDATE inv_balance
    INV->>DB: INSERT common_audit_log (POST)
    INV->>DB: INSERT outbox (CountVarianceApproved)
    INV->>DB: UPDATE inv_count SET status=POSTED
    INV->>DB: COMMIT
    Note over INV: lokasiya bloku götürüldü
    INV-->>M: 200 Count status=POSTED
```

### (d) PO təsdiqi — parametrik qaydalar + delegasiya

([SPEC §10](../SPEC-Satinalma-Anbar-Platformasi.md#10-şema-proc), TOR §10/§36)

```mermaid
sequenceDiagram
    autonumber
    actor O as Satınalma mütəxəssisi
    actor M1 as Menecer (təsdiqləyən)
    actor M2 as Əvəzedici (delegasiya)
    participant PROC as wms-procurement
    participant DB as MySQL
    participant MQ as RabbitMQ

    O->>PROC: POST /purchase-orders (DRAFT)
    PROC->>DB: SELECT master_currency_rate (docDate)
    alt məzənnə yoxdur
        PROC-->>O: 409 FX_RATE_MISSING
    else
        PROC->>DB: INSERT proc_purchase_order<br/>fx_rate DONDURULUR<br/>total_amount_base (AZN)
        PROC-->>O: 201 PO
    end

    O->>PROC: POST /purchase-orders/87/submit
    PROC->>DB: SELECT proc_approval_rule<br/>doc_type=PO, product_type,<br/>min/max_amount_base ⊇ total_amount_base
    alt uyğun qayda yoxdur
        PROC-->>O: 422 approval qaydası tapılmadı
    else qaydalar tapıldı
        PROC->>DB: INSERT approval_instance + steps<br/>(step_no, approver_role_id)
        loop hər addım üçün
            PROC->>DB: SELECT iam_delegation<br/>from_user = rol sahibi<br/>AND bu gün valid_from..valid_to
        end
        PROC->>DB: UPDATE PO SET status=PENDING_APPROVAL
        PROC-->>O: 200 PO + approval
    end

    par təsdiqləyənə bildiriş
        PROC->>MQ: PurchaseOrderPendingApproval
        MQ-->>M1: in-app / e-mail
    and delegasiya varsa əvəzediciyə də
        MQ-->>M2: "sizə delegasiya edilib"
    end

    alt əsas təsdiqləyən qərar verir
        M1->>PROC: POST /approvals/55/decide (APPROVED)
    else delegasiya ilə əvəzedici qərar verir
        M2->>PROC: POST /approvals/55/decide (APPROVED)
        PROC->>DB: step.delegated_from_user_id = M1
    end
    Note over PROC: PO-nu yaradan özü qərar verə bilməz → 403

    PROC->>DB: UPDATE approval_step SET decision, decided_at
    alt daha addım var
        PROC->>DB: UPDATE instance SET current_step = current_step + 1
        PROC-->>M1: növbəti addım gözlənilir
    else son addım
        PROC->>DB: UPDATE instance=APPROVED, PO status=APPROVED
        PROC->>DB: INSERT outbox (PurchaseOrderApproved)
        PROC->>MQ: PurchaseOrderApproved → Notification, Integration (1C)
    end

    O->>PROC: POST /purchase-orders/87/send
    alt status ≠ APPROVED
        PROC-->>O: 409 APPROVAL_REQUIRED
    else
        PROC->>DB: UPDATE status=SENT_TO_SUPPLIER, sent_at
        PROC-->>O: 200 PO
    end
```

### (e) Mobil login (PKCE) və `tenant_id` ilə API çağırışı

([SPEC §16](../SPEC-Satinalma-Anbar-Platformasi.md#16-təhlükəsizlik), ADR-009)

```mermaid
sequenceDiagram
    autonumber
    actor U as İstifadəçi
    participant APP as wms_mobile (Flutter)
    participant BR as Sistem brauzeri
    participant KC as Keycloak (realm wms)
    participant GW as Gateway
    participant API as wms-inventory
    participant IAM as wms-identity

    U->>APP: "Daxil ol"
    APP->>APP: code_verifier = random(64)<br/>code_challenge = S256(code_verifier)
    APP->>BR: authorize?client_id=wms-mobile<br/>&code_challenge&method=S256<br/>&redirect_uri=az.wms.mobile://callback
    BR->>KC: GET /protocol/openid-connect/auth
    KC-->>U: login forması
    U->>KC: username + parol
    KC-->>BR: 302 az.wms.mobile://callback?code=...
    BR-->>APP: deep link (code)

    APP->>KC: POST /token<br/>code + code_verifier<br/>(client secret YOXDUR)
    KC-->>APP: access_token (15 dəq) + refresh_token (8 saat)
    Note over APP: access_token claim-ləri:<br/>sub, preferred_username,<br/>tenant_id=1, aud=wms-api,<br/>realm_access.roles=[WAREHOUSE_KEEPER]
    APP->>APP: refresh_token → flutter_secure_storage

    APP->>GW: GET /api/v1/identity/me<br/>Authorization: Bearer ...
    GW->>IAM: forward
    IAM->>KC: JWKS ilə imza yoxlanışı (keşlənir)
    IAM->>IAM: tenant_id claim → TenantContext
    Note over IAM: tenant_id YALNIZ claim-dən —<br/>body/query-dən gələn dəyər nəzərə alınmır
    IAM-->>APP: permissions[], locationIds[], canViewCost=false

    APP->>GW: GET /api/v1/inventory/balances?locationId=3
    GW->>API: Bearer token
    API->>API: RequirePermission("inv.balance.view")
    API->>API: EF global query filter<br/>tenant_id = 1<br/>+ iam_user_location filtri
    API-->>APP: 200 BalancePage<br/>avgUnitCost sahəsi YOXDUR<br/>(view_cost icazəsi yoxdur)

    alt access_token bitdi (401)
        APP->>KC: POST /token (grant_type=refresh_token)
        KC-->>APP: yeni access_token
        APP->>GW: sorğunu təkrarla
    else refresh də bitdi
        APP->>U: yenidən login
    end
```

---

## 6. Vəziyyət diaqramları

### PO statusu

```mermaid
stateDiagram-v2
    [*] --> DRAFT: createPurchaseOrder
    DRAFT --> PENDING_APPROVAL: submitPurchaseOrder
    DRAFT --> CANCELLED: cancelPurchaseOrder

    PENDING_APPROVAL --> APPROVED: son addım təsdiqləndi
    PENDING_APPROVAL --> REJECTED: rejectPurchaseOrder (comment MƏCBURİ)

    REJECTED --> DRAFT: düzəliş üçün geri
    REJECTED --> CANCELLED: cancelPurchaseOrder

    APPROVED --> SENT_TO_SUPPLIER: sendPurchaseOrder
    APPROVED --> CANCELLED: cancelPurchaseOrder

    SENT_TO_SUPPLIER --> PARTIALLY_RECEIVED: qəbul post edildi (qismən)
    SENT_TO_SUPPLIER --> FULLY_RECEIVED: qəbul post edildi (tam)
    SENT_TO_SUPPLIER --> CLOSED: closePurchaseOrder (comment MƏCBURİ)

    PARTIALLY_RECEIVED --> PARTIALLY_RECEIVED: növbəti qismən qəbul
    PARTIALLY_RECEIVED --> FULLY_RECEIVED: qalıq tamamlandı
    PARTIALLY_RECEIVED --> CLOSED: closePurchaseOrder

    FULLY_RECEIVED --> CLOSED: closePurchaseOrder
    CLOSED --> [*]
    CANCELLED --> [*]

    note right of SENT_TO_SUPPLIER
        Göndərilmiş PO ləğv edilmir,
        yalnız bağlanır.
        Qəbul yalnız bu statusdan
        və PARTIALLY_RECEIVED-dən mümkündür.
    end note

    note right of PENDING_APPROVAL
        Addımlar proc_approval_rule ilə
        məbləğ intervalına görə seçilir.
        Delegasiya iam_delegation-dan.
    end note
```

### İnventarizasiya statusu

```mermaid
stateDiagram-v2
    [*] --> DRAFT: createCount
    DRAFT --> FROZEN: freezeCount
    DRAFT --> CANCELLED: cancelCount

    FROZEN --> COUNTING: ilk submitCountLines
    FROZEN --> CANCELLED: cancelCount

    COUNTING --> COUNTING: submitCountLines (hissə-hissə)
    COUNTING --> REVIEW: submitCount (bütün sətirlər dolu)
    COUNTING --> CANCELLED: cancelCount

    REVIEW --> APPROVED: approveCount (APPROVED)
    REVIEW --> COUNTING: approveCount (REJECTED) — yenidən say
    REVIEW --> CANCELLED: cancelCount

    APPROVED --> POSTED: postCount → COUNT_ADJUST qrupu
    APPROVED --> CANCELLED: cancelCount

    POSTED --> [*]
    CANCELLED --> [*]

    note right of FROZEN
        frozen_at yazılır, book_qty snapshot alınır.
        Bu andan lokasiyada RECEIPT / ISSUE /
        TRANSFER / WASTE / SAMPLE →
        409 LOCATION_FROZEN
    end note

    note right of POSTED
        Yalnız burada ledger dəyişir.
        Post-dan sonra lokasiya bloku götürülür.
        Səhv → yalnız storno (REVERSAL).
    end note
```

---

## 7. Əlaqəli sənədlər

| Sənəd | Nə var |
|---|---|
| [`data-model.md`](data-model.md) | `inv` və `proc` ER diaqramları, ikili yazılış cədvəli |
| [`../adr/README.md`](../adr/README.md) | 11 arxitektura qərarı |
| [`../../contracts/README.md`](../../contracts/README.md) | API kontraktları, contract-first axın |
| [`../ux/screen-map.md`](../ux/screen-map.md) | Rol × platforma ekran xəritəsi |
| [`../design-system/README.md`](../design-system/README.md) | Dizayn sistemi, tokenlər, komponentlər |
| [`../../deploy/README.md`](../../deploy/README.md) | Compose, k8s, Keycloak realm, miqrasiya |
