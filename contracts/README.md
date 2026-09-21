# API kontraktları (OpenAPI 3.1)

Bu qovluq platformanın **HTTP API-nin yeganə həqiqət mənbəyidir** (single source of truth).
Backend endpoint-ləri və Flutter client-i buradan törəyir, əksinə deyil (ADR-007).

```
contracts/
├── redocly.yaml            lint konfiqurasiyası (`recommended` ruleset + layihə qaydaları)
├── README.md               bu sənəd
└── openapi/
    ├── common.v1.yaml      ortaq komponentlər — `paths` YOXDUR
    ├── identity.v1.yaml    /api/v1/identity
    ├── masterdata.v1.yaml  /api/v1/masterdata
    ├── inventory.v1.yaml   /api/v1/inventory
    ├── procurement.v1.yaml /api/v1/procurement
    ├── documents.v1.yaml   /api/v1/documents
    ├── notifications.v1.yaml /api/v1/notifications
    └── reporting.v1.yaml   /api/v1/reporting
```

Modul sərhədləri və route prefiksləri `docs/CONVENTIONS.md`-dəki cədvəldən gəlir;
davranış qaydaları `docs/SPEC-Satinalma-Anbar-Platformasi.md` §13-dədir.

---

## 1. Contract-first iş axını

Yeni endpoint və ya sahə əlavə edərkən sıra **həmişə** belədir:

```
1. contracts/openapi/<modul>.v1.yaml    dəyiş
2. make lint-contracts                  redocly + openapi-generator validate
3. make gen-client                      Dart client yenidən generasiya olunur
4. backend endpoint-i yaz               → kontrakt testi yaşıl olana qədər
5. frontend-i generasiya olunmuş client üzərindən yaz
```

Kodu yazıb sonra kontraktı "uyğunlaşdırmaq" qadağandır: backend `openapi/v1.json`-u
generasiya edir, lakin o, **yoxlama artefaktıdır**, mənbə deyil.

### Fayl bölgüsü qaydaları

- **Hər modul bir fayl.** Fayl `servers: [{ url: /api/v1/<prefiks> }]` ilə başlayır —
  gateway (YARP) həmin prefiksi müvafiq konteynerə yönləndirir.
- **`common.v1.yaml`-da `paths` yoxdur.** O yalnız komponent kitabxanasıdır:
  `ProblemDetails`, `PageMeta`, `Decimal`, `Money`, `Quantity`, `RowVersion`, `AuditFields`,
  `Idempotency-Key` parametri, standart `400/401/403/404/409/422` cavabları,
  `oidc` və `bearer` security scheme-ləri.
- Modul faylları ortaq komponentə **alias** verir:

  ```yaml
  components:
    schemas:
      Decimal:
        $ref: './common.v1.yaml#/components/schemas/Decimal'
  ```

  Alias vacibdir: generator alias adını model adı kimi götürür, əks halda hər modulda
  `ListThings401Response` kimi uydurma tiplər yaranır.
- Modullararası `$ref` **qadağandır** (`inventory` → `masterdata` yox). Başqa modulun
  obyekti lazımdırsa, həmin modulda kiçik `*Ref` sxemi təyin edilir (`ProductRef`, `LocationRef`).
  Bu, ADR-001-dəki modul sərhədi qaydasının kontrakt səviyyəsindəki əksidir.

### Məcburi konvensiyalar (hər endpoint üçün)

| Qayda | Nə deməkdir |
|---|---|
| `operationId` camelCase | `listGoodsReceipts`, `postGoodsReceipt` — Dart metod adı və C# handler adı budur. Dəyişdirmək **breaking**-dir. |
| `x-permission` | Hər əməliyyatda bir icazə kodu (`inv.receipt.create`). Backend `.RequirePermission(...)` bunu təkrarlayır, kontrakt testi uyğunluğu yoxlayır. |
| `Idempotency-Key` | Bütün `POST`-larda məcburi (`$ref` ilə ortaq parametrdən). SPEC §13.2. |
| `409` kodları | Mutasiya edən hər endpoint-in `description`-ında hansı `code` dəyərlərinin mümkün olduğu sadalanır: `INSUFFICIENT_STOCK`, `LOCATION_FROZEN`, `STALE_VERSION`, `BATCH_BLOCKED`, `FX_RATE_MISSING`, `APPROVAL_REQUIRED`, `IDEMPOTENT_REPLAY`, `INVALID_STATE_TRANSITION`. |
| `rowVersion` | Redaktə/əməliyyat body-lərində optimistic lock tokeni; uyğunsuzluq → `409 STALE_VERSION`. |
| Səhifələmə | `page`/`size` (maks. 200) ortaq parametrlərdən, cavab `allOf: [PageMeta, {items}]`. |

### Decimal = string

**Bütün miqdar, məbləğ, məzənnə, əmsal və faiz sahələri JSON-da string-dir:**

```yaml
Decimal:
  type: string
  pattern: '^-?\d+(\.\d{1,8})?$'
```

Səbəb Excel-dən gələn `−23.50999999999999` artefaktıdır (SPEC §1.4). Client tərəfdə
`double` istifadəsi qadağandır — Dart-da `decimal` paketi, C#-da `decimal` (ADR-008).
Generator bu sahələri `String` kimi çıxarır; `wms_api_client`-dəki mapping qatı onları
`Decimal.parse()` ilə `wms_core` tiplərinə (`Quantity`, `Money`) çevirir.

### Maya dəyəri sahələri

`unitCost`, `avgUnitCost`, `totalValue`, `unitPrice`, `claimAmount` və oxşar sahələr
sxemdə **nullable və qeyri-məcburidir**, çünki `master.product.view_cost` icazəsi olmayan
istifadəçiyə server onları JSON-dan **tamamilə çıxarır** (SPEC §16, TOR §3.1/§40).
Client bunu "gizli" kimi göstərməlidir — `0` və ya `***` yox, sütun ümumiyyətlə render edilmir
(`docs/design-system/` → `WmsDataTable.permission`).

---

## 2. Lint

```bash
make lint-contracts
# və ya birbaşa:
docker run --rm -v "$PWD/contracts:/spec" redocly/cli lint \
  --config /spec/redocly.yaml /spec/openapi/*.v1.yaml
```

`redocly.yaml` `recommended` ruleset-ini genişləndirir və əlavə olaraq `operation-operationId`,
`operation-summary`, `operation-tag-defined`, `no-server-trailing-slash`, `info-license`
qaydalarını `error` səviyyəsinə qaldırır.

**Yeganə istisna:** `common.v1.yaml` üçün `no-unused-components` və `no-empty-servers`
söndürülüb (`apis.common@v1.rules`). Səbəb — bu fayl dizaynına görə `paths`/`servers`
daşımır və komponentləri **başqa fayllardan** istifadə olunur; Redocly isə hər faylı ayrıca
qiymətləndirir və "istifadə olunmayan komponent" xəbərdarlığı verir. Söndürmə yalnız o faylı əhatə edir.

Hazırkı vəziyyət: **8 fayl, 0 error, 0 warning.**

---

## 3. Dart client necə generasiya olunur

```bash
make gen-client                 # bütün modullar
scripts/gen-client.sh inventory # bir modul
```

Skript hər modul üçün Docker-də `openapitools/openapi-generator-cli` işlədir:

```
-g dart-dio
-i /spec/<modul>.v1.yaml
-o frontend/packages/wms_api_client/lib/src/generated/<modul>/
--additional-properties=pubName=wms_api_generated,nullableFields=true,...
```

- Çıxış qovluğu **gitignore edilib** (`.gitignore` sonuncu bölmə) — generasiya olunmuş kod
  commit edilmir, hər developer və CI özü generasiya edir.
- Generasiyadan sonra `built_value` üçün codegen lazımdır:
  `dart run build_runner build --delete-conflicting-outputs`.
- `wms_api_client` generasiya olunmuş API-ləri **birbaşa açmır**: hər modul üçün nazik
  fasad (`InventoryApiClient` və s.) yazılır, orada `Decimal` çevirməsi, `ProblemDetails`
  → `Failure` çevirməsi və interceptor-lar (auth, tenant, idempotency) tətbiq olunur.

Skriptin sonunda çap olunan qeydlər bu qaydaları təkrarlayır ki, generasiyanı ilk dəfə
işlədən developer decimal tələsinə düşməsin.

---

## 4. Backend kontrakt testləri

`backend/tests/Wms.Api.ContractTests/` bu faylları oxuyur və işləyən host-a qarşı yoxlayır:

1. **Route uyğunluğu** — spesifikasiyadakı hər `path` + metod cütü host-un endpoint
   cədvəlində (`EndpointDataSource`) var, artıq endpoint yoxdur.
2. **`operationId` uyğunluğu** — hər endpoint `.WithName(...)` ilə eyni `operationId`-ni daşıyır.
3. **`x-permission` uyğunluğu** — endpoint-in `RequirePermission` metadata-sı spesifikasiyadakı
   `x-permission` dəyəri ilə eynidir və həmin kod `iam_permission` seed-ində mövcuddur.
4. **Idempotentlik** — `Idempotency-Key`-siz `POST` → `400 IDEMPOTENCY_KEY_MISSING`.
5. **Sxem uyğunluğu** — nümunə sorğular üçün cavab body-si müvafiq sxemə (JSON Schema 2020-12)
   qarşı validasiya olunur; `Decimal` sahələrinin string olması ayrıca yoxlanılır.
6. **Xəta formatı** — `4xx`/`5xx` cavabları `application/problem+json` və `code` sahəsi ilə gəlir.

Bu testlər CI-da `contracts/**` və ya `backend/**` dəyişəndə işləyir.

---

## 5. Versiyalaşdırma (SPEC §13.6)

- Versiya **URL-dədir**: `/api/v1/...`. Fayl adı da versiyanı daşıyır: `inventory.v1.yaml`.
- `info.version` semantikdir (`1.0.0`) və hər dəyişiklikdə artırılır:
  - **patch** — yalnız sənədləşmə/nümunə dəyişikliyi;
  - **minor** — geriyə uyğun əlavə (yeni endpoint, yeni **opsional** sahə, yeni enum dəyəri
    **cavabda**, yeni opsional query parametri);
  - **major** — breaking dəyişiklik → **yeni fayl** `inventory.v2.yaml` + `/api/v2/inventory`.
- **Breaking sayılır:** endpoint və ya sahənin silinməsi, adının dəyişməsi; `operationId`
  dəyişməsi; opsional sahənin məcburiyə çevrilməsi; tipin dəyişməsi; enum dəyərinin
  **sorğudan** silinməsi; `409` kodunun mənasının dəyişməsi.
- **Köhnə major versiya minimum 6 ay saxlanılır.** Bu müddətdə `v1` və `v2` eyni host-da
  paralel işləyir; `v1` cavablarına `Deprecation` və `Sunset` header-ləri əlavə edilir.
- Enum genişlənməsi client-i sındırmamalıdır: Dart tərəfdə naməlum enum dəyəri
  `unknownEnumValue` ilə tutulur, UI onu olduğu kimi göstərir (`WmsDocStatusBadge` qaydası).
